#pragma once

#include <mutex>
#include <condition_variable>

struct timed_waiter {
    void interrupt() {
        auto l = lock();
        interrupted = true;
        cv.notify_one();
    }

    template<class Rep, class Period>
    bool wait_for(std::chrono::duration<Rep, Period> how_long) const {
        auto l = lock();
        return cv.wait_for(l, how_long,
                           [&] {
                               return interrupted;
                           }
        );
    }

private:
    std::unique_lock<std::mutex> lock() const {
        return std::unique_lock<std::mutex>(m);
    }

    mutable std::mutex m;
    mutable std::condition_variable cv;
    bool interrupted = false;
};