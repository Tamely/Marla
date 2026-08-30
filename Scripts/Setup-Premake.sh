#!/usr/bin/env sh
set -eu

premake_version="5.0.0-beta8"
script_directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
project_root=$(CDPATH= cd -- "$script_directory/.." && pwd)
premake_directory="$script_directory/bin"
premake_executable="$premake_directory/premake5"
download_directory="$project_root/build/dependencies"

if [ -x "$premake_executable" ] && "$premake_executable" --version 2>/dev/null | grep -q "$premake_version"; then
    echo "Premake $premake_version is already installed in $premake_directory"
    exit 0
fi

system_name=$(uname -s)
machine_name=$(uname -m)

case "$system_name" in
    Linux)
        case "$machine_name" in
            x86_64|amd64)
                archive_name="premake-$premake_version-linux.tar.gz"
                expected_sha256="63edd3e7461eebdd45b500a3c7e8ad4e7a67d68f230010f9a97cbb71b4ec59c8"
                ;;
            *)
                echo "Premake $premake_version does not provide a prebuilt Linux binary for $machine_name." >&2
                exit 2
                ;;
        esac
        ;;
    Darwin)
        case "$machine_name" in
            arm64|aarch64)
                archive_name="premake-$premake_version-macosx.tar.gz"
                expected_sha256="fa73a46f093fa6f17494a3d063421aa6cae3ea825a61c62dd59fc2f07a256d03"
                ;;
            x86_64|amd64)
                archive_name="premake-$premake_version-macosx-x64.tar.gz"
                expected_sha256="84b5fa5a432dcebdc3dd12e8677d10e38e5b32a3fe06d83ae68967e4f5e2db8a"
                ;;
            *)
                echo "Unsupported macOS architecture: $machine_name" >&2
                exit 2
                ;;
        esac
        ;;
    *)
        echo "Unsupported operating system: $system_name" >&2
        exit 2
        ;;
esac

download_file() {
    source_url=$1
    destination_file=$2

    if command -v curl >/dev/null 2>&1; then
        curl --fail --location --show-error "$source_url" --output "$destination_file"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$destination_file" "$source_url"
    else
        echo "curl or wget is required to download Premake." >&2
        exit 3
    fi
}

mkdir -p "$premake_directory" "$download_directory"
archive="$download_directory/$archive_name"
url="https://github.com/premake/premake-core/releases/download/v$premake_version/$archive_name"

echo "Downloading Premake $premake_version for $system_name $machine_name"
download_file "$url" "$archive"

if command -v sha256sum >/dev/null 2>&1; then
    actual_sha256=$(sha256sum "$archive" | awk '{ print $1 }')
elif command -v shasum >/dev/null 2>&1; then
    actual_sha256=$(shasum -a 256 "$archive" | awk '{ print $1 }')
else
    echo "sha256sum or shasum is required to verify Premake." >&2
    exit 3
fi

if [ "$actual_sha256" != "$expected_sha256" ]; then
    echo "Premake archive hash mismatch." >&2
    exit 4
fi

tar -xzf "$archive" -C "$premake_directory"
chmod +x "$premake_executable"

if [ ! -x "$premake_executable" ]; then
    echo "The Premake archive did not contain premake5." >&2
    exit 5
fi

if ! installed_version=$("$premake_executable" --version 2>&1); then
    echo "The downloaded Premake binary could not run on this system." >&2
    if [ "$system_name" = "Linux" ]; then
        echo "The official Linux binary requires an x86-64 glibc environment." >&2
    fi
    exit 5
fi

if ! printf '%s\n' "$installed_version" | grep -q "$premake_version"; then
    echo "The downloaded Premake binary reported an unexpected version: $installed_version" >&2
    exit 5
fi

echo "Installed Premake $premake_version in $premake_directory"
