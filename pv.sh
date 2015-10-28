#!/bin/bash
#
# Handy tools to use with pv

# Copy using a progress bar.
cpv () {
    IN="$1"
    OUT="$2"

    if [ -d "$OUT" ]
    then
        infile=${IN##*/}
        OUT="$OUT/$infile"
    fi
    
    if [ -r "$IN" ]
    then
        pv "$IN" > "$OUT"
    else
        echo "Cannot read from $IN"
    fi
}

# Safe move with a progress bar.
mpv () {
    IN="$1"
    OUT="$2"

    if [ "x$1" = "x" -o "x$2" = "x" ]
    then
        echo "mpv SOURCE DEST"
        echo "  (Careful! One file only)"
    fi

    if [ -d "$OUT" ]
    then
        infile=${IN##*/}
        OUT="$OUT/$infile"
    fi

    if [ -r "$IN" ]
    then
        md5in=$(pv "$IN" | tee "$OUT" | openssl md5 | awk -F '= ' '{print $2}')
        echo "Verifying ... "
        md5out=$(pv "$OUT" | openssl md5 | awk -F '= ' '{print $2}')
        if [ "$md5in" = "$md5out" ]
        then
            echo "Move successful! Cleaning up."
            rm -v "$IN"
        else
            echo "Move unsuccessful! Wah wah."
        fi
    else
        echo "Cannot read from '$IN'"
    fi

}
