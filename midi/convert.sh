for f in *.mid; do ./midicsv $f | grep _on_ > $f.txt; done
