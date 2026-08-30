#!/usr/bin/env sh
set -eu

script_directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
project_root=$(CDPATH= cd -- "$script_directory/.." && pwd)

if [ "$#" -gt 0 ]; then
    premake_action=$1
else
    case "$(uname -s)" in
        Darwin)
            premake_action=xcode4
            ;;
        Linux)
            premake_action=gmake
            ;;
        *)
            echo "Could not select a Premake action for $(uname -s)." >&2
            exit 2
            ;;
    esac
fi

if [ "${MARLA_SKIP_SETUP:-0}" != "1" ]; then
    sh "$script_directory/Setup-Premake.sh"
    sh "$script_directory/Setup-Dependencies.sh"
fi

cd "$project_root"
echo "Generating Marla with $premake_action"
"$script_directory/bin/premake5" "$premake_action"
echo "Projects generated under $project_root/build/$premake_action"
