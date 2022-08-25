" more advanced header for build scripts
insert
(build_script=$(readlink -f -- "$BASH_SOURCE")
conf_script=${build_script%-build}
[[ $build_script = "$conf_script" || ! -f $conf_script ]] ||
. "$conf_script") &&
(
make_args=(
)
make "${make_args[@]}" &&
midest "${make_args[@]}"
) &&
mkdir -p \
    b/install \
    "b/$(svn-docdir)" &&
.
