#!/usr/bin/env sh

script_directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
setup_result=0

sh "$script_directory/Scripts/Setup-Premake.sh" || setup_result=$?

if [ "$setup_result" -eq 0 ]; then
    sh "$script_directory/Scripts/Setup-Dependencies.sh" || setup_result=$?
fi

if [ "$setup_result" -eq 0 ]; then
    MARLA_SKIP_SETUP=1 sh "$script_directory/Scripts/Generate-Projects.sh" "$@" || setup_result=$?
fi

if [ "$setup_result" -eq 0 ]; then
    printf '\nMarla setup completed successfully.\n'
else
    printf '\nMarla setup failed with exit code %s.\n' "$setup_result" >&2
fi

printf 'Press Enter to continue...'
IFS= read -r _marla_setup_pause || true

exit "$setup_result"
