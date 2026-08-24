IncludeDir = {}
IncludeDir["Client"] = path.join(MarlaRoot, "Client/src")
IncludeDir["Vendor"] = path.join(MarlaRoot, "Client/vendor")
IncludeDir["GLAD"] = path.join(MarlaRoot, "Client/vendor/glad/include")
IncludeDir["GLFW"] = path.join(MarlaRoot, "Client/vendor/glfw/include")
IncludeDir["SPDLOG"] = path.join(MarlaRoot, "Client/vendor/spdlog/include")

Library = {}
Library["OpenGL"] = "opengl32.lib"
Library["GDI"] = "gdi32.lib"
Library["User32"] = "user32.lib"
Library["Shell32"] = "shell32.lib"
