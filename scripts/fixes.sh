#!/bin/sh
set -e

# Set link for Ansible to find python
sudo ln -s /usr/local/bin/python3 /usr/bin/python3

# Reinstall pkg to fix segmentation fault of pkg
sudo pkg-static install -fy pkg

# Write the MVC model defaults into config.xml, as an update would. Without
# them templates referencing missing sections fail to render on every boot.
migrations=$(sudo /usr/local/opnsense/mvc/script/run_migrations.php -v)
echo "${migrations}"
# run_migrations.php exits 0 even when a migration fails
if echo "${migrations}" | grep -q '^Failed'; then
	exit 1
fi

# Grow the root partition and filesystem to the instance's disk on first boot,
# done by /usr/local/etc/rc while / is mounted read-only
sudo touch /.probe.for.growfs
