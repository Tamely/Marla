# Installation and toolchain requirements

Marla is currently a C++26 modules project. Toolchain versions matter because the client imports the standard-library module with `import std;`, and MSVC uses `/std:c++latest` for its C++26 mode.

## Required dependencies

| Dependency | Required version | Notes |
| --- | --- | --- |
| CMake | 4.3.x or 4.4.x | The project requires CMake 4.3 or newer and enables CMake's version-specific experimental `import std` support. CMake 4.3.1 and 4.4.0-rc3 are tested. |
| C++ compiler and standard library | See the compiler matrix below | The compiler, standard library, CMake, and generator must all support C++ modules and `import std`. |
| Ninja | 1.11 or newer on Linux/macOS and for GCC/Clang builds | Ninja 1.13.2 is tested. CMake currently requires a Ninja generator for its imported standard-library module target. |
| GLFW | 3.5.1 | Downloaded and built automatically by CMake. Internet access is required during the first configure. |
| GLAD | 0.1.36, OpenGL 4.6 Core | Already vendored under `Client/vendor/glad`; no separate installation is needed. |
| Git | Any current release | Needed to clone and update the repository, but not to download GLFW because CMake fetches its release archive directly. |

The CMake module support and `import std` compiler matrix is documented in the [CMake C++ modules manual](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html).

## Compiler matrix

### Windows: MSVC

The recommended and tested Windows toolchain is:

- Visual Studio 2026 18.7.3
- MSVC compiler 19.51.36248
- MSVC toolset 14.51.36231
- Windows SDK 10.0.28000.0
- CMake 4.3.1 or 4.4.0-rc3

Install Visual Studio with the **Desktop development with C++** workload and a Windows SDK. MSVC toolset 14.36 is the minimum version CMake lists for `import std`, but Marla's current C++26 configuration is tested against toolset 14.51. Use the newest available MSVC toolset when working with draft C++26 features such as reflection.

MSVC receives `/std:c++latest`, which enables its implemented features from the latest working draft. Microsoft documents the behavior and compatibility caveats in the [`/std` compiler option reference](https://learn.microsoft.com/en-us/cpp/build/reference/std-specify-language-standard-version).

Both of these generator paths are supported:

- Visual Studio 18 2026: the project compiles MSVC's `std.ixx` and `std.compat.ixx` directly.
- Ninja: CMake provides and builds the standard-library module target.

### Windows: GCC/MinGW

The tested MinGW toolchain bundled with CLion is:

- CLion 2026.2.1
- GCC 15.2.0
- libstdc++ 15.2.0, including `libstdc++exp`
- Ninja 1.13.2
- CMake 4.3.1

GCC 15 is the minimum version CMake lists for `import std` outside macOS. The GNU build also links `stdc++exp`, which is required by the current libstdc++ implementation of facilities such as `std::println`.

Ensure `gcc`, `g++`, `ninja`, and `cmake` resolve to the intended toolchain before configuring. Use a clean `build/` directory when switching between MSVC and MinGW because CMake build directories cannot change generators or compilers in place.

### Linux

Use the following baseline:

- CMake 4.3.x or 4.4.x
- GCC 15 or newer with its matching libstdc++ development files, including `libstdc++exp`; or upstream Clang 18.1.2 or newer with compatible libc++ or libstdc++ module metadata
- Ninja 1.11 or newer
- A POSIX shell

The CMake documentation notes that Ubuntu releases before 26.04 ship broken `libstdc++.modules.json` metadata. Prefer Ubuntu 26.04 or newer, or install a compiler/standard-library toolchain that supplies corrected module metadata.

GLFW enables both Wayland and X11 by default on Linux. Install the corresponding development packages before configuring. The [official GLFW compilation guide](https://www.glfw.org/docs/latest/compile.html) currently recommends:

Debian, Ubuntu, and derivatives:

```sh
sudo apt install libwayland-dev libxkbcommon-dev xorg-dev
```

Fedora and derivatives:

```sh
sudo dnf install wayland-devel libxkbcommon-devel libXcursor-devel libXi-devel libXinerama-devel libXrandr-devel
```

You may disable an unused GLFW backend by passing `-DGLFW_BUILD_WAYLAND=OFF` or `-DGLFW_BUILD_X11=OFF` during configuration.

### macOS

Install:

- Xcode and its command-line tools
- CMake 4.3.x or 4.4.x
- Ninja 1.11 or newer
- A CMake-supported `import std` toolchain

CMake lists upstream Clang 18.1.2 or newer with compatible libc++ or libstdc++ metadata, or GCC 16 or newer on macOS, for `import std`. AppleClang distributions may not include the standard-library module metadata expected by CMake, so upstream LLVM Clang may be necessary. The macOS path has not yet been validated in this repository.

GLFW's Cocoa build dependencies are supplied by Xcode, so no separate GLFW system packages are required.

## Bundled and downloaded libraries

### GLFW 3.5.1

CMake downloads the official [GLFW 3.5.1 release archive](https://github.com/glfw/glfw/releases/tag/3.5.1) and verifies this SHA-256 hash:

```text
EA79BC5FEFFC254C87291980C2D0BCE9ACEBB68C4983B79F961DCD2CB8A611A0
```

GLFW documentation, examples, tests, and installation rules are disabled for the dependency build.

### GLAD 0.1.36

The checked-in GLAD sources were generated with these settings:

- API: OpenGL 4.6
- Profile: Core
- Loader: Enabled
- Generator: C/C++

The project compiles GLAD as a static C library and links it into `Marla.Client`.

## Building

All supported scripts configure and build into the repository's `build/` directory. Debug is the default configuration.

### Windows

```bat
Scripts\Build.bat
Scripts\Build.bat Release
Scripts\Build-Shipping.bat
```

The default Windows generator is selected by CMake. On a standard Visual Studio installation this is the current Visual Studio generator. To use Ninja instead, set `CMAKE_GENERATOR=Ninja` in a shell where the desired compiler is available before running the script.

### Linux and macOS

```sh
sh Scripts/Build.sh
sh Scripts/Build.sh Release
sh Scripts/Build-Shipping.sh
```

The POSIX script selects Ninja by default. Set `CMAKE_GENERATOR` before invoking it only when intentionally choosing another module-capable generator.

### CMake presets directly

The available presets are `Debug`, `Release`, and `Shipping`:

```sh
cmake --preset Debug -G Ninja
cmake --build --preset Debug --parallel
```

On Windows with the Visual Studio generator, the explicit `-G Ninja` is not needed:

```bat
cmake --preset Debug
cmake --build --preset Debug --parallel
```

## Build configurations

| Configuration | Optimization | Debug symbols | Assertions |
| --- | --- | --- | --- |
| Debug | Disabled | Included | Enabled |
| Release | Enabled | Included | Disabled by the compiler's standard Release flags |
| Shipping | Enabled | Removed/stripped | Disabled with `NDEBUG` |

## Toolchain notes

- The CMake `import std` integration is experimental, so an experimental-feature warning during configuration is expected.
- Do not reuse `build/` after changing the generator or compiler. Remove the generated directory and configure again.
- The project selects draft C++26 mode, but reflection is not used by the current source yet. Reflection availability must be checked against the exact compiler release when it is introduced.
- An OpenGL-capable graphics driver will be required once the client begins creating and rendering OpenGL contexts.
