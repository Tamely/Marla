$ErrorActionPreference = 'Stop'

$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$vendorDirectory = Join-Path $projectRoot 'Client\vendor'
$gladDirectory = Join-Path $vendorDirectory 'glad'
$glfwDirectory = Join-Path $vendorDirectory 'glfw'
$spdlogDirectory = Join-Path $vendorDirectory 'spdlog'
$downloadDirectory = Join-Path $projectRoot 'build\dependencies'

$glfwVersion = '3.5.1'
$glfwArchive = Join-Path $downloadDirectory "glfw-$glfwVersion.zip"
$glfwUrl = "https://github.com/glfw/glfw/releases/download/$glfwVersion/glfw-$glfwVersion.zip"
$glfwSha256 = 'EA79BC5FEFFC254C87291980C2D0BCE9ACEBB68C4983B79F961DCD2CB8A611A0'

$spdlogVersion = '1.17.0'
$spdlogArchive = Join-Path $downloadDirectory "spdlog-$spdlogVersion.zip"
$spdlogUrl = "https://github.com/gabime/spdlog/archive/refs/tags/v$spdlogVersion.zip"
$spdlogSha256 = 'B11912A82D149792FEF33FABD0503B13D54AEAC25C1464755461D4108EA71FC2'

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

function Install-MarlaDependency {
    param(
        [string] $Name,
        [string] $Version,
        [string] $Url,
        [string] $ExpectedSha256,
        [string] $Archive,
        [string] $Destination,
        [string] $ExtractedDirectoryName,
        [string] $ExpectedFile
    )

    $installedFile = Join-Path $Destination $ExpectedFile
    $premakeDefinition = Join-Path $Destination 'premake5.lua'

    if (-not (Test-Path -LiteralPath $premakeDefinition)) {
        throw "The $Name Premake definition is missing from $premakeDefinition. Restore it before setting up dependencies."
    }

    if (Test-Path -LiteralPath $installedFile) {
        Write-Host "$Name $Version is already installed in $Destination"
        return
    }

    New-Item -ItemType Directory -Force -Path $vendorDirectory, $downloadDirectory | Out-Null

    Write-Host "Downloading $Name $Version"
    Invoke-WebRequest -Uri $Url -OutFile $Archive -UseBasicParsing

    $actualHash = (Get-FileHash -LiteralPath $Archive -Algorithm SHA256).Hash
    if ($actualHash -ne $ExpectedSha256) {
        Remove-Item -LiteralPath $Archive -Force
        throw "$Name archive hash mismatch. Expected $ExpectedSha256 but received $actualHash."
    }

    $stagingDirectory = Join-Path $downloadDirectory "$Name-staging"
    Remove-MarlaManagedDirectory $stagingDirectory
    New-Item -ItemType Directory -Force -Path $stagingDirectory | Out-Null
    Expand-Archive -LiteralPath $Archive -DestinationPath $stagingDirectory -Force

    $extractedDirectory = Join-Path $stagingDirectory $ExtractedDirectoryName
    if (-not (Test-Path -LiteralPath (Join-Path $extractedDirectory $ExpectedFile))) {
        throw "The $Name archive did not contain the expected source tree."
    }

    $premakeDefinitionBackup = Join-Path $downloadDirectory "$Name-premake5.lua"
    Copy-Item -LiteralPath $premakeDefinition -Destination $premakeDefinitionBackup -Force
    Remove-MarlaManagedDirectory $Destination
    Move-Item -LiteralPath $extractedDirectory -Destination $Destination
    Copy-Item -LiteralPath $premakeDefinitionBackup -Destination $premakeDefinition -Force
    Remove-Item -LiteralPath $premakeDefinitionBackup -Force
    Remove-MarlaManagedDirectory $stagingDirectory

    Write-Host "Installed $Name $Version in $Destination"
}

$gladHeader = Join-Path $gladDirectory 'include\glad\glad.h'
$gladSource = Join-Path $gladDirectory 'src\glad.c'
if (-not (Test-Path -LiteralPath $gladHeader) -or -not (Test-Path -LiteralPath $gladSource)) {
    throw "The vendored GLAD sources are missing from $gladDirectory. Restore Client/vendor/glad before generating the solution."
}

Write-Host "Found vendored GLAD in $gladDirectory"

Install-MarlaDependency `
    -Name 'GLFW' `
    -Version $glfwVersion `
    -Url $glfwUrl `
    -ExpectedSha256 $glfwSha256 `
    -Archive $glfwArchive `
    -Destination $glfwDirectory `
    -ExtractedDirectoryName "glfw-$glfwVersion" `
    -ExpectedFile 'include\GLFW\glfw3.h'

Install-MarlaDependency `
    -Name 'spdlog' `
    -Version $spdlogVersion `
    -Url $spdlogUrl `
    -ExpectedSha256 $spdlogSha256 `
    -Archive $spdlogArchive `
    -Destination $spdlogDirectory `
    -ExtractedDirectoryName "spdlog-$spdlogVersion" `
    -ExpectedFile 'include\spdlog\spdlog.h'
