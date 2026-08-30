import Misc.Timer;

import <chrono>;
import <cstdint>;

namespace Marla {
	Timer::Timer() : mStartTime(std::chrono::steady_clock::now()) {}

	void Timer::Start() {
		mStartTime = std::chrono::steady_clock::now();
	}

	uint64_t Timer::GetElapsedTime() const {
		auto now = std::chrono::steady_clock::now();
		auto elapsed = std::chrono::duration_cast<std::chrono::milliseconds>(now - mStartTime).count();
		return static_cast<uint64_t>(elapsed);
	}

	double Timer::GetDeltaTime() {
		auto now = std::chrono::steady_clock::now();
		auto delta = std::chrono::duration_cast<std::chrono::duration<double>>(now - mStartTime).count();
		mStartTime = now;
		return delta;
	}
}