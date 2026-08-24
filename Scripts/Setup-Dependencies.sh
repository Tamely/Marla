#!/usr/bin/env sh
set -eu

glfw_version="3.5.1"
glfw_sha256="ea79bc5feffc254c87291980c2d0bce9acebb68c4983b79f961dcd2cb8a611a0"
spdlog_version="1.17.0"
spdlog_sha256="b11912a82d149792fef33fabd0503b13d54aeac25c1464755461d4108ea71fc2"

script_directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
project_root=$(CDPATH= cd -- "$script_directory/.." && pwd)
vendor_directory="$project_root/Client/vendor"
glad_directory="$vendor_directory/glad"
glfw_directory="$vendor_directory/glfw"
spdlog_directory="$vendor_directory/spdlog"
download_directory="$project_root/build/dependencies"

if [ ! -f "$glad_directory/include/glad/glad.h" ] || [ ! -f "$glad_directory/src/glad.c" ]; then
    echo "The vendored GLAD sources are missing from $glad_directory." >&2
    exit 2
fi

if ! command -v unzip >/dev/null 2>&1; then
    echo "unzip is required to set up project dependencies." >&2
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
        echo "curl or wget is required to download project dependencies." >&2
        exit 3
    fi
}

calculate_sha256() {
    archive_path=$1

    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$archive_path" | awk '{ print $1 }'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$archive_path" | awk '{ print $1 }'
    else
        echo "sha256sum or shasum is required to verify project dependencies." >&2
        exit 3
    fi
}

install_dependency() {
    dependency_name=$1
    dependency_version=$2
    dependency_url=$3
    expected_sha256=$4
    destination_directory=$5
    extracted_directory_name=$6
    expected_file=$7

    premake_definition="$destination_directory/premake5.lua"
    if [ ! -f "$premake_definition" ]; then
        echo "The $dependency_name Premake definition is missing from $premake_definition." >&2
        exit 2
    fi

    if [ -f "$destination_directory/$expected_file" ]; then
        echo "$dependency_name $dependency_version is already installed in $destination_directory"
        return
    fi

    case "$destination_directory" in
        "$vendor_directory"/*) ;;
        *)
            echo "Refusing to replace a directory outside $vendor_directory." >&2
            exit 6
            ;;
    esac

    mkdir -p "$download_directory"
    archive="$download_directory/$dependency_name-$dependency_version.zip"
    staging_directory="$download_directory/$dependency_name-staging-$$"

    echo "Downloading $dependency_name $dependency_version"
    download_file "$dependency_url" "$archive"

    actual_sha256=$(calculate_sha256 "$archive")
    if [ "$actual_sha256" != "$expected_sha256" ]; then
        rm -f "$archive"
        echo "$dependency_name archive hash mismatch." >&2
        exit 4
    fi

    mkdir -p "$staging_directory"
    unzip -q "$archive" -d "$staging_directory"
    extracted_directory="$staging_directory/$extracted_directory_name"

    if [ ! -f "$extracted_directory/$expected_file" ]; then
        echo "The $dependency_name archive did not contain the expected source tree." >&2
        exit 5
    fi

    premake_backup="$download_directory/$dependency_name-premake5.lua"
    cp "$premake_definition" "$premake_backup"
    rm -rf "$destination_directory"
    mv "$extracted_directory" "$destination_directory"
    cp "$premake_backup" "$destination_directory/premake5.lua"
    rm -f "$premake_backup"
    rm -rf "$staging_directory"

    echo "Installed $dependency_name $dependency_version in $destination_directory"
}

echo "Found vendored GLAD in $glad_directory"

install_dependency \
    "GLFW" \
    "$glfw_version" \
    "https://github.com/glfw/glfw/releases/download/$glfw_version/glfw-$glfw_version.zip" \
    "$glfw_sha256" \
    "$glfw_directory" \
    "glfw-$glfw_version" \
    "include/GLFW/glfw3.h"

install_dependency \
    "spdlog" \
    "$spdlog_version" \
    "https://github.com/gabime/spdlog/archive/refs/tags/v$spdlog_version.zip" \
    "$spdlog_sha256" \
    "$spdlog_directory" \
    "spdlog-$spdlog_version" \
    "include/spdlog/spdlog.h"
