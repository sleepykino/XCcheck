#!/bin/bash

SCRIPT_NAME="系统信息采集脚本"
SCRIPT_VERSION="1.1.0"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
DATE_STR=$(date '+%Y%m%d')
HOSTNAME_VAL=$(hostname 2>/dev/null || echo "Unknown")

get_first_ip() {
    local ip=""

    ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    if [ -n "$ip" ] && [ "$ip" != "127.0.0.1" ] && [ "$ip" != "::1" ]; then
        echo "$ip"
        return
    fi

    if command -v ip >/dev/null 2>&1; then
        ip=$(ip -4 route get 8.8.8.8 2>/dev/null | grep -oP 'src \K[0-9.]+' | head -1)
        if [ -n "$ip" ]; then
            echo "$ip"
            return
        fi
        ip=$(ip -4 addr show 2>/dev/null | grep -oP 'inet \K[0-9.]+' | grep -v '127\.0\.0\.' | head -1)
        if [ -n "$ip" ]; then
            echo "$ip"
            return
        fi
    fi

    if command -v ifconfig >/dev/null 2>&1; then
        ip=$(ifconfig 2>/dev/null | grep -oE 'inet [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | grep -v '127\.0\.0\.' | head -1 | awk '{print $2}')
        if [ -n "$ip" ]; then
            echo "$ip"
            return
        fi
    fi

    for f in /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-ens*; do
        if [ -f "$f" ]; then
            ip=$(grep "^IPADDR=" "$f" 2>/dev/null | sed 's/IPADDR=//' | tr -d '"' | head -1)
            if [ -n "$ip" ] && [ "$ip" != "127.0.0.1" ]; then
                echo "$ip"
                return
            fi
        fi
    done

    echo "Unknown"
}

INPUT_IP="$1"
if [ -n "$INPUT_IP" ]; then
    IP_ADDR="$INPUT_IP"
else
    IP_ADDR=$(get_first_ip)
fi

get_os_name() {
    local os_name=""

    if command -v nkvers >/dev/null 2>&1; then
        local nkout
        nkout=$(nkvers 2>/dev/null)
        if echo "$nkout" | grep -qi "kylin\|麒麟"; then
            os_name=$(echo "$nkout" | grep -i "Release" | head -1 | sed 's/.*:\s*//' | tr -d '"' | awk '{print $1}')
            [ -z "$os_name" ] && os_name=$(echo "$nkout" | head -1 | awk '{print $1" "$2" "$3}')
            [ -n "$os_name" ] && echo "$os_name" && return
        fi
    fi

    if [ -f /etc/kylin-release ]; then
        os_name=$(head -1 /etc/kylin-release | awk '{print $1" "$2" "$3}')
        [ -n "$os_name" ] && echo "$os_name" && return
    fi

    if [ -f /etc/neokylin-release ]; then
        os_name=$(head -1 /etc/neokylin-release | awk '{print $1" "$2" "$3}')
        [ -n "$os_name" ] && echo "$os_name" && return
    fi

    if [ -f /etc/uos-release ]; then
        os_name=$(grep "^NAME=" /etc/uos-release 2>/dev/null | head -1 | sed 's/NAME=//' | tr -d '"' | awk '{print $1" "$2}')
        [ -n "$os_name" ] && echo "$os_name" && return
    fi

    if [ -f /etc/deepin-release ] || [ -f /etc/deepin-version ]; then
        local df="/etc/deepin-release"
        [ -f /etc/deepin-version ] && df="/etc/deepin-version"
        os_name=$(head -1 "$df" | awk '{print $1" "$2" "$3}')
        [ -n "$os_name" ] && echo "$os_name" && return
    fi

    if [ -f /etc/openEuler-release ]; then
        os_name=$(head -1 /etc/openEuler-release | awk '{print $1" "$2}')
        [ -n "$os_name" ] && echo "$os_name" && return
    fi

    if [ -f /etc/euleros-release ]; then
        os_name=$(head -1 /etc/euleros-release | awk '{print $1" "$2}')
        [ -n "$os_name" ] && echo "$os_name" && return
    fi

    if [ -f /etc/anolis-release ]; then
        os_name=$(head -1 /etc/anolis-release | awk '{print $1" "$2" "$3}')
        [ -n "$os_name" ] && echo "$os_name" && return
    fi

    if [ -f /etc/tencentos-release ]; then
        os_name=$(head -1 /etc/tencentos-release | awk '{print $1" "$2}')
        [ -n "$os_name" ] && echo "$os_name" && return
    fi

    if [ -f /etc/iSoft-release ]; then
        os_name=$(head -1 /etc/iSoft-release | awk '{print $1" "$2" "$3}')
        [ -n "$os_name" ] && echo "$os_name" && return
    fi

    if [ -f /etc/redflag-release ]; then
        os_name=$(head -1 /etc/redflag-release | awk '{print $1" "$2" "$3}')
        [ -n "$os_name" ] && echo "$os_name" && return
    fi

    if [ -f /etc/linx-release ]; then
        os_name=$(head -1 /etc/linx-release | awk '{print $1" "$2" "$3}')
        [ -n "$os_name" ] && echo "$os_name" && return
    fi

    if [ -f /etc/newstart-release ]; then
        os_name=$(head -1 /etc/newstart-release | awk '{print $1" "$2" "$3}')
        [ -n "$os_name" ] && echo "$os_name" && return
    fi

    if [ -f /etc/nfs-release ]; then
        os_name=$(head -1 /etc/nfs-release | awk '{print $1" "$2" "$3}')
        [ -n "$os_name" ] && echo "$os_name" && return
    fi

    if [ -f /etc/founder-release ]; then
        os_name=$(head -1 /etc/founder-release | awk '{print $1" "$2" "$3}')
        [ -n "$os_name" ] && echo "$os_name" && return
    fi

    for f in /etc/os-release /usr/lib/os-release; do
        if [ -f "$f" ]; then
            os_name=$(grep "^NAME=" "$f" 2>/dev/null | head -1 | sed 's/NAME=//' | tr -d '"')
            [ -n "$os_name" ] && echo "$os_name" && return
        fi
    done

    if command -v lsb_release >/dev/null 2>&1; then
        os_name=$(lsb_release -i -s 2>/dev/null)
        [ -n "$os_name" ] && echo "$os_name" && return
    fi

    if [ -f /etc/redhat-release ]; then
        os_name=$(head -1 /etc/redhat-release | awk '{print $1" "$2" "$3}')
        [ -n "$os_name" ] && echo "$os_name" && return
    fi

    if [ -f /etc/lsb-release ]; then
        os_name=$(grep "^DISTRIB_ID=" /etc/lsb-release 2>/dev/null | sed 's/DISTRIB_ID=//' | tr -d '"')
        [ -n "$os_name" ] && echo "$os_name" && return
    fi

    os_name=$(uname -s 2>/dev/null)
    echo "${os_name:-Unknown}"
}

get_os_version() {
    local os_version=""

    if command -v nkvers >/dev/null 2>&1; then
        local nkout
        nkout=$(nkvers 2>/dev/null)
        if echo "$nkout" | grep -qi "kylin\|麒麟"; then
            os_version=$(echo "$nkout" | grep -i "Version" | head -1 | sed 's/.*:\s*//' | tr -d '"' | awk '{print $1}')
            [ -n "$os_version" ] && echo "$os_version" && return
        fi
    fi

    if [ -f /etc/kylin-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)+' /etc/kylin-release | head -1)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/neokylin-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)+' /etc/neokylin-release | head -1)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/uos-release ]; then
        os_version=$(grep "^VERSION=" /etc/uos-release 2>/dev/null | head -1 | sed 's/VERSION=//' | tr -d '"')
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/deepin-version ]; then
        os_version=$(grep -i "version" /etc/deepin-version 2>/dev/null | head -1 | sed 's/.*[=:]\s*//' | tr -d '"' | awk '{print $1}')
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/deepin-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)+' /etc/deepin-release | head -1)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/openEuler-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)+' /etc/openEuler-release | head -1)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/euleros-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)+' /etc/euleros-release | head -1)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/anolis-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)+' /etc/anolis-release | head -1)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/tencentos-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)+' /etc/tencentos-release | head -1)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/iSoft-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)+' /etc/iSoft-release | head -1)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/redflag-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)+' /etc/redflag-release | head -1)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/linx-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)+' /etc/linx-release | head -1)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/newstart-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)+' /etc/newstart-release | head -1)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/nfs-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)+' /etc/nfs-release | head -1)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/founder-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)+' /etc/founder-release | head -1)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    for f in /etc/os-release /usr/lib/os-release; do
        if [ -f "$f" ]; then
            os_version=$(grep "^VERSION=" "$f" 2>/dev/null | head -1 | sed 's/VERSION=//' | tr -d '"')
            [ -n "$os_version" ] && echo "$os_version" && return
        fi
    done

    if command -v lsb_release >/dev/null 2>&1; then
        os_version=$(lsb_release -r -s 2>/dev/null)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/redhat-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)+' /etc/redhat-release | head -1)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/lsb-release ]; then
        os_version=$(grep "^DISTRIB_RELEASE=" /etc/lsb-release 2>/dev/null | sed 's/DISTRIB_RELEASE=//' | tr -d '"')
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    os_version=$(uname -r 2>/dev/null)
    echo "${os_version:-Unknown}"
}

get_cpu_model() {
    local cpu_model=""

    if [ -f /proc/cpuinfo ]; then
        cpu_model=$(grep -m1 "model name" /proc/cpuinfo 2>/dev/null | sed 's/model name\s*:\s*//')
        if [ -z "$cpu_model" ]; then
            cpu_model=$(grep -m1 "Model" /proc/cpuinfo 2>/dev/null | sed 's/Model\s*:\s*//')
        fi
        if [ -z "$cpu_model" ]; then
            cpu_model=$(grep -m1 "cpu model" /proc/cpuinfo 2>/dev/null | sed 's/cpu model\s*:\s*//')
        fi
    fi

    if [ -z "$cpu_model" ] && command -v lscpu >/dev/null 2>&1; then
        cpu_model=$(lscpu 2>/dev/null | grep -m1 "Model name" | sed 's/Model name:\s*//')
        if [ -z "$cpu_model" ]; then
            cpu_model=$(lscpu 2>/dev/null | grep -m1 "Architecture" | awk '{print $2}')
        fi
    fi

    echo "${cpu_model:-Unknown}"
}

get_cpu_arch() {
    local arch=""
    arch=$(uname -m 2>/dev/null)
    echo "${arch:-Unknown}"
}

get_cpu_cores() {
    local cores=""
    if command -v nproc >/dev/null 2>&1; then
        cores=$(nproc 2>/dev/null)
    fi
    if [ -z "$cores" ] && [ -f /proc/cpuinfo ]; then
        cores=$(grep -c "^processor" /proc/cpuinfo 2>/dev/null)
    fi
    echo "${cores:-Unknown}"
}

get_kernel_version() {
    local kv=""
    kv=$(uname -r 2>/dev/null)
    echo "${kv:-Unknown}"
}

detect_db_single() {
    local db_name="$1"
    local cmd="$2"
    local ver_cmd="$3"
    local ver_pattern="$4"

    if command -v "$cmd" >/dev/null 2>&1; then
        local ver=""
        if [ -n "$ver_cmd" ]; then
            ver=$(eval "$ver_cmd" 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        fi
        if [ -n "$ver" ]; then
            echo "${db_name}|${ver}"
        else
            echo "${db_name}|"
        fi
        return 0
    fi
    return 1
}

detect_db_service() {
    local db_name="$1"
    local svc_pattern="$2"
    local ver_cmd="$3"

    if command -v systemctl >/dev/null 2>&1; then
        if systemctl list-units --type=service --all 2>/dev/null | grep -qi "$svc_pattern"; then
            local ver=""
            if [ -n "$ver_cmd" ]; then
                ver=$(eval "$ver_cmd" 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
            fi
            echo "${db_name}|${ver}"
            return 0
        fi
    fi

    if command -v service >/dev/null 2>&1; then
        if service --status-all 2>/dev/null | grep -qi "$svc_pattern"; then
            local ver=""
            if [ -n "$ver_cmd" ]; then
                ver=$(eval "$ver_cmd" 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
            fi
            echo "${db_name}|${ver}"
            return 0
        fi
    fi

    if [ -f /etc/init.d/"${svc_pattern}" ]; then
        local ver=""
        if [ -n "$ver_cmd" ]; then
            ver=$(eval "$ver_cmd" 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        fi
        echo "${db_name}|${ver}"
        return 0
    fi

    return 1
}

detect_databases() {
    local results=""

    detect_db_single "达梦" "dmserver" "dmserver -V" "" && results="${results}$(detect_db_single "达梦" "dmserver" "dmserver -V" "")
    detect_db_single "达梦" "disql" "disql -V" "" && { [ -z "$results" ] && results="达梦|"; }

    if [ -d /opt/dmdbms ] || [ -d /dmdbms ] || [ -d /opt/dameng ]; then
        local ver=""
        if [ -f /opt/dmdbms/bin/dmserver ]; then
            ver=$(/opt/dmdbms/bin/dmserver -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        elif [ -d /dmdbms/bin ]; then
            ver=$(/dmdbms/bin/dmserver -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        fi
        if ! echo "$results" | grep -q "达梦"; then
            results="${results}达梦|${ver}"$'\n'
        fi
    fi

    if command -v ksql >/dev/null 2>&1 || command -v kingbase >/dev/null 2>&1 || command -v sys_ctl >/dev/null 2>&1; then
        local ver=""
        command -v kingbase >/dev/null 2>&1 && ver=$(kingbase -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        [ -z "$ver" ] && command -v ksql >/dev/null 2>&1 && ver=$(ksql -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        results="${results}金仓|${ver}"$'\n'
    fi
    if [ -d /opt/Kingbase ] || [ -d /opt/kingbase ] || [ -d /usr/local/kingbase ]; then
        local ver=""
        [ -f /opt/Kingbase/ES/V8/Install/bin/kingbase ] && ver=$(/opt/Kingbase/ES/V8/Install/bin/kingbase -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        [ -z "$ver" ] && [ -f /opt/kingbase/bin/kingbase ] && ver=$(/opt/kingbase/bin/kingbase -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        if ! echo "$results" | grep -q "金仓"; then
            results="${results}金仓|${ver}"$'\n'
        fi
    fi

    if command -v osdb >/dev/null 2>&1 || command -v osci >/dev/null 2>&1; then
        local ver=""
        command -v osdb >/dev/null 2>&1 && ver=$(osdb -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        results="${results}神舟通用|${ver}"$'\n'
    fi
    if [ -d /opt/ShenTong ] || [ -d /opt/shentong ] || [ -d /usr/local/shentong ]; then
        local ver=""
        results="${results}神舟通用|${ver}"$'\n'
    fi

    if command -v hgdb >/dev/null 2>&1 || command -v hgdb-admin >/dev/null 2>&1; then
        local ver=""
        command -v hgdb >/dev/null 2>&1 && ver=$(hgdb -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        results="${results}瀚高|${ver}"$'\n'
    fi
    if [ -d /opt/highgo ] || [ -d /usr/local/highgo ]; then
        local ver=""
        [ -f /opt/highgo/bin/hgdb ] && ver=$(/opt/highgo/bin/hgdb -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        if ! echo "$results" | grep -q "瀚高"; then
            results="${results}瀚高|${ver}"$'\n'
        fi
    fi

    if command -v gbase >/dev/null 2>&1 || command -v gbasedbt >/dev/null 2>&1; then
        local ver=""
        command -v gbase >/dev/null 2>&1 && ver=$(gbase -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        [ -z "$ver" ] && command -v gbasedbt >/dev/null 2>&1 && ver=$(gbasedbt -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        results="${results}南大通用|${ver}"$'\n'
    fi
    if [ -d /opt/gbase ] || [ -d /usr/local/gbase ]; then
        local ver=""
        if ! echo "$results" | grep -q "南大通用"; then
            results="${results}南大通用|${ver}"$'\n'
        fi
    fi

    if command -v uxsql >/dev/null 2>&1 || command -v uxdb >/dev/null 2>&1; then
        local ver=""
        command -v uxsql >/dev/null 2>&1 && ver=$(uxsql -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        [ -z "$ver" ] && command -v uxdb >/dev/null 2>&1 && ver=$(uxdb -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        results="${results}优炫|${ver}"$'\n'
    fi
    if [ -d /opt/uxdb ] || [ -d /usr/local/uxdb ]; then
        local ver=""
        if ! echo "$results" | grep -q "优炫"; then
            results="${results}优炫|${ver}"$'\n'
        fi
    fi

    if command -v vds_cli >/dev/null 2>&1 || command -v vastbase >/dev/null 2>&1; then
        local ver=""
        command -v vastbase >/dev/null 2>&1 && ver=$(vastbase -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        results="${results}海量|${ver}"$'\n'
    fi
    if [ -d /opt/vastbase ] || [ -d /opt/hailiang ]; then
        local ver=""
        if ! echo "$results" | grep -q "海量"; then
            results="${results}海量|${ver}"$'\n'
        fi
    fi

    if command -v polardb >/dev/null 2>&1 || command -v psql 2>/dev/null | grep -qi polardb; then
        local ver=""
        command -v polardb >/dev/null 2>&1 && ver=$(polardb -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        results="${results}阿里PolarDB|${ver}"$'\n'
    fi
    if [ -d /opt/polardb ] || [ -d /usr/local/polardb ]; then
        local ver=""
        if ! echo "$results" | grep -q "阿里PolarDB"; then
            results="${results}阿里PolarDB|${ver}"$'\n'
        fi
    fi

    if command -v tdsql >/dev/null 2>&1; then
        local ver=""
        ver=$(tdsql -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        results="${results}腾讯TDSQL|${ver}"$'\n'
    fi
    detect_db_service "腾讯TDSQL" "tdsql" "" 2>/dev/null && { echo "$results" | grep -q "腾讯TDSQL" || results="${results}腾讯TDSQL|"$'\n'; }
    if [ -d /opt/tdsql ] || [ -d /usr/local/tdsql ]; then
        if ! echo "$results" | grep -q "腾讯TDSQL"; then
            results="${results}腾讯TDSQL|"$'\n'
        fi
    fi

    if command -v xugusql >/dev/null 2>&1 || command -v xugu >/dev/null 2>&1; then
        local ver=""
        command -v xugusql >/dev/null 2>&1 && ver=$(xugusql -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        results="${results}虚谷|${ver}"$'\n'
    fi
    if [ -d /opt/xugu ] || [ -d /usr/local/xugu ]; then
        if ! echo "$results" | grep -q "虚谷"; then
            results="${results}虚谷|"$'\n'
        fi
    fi

    if command -v xdb >/dev/null 2>&1 || command -v jxdb >/dev/null 2>&1; then
        local ver=""
        command -v xdb >/dev/null 2>&1 && ver=$(xdb -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        results="${results}东方金信|${ver}"$'\n'
    fi
    if [ -d /opt/jxserver ] || [ -d /opt/dongfang ]; then
        if ! echo "$results" | grep -q "东方金信"; then
            results="${results}东方金信|"$'\n'
        fi
    fi

    if command -v greatdb >/dev/null 2>&1 || command -v greatsql >/dev/null 2>&1; then
        local ver=""
        command -v greatsql >/dev/null 2>&1 && ver=$(greatsql -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        results="${results}万里开源|${ver}"$'\n'
    fi
    if [ -d /opt/greatdb ] || [ -d /opt/greatsql ]; then
        if ! echo "$results" | grep -q "万里开源"; then
            results="${results}万里开源|"$'\n'
        fi
    fi

    if command -v gaussdb >/dev/null 2>&1 || command -v gs_ctl >/dev/null 2>&1; then
        local ver=""
        command -v gaussdb >/dev/null 2>&1 && ver=$(gaussdb -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        [ -z "$ver" ] && command -v gs_ctl >/dev/null 2>&1 && ver=$(gs_ctl -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        results="${results}华为GaussDB|${ver}"$'\n'
    fi
    if [ -d /opt/gaussdb ] || [ -d /opt/huawei/gaussdb ] || [ -d /var/lib/gaussdb ]; then
        if ! echo "$results" | grep -q "华为GaussDB"; then
            results="${results}华为GaussDB|"$'\n'
        fi
    fi
    detect_db_service "华为GaussDB" "gaussdb" "gaussdb -V" 2>/dev/null && { echo "$results" | grep -q "华为GaussDB" || results="${results}华为GaussDB|"$'\n'; }

    if command -v pingcap >/dev/null 2>&1 || command -v tidb >/dev/null 2>&1; then
        local ver=""
        command -v tidb >/dev/null 2>&1 && ver=$(tidb -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        results="${results}平凯|${ver}"$'\n'
    fi
    if [ -d /opt/tidb ] || [ -d /opt/pingcap ]; then
        if ! echo "$results" | grep -q "平凯"; then
            results="${results}平凯|"$'\n'
        fi
    fi
    detect_db_service "平凯" "tidb" "tidb -V" 2>/dev/null && { echo "$results" | grep -q "平凯" || results="${results}平凯|"$'\n'; }

    if command -v goldendb >/dev/null 2>&1; then
        local ver=""
        ver=$(goldendb -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        results="${results}中兴GoldenDB|${ver}"$'\n'
    fi
    if [ -d /opt/goldendb ] || [ -d /opt/zte/goldendb ]; then
        if ! echo "$results" | grep -q "中兴GoldenDB"; then
            results="${results}中兴GoldenDB|"$'\n'
        fi
    fi
    detect_db_service "中兴GoldenDB" "goldendb" "" 2>/dev/null && { echo "$results" | grep -q "中兴GoldenDB" || results="${results}中兴GoldenDB|"$'\n'; }

    if command -v oxbase >/dev/null 2>&1 || command -v oceanbase >/dev/null 2>&1; then
        local ver=""
        command -v observer >/dev/null 2>&1 && ver=$(observer -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        results="${results}奥星贝斯|${ver}"$'\n'
    fi
    if [ -d /opt/oceanbase ] || [ -d /usr/local/oceanbase ]; then
        if ! echo "$results" | grep -q "奥星贝斯"; then
            results="${results}奥星贝斯|"$'\n'
        fi
    fi
    detect_db_service "奥星贝斯" "oceanbase\|observer" "" 2>/dev/null && { echo "$results" | grep -q "奥星贝斯" || results="${results}奥星贝斯|"$'\n'; }

    detect_db_service "TaurusDB" "taurusdb\|taurus" "" 2>/dev/null && results="${results}TaurusDB|"$'\n'
    if [ -d /opt/taurusdb ] || [ -d /opt/huawei/taurusdb ]; then
        if ! echo "$results" | grep -q "TaurusDB"; then
            results="${results}TaurusDB|"$'\n'
        fi
    fi

    results=$(echo "$results" | sed '/^$/d' | sort -u)

    if [ -z "$results" ]; then
        echo "不存在数据库"
    else
        echo "$results"
    fi
}

xml_escape() {
    local s="$1"
    s=$(echo "$s" | sed 's/&/\&amp;/g')
    s=$(echo "$s" | sed 's/</\&lt;/g')
    s=$(echo "$s" | sed 's/>/\&gt;/g')
    s=$(echo "$s" | sed 's/"/\&quot;/g')
    s=$(echo "$s" | sed "s/'/\&apos;/g")
    echo "$s"
}

echo "=========================================="
echo "  ${SCRIPT_NAME} v${SCRIPT_VERSION}"
echo "=========================================="
echo ""

OS_NAME=$(get_os_name)
OS_VERSION=$(get_os_version)
CPU_MODEL=$(get_cpu_model)
CPU_ARCH=$(get_cpu_arch)
CPU_CORES=$(get_cpu_cores)
KERNEL_VERSION=$(get_kernel_version)
DB_RESULT=$(detect_databases)

echo "[*] 系统名称:    ${OS_NAME}"
echo "[*] 系统版本:    ${OS_VERSION}"
echo "[*] 内核版本:    ${KERNEL_VERSION}"
echo "[*] CPU型号:     ${CPU_MODEL}"
echo "[*] CPU架构:     ${CPU_ARCH}"
echo "[*] CPU核心数:   ${CPU_CORES}"
echo "[*] 主机名:      ${HOSTNAME_VAL}"
echo "[*] IP地址:      ${IP_ADDR}"
echo "[*] 数据库:      ${DB_RESULT}"
echo "[*] 采集时间:    ${TIMESTAMP}"
echo ""

OUTPUT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_FILE="${OUTPUT_DIR}/sysinfo_${IP_ADDR}_${DATE_STR}.xml"

OS_NAME_E=$(xml_escape "$OS_NAME")
OS_VERSION_E=$(xml_escape "$OS_VERSION")
CPU_MODEL_E=$(xml_escape "$CPU_MODEL")
CPU_ARCH_E=$(xml_escape "$CPU_ARCH")
CPU_CORES_E=$(xml_escape "$CPU_CORES")
KERNEL_VERSION_E=$(xml_escape "$KERNEL_VERSION")
HOSTNAME_E=$(xml_escape "$HOSTNAME_VAL")
IP_ADDR_E=$(xml_escape "$IP_ADDR")
TIMESTAMP_E=$(xml_escape "$TIMESTAMP")

DB_XML="  <Database>不存在数据库</Database>"

if [ "$DB_RESULT" != "不存在数据库" ]; then
    DB_XML=""
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        db_name=$(echo "$line" | cut -d'|' -f1)
        db_ver=$(echo "$line" | cut -d'|' -f2)
        db_name_e=$(xml_escape "$db_name")
        db_ver_e=$(xml_escape "$db_ver")
        if [ -n "$db_ver_e" ]; then
            DB_XML="${DB_XML}  <Database><Name>${db_name_e}</Name><Version>${db_ver_e}</Version></Database>"$'\n'
        else
            DB_XML="${DB_XML}  <Database><Name>${db_name_e}</Name><Version/></Database>"$'\n'
        fi
    done <<< "$DB_RESULT"
    DB_XML=$(echo "$DB_XML" | sed '/^$/d')
fi

cat > "$OUTPUT_FILE" << XMLEOF
<?xml version="1.0" encoding="UTF-8"?>
<SystemInfo>
  <Hostname>${HOSTNAME_E}</Hostname>
  <IP>${IP_ADDR_E}</IP>
  <CollectTime>${TIMESTAMP_E}</CollectTime>
  <OS>
    <Name>${OS_NAME_E}</Name>
    <Version>${OS_VERSION_E}</Version>
    <Kernel>${KERNEL_VERSION_E}</Kernel>
  </OS>
  <CPU>
    <Model>${CPU_MODEL_E}</Model>
    <Architecture>${CPU_ARCH_E}</Architecture>
    <Cores>${CPU_CORES_E}</Cores>
  </CPU>
${DB_XML}
</SystemInfo>
XMLEOF

if [ -f "$OUTPUT_FILE" ]; then
    echo "[+] XML文件已生成: ${OUTPUT_FILE}"
else
    echo "[-] XML文件生成失败！"
    exit 1
fi

echo ""
echo "=========================================="
echo "  采集完成"
echo "=========================================="
