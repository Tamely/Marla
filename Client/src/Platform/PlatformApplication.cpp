import Platform.Application;

import Platform.Window;

namespace Marla {
	void PlatformApplication::Run() {
		mWindow = std::make_unique<PlatformWindow>();

		mTimer.Start();
		while (!mWindow->ShouldClose()) {
			mWindow->Update(mTimer.GetDeltaTime());
		}
	}

	void PlatformApplication::Quit() {
		mWindow->Quit();
	}
}