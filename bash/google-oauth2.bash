#!/usr/bin/env bash
# shellcheck source=/dev/null

# A simple curl OAuth2 authenticator
#
# Usage:
#	./google-oauth2.sh create - authenticates a user
#	./google-oauth2.sh refresh <token> - gets a new token
#
# Set CLIENT_ID and CLIENT_SECRET and SCOPE
# See SCOPES at https://developers.google.com/identity/protocols/oauth2/scopes#docsv1

set -o errexit -o noclobber -o pipefail

_usage() {
    printf "%s\n" "
No valid arguments provided.
Usage:

 ./${0##*/} create - authenticates a new user.
 ./${0##*/} refresh - gets a new access token.

 ./${0##*/} help - show this help."
    exit 0
}

UTILS_FOLDER="${UTILS_FOLDER:-$(pwd)}"
{ . "${UTILS_FOLDER}"/common-utils.bash && . "${UTILS_FOLDER}"/auth-utils.bash; } || { printf "Error: Unable to source util files.\n" && exit 1; }

[[ $# = 0 ]] && _usage

_check_debug

_cleanup() {
    # unhide the cursor if hidden
    [[ -n ${SUPPORT_ANSI_ESCAPES} ]] && printf "\e[?25h\e[?7h"
    {
        # grab all script children pids
        script_children_pids="$(ps --ppid="${MAIN_PID}" -o pid=)"

        # kill all grabbed children processes
        # shellcheck disable=SC2086
        kill ${script_children_pids} 1>| /dev/null

        export abnormal_exit && if [[ -n ${abnormal_exit} ]]; then
            printf "\n\n%s\n" "Script exited manually."
            kill -- -$$ &
        fi
    } 2>| /dev/null || :
    return 0
}

trap 'abnormal_exit="1"; exit' INT TERM
trap '_cleanup' EXIT
trap '' TSTP # ignore ctrl + z

export MAIN_PID="$$"

unset ROOT_FOLDER ROOT_FOLDER_NAME CLIENT_ID CLIENT_SECRET REFRESH_TOKEN ACCESS_TOKEN
export API_URL="https://www.googleapis.com"
export API_VERSION="v3" \
    SCOPE="${API_URL}/auth/drive" \
    REDIRECT_URI="urn:ietf:wg:oauth:2.0:oob" \
    TOKEN_URL="https://accounts.google.com/o/oauth2/token"

INFO_PATH="${HOME}/.google-drive-upload" CONFIG_INFO="${INFO_PATH}/google-drive-upload.configpath"
[[ -f ${CONFIG_INFO} ]] && . "${CONFIG_INFO}"
CONFIG="${CONFIG:-${HOME}/.googledrive.conf}"

[[ -r ${CONFIG} ]] && . "${CONFIG}"

case "${1}" in
    help) _usage ;;
    create) NEW_ACCOUNT="true" && _set_account_name "" ;;
    refresh) UPDATE_REFRESH_TOKEN="true" ;;
esac

ACCOUNT_NAME="${ACCOUNT_NAME:-${DEFAULT_ACCOUNT}}"

[[ -n ${UPDATE_REFRESH_TOKEN} ]] && export "ACCOUNT_${ACCOUNT_NAME}_ACCESS_TOKEN="

printf "%s\n" "Account: ${ACCOUNT_NAME:-Not set yet}"

_check_credentials no_token_service

[[ -n ${NEW_ACCOUNT} ]] && printf "Refresh Token: %s\n\n" "${REFRESH_TOKEN}" 1>&2

printf "Access Token: %s\n" "${ACCESS_TOKEN}" 1>&2

exit
