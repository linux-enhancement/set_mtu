# set_mtu
a bash script to set mtu in linux Server

## Usage
```bash
$ bash set_mtu.sh help
Usage:
  set_mtu.sh <action> <interface> <mtu>
  action: set|status
Example:
  bash set_mtu.sh set <eth0> <1600>
  bash set_mtu.sh status <eth0>   
```

## Check MTU Status
```bash
$ bash set_mtu.sh status
Interface MTU status:
lo: 65536
eth0: 1500

# Check specific MTU status
$ bash set_mtu.sh status eth0
Interface MTU status:
eth0: 1500  
```

## Set MTU
```bash
$  bash set_mtu.sh set eth0 1600
Interface eth0 exists.
MTU 1600 is a number.
[1/2] Start to set MTU of eth0 to 1600 temporarily -- Done.
Set MTU of eth0 to 1600 temporarily Successfully.
[2/2] Start to set MTU of eth0 to 1600 permanently.
[2.1] Setting MTU of eth0 to 1600 permanently in DHCP -- Done.
Set MTU of eth0 in DHCP to 1600 permanently Successfully.
[2.2] Setting MTU of eth0 to 1600 permanently in config file -- Done.
Set MTU of eth0 in config file to 1600 permanently Successfully.

# ignore when related setting is configured. 
$ bash set_mtu.sh set eth0 1600
Interface eth0 exists.
MTU 1600 is a number.
[1/2] Start to set MTU of eth0 to 1600 temporarily -- Skipped.
MTU of eth0 has already been set to 1600 temporarily.
[2/2] Start to set MTU of eth0 to 1600 permanently.
[2.1] Setting MTU of eth0 to 1600 permanently in DHCP -- Skipped.
MTU of eth0 in DHCP has been set to 1600 permanently.
[2.2] Setting MTU of eth0 to 1600 permanently in config file -- Skipped.
MTU of eth0 in config file has been set to 1600 permanently.

# You can use this command to configure MTU even some files are changed manually
$ cat /etc/sysconfig/network-scripts/ifcfg-eth0
BOOTPROTO=dhcp
DEVICE=eth0
HWADDR=fa:16:3e:4e:41:ae
ONBOOT=yes
STARTMODE=auto
TYPE=Ethernet
USERCTL=no

$ bash set_mtu.sh set eth0 1600
Interface eth0 exists.
MTU 1600 is a number.
[1/2] Start to set MTU of eth0 to 1600 temporarily -- Skipped.
MTU of eth0 has already been set to 1600 temporarily.
[2/2] Start to set MTU of eth0 to 1600 permanently.
[2.1] Setting MTU of eth0 to 1600 permanently in DHCP -- Skipped.
MTU of eth0 in DHCP has been set to 1600 permanently.
[2.2] Setting MTU of eth0 to 1600 permanently in config file -- Done.
Set MTU of eth0 in config file to 1600 permanently Successfully.

$ cat /etc/sysconfig/network-scripts/ifcfg-eth0
# Created by cloud-init on instance boot automatically, do not edit.
#
BOOTPROTO=dhcp
DEVICE=eth0
HWADDR=fa:16:3e:4e:41:ae
ONBOOT=yes
STARTMODE=auto
TYPE=Ethernet
USERCTL=no
MTU=1600   
```

## Test Cases
- Validation check about mtu type and range
- Interface existing check
- Interface config file existing check. e.g /etc/sysconfig/network-scripts/ifcfg-eth0
- DHCP config file existing check. e.g /etc/dhcp/dhclient-eth0.conf
- set_mtu_temporary function. e.g ip link set dev eth0 mtu 1500
- set_mtu_permanent_in_dhcp
- set_mtu_permanent_in_config_file
- configuration persists after the VM reboots
- test in OpenStack
- test in AWS

## Support
Any questions please reach out to <liozza@163.com> or create an issue directly.