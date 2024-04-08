# scale-flame-dir
Generate flame graph over used capacity per IBM Storage Scale directory, using the GPFS policy engine. Generating the graph over all *files* will likely be too much data to handle, so we rather summarize the capacity of all files in each directory, and generate the graph on the directory level instead.

[![Sample flame graph](https://tanso.net/scale-flame-dir/forum-lab.svg)](https://tanso.net/scale-flame-dir/forum-lab.svg)

Click on the image to get to a version that can be used to zoom into the directory structure, and hover on each box to get more details.

To generate the above plot, we first use the policy engine to list all files and sizes, and summarize this per directory in a sqlite3 database. This should only take minutes on a 100 million+ file file system.

```
git clone https://github.com/janfrode/scale-flame-dir.git
cd scale-flame-dir
mmapplypolicy gpfs0 -P populatedb.policy -N localhost -B 100000 --choice-algorithm fast
```

If there are ```database is locked``` errors logged while mmapplypolicy is running, consider reducing the number of parallel database updates with the ```mmapplypolicy ... -m ThreadLevel``` option, which defaults to 24.


This will generate the sqlite3 database ```scaledir.db```, which can then be used to generate a capacity flame graph using:

```
git clone https://github.com/brendangregg/FlameGraph.git
sqlite3 scaledir.db 'select printf("%s %s", replace(ltrim(path,"/"),"/",";"), kballocated) from directories;' | FlameGraph/flamegraph.pl --countname=kbytes  --title "Directory capacity"  --nametype Directory > out.svg
```

Or, a flame graph on number of files instead of capacity:

```
sqlite3 scaledir.db 'select printf("%s %s", replace(ltrim(path,"/"),"/",";"), files) from directories;' | FlameGraph/flamegraph.pl --countname=files  --title "Directory files"  --nametype Directory > out.svg
```
[![Sample flame graph over files](https://tanso.net/scale-flame-dir/forum-scale-files.svg)](https://tanso.net/scale-flame-dir/forum-scale-files.svg)

Beware, for a 200 million file file system with 24 million directories, generating the graphs needed 16 GB memory.

