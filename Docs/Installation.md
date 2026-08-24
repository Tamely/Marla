# Installation and Visual Studio setup

Marla uses Premake to generate Visual Studio, GNU Make, or Xcode projects. The project targets C++20 and keeps C++ module support enabled for the Core project.

## Windows requirements

- Windows 10 or newer
- Visual Studio 2022 or Visual Studio 2026
- The **Desktop development with C++** workload
- PowerShell 5.1 or newer
- Internet access during the first project generation

The setup scripts download and verify these project dependencies:

| Dependency | Version | Location |
| --- | --- | --- |
| Premake | 5.0.0-beta8 | `Scripts/bin` |
| GLFW | 3.5.1 | `Client/vendor/glfw` |
| GLAD | 0.1.36, OpenGL 4.6 Core | Already checked into `Client/vendor/glad` |

## Generate and open the solution

From the repository root, run the complete setup sequence:

```bat
Setup.bat
```

This sets up Premake, installs the project dependencies, generates the Visual Studio projects, and pauses before exiting. You may pass `vs2022` to target Visual Studio 2022:

```bat
Setup.bat vs2022
```

Visual Studio 2026 is the default generator:

```bat
Scripts\Open-VisualStudio.bat
```

To generate for Visual Studio 2022 instead:

```bat
Scripts\Open-VisualStudio.bat vs2022
```

These commands download Premake and GLFW when needed, generate the solution under `build/vs2026` or `build/vs2022`, and open it. Visual Studio 2026 uses `Marla.slnx`; Visual Studio 2022 uses `Marla.sln`.

The generated Client and Core `.vcxproj` files are placed in `Client/src` and `Core/src`. This makes Visual Studio create new project items in the corresponding source directory instead of under `build/`.

To generate without opening Visual Studio:

```bat
Scripts\Generate-Projects.bat
Scripts\Generate-Projects.bat vs2022
```

## Build from a terminal

The existing configuration scripts now generate the Premake solution and invoke Visual Studio's MSBuild:

```bat
Scripts\Build-Debug.bat
Scripts\Build-Release.bat
Scripts\Build-Shipping.bat
```

Set `MARLA_PREMAKE_ACTION=vs2022` before invoking a build script when using Visual Studio 2022. Otherwise, the scripts default to `vs2026`.

## Linux and macOS project generation

The POSIX scripts download a native `premake5` executable without the Windows `.exe` suffix. Premake 5.0.0-beta8 is available for glibc-based x86-64 Linux, Intel macOS, and Apple Silicon macOS. The official Linux binary does not run directly on musl-only distributions such as Alpine Linux.

Required command-line tools:

- `curl` or `wget`
- `tar`
- `unzip`
- `sha256sum` on Linux or `shasum` on macOS
- GNU Make and an X11 development environment on Linux
- Xcode and its command-line tools on macOS

Generate the platform-default projects:

```sh
sh Setup.sh
```

The root setup script runs Premake setup, dependency setup, and project generation in that order, then waits for Enter before exiting. Use `sh Scripts/Generate-Projects.sh` when you want to regenerate without the final pause.

Linux defaults to the `gmake` action and writes Makefiles under `build/gmake`. macOS defaults to `xcode4` and writes its workspace under `build/xcode4`. You may pass a different Premake action explicitly.

```sh
sh Scripts/Generate-Projects.sh ninja
```

GLFW uses its X11 backend on Linux and Cocoa backend on macOS.

> Premake's documented `compileas "Module"` and `enablemodules` integration currently targets Visual Studio. Project generation is cross-platform, but the existing `Marla.Core` C++ module may require a platform-specific fallback or additional build rules before it can compile with GNU Make or Xcode.

## Build configurations

| Configuration | Optimization | Debug symbols |
| --- | --- | --- |
| Debug | Disabled | Included |
| Release | Speed optimized | Included |
| Shipping | Speed optimized | Disabled |

## Project layout

- `Marla.Core` is a static library containing the Core C++20 module.
- `Marla.Client` is the executable and links Core, GLAD, and GLFW.
- `Glad` and `GLFW` are separate dependency projects in the generated solution.
- `Client/src` and `Client/vendor` are client include roots.

The root `Dependencies.lua` owns shared include and library paths. Like Hazel, each dependency keeps its own `premake5.lua` beside its vendor sources, and the root workspace includes those vendor folders under the `Dependencies` solution group.
