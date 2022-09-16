# Custom FireJail Implementation for Discord

# Persistant Local Customization
include discord.local
# Persistant Gobal Customization
include globals.local

noblacklist ${HOME}/.config/discord

mkdir ${HOME}/.config/discord
whitelist ${HOME}/.config/discord

# Additonal Common Restrictions
include /etc/firejail/disable-common.inc
include /etc/firejail/disable-devel.inc
include /etc/firejail/disable-programs.inc

private-bin discord
private-opt discord
private-tmp

caps.drop all
netfilter
nodvd
nogroups
nonewprivs
noroot
notv
novideo
protocol unix,inet,inet6,netlink
# seccomp

# noexec ${HOME}
noexec /tmp

# Redirect
include discord-common.profile
