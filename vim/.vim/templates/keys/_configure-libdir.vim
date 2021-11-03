" add dynamic libdir
append
"/usr/lib$([[ ${ARCH:-$(uname -m)} = x86_64 ]] && echo '64')"
.
