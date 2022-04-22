### about this repogitory

This script receives prefix delegation via DHCPv6-PD from a router on the physical network and advertises RA in the hyper-v virtual network.
## Requirement
 - The following tasks should be performed in the WSL2 distro.
 - Windows host must be connected to a network capable of receiving DHCPv6-PD.
 - Enable Windows Subsystem for Linux to use both WSL2 and WSL1.

## Install
run `install.sh`
 - Create distro, that name is IPv6.(Alpine 3.14 miniroot)
 - Install packages and configuration scripts.
 - The distro will be installed in "%USERNAME%\AppData\Local\WSL\IPv6".
 - I assume Ubuntu as the execution distro, so some arrangements may be necessary for other distros.

Execute the following command, when the installation is complete.

```
$ wsl.exe -d ipv6 enable
```

Check the windows network.
```
$ powershell.exe ipconfig

Ethernet adapter vEthernet (WSL):

   Connection-specific DNS Suffix  . :
   IPv6 Address. . . . . . . . . . . : xxxx:xxxx:xxxx:4d10:98b3:4210:e2fc:8403
   Temporary IPv6 Address. . . . . . : xxxx:xxxx:xxxx:4d10:3458:923d:2cee:1f3a
   IPv6 Address. . . . . . . . . . . : xxxx:xxxx:xxxx:4d10:5931:9a9:b0d8:9980
   Link-local IPv6 Address . . . . . : fe80::98b3:4210:e2fc:8403%30
   IPv4 Address. . . . . . . . . . . : 172.24.80.1
   Subnet Mask . . . . . . . . . . . : 255.255.240.0
   Default Gateway . . . . . . . . . :
```

If GUA is assigned from upstream, it is successful.
After a few seconds, WSL2 will also be assigned IPv6 address.

```
$ ip -6 a show dev eth0
4: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    inet6 xxxx:xxxx:xxxx:4d10:215:5dff:fe0b:343b/64 scope global dynamic mngtmpaddr
       valid_lft forever preferred_lft forever
    inet6 fe80::215:5dff:fe0b:343b/64 scope link
       valid_lft forever preferred_lft forever
```

## Register to Task

Now you are ready to configure IPv6.But, after the lease time of DHCPv6-PD expires, connection with the upstream will be disabled.
So you can register to the task using `installtask.sh` script.

You can see your registered task that name is "\WSL\IPv6 Enabler" in the Task Scheduler.
