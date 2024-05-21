#!/usr/bin/env bash

set -euo pipefail

# Install SELinux policies to make sure swtpm_exec_t exists
echo "Installing swtpm.pp SELinux policy"
semodule -i /usr/share/selinux/packages/swtpm.pp > /dev/null 2>&1
echo "Installing swtpm_libvirt.pp SELinux policy"
semodule -i /usr/share/selinux/packages/swtpm_libvirt.pp > /dev/null 2>&1
echo "Installing swtpm_svirt.pp SELinux policy"
semodule -i /usr/share/selinux/packages/swtpm_svirt.pp > /dev/null 2>&1

# Set the default context
echo "Setting the default SELinux context on /usr/bin/swtpm"
if semanage fcontext -a -t swtpm_exec_t "/usr/bin/swtpm" > /dev/null 2>&1 ; then
    echo "Default context set!"
else
    echo "Default context already set!"
fi

# Write tmpfile.d settings file
echo "Writing /etc/tmpfiles.d/swtpm-workaround.conf"
{
    echo 'C /usr/local/bin/.swtpm - - - - /usr/bin/swtpm'
    echo 'd /var/lib/swtpm-localca 0750 tss tss - -'
} > /etc/tmpfiles.d/swtpm-workaround.conf

# Set permissions
echo "Setting /etc/tmpfiles.d/swtpm-workaround.conf to 0644"
chmod 0644 /etc/tmpfiles.d/swtpm-workaround.conf

# Write unit file
echo "Writing /etc/systemd/system/swtpm-workaround.service"
{
    echo '[Unit]'
    echo 'Description=Workaround swtpm not having the correct label'
    echo 'ConditionFileIsExecutable=/usr/bin/swtpm'
    echo 'After=local-fs.target'
    echo ''
    echo '[Service]'
    echo 'Type=oneshot'
    echo '# Copy if it does not exist'
    echo 'ExecStartPre=/usr/bin/bash -c "[ -x /usr/local/bin/.swtpm ] || /usr/bin/cp /usr/bin/swtpm /usr/local/bin/.swtpm"'
    echo '# This is faster than using .mount unit. Also allows for the previous line/cleanup'
    echo 'ExecStartPre=/usr/bin/mount --bind /usr/local/bin/.swtpm /usr/bin/swtpm'
    echo '# Fix SELinux label'
    echo 'ExecStart=/usr/sbin/restorecon /usr/bin/swtpm'
    echo '# Clean-up after ourselves'
    echo 'ExecStop=/usr/bin/umount /usr/bin/swtpm'
    echo 'ExecStop=/usr/bin/rm /usr/local/bin/.swtpm'
    echo 'RemainAfterExit=yes'
    echo ''
    echo '[Install]'
    echo 'WantedBy=multi-user.target'
    echo ''
} > /etc/systemd/system/swtpm-workaround.service

# Reload services
echo "Reloading systemctl daemons"
systemctl daemon-reload

# Enable service to start on boot
echo "Setting swtpm-workaround.service to start on boot"
systemctl enable swtpm-workaround.service

echo "fix-virtmanager-swtpm.sh done. Changes will take effect on reboot!"
