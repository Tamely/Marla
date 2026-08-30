project "Marla.Client"
    kind "ConsoleApp"
    language "C++"
    cppdialect "C++23"
    enablemodules "On"
    scanformoduledependencies "On"
    staticruntime "Off"

    if _ACTION and string.sub(_ACTION, 1, 2) == "vs" then
        location (path.join(MarlaRoot, "Client/src"))
    else
        location (path.join(MarlaRoot, "build", _ACTION, "Client"))
    end

    targetdir (path.join(MarlaRoot, "build/bin/" .. outputdir .. "/%{prj.name}"))
    objdir (path.join(MarlaRoot, "build/bin-int/" .. outputdir .. "/%{prj.name}"))

    files {
        path.join(MarlaRoot, "Client/src/**.h"),
        path.join(MarlaRoot, "Client/src/**.hpp"),
        path.join(MarlaRoot, "Client/src/**.cpp"),
        path.join(MarlaRoot, "Client/src/**.cppm")
    }

    includedirs {
        "%{IncludeDir.Client}",
        "%{IncludeDir.Vendor}",
        "%{IncludeDir.GLAD}",
        "%{IncludeDir.GLFW}",
        "%{IncludeDir.SPDLOG}",

        "%{IncludeDir.Client}/Core",
    }

    links {
        "Marla.Core",
        "Glad",
        "GLFW",
        "Spdlog"
    }

    defines {
        "GLFW_INCLUDE_NONE",
        "SPDLOG_COMPILED_LIB"
    }

    filter "action:vs*"
        buildoptions { "/utf-8" }

    filter "files:**.cppm"
        compileas "Module"

    filter "system:windows"
        links {
            "%{Library.OpenGL}",
            "%{Library.GDI}",
            "%{Library.User32}",
            "%{Library.Shell32}"
        }

    filter "system:linux"
        links { "X11", "pthread", "dl", "m" }

    filter "system:macosx"
        links {
            "OpenGL.framework",
            "Cocoa.framework",
            "IOKit.framework",
            "QuartzCore.framework",
            "CoreFoundation.framework"
        }

    filter {}
