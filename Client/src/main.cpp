import Platform.Application;

int main() {
	Marla::PlatformApplication* app = new Marla::PlatformApplication();
	app->Run();
	delete app;

    return 0;
}
