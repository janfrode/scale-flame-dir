#! /bin/bash -

case "$1" in
	TEST)
		echo Deleting old sqlite3 databasefile.
		rm -f scaledir.db
		exit 0
	;;
	LIST)
		cat  "$2"|awk -F ' -- ' -f sizes.awk |sqlite3 scaledir.db
	;;
esac
