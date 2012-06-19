#!/bin/sh

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
OUTDIR=/export/work/scan
BASENAME=scan-`date "+%Y%m%d-%H%M%S"`

/bin/mkdir -p $TMPDIR
cd $TMPDIR

echo >$LOGFILE

echo `date "+[%Y-%m-%d %H:%M:%S]"` Scanning $SOURCE,$MODE,$RESOLUTION ... >>$LOGFILE
/usr/bin/scanimage --batch --source "$SOURCE" --mode "$MODE" --resolution="$RESOLUTION" --y-resolution="$RESOLUTION" --format=tiff >>$LOGFILE 2>&1

echo `date "+[%Y-%m-%d %H:%M:%S]"` Joining... >>$LOGFILE
/usr/bin/convert -compress JPEG -quality 85 -adjoin `ls -1 *.tif | sort -t t -k 2 -n` out.pdf >>$LOGFILE 2>&1

echo `date "+[%Y-%m-%d %H:%M:%S]"` Moving... >>$LOGFILE
/bin/mv out.pdf "$PDF_PATH" >>$LOGFILE 2>&1
/bin/mv $LOGFILE "$LOG_PATH"

rm -rf $TMPDIR
