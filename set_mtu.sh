#!/usr/bin/env bash

function help() {
    echo "Usage:"
    echo "  set_mtu.sh <action> <interface> <mtu>"
    echo "  action: set|status"
    echo "Example:"
    echo "  bash $0 set <eth0> <1600>"
    echo "  bash $0 status <eth0>"
    exit 0
}
function set_mtu() {
    ################################################################
    ## Set MTU of the specified interface to the specified value. ##
    ################################################################
    local interface=${1:-eth0}
    local mtu=${2:-1500}
    local interface_dhcp_file="/etc/dhcp/dhclient-${interface}.conf"
    local interface_dhcp_file_tmp="${interface_dhcp_file}.tmp"
    local interface_config_file="/etc/sysconfig/network-scripts/ifcfg-${interface}"

    validation_check $@
    set_mtu_temporary $@
    set_mtu_permanent $@

}

function set_mtu_temporary() {
    echo -n "[1/2] Start to set MTU of ${interface} to ${mtu} temporarily -- "

    if ip link show ${interface} | grep -i "mtu ${mtu}" > /dev/null 2>&1; then
        echo "Skipped."
        echo "MTU of ${interface} has already been set to ${mtu} temporarily."
        return
    fi

    ip link set dev ${interface} mtu ${mtu}
    if ip link show ${interface} | grep -i "mtu ${mtu}" > /dev/null 2>&1; then
        echo "Done."
        echo "Set MTU of ${interface} to ${mtu} temporarily Successfully."
    else
        echo "Failed."
        echo "Failed to set MTU of ${interface} to ${mtu} temporarily"
    fi
}

function set_mtu_permanent() {
    echo "[2/2] Start to set MTU of ${interface} to ${mtu} permanently."

    echo -n "[2.1] Setting MTU of ${interface} to ${mtu} permanently in DHCP -- "
    set_met_permanent_in_dhcp

    echo -n "[2.2] Setting MTU of ${interface} to ${mtu} permanently in config file -- "
    set_net_permanent_in_config_file

}

function set_met_permanent_in_dhcp() {
    cat << EOF > ${interface_dhcp_file_tmp}
interface "${interface}" {
supersede interface-mtu ${mtu};
}
EOF

    if [ -f ${interface_dhcp_file} ]; then
        if diff ${interface_dhcp_file} ${interface_dhcp_file_tmp} > /dev/null 2>&1; then
            echo "Skipped."
            echo "MTU of ${interface} in DHCP has been set to ${mtu} permanently."
            rm -f ${interface_dhcp_file_tmp}
            return
        fi
    fi

    mv ${interface_dhcp_file_tmp} ${interface_dhcp_file}
    echo "Done."
    echo "Set MTU of ${interface} in DHCP to ${mtu} permanently Successfully."
}

function set_net_permanent_in_config_file() {
    if grep -i "MTU=${mtu}" ${interface_config_file} > /dev/null 2>&1; then
        echo "Skipped."
        echo "MTU of ${interface} in config file has been set to ${mtu} permanently."
    else
        if grep -i "MTU=" ${interface_config_file} > /dev/null 2>&1; then
            sed -i "s/MTU=.*/MTU=${mtu}/g" ${interface_config_file}
        else
            echo "MTU=${mtu}" >> ${interface_config_file}
        fi
        echo "Done."
        echo "Set MTU of ${interface} in config file to ${mtu} permanently Successfully."
    fi
}
function validation_check() {
    # Check if the interface exists.
    if ip link show ${interface} > /dev/null 2>&1; then
        echo "Interface ${interface} exists."
    else
        echo "Interface ${interface} does not exist."
        exit 1
    fi

    if [[ ${mtu} =~ ^[0-9]+$ ]]; then
        echo "MTU ${mtu} is a number."
    else
        echo "MTU ${mtu} is not a number."
        exit 1
    fi

    if [[ ${mtu} -lt 68 || ${mtu} -gt 65535 ]]; then
        echo "MTU ${mtu} is not in the range of 68 to 65535."
        exit 1
    fi

    if [[ ${mtu} -eq 1500 ]]; then
        echo "You're setting ${mtu} to a non-common value, please make sure you know what you're doing."
    fi

    if [[ ! -e ${interface_dhcp_file} ]]; then
        echo "Interface ${interface} does not have a DHCP config file, will create one following OS UMASK"
    fi

    if [[ ! -e ${interface_config_file} ]]; then
        echo "Interface ${interface} does not have a config file, ${interface_config_file} Not Found. Exiting."
        exit 1
    fi

}
function mtu_status() {
    local interface=${1}

    echo "Interface MTU status:"
    ip link show ${interface} | sed -n 's/[0-9]: \(.*:\).*mtu \([0-9]\+\).*/\1 \2/p'
}

action=${1:-help}

case ${action} in
set)
    shift 1
    set_mtu $@
  ;;
status)
    shift 1
    mtu_status $@
    ;;
*)
    help
  ;;
esac