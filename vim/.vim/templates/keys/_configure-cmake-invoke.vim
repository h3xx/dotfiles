" cmake -> _build
insert
(
mkdir -p _build &&
cd _build &&
def_cmake \
    "$@" \
    ..
)
.
