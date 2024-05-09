# vim: set ft=make :

# Fix libvirt / virt-manager VM creation swtpm SELinux label issue
bluebeard-fix-virtmanager-swtpm:
    sudo /usr/share/bluebeard/scripts/fix-virtmanager-swtpm.sh
