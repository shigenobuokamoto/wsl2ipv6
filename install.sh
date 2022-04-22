#! /bin/sh
ALPINE_MINIROOT=https://dl-cdn.alpinelinux.org/alpine/v3.14/releases/x86_64/alpine-minirootfs-3.14.6-x86_64.tar.gz
DISTRO_NAME=IPv6
DISTRO_EXEC="wsl.exe -d $DISTRO_NAME"
execPowerShell () {
    powershell.exe -command "$@" |tr -d '\r'
}

installAlpine() {
    local ROOTFS=$(execPowerShell '$env:USERPROFILE')'\AppData\Local\WSL\IPv6'
    mkdir -p $(wslpath $ROOTFS)
    curl -s $ALPINE_MINIROOT | wsl.exe --import $DISTRO_NAME $ROOTFS - --version 1
}

createDhcpcdConf () {
    $DISTRO_EXEC apk --no-cache add dhcpcd > /dev/null
    local defaultindex=$(execPowerShell "(Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Get-NetAdapter | ?{\$_.Status -eq 'Up'}).InterfaceIndex")
    local primary=$($DISTRO_EXEC ip -4 addr 2> /dev/null | sed -nr "s/^$defaultindex: *([^:]*):.*\$/\\1/p")
    local devs=$($DISTRO_EXEC cat /proc/net/route | sed -nr 's/^([a-z]+[0-9]+)\s.*$/\1/p' | sort | uniq | grep -v $primary)
    local conf="denyinterfaces "$devs"\ninterface $primary\nscript /etc/dhcpcd.script\nnogateway\nnoipv6rs\nipv6only\nnodhcp\nnoipv4\nnoipv4ll\ndhcp6\nduid lt\nia_pd 1"
    echo $conf | $DISTRO_EXEC sh -c "cat > /etc/dhcpcd.conf"
}

installScript() {
    local ENABLER=/usr/local/bin/enable
    local SCRIPT=/etc/dhcpcd.script
    cat $(dirname $0)$SCRIPT | $DISTRO_EXEC sh -c "cat > $SCRIPT"
    $DISTRO_EXEC sh -c "echo 'dhcpcd -1' > $ENABLER;chmod +x $ENABLER $SCRIPT"
}

installAlpine

wsl.exe -l -v | iconv -futf16 | egrep -q '\s+'$DISTRO_NAME'\s+[A-Za-z]+\s+1'
test $? -ne 0 && exit

createDhcpcdConf
installScript

wsl.exe -l -v
