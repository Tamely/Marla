#!/usr/bin/env sh
set -eu

case "${1:-Debug}" in
    Debug|debug)
        configuration=Debug
        ;;
    Release|release)
        configuration=Release
        ;;
    Shipping|shipping)
        configuration=Shipping
        ;;
    *)
        echo "Unknown configuration: $1" >&2
        echo "Expected Debug, Release, or Shipping." >&2
        exit 2
        ;;
esac

script_directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
project_root=$(CDPATH= cd -- "$script_directory/.." && pwd)

cd "$project_root"

generator=${CMAKE_GENERATOR:-Ninja}

echo "Configuring Marla: $configuration"
cmake --preset "$configuration" -G "$generator"

echo "Building Marla: $configuration"
cmake --build --preset "$configuration" --parallel

echo "Build complete: $project_root/build"
