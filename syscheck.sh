#!/bin/bash

SCRIPT_NAME="系统信息采集脚本"
SCRIPT_VERSION="1.2.0"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
DATE_STR=$(date '+%Y%m%d')
HOSTNAME_VAL=$(hostname 2>/dev/null || echo "Unknown")

if [ "$(id -u)" = "0" ]; then
    IS_ROOT=1
else
    IS_ROOT=0
fi

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
        nkout=$(nkvers 2>/dev/null | sed 's/#//g')
        if echo "$nkout" | grep -qi "kylin\|麒麟"; then
            os_name=$(echo "$nkout" | grep -i "^Kylin Linux" | grep -vi "Version" | head -1 | awk '{print $1" "$2" "$3}')
            if [ -z "$os_name" ]; then
                os_name=$(echo "$nkout" | grep -i "release" | grep -vi "^$" | grep -vi "Version\|Kernel\|Build" | head -1 | awk '{print $1" "$2" "$3}')
            fi
            if [ -z "$os_name" ]; then
                os_name=$(echo "$nkout" | grep -i "Kylin" | grep -vi "Version\|Kernel\|Build" | head -1 | awk '{print $1" "$2" "$3}')
            fi
            [ -n "$os_name" ] && echo "$os_name" && return
        fi
    fi

    if [ -f /etc/kylin-release ]; then
        os_name=$(head -1 /etc/kylin-release | sed 's/#//g' | awk '{print $1" "$2" "$3}')
        [ -n "$os_name" ] && echo "$os_name" && return
    fi

    if [ -f /etc/neokylin-release ]; then
        os_name=$(head -1 /etc/neokylin-release | sed 's/#//g' | awk '{print $1" "$2" "$3}')
        [ -n "$os_name" ] && echo "$os_name" && return
    fi

    if [ -f /etc/uos-release ]; then
        os_name=$(grep "^NAME=" /etc/uos-release 2>/dev/null | head -1 | sed 's/NAME=//' | tr -d '"' | awk '{print $1" "$2}')
        if [ -z "$os_name" ]; then
            os_name=$(head -1 /etc/uos-release | awk '{print $1" "$2}')
        fi
        if [ -z "$os_name" ]; then
            os_name="统信UOS"
        fi
        [ -n "$os_name" ] && echo "$os_name" && return
    fi

    if [ -f /etc/deepin-release ] || [ -f /etc/deepin-version ]; then
        local is_uos=0
        if [ -f /etc/uos-release ]; then
            is_uos=1
        elif [ -f /etc/os-release ] && grep -qi "uos\|Uniontech" /etc/os-release 2>/dev/null; then
            is_uos=1
        fi
        if [ "$is_uos" = "0" ]; then
            local df="/etc/deepin-release"
            [ -f /etc/deepin-version ] && df="/etc/deepin-version"
            os_name=$(head -1 "$df" | awk '{print $1" "$2" "$3}')
            [ -n "$os_name" ] && echo "$os_name" && return
        fi
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
        nkout=$(nkvers 2>/dev/null | sed 's/#//g')
        if echo "$nkout" | grep -qi "kylin\|麒麟"; then
            os_version=$(echo "$nkout" | grep -i "^Kylin Linux" | grep -vi "Version" | head -1 | sed 's/.*[Rr]elease\s*//')
            if [ -z "$os_version" ]; then
                os_version=$(echo "$nkout" | grep -oE 'V[0-9]+(\.[0-9]+)*' | head -1)
            fi
            if [ -z "$os_version" ]; then
                os_version=$(echo "$nkout" | grep -i "Kernel" | head -1 | grep -oE '[0-9]+(\.[0-9]+)*' | head -1)
            fi
            [ -n "$os_version" ] && echo "$os_version" && return
        fi
    fi

    if [ -f /etc/kylin-release ]; then
        os_version=$(head -1 /etc/kylin-release | sed 's/#//g' | sed 's/.*release\s*//' | awk '{print $0}')
        if [ -z "$os_version" ]; then
            os_version=$(grep -oE '[0-9]+(\.[0-9]+)*' /etc/kylin-release | head -1)
        fi
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/neokylin-release ]; then
        os_version=$(head -1 /etc/neokylin-release | sed 's/#//g' | sed 's/.*release\s*//' | awk '{print $0}')
        if [ -z "$os_version" ]; then
            os_version=$(grep -oE '[0-9]+(\.[0-9]+)*' /etc/neokylin-release | head -1)
        fi
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/uos-release ]; then
        os_version=$(grep "^VERSION=" /etc/uos-release 2>/dev/null | head -1 | sed 's/VERSION=//' | tr -d '"')
        if [ -z "$os_version" ]; then
            os_version=$(grep "^VERSION_ID=" /etc/uos-release 2>/dev/null | head -1 | sed 's/VERSION_ID=//' | tr -d '"')
        fi
        if [ -z "$os_version" ]; then
            os_version=$(grep -oE '[0-9]+(\.[0-9]+)*' /etc/uos-release | head -1)
        fi
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/deepin-version ]; then
        if [ -f /etc/uos-release ]; then
            :
        elif [ -f /etc/os-release ] && grep -qi "uos\|Uniontech" /etc/os-release 2>/dev/null; then
            :
        else
            os_version=$(grep -i "version" /etc/deepin-version 2>/dev/null | head -1 | sed 's/.*[=:]\s*//' | tr -d '"' | awk '{print $1}')
            [ -n "$os_version" ] && echo "$os_version" && return
        fi
    fi

    if [ -f /etc/deepin-release ]; then
        if [ -f /etc/uos-release ]; then
            :
        elif [ -f /etc/os-release ] && grep -qi "uos\|Uniontech" /etc/os-release 2>/dev/null; then
            :
        else
            os_version=$(grep -oE '[0-9]+(\.[0-9]+)*' /etc/deepin-release | head -1)
            [ -n "$os_version" ] && echo "$os_version" && return
        fi
    fi

    if [ -f /etc/openEuler-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)*' /etc/openEuler-release | head -1)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/euleros-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)*' /etc/euleros-release | head -1)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/anolis-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)*' /etc/anolis-release | head -1)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/tencentos-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)*' /etc/tencentos-release | head -1)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/iSoft-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)*' /etc/iSoft-release | head -1)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/redflag-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)*' /etc/redflag-release | head -1)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/linx-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)*' /etc/linx-release | head -1)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/newstart-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)*' /etc/newstart-release | head -1)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/nfs-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)*' /etc/nfs-release | head -1)
        [ -n "$os_version" ] && echo "$os_version" && return
    fi

    if [ -f /etc/founder-release ]; then
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)*' /etc/founder-release | head -1)
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
        os_version=$(grep -oE '[0-9]+(\.[0-9]+)*' /etc/redhat-release | head -1)
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

    if command -v lscpu >/dev/null 2>&1; then
        cpu_model=$(lscpu 2>/dev/null | grep -m1 "Model name" | sed 's/Model name:\s*//')
        if [ -z "$cpu_model" ]; then
            cpu_model=$(lscpu 2>/dev/null | grep -m1 "Hypervisor vendor" | sed 's/Hypervisor vendor:\s*//')
        fi
    fi

    if [ -f /proc/cpuinfo ]; then
        local proc_cpu
        proc_cpu=$(grep -m1 "model name" /proc/cpuinfo 2>/dev/null | sed 's/model name\s*:\s*//')
        if [ -z "$proc_cpu" ]; then
            proc_cpu=$(grep -m1 "^Model\s*:" /proc/cpuinfo 2>/dev/null | sed 's/Model\s*:\s*//')
        fi
        if [ -z "$proc_cpu" ]; then
            proc_cpu=$(grep -m1 "Hardware" /proc/cpuinfo 2>/dev/null | sed 's/Hardware\s*:\s*//')
        fi
        if [ -z "$proc_cpu" ]; then
            proc_cpu=$(grep -m1 "cpu model" /proc/cpuinfo 2>/dev/null | sed 's/cpu model\s*:\s*//')
        fi
        if [ -z "$proc_cpu" ]; then
            proc_cpu=$(grep -m1 "^cpu\s*:" /proc/cpuinfo 2>/dev/null | sed 's/^cpu\s*:\s*//')
        fi
        if [ -z "$proc_cpu" ]; then
            proc_cpu=$(grep -m1 "cpu part" /proc/cpuinfo 2>/dev/null | sed 's/cpu part\s*:\s*//')
        fi
        if echo "$cpu_model" | grep -qi "bios\|virt\|qemu\|bochs"; then
            cpu_model=""
        fi
        if [ -z "$cpu_model" ] && [ -n "$proc_cpu" ]; then
            if echo "$proc_cpu" | grep -qi "bios\|virt\|qemu\|bochs"; then
                :
            else
                cpu_model="$proc_cpu"
            fi
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

check_dual_boot() {
    local result="否"
    local found_os=""

    if [ -f /boot/grub2/grub.cfg ]; then
        local grub_out
        grub_out=$(grep -i "menuentry\|windows" /boot/grub2/grub.cfg 2>/dev/null)
        if echo "$grub_out" | grep -qi "windows"; then
            result="是"
            found_os="Windows"
        fi
    fi

    if [ "$result" = "否" ] && [ -f /boot/grub/grub.cfg ]; then
        local grub_out
        grub_out=$(grep -i "menuentry\|windows" /boot/grub/grub.cfg 2>/dev/null)
        if echo "$grub_out" | grep -qi "windows"; then
            result="是"
            found_os="Windows"
        fi
    fi

    if [ "$result" = "否" ] && [ -f /boot/efi/EFI ]; then
        local efi_out
        efi_out=$(ls /boot/efi/EFI/ 2>/dev/null)
        if echo "$efi_out" | grep -qi "windows\|Microsoft"; then
            result="是"
            found_os="Windows"
        fi
    fi

    if [ "$result" = "否" ] && [ -d /sys/firmware/efi ]; then
        for d in /boot/efi/EFI/*/; do
            if [ -d "$d" ]; then
                local dirname
                dirname=$(basename "$d")
                case "$dirname" in
                    microsoft|Microsoft|Windows|windows)
                        result="是"
                        found_os="Windows"
                        break
                        ;;
                    BOOT|boot|kylin|Kylin|uos|UOS|deepin|Deepin|openEuler|hce|HCE|centos|ubuntu|fedora|HISI|hisi|tools|diags|diag|resource|RESERVE|reserve|shell|SHELL|tool|tools|fw|FW)
                        ;;
                    *)
                        if [ "$result" = "否" ]; then
                            result="是"
                            found_os="$dirname"
                        fi
                        ;;
                esac
            fi
        done
    fi

    if [ "$result" = "否" ]; then
        if [ "$IS_ROOT" = "1" ] && command -v efibootmgr >/dev/null 2>&1; then
            local efi_boot
            efi_boot=$(efibootmgr 2>/dev/null)
            if echo "$efi_boot" | grep -qi "windows\|microsoft"; then
                result="是"
                found_os="Windows"
            elif echo "$efi_boot" | grep -qi "BootOrder"; then
                local other_boot
                other_boot=$(echo "$efi_boot" | grep "^Boot[0-9]" | grep -vi "kylin\|linux\|deepin\|uos\|openeuler\|euler\|hce\|centos\|ubuntu\|fedora\|shell\|bootmanagermenu\|byouiapp\|boot manager\|consolidated boot\|fdi\|diagnostic\|bios\|setup\|systemreset\|recovery\|backup\|ip4\|ip6\|pxe\|network\|usb\|cdrom\|card\|nvme\|sata\|ahci\|raid\|ieee" | head -1)
                if [ -n "$other_boot" ]; then
                    result="是"
                    found_os=$(echo "$other_boot" | sed 's/^Boot[0-9]\+\**\s*//')
                fi
            fi
        fi
    fi

    if [ "$result" = "否" ] && [ "$IS_ROOT" = "1" ] && [ -f /etc/grub.d/30_os-prober ]; then
        if [ -x /usr/bin/os-prober ] || [ -x /sbin/os-prober ]; then
            local prober_out
            prober_out=$(os-prober 2>/dev/null)
            if [ -n "$prober_out" ]; then
                result="是"
                found_os=$(echo "$prober_out" | head -1 | cut -d: -f2 | sed 's/,.*//')
            fi
        fi
    fi

    if [ "$result" = "否" ] && command -v blkid >/dev/null 2>&1; then
        local ntfs_parts
        ntfs_parts=$(blkid 2>/dev/null | grep -i "ntfs\|microsoft\|windows" | head -1)
        if [ -n "$ntfs_parts" ]; then
            result="是"
            found_os="Windows(NTFS分区)"
        fi
    fi

    if [ -n "$found_os" ]; then
        echo "${result}|${found_os}"
    else
        echo "${result}|"
    fi
}

get_machine_vendor() {
    local vendor=""

    if [ -f /sys/devices/virtual/dmi/id/sys_vendor ]; then
        vendor=$(cat /sys/devices/virtual/dmi/id/sys_vendor 2>/dev/null | head -1)
    fi

    if [ -z "$vendor" ] && [ -f /sys/devices/virtual/dmi/id/board_vendor ]; then
        vendor=$(cat /sys/devices/virtual/dmi/id/board_vendor 2>/dev/null | head -1)
    fi

    if [ -z "$vendor" ] && [ -f /sys/devices/virtual/dmi/id/chassis_vendor ]; then
        vendor=$(cat /sys/devices/virtual/dmi/id/chassis_vendor 2>/dev/null | head -1)
    fi

    if [ -z "$vendor" ] && [ "$IS_ROOT" = "1" ] && command -v dmidecode >/dev/null 2>&1; then
        vendor=$(dmidecode -s system-manufacturer 2>/dev/null | head -1)
    fi

    if [ -z "$vendor" ] && [ -f /sys/devices/virtual/dmi/id/product_name ]; then
        local product
        product=$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null)
        if echo "$product" | grep -qi "lenovo\|thinkpad\|ideapad\|legion"; then
            vendor="Lenovo"
        elif echo "$product" | grep -qi "huawei\|matebook"; then
            vendor="Huawei"
        elif echo "$product" | grep -qi "dell\|inspiron\|latitude\|optiplex\|poweredge"; then
            vendor="Dell"
        elif echo "$product" | grep -qi "hp\|probook\|elitebook\|prodesk"; then
            vendor="HP"
        elif echo "$product" | grep -qi "asus\|rog\|zenbook"; then
            vendor="ASUS"
        elif echo "$product" | grep -qi "acer\|swift\|predator"; then
            vendor="Acer"
        elif echo "$product" | grep -qi "hasee"; then
            vendor="Hasee"
        elif echo "$product" | grep -qi "thinkvision"; then
            vendor="Lenovo"
        fi
    fi

    if [ -n "$vendor" ]; then
        case "$vendor" in
            "LENOVO"|"Lenovo"|"lenovo")
                vendor="联想";;
            "HUAWEI"|"Huawei"|"huawei")
                vendor="华为";;
            "DELL"|"Dell"|"dell")
                vendor="戴尔";;
            "HP"|"Hewlett-Packard"|"Hewlett Packard")
                vendor="惠普";;
            "ASUS"|"Asus"|"asus"|"ASUSTeK COMPUTER INC."|"ASUSTeK")
                vendor="华硕";;
            "ACER"|"Acer"|"acer")
                vendor="宏碁";;
            "Hasee"|"hasee"|"HASEE")
                vendor="神舟";;
            "Inspur"|"inspur"|"INSPUR")
                vendor="浪潮";;
            "Lenovo"|"lenovo"|"LENOVO")
                vendor="联想";;
            "Sugon"|"sugon"|"SUGON")
                vendor="曙光";;
            "Great Wall"|"GREAT WALL"|"GreatWall"|"greatwall")
                vendor="长城";;
            "PowerLeader"|"powerleader"|"POWERLEADER")
                vendor="宝德";;
            "UniCloud"|"unicloud"|"UNICLOUD")
                vendor="紫光";;
            "H3C"|"h3c"|"H3C")
                vendor="新华三";;
            "ZTE"|"zte"|"ZTE Corporation")
                vendor="中兴";;
            "Fujitsu"|"fujitsu"|"FUJITSU")
                vendor="富士通";;
            "Samsung"|"samsung"|"SAMSUNG")
                vendor="三星";;
            "Tongfang"|"tongfang"|"TONGFANG"|"Tsinghua Tongfang")
                vendor="清华同方";;
            "Haier"|"haier"|"HAIER")
                vendor="海尔";;
        esac
    fi

    echo "${vendor:-Unknown}"
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
            ver=$(eval "$ver_cmd" 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)*' | head -1)
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
        if [ "$IS_ROOT" = "1" ]; then
            if systemctl list-units --type=service --all 2>/dev/null | grep -qi "$svc_pattern"; then
                local ver=""
                if [ -n "$ver_cmd" ]; then
                    ver=$(eval "$ver_cmd" 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)*' | head -1)
                fi
                db_add "$db_name" "$ver"
                return
            fi
        else
            if systemctl list-unit-files --type=service 2>/dev/null | grep -qi "$svc_pattern"; then
                local ver=""
                if [ -n "$ver_cmd" ]; then
                    ver=$(eval "$ver_cmd" 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)*' | head -1)
                fi
                db_add "$db_name" "$ver"
                return
            fi
        fi
    fi

    if command -v service >/dev/null 2>&1; then
        if service --status-all 2>/dev/null | grep -qi "$svc_pattern"; then
            local ver=""
            if [ -n "$ver_cmd" ]; then
                ver=$(eval "$ver_cmd" 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)*' | head -1)
            fi
            db_add "$db_name" "$ver"
            return
        fi
    fi

    for f in /etc/init.d/*"${svc_pattern}"*; do
        if [ -f "$f" ]; then
            local ver=""
            if [ -n "$ver_cmd" ]; then
                ver=$(eval "$ver_cmd" 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)*' | head -1)
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
            if netstat -tln 2>/dev/null | grep -q ":${port} "; then
                db_add "$db_name" ""
            fi
        fi
    fi
}

db_check_docker() {
    local db_name="$1"
    local image_keywords="$2"

    if ! command -v docker >/dev/null 2>&1; then
        return
    fi

    local docker_out
    docker_out=$(docker ps --format '{{.Image}} {{.Names}}' 2>/dev/null)
    if [ -z "$docker_out" ]; then
        return
    fi

    for kw in $image_keywords; do
        if echo "$docker_out" | grep -qi "$kw"; then
            local ver=""
            local container_id
            container_id=$(docker ps --filter "ancestor=$kw" --format '{{.ID}}' 2>/dev/null | head -1)
            if [ -z "$container_id" ]; then
                container_id=$(docker ps --format '{{.ID}} {{.Image}} {{.Names}}' 2>/dev/null | grep -i "$kw" | head -1 | awk '{print $1}')
            fi
            if [ -n "$container_id" ]; then
                local img
                img=$(docker inspect --format '{{.Config.Image}}' "$container_id" 2>/dev/null)
                ver=$(echo "$img" | grep -oE '[0-9]+(\.[0-9]+)*' | head -1)
                if [ -z "$ver" ]; then
                    ver=$(docker inspect --format '{{range .Config.Env}}{{println .}}{{end}}' "$container_id" 2>/dev/null | grep -iE 'VERSION|VER' | head -1 | grep -oE '[0-9]+(\.[0-9]+)*' | head -1)
                fi
            fi
            db_add "$db_name" "$ver"
            return
        fi
    done
}

detect_databases() {
    _DB_RESULTS=""
    _DB_FOUND=""

    db_check_cmd "达梦" "dmserver" "dmserver -V"
    db_check_cmd "达梦" "disql" "disql -V"
    db_check_dir "达梦" "/opt/dmdbms /dmdbms /opt/dameng"
    for d in /opt/dmdbms/bin /dmdbms/bin; do
        if [ -d "$d" ] && [ -f "$d/dmserver" ]; then
            local ver=$("$d/dmserver" -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)*' | head -1)
            if [ -n "$ver" ] && ! echo "$_DB_FOUND" | grep -qx "达梦"; then
                db_add "达梦" "$ver"
            fi
            break
        fi
    done
    db_check_service "达梦" "dmserver" ""
    db_check_process "达梦" "dmserver"
    db_check_docker "达梦" "dmdb\|dameng\|dm8"

    db_check_cmd "金仓" "kingbase" "kingbase -V"
    db_check_cmd "金仓" "ksql" "ksql -V"
    db_check_cmd "金仓" "sys_ctl" "sys_ctl -V"
    db_check_dir "金仓" "/opt/Kingbase /opt/kingbase /usr/local/kingbase"
    for d in /opt/Kingbase/ES/V8/Install/bin /opt/kingbase/bin; do
        if [ -d "$d" ] && [ -f "$d/kingbase" ]; then
            local ver=$("$d/kingbase" -V 2>/dev/null | head -1 | grep -oE '[0-9]+(\.[0-9]+)*' | head -1)
            if [ -n "$ver" ] && ! echo "$_DB_FOUND" | grep -qx "金仓"; then
                db_add "金仓" "$ver"
            fi
            break
        fi
    done
    db_check_service "金仓" "kingbase" ""
    db_check_process "金仓" "kingbase"
    db_check_docker "金仓" "kingbase\|kingbasev8r6\|kingbase8"

    db_check_cmd "神舟通用" "osdb" "osdb -V"
    db_check_cmd "神舟通用" "osci" ""
    db_check_dir "神舟通用" "/opt/ShenTong /opt/shentong /usr/local/shentong"
    db_check_service "神舟通用" "shentong" ""
    db_check_process "神舟通用" "oscar\|osdb"
    db_check_docker "神舟通用" "shentong\|oscar"

    db_check_cmd "瀚高" "hgdb" "hgdb -V"
    db_check_cmd "瀚高" "hgdb-admin" ""
    db_check_dir "瀚高" "/opt/highgo /usr/local/highgo"
    db_check_service "瀚高" "highgo" ""
    db_check_process "瀚高" "hgdb\|highgo"
    db_check_docker "瀚高" "highgo\|hgdb"

    db_check_cmd "南大通用" "gbase" "gbase -V"
    db_check_cmd "南大通用" "gbasedbt" "gbasedbt -V"
    db_check_dir "南大通用" "/opt/gbase /usr/local/gbase"
    db_check_service "南大通用" "gbase" ""
    db_check_process "南大通用" "gbase\|gbasedbt"
    db_check_docker "南大通用" "gbase\|gbasedbt"

    db_check_cmd "优炫" "uxsql" "uxsql -V"
    db_check_cmd "优炫" "uxdb" "uxdb -V"
    db_check_dir "优炫" "/opt/uxdb /usr/local/uxdb"
    db_check_service "优炫" "uxdb" ""
    db_check_process "优炫" "uxdb"
    db_check_docker "优炫" "uxdb"

    db_check_cmd "海量" "vastbase" "vastbase -V"
    db_check_cmd "海量" "vds_cli" ""
    db_check_dir "海量" "/opt/vastbase /opt/hailiang"
    db_check_service "海量" "vastbase" ""
    db_check_process "海量" "vastbase\|vds"
    db_check_docker "海量" "vastbase"

    db_check_cmd "阿里PolarDB" "polardb" "polardb -V"
    db_check_dir "阿里PolarDB" "/opt/polardb /usr/local/polardb"
    db_check_service "阿里PolarDB" "polardb" ""
    db_check_process "阿里PolarDB" "polardb"
    db_check_docker "阿里PolarDB" "polardb\|polardbx"
    if command -v psql >/dev/null 2>&1; then
        local psql_out
        psql_out=$(psql --version 2>/dev/null | head -1)
        if echo "$psql_out" | grep -qi "polardb"; then
            local ver
            ver=$(echo "$psql_out" | grep -oE '[0-9]+(\.[0-9]+)*' | head -1)
            db_add "阿里PolarDB" "$ver"
        fi
    fi

    db_check_cmd "腾讯TDSQL" "tdsql" "tdsql -V"
    db_check_dir "腾讯TDSQL" "/opt/tdsql /usr/local/tdsql"
    db_check_service "腾讯TDSQL" "tdsql" ""
    db_check_process "腾讯TDSQL" "tdsql"
    db_check_docker "腾讯TDSQL" "tdsql\|tencentcloud\|tdsqlhack"

    db_check_cmd "虚谷" "xugusql" "xugusql -V"
    db_check_cmd "虚谷" "xugu" ""
    db_check_dir "虚谷" "/opt/xugu /usr/local/xugu"
    db_check_service "虚谷" "xugu" ""
    db_check_process "虚谷" "xugu"
    db_check_docker "虚谷" "xugu"

    db_check_cmd "东方金信" "xdb" "xdb -V"
    db_check_cmd "东方金信" "jxdb" ""
    db_check_dir "东方金信" "/opt/jxserver /opt/dongfang"
    db_check_service "东方金信" "jxserver" ""
    db_check_process "东方金信" "jxdb"
    db_check_docker "东方金信" "jxserver\|dongfang"

    db_check_cmd "万里开源" "greatsql" "greatsql -V"
    db_check_cmd "万里开源" "greatdb" "greatdb -V"
    db_check_dir "万里开源" "/opt/greatdb /opt/greatsql"
    db_check_service "万里开源" "greatdb" ""
    db_check_process "万里开源" "greatsql\|greatdb"
    db_check_docker "万里开源" "greatsql\|greatdb"

    db_check_cmd "华为GaussDB" "gaussdb" "gaussdb -V"
    db_check_cmd "华为GaussDB" "gs_ctl" "gs_ctl -V"
    db_check_dir "华为GaussDB" "/opt/gaussdb /opt/huawei/gaussdb /var/lib/gaussdb"
    db_check_service "华为GaussDB" "gaussdb" "gaussdb -V"
    db_check_process "华为GaussDB" "gaussdb\|gs_ctl"
    db_check_docker "华为GaussDB" "gaussdb\|opengauss\|gaussdb-k8s"

    db_check_cmd "平凯" "tidb" "tidb -V"
    db_check_cmd "平凯" "pingcap" ""
    db_check_dir "平凯" "/opt/tidb /opt/pingcap"
    db_check_service "平凯" "tidb" "tidb -V"
    db_check_process "平凯" "tidb"
    db_check_docker "平凯" "tidb\|pingcap\|tikv\|pd"

    db_check_cmd "中兴GoldenDB" "goldendb" "goldendb -V"
    db_check_dir "中兴GoldenDB" "/opt/goldendb /opt/zte/goldendb"
    db_check_service "中兴GoldenDB" "goldendb" ""
    db_check_process "中兴GoldenDB" "goldendb"
    db_check_docker "中兴GoldenDB" "goldendb\|zte"

    db_check_cmd "奥星贝斯" "observer" "observer -V"
    db_check_dir "奥星贝斯" "/opt/oceanbase /usr/local/oceanbase"
    db_check_service "奥星贝斯" "oceanbase\|observer" ""
    db_check_process "奥星贝斯" "observer\|oceanbase"
    db_check_port "奥星贝斯" "2881"
    db_check_docker "奥星贝斯" "oceanbase\|observer"

    db_check_dir "TaurusDB" "/opt/taurusdb /opt/huawei/taurusdb"
    db_check_service "TaurusDB" "taurusdb" ""
    db_check_process "TaurusDB" "taurusdb"
    db_check_docker "TaurusDB" "taurusdb\|taurus"

    db_check_cmd "MySQL" "mysql" "mysql --version"
    db_check_cmd "MySQL" "mysqld" "mysqld --version"
    db_check_service "MySQL" "mysql\|mysqld\|mariadb" ""
    db_check_process "MySQL" "mysqld\|mariadbd"
    db_check_port "MySQL" "3306"
    db_check_docker "MySQL" "mysql\|mariadb\|percona"
    if [ -d /var/lib/mysql ] || [ -d /var/lib/mysql/data ]; then
        db_add "MySQL" ""
    fi

    db_check_cmd "PostgreSQL" "psql" "psql --version"
    db_check_cmd "PostgreSQL" "postgres" "postgres --version"
    db_check_service "PostgreSQL" "postgresql\|postgres" ""
    db_check_process "PostgreSQL" "postgres"
    db_check_port "PostgreSQL" "5432"
    db_check_docker "PostgreSQL" "postgres\|postgresql"
    if [ -d /var/lib/pgsql ] || [ -d /var/lib/postgresql ]; then
        db_add "PostgreSQL" ""
    fi

    db_check_cmd "MariaDB" "mariadb" "mariadb --version"
    db_check_cmd "MariaDB" "mariadbd" "mariadbd --version"
    db_check_service "MariaDB" "mariadb" ""
    db_check_process "MariaDB" "mariadbd"
    db_check_port "MariaDB" "3307"
    db_check_docker "MariaDB" "mariadb"

    db_check_cmd "Oracle" "sqlplus" "sqlplus -V"
    db_check_dir "Oracle" "/opt/oracle /u01/app/oracle /u01/app/oracle/product"
    db_check_service "Oracle" "oracle\|oradb" ""
    db_check_process "Oracle" "ora_pmon\|oracle"
    db_check_port "Oracle" "1521"
    db_check_docker "Oracle" "oracle\|oraclelinux\|oradb"

    db_check_cmd "Redis" "redis-server" "redis-server --version"
    db_check_cmd "Redis" "redis-cli" "redis-cli --version"
    db_check_service "Redis" "redis" ""
    db_check_process "Redis" "redis-server"
    db_check_port "Redis" "6379"
    db_check_docker "Redis" "redis"

    db_check_cmd "MongoDB" "mongod" "mongod --version"
    db_check_cmd "MongoDB" "mongo" "mongo --version"
    db_check_service "MongoDB" "mongod\|mongodb" ""
    db_check_process "MongoDB" "mongod"
    db_check_port "MongoDB" "27017"
    db_check_docker "MongoDB" "mongo\|mongodb"

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
DUAL_BOOT=$(check_dual_boot)
MACHINE_VENDOR=$(get_machine_vendor)
DB_RESULT=$(detect_databases)

if [ "$IS_ROOT" = "0" ]; then
    echo "[!] 当前非root权限运行，部分检测项可能不完整（如efibootmgr、dmidecode、os-prober）"
fi

echo "[*] 系统名称:    ${OS_NAME}"
echo "[*] 系统版本:    ${OS_VERSION}"
echo "[*] 内核版本:    ${KERNEL_VERSION}"
echo "[*] CPU型号:     ${CPU_MODEL}"
echo "[*] CPU架构:     ${CPU_ARCH}"
echo "[*] CPU核心数:   ${CPU_CORES}"
echo "[*] 主机名:      ${HOSTNAME_VAL}"
echo "[*] IP地址:      ${IP_ADDR}"
echo "[*] 数据库:      ${DB_RESULT}"
echo "[*] 双系统:      ${DUAL_BOOT}"
echo "[*] 机器品牌:    ${MACHINE_VENDOR}"
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

DUAL_BOOT_FLAG=$(echo "$DUAL_BOOT" | cut -d'|' -f1)
DUAL_BOOT_OS=$(echo "$DUAL_BOOT" | cut -d'|' -f2)
DUAL_BOOT_FLAG_E=$(xml_escape "$DUAL_BOOT_FLAG")
DUAL_BOOT_OS_E=$(xml_escape "$DUAL_BOOT_OS")
MACHINE_VENDOR_E=$(xml_escape "$MACHINE_VENDOR")

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
  <DualBoot>
    <Flag>${DUAL_BOOT_FLAG_E}</Flag>
    <OS>${DUAL_BOOT_OS_E}</OS>
  </DualBoot>
  <MachineVendor>${MACHINE_VENDOR_E}</MachineVendor>
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
