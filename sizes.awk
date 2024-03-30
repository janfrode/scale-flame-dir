BEGIN {
        printf "CREATE TABLE  IF NOT EXISTS directories(DIRECTORY_HASH text PRIMARY KEY, files INT, kballocated INT, path TEXT);\n";


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
        DIRECTORY_HASH=fields[4] ;
        a[DIRECTORY_HASH] += $kballocated ;
        b[DIRECTORY_HASH] += 1 ;
        c[DIRECTORY_HASH] = dirname($2)
}
END {
        printf ".output /dev/null\n";
        printf "PRAGMA busy_timeout=20000;\n";
        #printf "PRAGMA journal_mode = MEMORY;\n";
        printf "PRAGMA journal_mode = WAL;\n";
        printf ".output stdout\n";
        printf "BEGIN TRANSACTION;\n";
        for (i in a) printf "INSERT INTO directories(DIRECTORY_HASH, files, kballocated, path) VALUES('%s', %s, %s, '%s') ON CONFLICT(DIRECTORY_HASH) DO UPDATE SET files=files+%s, kballocated=kballocated+%s, path='%s';\n", i, b[i], a[i], c[i], b[i], a[i], c[i]
        printf "END TRANSACTION;\n";
}
