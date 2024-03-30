#! /bin/bash -

cd /root/scale-flame-dir

case "$1" in
	TEST)
		echo Deleting old sqlite3 databasefile.
		rm -f dir.db
		exit 0
	;;
	LIST)
		cat  "$2"|awk -F ' -- ' -f sizes.awk |sqlite3 dir.db
	;;
esac
