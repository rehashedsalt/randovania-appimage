#! /bin/bash

# Export APPRUN if running from an extracted image
self="$(readlink -f -- $0)"
here="${self%/*}"
APPDIR="${APPDIR:-${here}}"

# Export TCl/Tk
export TCL_LIBRARY="${APPDIR}/usr/share/tcltk/tcl8.4"
export TK_LIBRARY="${APPDIR}/usr/share/tcltk/tk8.4"
export TKPATH="${TK_LIBRARY}"

# Export SSL certificate
export SSL_CERT_FILE="${APPDIR}/opt/_internal/certs.pem"

# Call the entry point
for opt in "$@"
do
    [ "${opt:0:1}" != "-" ] && break
    if [[ "${opt}" =~ "I" ]] || [[ "${opt}" =~ "E" ]]; then
        # Environment variables are disabled ($PYTHONHOME). Let's run in a safe
        # mode from the raw Python binary inside the AppImage
        "$APPDIR/opt/python3.9/bin/python3.9" "$@"
        exit "$?"
    fi
done

# Get the executable name, i.e. the AppImage or the python binary if running from an
# extracted image
executable="${APPDIR}/opt/python3.9/bin/python3.9"
if [[ "${ARGV0}" =~ "/" ]]; then
    executable="$(cd $(dirname ${ARGV0}) && pwd)/$(basename ${ARGV0})"
elif [[ "${ARGV0}" != "" ]]; then
    executable=$(which "${ARGV0}")
fi

# This is a reimplementation of tools/start_client.sh from the base repository
# The UI build was performed during AppImage build, so we skip that step
(
	set -e -x
	export PATH="${APPDIR}/usr/bin:${PATH}"
	. "$APPDIR/opt/randovania/venv/bin/activate"
	cd "$APPDIR/opt/randovania"
	python3 -m randovania gui --preview main
)
exit "$?"

