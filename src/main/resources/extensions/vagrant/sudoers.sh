#!/bin/bash
# Script for placing sudoers.d files with syntax-checking

# By default we use the current system user
VAGRANT_USER=${1:-${USER}}

# Making a temporary file to contain the sudoers-changes to be pre-checked
echo "# User alias specification
User_Alias VAGRANT_USERS = ${USER}

# Allow passwordless startup of Vagrant when using NFS.
Cmnd_Alias VAGRANT_EXPORTS_ADD = /bin/su root -c echo '*' >> /etc/exports
Cmnd_Alias VAGRANT_NFSD = /etc/init.d/nfs-kernel-server restart
Cmnd_Alias VAGRANT_EXPORTS_REMOVE = /bin/sed -e * /etc/exports
VAGRANT_USERS ALL = NOPASSWD: VAGRANT_EXPORTS_ADD, VAGRANT_NFSD, VAGRANT_EXPORTS_REMOVE" > /tmp/vagrant_sudoers

chmod 0440 /etc/sudoers.d/vagrant_sudoers

sudo mv /tmp/vagrant_sudoers /etc/sudoers.d/
