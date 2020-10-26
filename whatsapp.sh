#!/usr/bin/env sh

## Dark-WhatsApp helper script. \n
##
## \033[0;36mUsage:\033[0m
##     sh whatsapp.sh [-cufprh] \n
##
## \033[0;36mOptions:\033[0m
##     -c      Compile custom ~wa.user.styl~ userstyle.
##     -u      Compile ~wa.user.styl~ to ~wa.user.css~.
##     -f      Convert ~wa.user.css~ to ~darkmode.css~.
##     -p      Print the file content to standard output.
##     -r      Remove files generated by this script.
##     -h      Print help and exit. \n
##
## Source:
##    \033[0;34m https://github.com/vednoc/dark-whatsapp \033[0m \n
##
## Documentation:
##    \033[0;34m https://github.com/vednoc/dark-whatsapp/wiki \033[0m

short_help() {
    help | tail -n +2
}

help() {
    printf "$(sed -n "s/##\ //p" "$0") \n"
}

print() {
    if [ -n "${USERCSS+x}" ]; then
        input="wa.user.css"
    elif [ -n "${COMPILE+x}" ]; then
        input="custom.user.css"
    else
        echo "You must pick an option." >&2
        exit 0
    fi

    cat $input
}

remove_if_exists() {
    if [ -f "$1" ]; then
        rm "$1"
    fi
}

remove() {
    echo "Removing files..."

    remove_if_exists temp.styl
    remove_if_exists darkmode.css
    remove_if_exists custom.user.css

    echo "Done!"
}

compile() {
    echo "Compiling..."

    temp="temp.styl"
    input="wa.user.styl"

    if [ -n "${USERCSS+x}" ]; then
        output="wa.user.css"
    else
        output="custom.user.css"
    fi

    sed -n '/^\/\//,$p; 1i @import("metadata.styl");' $input > $temp

    if command -v stylus >/dev/null; then
        stylus $temp -o $output
        rm $temp
    elif ! command -v npm >/dev/null; then
        echo "You're missing ~npm~ and ~Node.js~ libraries." >&2
    else
        echo "Missing ~stylus~ executable in your \$PATH." >&2
    fi
}

convert() {
    echo "Converting..."

    if [ -n "${USERCSS+x}" ]; then
        input="wa.user.css"
    elif [ -n "${COMPILE+x}" ]; then
        input="custom.user.css"
    else
        input="wa.user.css"
    fi

    output="darkmode.css"

    sed -n '/:root/,$p' $input | sed 's/^\ \ //; $d' > $output

    [ -e $output ] && echo "Done! $output is ready." \
                   || echo "File not found!" >&2
}

[ $# -eq 0 ] && { echo "No arguments given"; short_help; }

while getopts "rcfuph" option; do
    case "$option" in
        "r") REMOVE=1  ;;
        "c") COMPILE=1 ;;
        "f") CONVERT=1 ;;
        "u") USERCSS=1 ;;
        "p") PRINT=1   ;;
        "h") help      ;;
        *) short_help  ;;
    esac
done

# Functions need to run in this order, therefore they are not called in getopts.
[ -n "${REMOVE+x}"  ] && remove
[ -n "${COMPILE+x}" ] && compile
[ -n "${CONVERT+x}" ] && convert
[ -n "${PRINT+x}"   ] && print
