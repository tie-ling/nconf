printf "put_my_text_password_here" > /root/diskpw
DISK=/dev/disk/by-id/ata-INTEL_SSDSCKKF256G8H_BTLA81651HQR256J

# discard the entire block device
blkdiscard -f $DISK

# create empty gpt partition table
sgdisk --zap-all $DISK

# create two partitions, align both partition beginning and end
sgdisk --align-end --new 1:0:+4G --new 2:0:0 --typecode 1:ef00 --typecode 2:8304 $DISK

sleep 1

# format esp
mkfs.vfat -n ESP ${DISK}-part1

# format encrypted root
cryptsetup -q luksFormat  --type luks2 --key-file=/root/diskpw ${DISK}-part2
cryptsetup luksOpen --allow-discards --key-file=/root/diskpw ${DISK}-part2 root

# format encrypted container
mkfs.xfs /dev/mapper/root

# mount root
mount /dev/mapper/root /mnt

# create swap
fallocate -l 8G /mnt/swapfile
chmod 0600 /mnt/swapfile
mkswap /mnt/swapfile
swapon /mnt/swapfile

# mount esp as /boot
mkdir -p /mnt/boot
mount -o umask=077,iocharset=iso8859-1  ${DISK}-part1 /mnt/boot

# install git; unclear if necessary
# nix-env -f '<nixpkgs>' -iA git
nixos-install --root /mnt --no-root-passwd --flake github:tie-ling/nconf#qinghe

poweroff

# download gpg archive
curl -LO https://github.com/tie-ling/gpg/raw/main/gpg-2024-02-07.tar.xz
tar axf gpg-2024-02-07.tar.xz
mv $(find -name 'gpg' -type d) ~/.gnupg

# clone dotfiles repo
git clone git@github.com:tie-ling/alpine-dots
mv alpine-dots/.git ~/
git reset --hard
