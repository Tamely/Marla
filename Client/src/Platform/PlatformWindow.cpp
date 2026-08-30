import Platform.Window;

import <glad/glad.h>;
import <GLFW/glfw3.h>;

import <spdlog/spdlog.h>;

namespace Marla {
	PlatformWindow::PlatformWindow() : PlatformWindow(WindowConfig{ "Marla Engine", 1280, 720, true }) {}
	PlatformWindow::PlatformWindow(const WindowConfig& config) : mConfig(config) {
		glfwInit();

		glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
		glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 6);
		glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

		mNativeHandle = glfwCreateWindow(mConfig.Width, mConfig.Height, mConfig.Title.c_str(), nullptr, nullptr);
		if (!mNativeHandle) {
			spdlog::error("PlatformWindow::PlatformWindow: Failed to create GLFW window!");
			glfwTerminate();
			return;
		}
		glfwMakeContextCurrent(mNativeHandle);

		glfwSwapInterval(mConfig.VSync ? 1 : 0);

		if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
			spdlog::error("PlatformWindow::PlatformWindow: Failed to initialize GLAD!");
			glfwTerminate();
			return;
		}

		glClearColor(1.0f, 0.0f, 0.0f, 1.0f);
		glViewport(0, 0, mConfig.Width, mConfig.Height);
	}

	PlatformWindow::~PlatformWindow() {
		glfwDestroyWindow(mNativeHandle);
		glfwTerminate();
	}

	void PlatformWindow::Update(double DeltaTime) {
		spdlog::info("PlatformWindow::Update: DeltaTime = {0} seconds", DeltaTime);
		glfwPollEvents();
		glfwSwapBuffers(mNativeHandle);
		glClear(GL_COLOR_BUFFER_BIT);
	}

	void PlatformWindow::Quit() {
		glfwSetWindowShouldClose(mNativeHandle, true);
	}

	bool PlatformWindow::ShouldClose() const {
		return glfwWindowShouldClose(mNativeHandle);
	}
}