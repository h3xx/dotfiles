#!/bin/bash

PROJECTS=(
workday-demo    workday_ec
workday         workday_ec
hilti-demo      hilti_ec
hilti           hilti_ec
boa-demo        boa_ec
future-test     future_ec
future          future_ec
smartco-test    smartco_ec
smartco         smartco_ec

redhat-demo     redhat_ec
redhat          redhat_ec
#cisco-demo      cisco_ec
#cisco           cisco_ec
intelgcm-demo   intelgcm_ec
intelgcm        intelgcm_ec

infiniti-demo   infiniti
)

declare -A SERVER_COLORS
SERVER_COLORS['223_1']='\e[30;48;5;118m' # lime
SERVER_COLORS['223']='\e[30;48;5;106m' # dark lime
SERVER_COLORS['220']='\e[37;48;5;124m' # maroon

report_server() {
    local sub_dns=$1 project=$2
    printf '%-25s    ' \
        "$(printf '%s@%s' "$project" "$sub_dns")"
    local server_name="$(curl -s "https://${sub_dns}.g2planet.com/$project/server_info?simple"|head -1)"
    local server_pat server_color

    for server_pat in "${!SERVER_COLORS[@]}"; do
        if [[ $server_name =~ $server_pat ]]; then
            server_color="${SERVER_COLORS[$server_pat]}"
            break
        fi
    done

    printf '%s%s%s\n' \
        "$(printf "$server_color")" \
        "$server_name"\
        $'\e[0m'
}

for ((i=0; i<${#PROJECTS[@]}; i+=2)); do
    sub_dns=${PROJECTS[i]}
    project=${PROJECTS[i+1]}

    report_server "$sub_dns" "$project";
done
