export module Misc.Timer;

import <chrono>;
import <cstdint>;

namespace Marla {
	export class Timer {
	public:
		Timer();
		void Start();

		[[nodiscard]] uint64_t GetElapsedTime() const;
		[[nodiscard]] double GetDeltaTime();
	private:
		std::chrono::steady_clock::time_point mStartTime;
	};
}