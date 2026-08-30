project "Glad"
    kind "StaticLib"
    language "C"
    cdialect "C99"
    staticruntime "Off"
    location (path.join(MarlaRoot, "build", _ACTION, "Dependencies/GLAD"))

    targetdir (path.join(MarlaRoot, "build/bin/" .. outputdir .. "/%{prj.name}"))
    objdir (path.join(MarlaRoot, "build/bin-int/" .. outputdir .. "/%{prj.name}"))

    files {
        path.join(MarlaRoot, "Client/vendor/glad/include/glad/glad.h"),
        path.join(MarlaRoot, "Client/vendor/glad/include/KHR/khrplatform.h"),
        path.join(MarlaRoot, "Client/vendor/glad/src/glad.c")
    }

    includedirs {
        "%{IncludeDir.GLAD}"
    }
