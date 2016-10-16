#!/bin/sh
#
#  convert.sh
#
#  Created by Wikitude GmbH on 05/21/15.
#
#


# global variables
INPUT_VIDEO_PATH=""
OUTPUT_VIDEO_PATH=""

usage() {
cat <<EOF
Usage: $0 [options] [--]

    Arguments:

    -h, --help
    Display this usage message and exit.

    -i <val>, --input_video <val>, --input_video=<val>
    Specifies the video file that should be converted

    -o <val>, --output_video <val>, --output_video=<val>
    Specifies the name and path of the video that will be generated during conversion
EOF
}

while [ "$#" -gt 0 ]; do
    arg=$1
    case $1 in
        # convert "--opt=the value" to --opt "the value".
        # the quotes around the equals sign is to work around a
        # bug in emacs' syntax parsing
        --*'='*) shift; set -- "${arg%=*}" "${arg#*=}" "$@"; continue;;
        -i|--input_video) shift; INPUT_VIDEO_PATH=$1;;
        -o|--output_video) shift; OUTPUT_VIDEO_PATH=$1;;
        -h|--help) usage; exit 0;;
        --) shift; break;;
        -*) echo "unknown option: '$1'";;
        *) break;; # reached the list of file names
    esac
    shift || echo "option '${arg}' requires a value"
done


# cd into the script directory, so that we can safely use ffmpeg
SCRIPT_DIRECTORY=`cd "$(dirname "$0")" && pwd`
cd $SCRIPT_DIRECTORY

# actually convert the video and append the alpha channel
./ffmpeg -i "${INPUT_VIDEO_PATH}" -vf 'split[a][b]; [a]pad=iw:ih*2[src]; [b]format=rgba,alphaextract[filt]; [src][filt]overlay=0:h' "${OUTPUT_VIDEO_PATH}"

if [ "$?" == "0" ]; then
    echo ""
    echo "DONE  **SUCCESS**"
    echo ""
else
    echo ""
    echo "DONE  **ERROR** "$?
    echo ""
fi
