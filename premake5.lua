MarlaRoot = _MAIN_SCRIPT_DIR
local hostArchitecture = os.hostarch()

include "Dependencies.lua"

workspace "Marla"
    if hostArchitecture == "arm64" or hostArchitecture == "aarch64"
        or hostArchitecture == "ARM64" or hostArchitecture == "AARCH64" then
        architecture "ARM64"
    else
        architecture "x86_64"
    end
    startproject "Marla.Client"

    configurations
    {
        "Debug",
        "Release",
        "Shipping"
    }

    location (path.join(MarlaRoot, "build", _ACTION))

    multiprocessorcompile "On"

    filter "configurations:Debug"
        defines { "MARLA_DEBUG" }
        optimize "Off"
        symbols "On"
        runtime "Debug"

    filter "configurations:Release"
        defines { "MARLA_RELEASE", "NDEBUG" }
        optimize "Speed"
        symbols "On"
        runtime "Release"

    filter "configurations:Shipping"
        defines { "MARLA_SHIPPING", "NDEBUG" }
        optimize "Speed"
        symbols "Off"
        runtime "Release"

    filter "system:windows"
        systemversion "latest"

    filter {}

outputdir = "%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}"

group "Dependencies"
    include "Client/vendor/glad"
    include "Client/vendor/glfw"
    include "Client/vendor/spdlog"
group ""

group "Core"
    include "Core"
group ""

group "Client"
    include "Client"
group ""
