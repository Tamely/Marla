$ErrorActionPreference = 'Stop'

$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$premakeVersion = '5.0.0-beta8'
$premakeDirectory = Join-Path $PSScriptRoot 'bin'
$premakeExecutable = Join-Path $premakeDirectory 'premake5.exe'
$downloadDirectory = Join-Path $projectRoot 'build\dependencies'
$archive = Join-Path $downloadDirectory "premake-$premakeVersion-windows.zip"
$url = "https://github.com/premake/premake-core/releases/download/v$premakeVersion/premake-$premakeVersion-windows.zip"
$expectedSha256 = 'E64CE2ED8778E0098F63674CCA61FE33941B5F0C8D9A4AFD651152BDEA3758AB'

if (Test-Path -LiteralPath $premakeExecutable) {
    $installedVersion = & $premakeExecutable --version
    if ($LASTEXITCODE -eq 0 -and $installedVersion -match [regex]::Escape($premakeVersion)) {
        Write-Host "Premake $premakeVersion is already installed in $premakeDirectory"
        exit 0
    }
}

New-Item -ItemType Directory -Force -Path $premakeDirectory, $downloadDirectory | Out-Null

Write-Host "Downloading Premake $premakeVersion"
Invoke-WebRequest -Uri $url -OutFile $archive -UseBasicParsing

$actualHash = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash
if ($actualHash -ne $expectedSha256) {
    Remove-Item -LiteralPath $archive -Force
    throw "Premake archive hash mismatch. Expected $expectedSha256 but received $actualHash."
}

Expand-Archive -LiteralPath $archive -DestinationPath $premakeDirectory -Force

if (-not (Test-Path -LiteralPath $premakeExecutable)) {
    throw 'The Premake archive did not contain premake5.exe.'
}

Write-Host "Installed Premake $premakeVersion in $premakeDirectory"
