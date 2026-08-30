project "Marla.Core"
    kind "StaticLib"
    language "C++"
    cppdialect "C++20"
    enablemodules "On"
    scanformoduledependencies "On"
    staticruntime "Off"

    if _ACTION and string.sub(_ACTION, 1, 2) == "vs" then
        location (path.join(MarlaRoot, "Core/src"))
    else
        location (path.join(MarlaRoot, "build", _ACTION, "Core"))
    end

    targetdir (path.join(MarlaRoot, "build/bin/" .. outputdir .. "/%{prj.name}"))
    objdir (path.join(MarlaRoot, "build/bin-int/" .. outputdir .. "/%{prj.name}"))

    files {
        path.join(MarlaRoot, "Core/src/**.cpp"),
        path.join(MarlaRoot, "Core/src/**.cppm")
    }

    includedirs {
        path.join(MarlaRoot, "Core/src")
    }

    filter "files:**.cppm"
        compileas "Module"

    filter {}
