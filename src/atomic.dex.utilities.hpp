#pragma once

//! C++ System Headers
#include <condition_variable>
#include <functional>
#include <future>
#include <mutex>
#include <queue>

struct timed_waiter
{
    void
    interrupt()
    {
        auto l      = lock();
        interrupted = true;
        cv.notify_one();
    }

    template <class Rep, class Period>
    bool
    wait_for(std::chrono::duration<Rep, Period> how_long) const
    {
        auto l = lock();
        return cv.wait_for(l, how_long, [&] { return interrupted; });
    }

  private:
    std::unique_lock<std::mutex>
    lock() const
    {
        return std::unique_lock<std::mutex>(m);
    }

    mutable std::mutex              m;
    mutable std::condition_variable cv;
    bool                            interrupted = false;
};


namespace atomic_dex::utils
{
    struct my_json_sax : nlohmann::json_sax<nlohmann::json>
    {
        bool
        null() override
        {
            return true;
        }

        bool
        boolean([[maybe_unused]] bool val) override
        {
            return true;
        }

        bool
        number_integer([[maybe_unused]] number_integer_t val) override
        {
            return true;
        };

        bool
        number_unsigned([[maybe_unused]] number_unsigned_t val) override
        {
            return true;
        };

        bool
        number_float([[maybe_unused]] number_float_t val, [[maybe_unused]] const string_t& s) override
        {
            this->float_as_string = s;
            return true;
        }

        bool
        string([[maybe_unused]] string_t& val) override
        {
            return true;
        }

        bool
        start_object([[maybe_unused]] std::size_t elements) override
        {
            return true;
        }

        bool
        key([[maybe_unused]] string_t& val) override
        {
            return true;
        }

        bool
        end_object() override
        {
            return true;
        }

        bool
        start_array([[maybe_unused]] std::size_t elements) override
        {
            return true;
        }

        bool
        end_array() override
        {
            return true;
        }

        bool
        parse_error([[maybe_unused]] std::size_t position, [[maybe_unused]] const std::string& last_token,
                    [[maybe_unused]] const nlohmann::detail::exception& ex) override
        {
            return false;
        };

        std::string float_as_string;
    };
} // namespace atomic_dex::utils

class thread_pool
{
  public:
    explicit thread_pool(std::size_t threads) : stop(false)
    {
        for (size_t i = 0; i < threads; ++i)
            workers.emplace_back([this] {
                for (;;)
                {
                    std::packaged_task<void()> task;
                    {
                        std::unique_lock<std::mutex> lock(this->queue_mutex);
                        this->condition.wait(lock, [this] { return this->stop or !this->tasks.empty(); });
                        if (this->stop && this->tasks.empty()) return;
                        task = std::move(this->tasks.front());
                        this->tasks.pop();
                    }

                    task();
                }
            });
    }

    template <class F, class... Args>
    decltype(auto) enqueue(F&& f, Args&&... args);

    ~thread_pool() noexcept
    {
        {
            std::unique_lock<std::mutex> lock(queue_mutex);
            stop = true;
        }
        condition.notify_all();
        for (std::thread& worker: workers) worker.join();
    };

  private:
    // need to keep track of threads so we can join them
    std::vector<std::thread> workers;
    // the task queue
    std::queue<std::packaged_task<void()>> tasks;

    // synchronization
    std::mutex              queue_mutex;
    std::condition_variable condition;
    bool                    stop;
};

// add new work item to the pool
template <class F, class... Args>
decltype(auto)
thread_pool::enqueue(F&& f, Args&&... args)
{
    using return_type = std::invoke_result_t<F, Args...>;

    std::packaged_task<return_type()> task(std::bind(std::forward<F>(f), std::forward<Args>(args)...));

    std::future<return_type> res = task.get_future();
    {
        std::unique_lock<std::mutex> lock(queue_mutex);

        // don't allow enqueueing after stopping the pool
        if (stop) throw std::runtime_error("enqueue on stopped thread_pool");

        tasks.emplace(std::move(task));
    }
    condition.notify_one();
    return res;
}
