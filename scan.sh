#!/bin/bash

if [ -z "$6" ] ; then
  echo usage: $0 pdf-path log-path thumbs-path source mode resolution
  exit 1
fi

PDF_PATH="$1"
LOG_PATH="$2"
THUMBS_PATH="$3"
SOURCE="$4"
MODE="$5"
RESOLUTION="$6"

TMPDIR=/var/cache/scan/scanweb.$$
LOGFILE=$TMPDIR/scan.log
THUMBSIZE=280x362

/bin/mkdir -p $TMPDIR
cd $TMPDIR

echo >$LOGFILE

echo `date "+[%Y-%m-%d %H:%M:%S]"` Scanning $SOURCE,$MODE,$RESOLUTION ... >>$LOGFILE
/usr/bin/scanimage --batch --source "$SOURCE" --mode "$MODE" --resolution="$RESOLUTION" --y-resolution="$RESOLUTION" --format=tiff >>$LOGFILE 2>&1
##cp /tmp/sourcedir/*.tif .

echo `date "+[%Y-%m-%d %H:%M:%S]"` Converting... >>$LOGFILE
for TIFFNAME in `ls -1 out*.tif | sort -t t -k 2 -n`; do
  NUM=${TIFFNAME#out}
  NUM=${NUM%.tif}
  JPGNAME=`printf out%04d.jpg $NUM`
  /usr/bin/convert -quality 85 $TIFFNAME $JPGNAME >>$LOGFILE 2>&1
done

echo `date "+[%Y-%m-%d %H:%M:%S]"` Creating PDF... >>$LOGFILE
/usr/bin/convert -adjoin out*.jpg out.pdf >>$LOGFILE 2>&1

echo `date "+[%Y-%m-%d %H:%M:%S]"` Creating Thumbnail... >>$LOGFILE
for LARGENAME in out*.jpg; do
  NUM=${LARGENAME#out}
  NUM=${NUM%.jpg}
  THUMBNAME=thumb${NUM}.jpg
  /usr/bin/convert -define jpeg:size=$THUMBSIZE -geometry $THUMBSIZE $LARGENAME $THUMBNAME>>$LOGFILE 2>&1
done
/usr/bin/zip thumb.zip thumb*.jpg >>$LOGFILE 2>&1

echo `date "+[%Y-%m-%d %H:%M:%S]"` Moving... >>$LOGFILE
/bin/mv out.pdf "$PDF_PATH" >>$LOGFILE 2>&1
/bin/mv thumb.zip "$THUMBS_PATH" >>$LOGFILE 2>&1
/bin/mv $LOGFILE "$LOG_PATH"

rm -rf $TMPDIR

