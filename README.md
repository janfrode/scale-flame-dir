# scale-flame-dir
Generate flame graph over used capacity per IBM Storage Scale directory, using the GPFS policy engine. Generating the graph over all *files* will likely be too much data to handle, so we rather summarize the capacity of each file in each directory, and generate the graph on the directory level instead.

![Sample flame graph](https://tanso.net/scale-flame-dir/forum-lab.svg)

To generate the above plot, we first use the policy engine to list all files and sizes, and summarize this per directory in a sqlite3 database. This should only take minutes on a 100 million+ file file system.

```
# cd /root
# git clone https://github.com/janfrode/scale-flame-dir.git
# cd scale-flame-dir
# mmapplypolicy gpfs0 -P populatedb.policy -N localhost -B 100000 --choice-algorithm fast
```

This will generate the sqlite3 database /root/scale-flame-dir/dir.db, which can then be used to generate a capacity flame graph using:

```
# git clone https://github.com/brendangregg/FlameGraph.git
# sqlite3 dir.db 'select printf("%s %s", path, kballocated)  from directories;'|sed 's#/#;#g'|sed 's/^;//' | FlameGraph/flamegraph.pl --countname=kbytes  --title "Directory capacity"  --nametype Directory > out.svg
```

Or, a flame graph of number of files instead of capacity:

```
# sqlite3 dir.db 'select printf("%s %s", path, files)  from directories;'|sed 's#/#;#g'|sed 's/^;//' | FlameGraph/flamegraph.pl --countname=files  --title "Directory files"  --nametype Directory > out.svg
```


