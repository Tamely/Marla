# Marla

Marla uses Premake and C++20. Visual Studio 2026 is the default generator.

Set up everything from the repository root:

```bat
Setup.bat
```

On Linux or macOS:

```sh
sh Setup.sh
```

Both setup scripts pause before exiting. To generate and open the Visual Studio solution directly:

```bat
Scripts\Open-VisualStudio.bat
```

For Visual Studio 2022:

```bat
Scripts\Open-VisualStudio.bat vs2022
```

Premake 5.0.0-beta8 and GLFW 3.5.1 are downloaded automatically on first use. The generated solution is written under `build/`.

On Linux or macOS, download the native Premake binary and generate projects with:

```sh
sh Scripts/Generate-Projects.sh
```

This generates GNU Makefiles on Linux and an Xcode workspace on macOS.

See the [full installation instructions](Docs/Installation.md) in the [Docs](Docs/) folder.
