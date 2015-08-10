#!/bin/sh

IN="$1"
OUT="${1/.*/}.m4a"
DIR="$2"
[[ ! -z "$DIR" ]] && OUT="$DIR/$OUT"

TMP=$(mktemp)

for t in ARTIST TITLE ALBUM DATE TRACKNUMBER GENRE DISCNUMBER TOTALDISCS TOTALTRACKS
do
#    metaflac --show-tag=$t "$IN" | sed 's/=\(.*\)$/="\1"/'
    eval $(metaflac --show-tag=$t "$IN" | sed 's/\(.*\)=\(.*\)$/\U\1\E="\2"/')
done

echo $TITLE
flac -d -o - "$IN" | fdkaac -m 5 -o "$OUT" \
       --title="$TITLE" \
       --artist="$ARTIST" \
       --album="$ALBUM" \
       --genre="$GENRE" \
       --date="$DATE" \
       --track="$TRACKNUMBER/$TOTALTRACKS" \
       --disk="$DISCNUMBER/$TOTALDISCS" \
                            -

# Picture
metaflac --export-picture-to=$TMP "$IN"
CMD="set picture:\"$TMP\" \"\""
kid3-cli -c "$CMD" "$OUT"

rm -f $TMP
