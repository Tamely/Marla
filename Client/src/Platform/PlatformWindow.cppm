export module Platform.Window;

import <string>;
import <GLFW/glfw3.h>;

namespace Marla {
	export struct WindowConfig {
		std::string Title;
		uint32_t Width;
		uint32_t Height;
		bool VSync;
	};

	export class PlatformWindow {
	public:
		PlatformWindow();
		PlatformWindow(const WindowConfig& config);

		~PlatformWindow();

		void Update(double DeltaTime);
		void Quit();

		bool ShouldClose() const;

	private:
		GLFWwindow* mNativeHandle;
		WindowConfig mConfig;
	};
}