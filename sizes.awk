BEGIN {
    printf "CREATE TABLE IF NOT EXISTS directories(path text NOT NULL PRIMARY KEY, files INT NOT NULL, kballocated INT NOT NULL);\n";
	printf ".output /dev/null\n";
	printf "PRAGMA busy_timeout=20000;\n";
	printf "PRAGMA journal_mode = WAL;\n";
	printf "PRAGMA synchronous = OFF;\n";
	printf ".output stdout\n";
}
function dirname (pathname){
        if (!sub(/\/[^\/]*\/?$/, "", pathname))
                return "."
        else if (pathname != "")
                return pathname
        else
                return "/"
}
{
        split($1, fields, " ") ;
        kballocated=fields[7];
	directory = dirname($2)
	# Sanitize output for sqlite, just drop single quotes..
	gsub("'", "", directory)
        a[directory] += kballocated ;
        b[directory] += 1 ;
	# flush after every million lines to avoid using too much memory
	if (NR%1000000)
	{
        	printf "BEGIN IMMEDIATE TRANSACTION;\n";
        	for (i in a) printf "INSERT INTO directories(path, files, kballocated) VALUES('%s', %i, %i) ON CONFLICT(path) DO UPDATE SET files=files+%i, kballocated=kballocated+%i;\n", i, b[i], a[i], b[i], a[i]
        	printf "END TRANSACTION;\n";
        	delete a;
        	delete b;
        	delete c;
	}
}
END {
        printf "BEGIN IMMEDIATE TRANSACTION;\n";
        for (i in a) printf "INSERT INTO directories(path, files, kballocated) VALUES('%s', %i, %i) ON CONFLICT(path) DO UPDATE SET files=files+%i, kballocated=kballocated+%i;\n", i, b[i], a[i], b[i], a[i]
        printf "END TRANSACTION;\n";
}
