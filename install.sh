mkfs.ext4 /dev/sda1
mkfs.fat -F32 /dev/sda2
mkfs.ext4 /dev/sda4

mkswap /dev/sda3
swapon /dev/sda3

mount /dev/sda1 /mnt
mkdir /mnt/{boot,boot/efi,home}
mount /dev/sda2 /mnt/boot/efi
mount /dev/sda4 /mnt/home

pacstrap /mnt base base-devel linux-lts
pacstrap /mnt zip unzip p7zip vim mc alsa-utils syslog-ng mtools dosfstools lsb-release ntfs-3g exfat-utils bash-completion intel-ucode nano vi

genfstab -U -p /mnt >> /mnt/etc/fstab

pacstrap /mnt grub os-prober efibootmgr

arch-chroot /mnt

KEYMAP=fr-latin9 > /etc/vconsole.conf
FONT=eurlatgr >> /etc/vconsole.conf

LANG=en_US.UTF-8 > /etc/locale.conf
LC_COLLATE=C >> /etc/locale.conf

en_US.UTF-8 UTF-8 > /etc/locale.gen
locale-gen

arch > /etc/hostname

ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime

hwclock --systohc --utc

mkinitcpio -p linux-lts

mount | grep efivars &> /dev/null || mount -t efivarfs efivarfs /sys/firmware/efi/efivars
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch_grub --recheck

mkdir /boot/efi/EFI/boot
cp /boot/efi/EFI/arch_grub/grubx64.efi /boot/efi/EFI/boot/bootx64.efi

grub-mkconfig -o /boot/grub/grub.cfg

passwd root

pacman -Syy networkmanager
systemctl enable NetworkManager

exit
umount -R /mnt


