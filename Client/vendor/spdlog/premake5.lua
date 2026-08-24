project "Spdlog"
    kind "StaticLib"
    language "C++"
    cppdialect "C++20"
    staticruntime "Off"
    location (path.join(MarlaRoot, "build", _ACTION, "Dependencies/Spdlog"))

    targetdir (path.join(MarlaRoot, "build/bin/" .. outputdir .. "/%{prj.name}"))
    objdir (path.join(MarlaRoot, "build/bin-int/" .. outputdir .. "/%{prj.name}"))

    files {
        path.join(MarlaRoot, "Client/vendor/spdlog/include/**.h"),
        path.join(MarlaRoot, "Client/vendor/spdlog/src/spdlog.cpp"),
        path.join(MarlaRoot, "Client/vendor/spdlog/src/stdout_sinks.cpp"),
        path.join(MarlaRoot, "Client/vendor/spdlog/src/color_sinks.cpp"),
        path.join(MarlaRoot, "Client/vendor/spdlog/src/file_sinks.cpp"),
        path.join(MarlaRoot, "Client/vendor/spdlog/src/async.cpp"),
        path.join(MarlaRoot, "Client/vendor/spdlog/src/cfg.cpp"),
        path.join(MarlaRoot, "Client/vendor/spdlog/src/bundled_fmtlib_format.cpp")
    }

    includedirs {
        "%{IncludeDir.SPDLOG}"
    }

    defines { "SPDLOG_COMPILED_LIB" }

    filter "action:vs*"
        buildoptions { "/utf-8" }

    filter "system:windows"
        defines { "_CRT_SECURE_NO_WARNINGS" }

    filter {}
