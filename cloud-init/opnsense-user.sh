#!/bin/sh
# Register the cloud-init default user in /conf/config.xml, OPNsense manages
# accounts and their SSH keys from there. Runs once per instance from
# scripts_per_instance, so user-data with its own runcmd does not replace it.
set -e

USER=freebsd
CONFIG=/conf/config.xml

if xml sel -Q -t -c "/opnsense/system/user[name='${USER}']" "${CONFIG}"; then
	exit 0
fi

uid=$(id -u "${USER}")
keys=""
if [ -f "/home/${USER}/.ssh/authorized_keys" ]; then
	keys=$(base64 < "/home/${USER}/.ssh/authorized_keys" | tr -d '\n')
fi

xml edit --inplace \
	-a '/opnsense/system/user[last()]' -t elem -n user \
	-s '/opnsense/system/user[last()]' -t elem -n name -v "${USER}" \
	-s '/opnsense/system/user[last()]' -t elem -n descr -v FreeBSD \
	-s '/opnsense/system/user[last()]' -t elem -n scope -v system \
	-s '/opnsense/system/user[last()]' -t elem -n groupname -v admins \
	-s '/opnsense/system/user[last()]' -t elem -n password -v '*' \
	-s '/opnsense/system/user[last()]' -t elem -n shell -v /bin/tcsh \
	-s '/opnsense/system/user[last()]' -t elem -n uid -v "${uid}" \
	-s '/opnsense/system/user[last()]' -t elem -n authorizedkeys -v "${keys}" \
	-a "/opnsense/system/group[name='admins']/member[last()]" -t elem -n member -v "${uid}" \
	"${CONFIG}"
