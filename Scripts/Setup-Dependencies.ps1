$ErrorActionPreference = 'Stop'

$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$vendorDirectory = Join-Path $projectRoot 'Client\vendor'
$gladDirectory = Join-Path $vendorDirectory 'glad'
$glfwDirectory = Join-Path $vendorDirectory 'glfw'
$downloadDirectory = Join-Path $projectRoot 'build\dependencies'
$glfwVersion = '3.5.1'
$glfwArchive = Join-Path $downloadDirectory "glfw-$glfwVersion.zip"
$glfwUrl = "https://github.com/glfw/glfw/releases/download/$glfwVersion/glfw-$glfwVersion.zip"
$glfwSha256 = 'EA79BC5FEFFC254C87291980C2D0BCE9ACEBB68C4983B79F961DCD2CB8A611A0'

function Remove-MarlaManagedDirectory([string] $Path) {
    $resolvedPath = [IO.Path]::GetFullPath($Path)
    $rootPrefix = $projectRoot.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar

    if (-not $resolvedPath.StartsWith($rootPrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove a directory outside the Marla repository: $resolvedPath"
    }

    if (Test-Path -LiteralPath $resolvedPath) {
        Remove-Item -LiteralPath $resolvedPath -Recurse -Force
    }
}

$gladHeader = Join-Path $gladDirectory 'include\glad\glad.h'
$gladSource = Join-Path $gladDirectory 'src\glad.c'
if (-not (Test-Path -LiteralPath $gladHeader) -or -not (Test-Path -LiteralPath $gladSource)) {
    throw "The vendored GLAD sources are missing from $gladDirectory. Restore Client/vendor/glad before generating the solution."
}

Write-Host "Found vendored GLAD in $gladDirectory"

$glfwHeader = Join-Path $glfwDirectory 'include\GLFW\glfw3.h'
$glfwPremakeSource = Join-Path $glfwDirectory 'src\window.c'
$glfwPremakeDefinition = Join-Path $glfwDirectory 'premake5.lua'

if (-not (Test-Path -LiteralPath $glfwPremakeDefinition)) {
    throw "The GLFW Premake definition is missing from $glfwPremakeDefinition. Restore it before setting up dependencies."
}

if ((Test-Path -LiteralPath $glfwHeader) -and (Test-Path -LiteralPath $glfwPremakeSource)) {
    Write-Host "GLFW $glfwVersion is already installed in $glfwDirectory"
    exit 0
}

New-Item -ItemType Directory -Force -Path $vendorDirectory, $downloadDirectory | Out-Null

Write-Host "Downloading GLFW $glfwVersion"
Invoke-WebRequest -Uri $glfwUrl -OutFile $glfwArchive -UseBasicParsing

$actualHash = (Get-FileHash -LiteralPath $glfwArchive -Algorithm SHA256).Hash
if ($actualHash -ne $glfwSha256) {
    Remove-Item -LiteralPath $glfwArchive -Force
    throw "GLFW archive hash mismatch. Expected $glfwSha256 but received $actualHash."
}

$stagingDirectory = Join-Path $downloadDirectory 'glfw-staging'
Remove-MarlaManagedDirectory $stagingDirectory
New-Item -ItemType Directory -Force -Path $stagingDirectory | Out-Null
Expand-Archive -LiteralPath $glfwArchive -DestinationPath $stagingDirectory -Force

$extractedDirectory = Join-Path $stagingDirectory "glfw-$glfwVersion"
if (-not (Test-Path -LiteralPath (Join-Path $extractedDirectory 'include\GLFW\glfw3.h'))) {
    throw 'The GLFW archive did not contain the expected source tree.'
}

$premakeDefinitionBackup = Join-Path $downloadDirectory 'GLFW-premake5.lua'
Copy-Item -LiteralPath $glfwPremakeDefinition -Destination $premakeDefinitionBackup -Force
Remove-MarlaManagedDirectory $glfwDirectory
Move-Item -LiteralPath $extractedDirectory -Destination $glfwDirectory
Copy-Item -LiteralPath $premakeDefinitionBackup -Destination $glfwPremakeDefinition -Force
Remove-Item -LiteralPath $premakeDefinitionBackup -Force
Remove-MarlaManagedDirectory $stagingDirectory

Write-Host "Installed GLFW $glfwVersion in $glfwDirectory"
