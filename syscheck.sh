#!/bin/bash

SCRIPT_NAME="系统信息采集脚本"
SCRIPT_VERSION="1.2.0"
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

db_add() {
    local db_name="$1"
    local ver="$2"
    if echo "$_DB_FOUND" | grep -qx "$db_name"; then
        return
    fi
    if [ -n "$ver" ]; then
        _DB_RESULTS="${_DB_RESULTS}${db_name}|${ver}"$'\n'
    else
        _DB_RESULTS="${_DB_RESULTS}${db_name}|"$'\n'
    fi
    _DB_FOUND="${_DB_FOUND}${db_name}"$'\n'
}

db_check_cmd() {
    local db_name="$1"
    shift
    local cmd="$1"
    shift
    local ver_cmd="$*"

    if command -v "$cmd" >/dev/null 2>&1; then
        local ver=""
        if [ -n "$ver_cmd" ]; then
            ver=$(eval "$ver_cmd" 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
        fi
        db_add "$db_name" "$ver"
    fi
}

db_check_dir() {
    local db_name="$1"
    shift
    local dirs="$*"

    for d in $dirs; do
        if [ -d "$d" ]; then
            db_add "$db_name" ""
            return
        fi
    done
}

db_check_service() {
    local db_name="$1"
    local svc_pattern="$2"
    local ver_cmd="$3"

    if command -v systemctl >/dev/null 2>&1; then
        if systemctl list-units --type=service --all 2>/dev/null | grep -qi "$svc_pattern"; then
            local ver=""
            if [ -n "$ver_cmd" ]; then
                ver=$(eval "$ver_cmd" 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
            fi
            db_add "$db_name" "$ver"
            return
        fi
    fi

    if command -v service >/dev/null 2>&1; then
        if service --status-all 2>/dev/null | grep -qi "$svc_pattern"; then
            local ver=""
            if [ -n "$ver_cmd" ]; then
                ver=$(eval "$ver_cmd" 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
            fi
            db_add "$db_name" "$ver"
            return
        fi
    fi

    for f in /etc/init.d/*"${svc_pattern}"*; do
        if [ -f "$f" ]; then
            local ver=""
            if [ -n "$ver_cmd" ]; then
                ver=$(eval "$ver_cmd" 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
            fi
            db_add "$db_name" "$ver"
            return
        fi
    done
}

db_check_process() {
    local db_name="$1"
    local proc_pattern="$2"

    if ! echo "$_DB_FOUND" | grep -qx "$db_name"; then
        if ps -e -o comm= 2>/dev/null | grep -qi "$proc_pattern"; then
            db_add "$db_name" ""
            return
        fi
        if pgrep -l "$proc_pattern" >/dev/null 2>&1; then
            db_add "$db_name" ""
        fi
    fi
}

db_check_port() {
    local db_name="$1"
    local port="$2"

    if ! echo "$_DB_FOUND" | grep -qx "$db_name"; then
        if command -v ss >/dev/null 2>&1; then
            if ss -tlnp 2>/dev/null | grep -q ":${port} "; then
                db_add "$db_name" ""
                return
            fi
        fi
        if command -v netstat >/dev/null 2>&1; then
            if netstat -tlnp 2>/dev/null | grep -q ":${port} "; then
                db_add "$db_name" ""
            fi
        fi
    fi
}

detect_databases() {
    _DB_RESULTS=""
    _DB_FOUND=""

    db_check_cmd "达梦" "dmserver" "dmserver -V"
    db_check_cmd "达梦" "disql" "disql -V"
    db_check_dir "达梦" "/opt/dmdbms /dmdbms /opt/dameng"
    for d in /opt/dmdbms/bin /dmdbms/bin; do
        if [ -d "$d" ] && [ -f "$d/dmserver" ]; then
            local ver=$("$d/dmserver" -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
            if [ -n "$ver" ] && ! echo "$_DB_FOUND" | grep -qx "达梦"; then
                db_add "达梦" "$ver"
            fi
            break
        fi
    done
    db_check_service "达梦" "dmserver" ""
    db_check_process "达梦" "dmserver"

    db_check_cmd "金仓" "kingbase" "kingbase -V"
    db_check_cmd "金仓" "ksql" "ksql -V"
    db_check_cmd "金仓" "sys_ctl" "sys_ctl -V"
    db_check_dir "金仓" "/opt/Kingbase /opt/kingbase /usr/local/kingbase"
    for d in /opt/Kingbase/ES/V8/Install/bin /opt/kingbase/bin; do
        if [ -d "$d" ] && [ -f "$d/kingbase" ]; then
            local ver=$("$d/kingbase" -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
            if [ -n "$ver" ] && ! echo "$_DB_FOUND" | grep -qx "金仓"; then
                db_add "金仓" "$ver"
            fi
            break
        fi
    done
    db_check_service "金仓" "kingbase" ""
    db_check_process "金仓" "kingbase"

    db_check_cmd "神舟通用" "osdb" "osdb -V"
    db_check_cmd "神舟通用" "osci" ""
    db_check_dir "神舟通用" "/opt/ShenTong /opt/shentong /usr/local/shentong"
    db_check_service "神舟通用" "shentong" ""
    db_check_process "神舟通用" "oscar\|osdb"

    db_check_cmd "瀚高" "hgdb" "hgdb -V"
    db_check_cmd "瀚高" "hgdb-admin" ""
    db_check_dir "瀚高" "/opt/highgo /usr/local/highgo"
    db_check_service "瀚高" "highgo" ""
    db_check_process "瀚高" "hgdb\|highgo"

    db_check_cmd "南大通用" "gbase" "gbase -V"
    db_check_cmd "南大通用" "gbasedbt" "gbasedbt -V"
    db_check_dir "南大通用" "/opt/gbase /usr/local/gbase"
    db_check_service "南大通用" "gbase" ""
    db_check_process "南大通用" "gbase\|gbasedbt"

    db_check_cmd "优炫" "uxsql" "uxsql -V"
    db_check_cmd "优炫" "uxdb" "uxdb -V"
    db_check_dir "优炫" "/opt/uxdb /usr/local/uxdb"
    db_check_service "优炫" "uxdb" ""
    db_check_process "优炫" "uxdb"

    db_check_cmd "海量" "vastbase" "vastbase -V"
    db_check_cmd "海量" "vds_cli" ""
    db_check_dir "海量" "/opt/vastbase /opt/hailiang"
    db_check_service "海量" "vastbase" ""
    db_check_process "海量" "vastbase\|vds"

    db_check_cmd "阿里PolarDB" "polardb" "polardb -V"
    db_check_dir "阿里PolarDB" "/opt/polardb /usr/local/polardb"
    db_check_service "阿里PolarDB" "polardb" ""
    db_check_process "阿里PolarDB" "polardb"
    if command -v psql >/dev/null 2>&1; then
        local psql_out
        psql_out=$(psql --version 2>/dev/null | head -1)
        if echo "$psql_out" | grep -qi "polardb"; then
            local ver
            ver=$(echo "$psql_out" | grep -oE '[0-9]+(\.[0-9]+)+' | head -1)
            db_add "阿里PolarDB" "$ver"
        fi
    fi

    db_check_cmd "腾讯TDSQL" "tdsql" "tdsql -V"
    db_check_dir "腾讯TDSQL" "/opt/tdsql /usr/local/tdsql"
    db_check_service "腾讯TDSQL" "tdsql" ""
    db_check_process "腾讯TDSQL" "tdsql"

    db_check_cmd "虚谷" "xugusql" "xugusql -V"
    db_check_cmd "虚谷" "xugu" ""
    db_check_dir "虚谷" "/opt/xugu /usr/local/xugu"
    db_check_service "虚谷" "xugu" ""
    db_check_process "虚谷" "xugu"

    db_check_cmd "东方金信" "xdb" "xdb -V"
    db_check_cmd "东方金信" "jxdb" ""
    db_check_dir "东方金信" "/opt/jxserver /opt/dongfang"
    db_check_service "东方金信" "jxserver" ""
    db_check_process "东方金信" "jxdb"

    db_check_cmd "万里开源" "greatsql" "greatsql -V"
    db_check_cmd "万里开源" "greatdb" "greatdb -V"
    db_check_dir "万里开源" "/opt/greatdb /opt/greatsql"
    db_check_service "万里开源" "greatdb" ""
    db_check_process "万里开源" "greatsql\|greatdb"

    db_check_cmd "华为GaussDB" "gaussdb" "gaussdb -V"
    db_check_cmd "华为GaussDB" "gs_ctl" "gs_ctl -V"
    db_check_dir "华为GaussDB" "/opt/gaussdb /opt/huawei/gaussdb /var/lib/gaussdb"
    db_check_service "华为GaussDB" "gaussdb" "gaussdb -V"
    db_check_process "华为GaussDB" "gaussdb\|gs_ctl"

    db_check_cmd "平凯" "tidb" "tidb -V"
    db_check_cmd "平凯" "pingcap" ""
    db_check_dir "平凯" "/opt/tidb /opt/pingcap"
    db_check_service "平凯" "tidb" "tidb -V"
    db_check_process "平凯" "tidb"

    db_check_cmd "中兴GoldenDB" "goldendb" "goldendb -V"
    db_check_dir "中兴GoldenDB" "/opt/goldendb /opt/zte/goldendb"
    db_check_service "中兴GoldenDB" "goldendb" ""
    db_check_process "中兴GoldenDB" "goldendb"

    db_check_cmd "奥星贝斯" "observer" "observer -V"
    db_check_dir "奥星贝斯" "/opt/oceanbase /usr/local/oceanbase"
    db_check_service "奥星贝斯" "oceanbase\|observer" ""
    db_check_process "奥星贝斯" "observer\|oceanbase"
    db_check_port "奥星贝斯" "2881"

    db_check_dir "TaurusDB" "/opt/taurusdb /opt/huawei/taurusdb"
    db_check_service "TaurusDB" "taurusdb" ""
    db_check_process "TaurusDB" "taurusdb"

    db_check_cmd "MySQL" "mysql" "mysql --version"
    db_check_cmd "MySQL" "mysqld" "mysqld --version"
    db_check_service "MySQL" "mysql\|mysqld\|mariadb" ""
    db_check_process "MySQL" "mysqld\|mariadbd"
    db_check_port "MySQL" "3306"
    if [ -d /var/lib/mysql ] || [ -d /var/lib/mysql/data ]; then
        db_add "MySQL" ""
    fi

    db_check_cmd "PostgreSQL" "psql" "psql --version"
    db_check_cmd "PostgreSQL" "postgres" "postgres --version"
    db_check_service "PostgreSQL" "postgresql\|postgres" ""
    db_check_process "PostgreSQL" "postgres"
    db_check_port "PostgreSQL" "5432"
    if [ -d /var/lib/pgsql ] || [ -d /var/lib/postgresql ]; then
        db_add "PostgreSQL" ""
    fi

    db_check_cmd "MariaDB" "mariadb" "mariadb --version"
    db_check_cmd "MariaDB" "mariadbd" "mariadbd --version"
    db_check_service "MariaDB" "mariadb" ""
    db_check_process "MariaDB" "mariadbd"
    db_check_port "MariaDB" "3307"

    db_check_cmd "Oracle" "sqlplus" "sqlplus -V"
    db_check_dir "Oracle" "/opt/oracle /u01/app/oracle /u01/app/oracle/product"
    db_check_service "Oracle" "oracle\|oradb" ""
    db_check_process "Oracle" "ora_pmon\|oracle"
    db_check_port "Oracle" "1521"

    db_check_cmd "Redis" "redis-server" "redis-server --version"
    db_check_cmd "Redis" "redis-cli" "redis-cli --version"
    db_check_service "Redis" "redis" ""
    db_check_process "Redis" "redis-server"
    db_check_port "Redis" "6379"

    db_check_cmd "MongoDB" "mongod" "mongod --version"
    db_check_cmd "MongoDB" "mongo" "mongo --version"
    db_check_service "MongoDB" "mongod\|mongodb" ""
    db_check_process "MongoDB" "mongod"
    db_check_port "MongoDB" "27017"

    _DB_RESULTS=$(echo "$_DB_RESULTS" | sed '/^$/d' | sort -u)

    if [ -z "$_DB_RESULTS" ]; then
        echo "不存在数据库"
    else
        echo "$_DB_RESULTS"
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
