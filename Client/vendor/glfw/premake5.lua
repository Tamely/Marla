project "GLFW"
    kind "StaticLib"
    language "C"
    cdialect "C99"
    staticruntime "Off"
    location (path.join(MarlaRoot, "build", _ACTION, "Dependencies/GLFW"))

    targetdir (path.join(MarlaRoot, "build/bin/" .. outputdir .. "/%{prj.name}"))
    objdir (path.join(MarlaRoot, "build/bin-int/" .. outputdir .. "/%{prj.name}"))

    files {
        path.join(MarlaRoot, "Client/vendor/glfw/include/GLFW/glfw3.h"),
        path.join(MarlaRoot, "Client/vendor/glfw/include/GLFW/glfw3native.h"),
        path.join(MarlaRoot, "Client/vendor/glfw/src/internal.h"),
        path.join(MarlaRoot, "Client/vendor/glfw/src/platform.h"),
        path.join(MarlaRoot, "Client/vendor/glfw/src/mappings.h"),
        path.join(MarlaRoot, "Client/vendor/glfw/src/context.c"),
        path.join(MarlaRoot, "Client/vendor/glfw/src/init.c"),
        path.join(MarlaRoot, "Client/vendor/glfw/src/input.c"),
        path.join(MarlaRoot, "Client/vendor/glfw/src/monitor.c"),
        path.join(MarlaRoot, "Client/vendor/glfw/src/platform.c"),
        path.join(MarlaRoot, "Client/vendor/glfw/src/vulkan.c"),
        path.join(MarlaRoot, "Client/vendor/glfw/src/window.c"),
        path.join(MarlaRoot, "Client/vendor/glfw/src/egl_context.c"),
        path.join(MarlaRoot, "Client/vendor/glfw/src/osmesa_context.c"),
        path.join(MarlaRoot, "Client/vendor/glfw/src/null_platform.h"),
        path.join(MarlaRoot, "Client/vendor/glfw/src/null_joystick.h"),
        path.join(MarlaRoot, "Client/vendor/glfw/src/null_init.c"),
        path.join(MarlaRoot, "Client/vendor/glfw/src/null_monitor.c"),
        path.join(MarlaRoot, "Client/vendor/glfw/src/null_window.c"),
        path.join(MarlaRoot, "Client/vendor/glfw/src/null_joystick.c")
    }

    includedirs {
        "%{IncludeDir.GLFW}",
        path.join(MarlaRoot, "Client/vendor/glfw/src")
    }

    filter "system:windows"
        files {
            path.join(MarlaRoot, "Client/vendor/glfw/src/win32_platform.h"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/win32_joystick.h"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/win32_time.h"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/win32_thread.h"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/win32_init.c"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/win32_joystick.c"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/win32_module.c"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/win32_monitor.c"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/win32_time.c"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/win32_thread.c"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/win32_window.c"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/wgl_context.c")
        }
        defines {
            "_GLFW_WIN32",
            "UNICODE",
            "_UNICODE",
            "_CRT_SECURE_NO_WARNINGS"
        }

    filter "system:linux"
        files {
            path.join(MarlaRoot, "Client/vendor/glfw/src/posix_time.h"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/posix_thread.h"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/posix_poll.h"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/x11_platform.h"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/posix_module.c"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/posix_time.c"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/posix_thread.c"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/posix_poll.c"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/linux_joystick.h"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/linux_joystick.c"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/x11_init.c"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/x11_monitor.c"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/x11_window.c"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/xkb_unicode.c"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/glx_context.c")
        }
        defines { "_GLFW_X11", "_DEFAULT_SOURCE" }

    filter "system:macosx"
        files {
            path.join(MarlaRoot, "Client/vendor/glfw/src/macos_time.h"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/macos_time.c"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/posix_thread.h"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/posix_module.c"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/posix_thread.c"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/cocoa_platform.h"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/cocoa_joystick.h"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/cocoa_init.m"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/cocoa_joystick.m"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/cocoa_monitor.m"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/cocoa_window.m"),
            path.join(MarlaRoot, "Client/vendor/glfw/src/nsgl_context.m")
        }
        defines { "_GLFW_COCOA" }

    filter {}
