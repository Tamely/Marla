#!/usr/bin/env sh
set -eu

glfw_version="3.5.1"
glfw_sha256="ea79bc5feffc254c87291980c2d0bce9acebb68c4983b79f961dcd2cb8a611a0"
script_directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
project_root=$(CDPATH= cd -- "$script_directory/.." && pwd)
vendor_directory="$project_root/Client/vendor"
glad_directory="$vendor_directory/glad"
glfw_directory="$vendor_directory/glfw"
download_directory="$project_root/build/dependencies"

if [ ! -f "$glad_directory/include/glad/glad.h" ] || [ ! -f "$glad_directory/src/glad.c" ]; then
    echo "The vendored GLAD sources are missing from $glad_directory." >&2
    exit 2
fi

if [ ! -f "$glfw_directory/premake5.lua" ]; then
    echo "The GLFW Premake definition is missing from $glfw_directory/premake5.lua." >&2
    exit 2
fi

echo "Found vendored GLAD in $glad_directory"

if [ -f "$glfw_directory/include/GLFW/glfw3.h" ] && [ -f "$glfw_directory/src/window.c" ]; then
    echo "GLFW $glfw_version is already installed in $glfw_directory"
    exit 0
fi

if ! command -v unzip >/dev/null 2>&1; then
    echo "unzip is required to set up GLFW." >&2
    exit 3
fi

download_file() {
    source_url=$1
    destination_file=$2

    if command -v curl >/dev/null 2>&1; then
        curl --fail --location --show-error "$source_url" --output "$destination_file"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$destination_file" "$source_url"
    else
        echo "curl or wget is required to download GLFW." >&2
        exit 3
    fi
}

mkdir -p "$glfw_directory" "$download_directory"
archive="$download_directory/glfw-$glfw_version.zip"
staging_directory="$download_directory/glfw-staging-$$"
url="https://github.com/glfw/glfw/releases/download/$glfw_version/glfw-$glfw_version.zip"

echo "Downloading GLFW $glfw_version"
download_file "$url" "$archive"

if command -v sha256sum >/dev/null 2>&1; then
    actual_sha256=$(sha256sum "$archive" | awk '{ print $1 }')
elif command -v shasum >/dev/null 2>&1; then
    actual_sha256=$(shasum -a 256 "$archive" | awk '{ print $1 }')
else
    echo "sha256sum or shasum is required to verify GLFW." >&2
    exit 3
fi

if [ "$actual_sha256" != "$glfw_sha256" ]; then
    echo "GLFW archive hash mismatch." >&2
    exit 4
fi

mkdir -p "$staging_directory"
unzip -q "$archive" -d "$staging_directory"
extracted_directory="$staging_directory/glfw-$glfw_version"

if [ ! -f "$extracted_directory/include/GLFW/glfw3.h" ]; then
    echo "The GLFW archive did not contain the expected source tree." >&2
    exit 5
fi

cp -R "$extracted_directory/." "$glfw_directory/"
rm -rf "$staging_directory"

echo "Installed GLFW $glfw_version in $glfw_directory"
