/******************************************************************************
 * Copyright © 2013-2019 The Komodo Platform Developers.                      *
 *                                                                            *
 * See the AUTHORS, DEVELOPER-AGREEMENT and LICENSE files at                  *
 * the top-level directory of this distribution for the individual copyright  *
 * holder information and the developer policies on copyright and licensing.  *
 *                                                                            *
 * Unless otherwise agreed in a custom licensing agreement, no part of the    *
 * Komodo Platform software, including this file may be copied, modified,     *
 * propagated or distributed except according to the terms contained in the   *
 * LICENSE file                                                               *
 *                                                                            *
 * Removal or modification of this copyright notice is prohibited.            *
 *                                                                            *
 ******************************************************************************/

#pragma once

//! PCH Headers
#include "atomic.dex.pch.hpp"

inline constexpr std::size_t g_max_threads = 8_sz;

namespace atomic_dex
{
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
                            if (this->stop && this->tasks.empty())
                                return;
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
            if (stop)
            {
                throw std::runtime_error("enqueue on stopped thread_pool");
            }

            tasks.emplace(std::move(task));
        }
        condition.notify_one();
        return res;
    }
} // namespace atomic_dex

//! Private Singleton
static inline atomic_dex::thread_pool&
get_threadpool()
{
    static atomic_dex::thread_pool thread_pool(g_max_threads);
    return thread_pool;
}

//! Public API
namespace atomic_dex
{
    template <typename F, typename... Args>
    static auto
    spawn(F&& f, Args&&... args) noexcept
    {
        return get_threadpool().enqueue(std::forward<F>(f), std::forward<Args>(args)...);
    }
} // namespace atomic_dex