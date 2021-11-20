" header for shell scripts

if get(g:, 'is_bash') || get(b:, 'is_bash')
    insert
#!/bin/bash
.
else
    insert
#!/bin/sh
.
endif

append
# vi: et sts=4 sw=4 ts=4
.
