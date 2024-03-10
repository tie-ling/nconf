printf "put_my_text_password_here" > /root/diskpw
DISK=/dev/disk/by-id/ata-INTEL_SSDSCKKF256G8H_BTLA81651HQR256J


mkdir -p /etc/repart.d/

tee /etc/repart.d/01-esp.conf <<EOF
[Partition]
Type=esp
SizeMinBytes=4G
SizeMaxBytes=4G
EOF

# nixos installer does not support xbootldr partition

tee /etc/repart.d/02-root.conf <<EOF
[Partition]
Type=root
Encrypt=key-file
EOF

tee /etc/repart.d/03-swap.conf <<EOF
[Partition]
Type=swap
SizeMinBytes=2G
SizeMaxBytes=8G
EOF

systemd-repart --dry-run=no --empty=force --discard=yes --key-file=/root/diskpw $DISK

cryptsetup open -q --type plain --key-file /dev/random ${DISK}-part3 swap
mkswap /dev/mapper/swap
swapon /dev/mapper/swap

cryptsetup open --key-file=/root/diskpw ${DISK}-part2 root

mount /dev/mapper/root /mnt

mkdir -p /mnt/boot
mkfs.vfat ${DISK}-part1
mount -o umask=077,iocharset=iso8859-1  ${DISK}-part1 /mnt/boot

nixos-install --root /mnt --no-root-passwd

poweroff

