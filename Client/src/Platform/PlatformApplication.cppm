export module Platform.Application;

import <memory>;

import Platform.Window;
import Misc.Timer;

namespace Marla {
	export class PlatformApplication {
	public:
		void Run();
		void Quit();

	private:
		std::unique_ptr<PlatformWindow> mWindow;
		Timer mTimer;
	};
}