" cmake -> _build
append
(
mkdir -p _build &&
cd _build &&
def_cmake \
    "$@" \
    ..
)
.
