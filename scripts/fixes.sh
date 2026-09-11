#!/bin/sh
set -e

# Set link for Ansible to find python
sudo ln -s /usr/local/bin/python3 /usr/bin/python3

# Reinstall pkg to fix segmentation fault of pkg
sudo pkg-static install -fy pkg
