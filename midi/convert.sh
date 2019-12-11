for f in *.mid; do ./midicsv "$f" > "$f.txt"; done

mv *.mid.txt ../host/data/
