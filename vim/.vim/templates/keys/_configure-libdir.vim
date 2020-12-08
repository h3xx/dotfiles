" add dynamic libdir
append
"/usr/lib$([ "_${ARCH:-$(uname -m)}" == '_x86_64' ] && echo '64')"
.
