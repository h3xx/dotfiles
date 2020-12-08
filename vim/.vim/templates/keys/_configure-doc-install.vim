" insert docfile installing meme
append
find . \
    -type f \
    -maxdepth 1 \
    -mindepth 1 \
    -regextype posix-egrep \
    -iregex ".*(AUTHORS|COPYING|NEWS|README|THANKS|TODO|HACKING|MAINTAINERS|TRANSLATORS|LICENSE|ChangeLog).*" \
    ! -empty \
    -exec install -m 0644 -p -- {} "$docdir" \;
.
