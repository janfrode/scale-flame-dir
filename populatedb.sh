#! /bin/bash -

case "$1" in
	TEST)
		exit 0
	;;
	LIST)
		cat  "$2"|awk -F ' -- ' -f sizes.awk |sqlite3 scaledir.db
	;;
esac
