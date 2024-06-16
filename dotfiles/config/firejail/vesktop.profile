# Custom FireJail Profile for Vesktop
include globals.local

# allow discord access to config directory
noblacklist ${HOME}/.config/discord
mkdir       ${HOME}/.config/discord
whitelist   ${HOME}/.config/discord

# allow Vencord access to config directory
noblacklist ${HOME}/.config/Vencord
mkdir       ${HOME}/.config/Vencord
whitelist   ${HOME}/.config/Vencord

# allow vesktop access to config directory
noblacklist ${HOME}/.config/vesktop
mkdir       ${HOME}/.config/vesktop
whitelist   ${HOME}/.config/vesktop

include /etc/firejail/disable-common.inc
include /etc/firejail/disable-devel.inc
include /etc/firejail/disable-programs.inc

# disable temp
private-tmp
noexec /tmp

# additional restrictions
caps.drop all
netfilter
nodvd
nogroups
nonewprivs
noroot
notv
protocol unix,inet,inet6,netlink

# Below is modified `discord-common.profile`
# ==========================================
include discord-common.local

ignore include disable-interpreters.inc
ignore include disable-xdg.inc
ignore include whitelist-runuser-common.inc
ignore include whitelist-usr-share-common.inc
ignore apparmor
ignore disable-mnt
ignore private-cache
ignore dbus-user none
ignore dbus-system none

ignore noexec ${HOME}
ignore novideo

private-bin bash,cut,echo,egrep,fish,grep,head,sed,sh,tclsh,tr,xdg-mime,xdg-open,zsh,discord,vesktop
private-etc alternatives,ca-certificates,crypto-policies,fonts,group,ld.so.cache,localtime,login.defs,machine-id,password,pki,pulse,resolv.conf,ssl

include electron.profile
