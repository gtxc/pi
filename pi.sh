#!/bin/sh

station=""
ssid=""
passphrase=""
username=""
password=""
# post_installation=false
# swapsize=auto
# output=Virtual-1
# resolution=1920x1080
# gen_xprofile=true
n550jk=false

main() {
  verify_user
  verify_boot_mode
  check_disk
  check_network
  partition_disk
  format_disk
  mount_fs
  rank_mirrors
  detect_ucode
  base_install
  post_install
}

verify_user() {
  inf "Verifying user..."
  [ "$(id -u)" -eq 0 ] || die "This script must be run as root."
}

# dir exists?
[ -d /sys/firmware/efi ] || die "Reboot system in UEFI mode."

# variable set?
[ -z "$disk" ]

check_network() {
  inf "Checking network connection..."
  if ! nc -zw1 archlinux.org 443; then
    inf "Connecting to $ssid through $station..."
    iwctl station "$station" connect "$ssid" --passphrase "$passphrase" || die "Failed to connect. Check network preferences."
  fi
  timedatectl set-ntp true
}

rank_mirrors() {
  inf "Ranking pacman mirrorlist..."
  set -x
  reflector --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
  set +x
}

base_install() {
  # create terminal trash for rm
  inf "Installing base packages..."
  # base base-devel linux linux-firmware "$ucode" neovim tmux git dash networkmanager man-db man-pages ufw reflector
  timedatectl set-ntp true
  inf "Creating reflector config..."
  cat <<-EOF >/mnt/etc/xdg/reflector/reflector.conf
		--save /etc/pacman.d/mirrorlist
		--protocol https 
		--sort rate 
		--latest 10 
	EOF
  # inf "Setting UFW rules..."
  # arch-chroot /mnt ufw allow 80/tcp
  # arch-chroot /mnt ufw allow 443/tcp
  # arch-chroot /mnt ufw default deny incoming
  # arch-chroot /mnt ufw default allow outgoing
  # arch-chroot /mnt ufw enable
  inf "Enabling/Staring services..."
  arch-chroot /mnt systemctl enable NetworkManager.service
  # arch-chroot /mnt systemctl enable reflector.timer
  # arch-chroot /mnt systemctl enable ufw.service
  inf "Installing yay..."
  arch-chroot /mnt <<-EOF
		su $username
		cd /tmp
		git clone https://aur.archlinux.org/yay.git
		cd yay
		makepkg -si --noconfirm
	EOF

  inf "Installing/Configuring WM..."
  # 	inf "	\$ curl -LO https://raw.githubusercontent.com/gtxc/di/main/di.sh"

  if [ "$n550jk" = true ]; then
    cat <<-EOF >>/mnt/etc/modprobe.d/i915.conf
			options i915 enable_psr=0
		EOF
  fi
}

# post_install() {
#     mkinitcpio -P
#     pacman -S base-devel dosfstools efibootmgr networkmanager openssh os-prober sudo
#     pacman -S linux linux-firmware linux-headers
#     pacman -S grub efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools base-devel linux-headers avahi xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils inetutils dnsutils bluez bluez-utils cups hplip alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion openssh rsync reflector acpi acpi_call tlp virt-manager qemu qemu-arch-extra edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat iptables-nft ipset firewalld flatpak sof-firmware nss-mdns acpid os-prober ntfs-3g terminus-font
#     pacman -S mesa
#     mkinitcpio -p linux
#     uncomment /etc/locale.gen
#     mkdir /boot/EFI
#     mount boot_partition /boot/EFI
#
#     bootctl install
#     esp/loader/loader.conf
#
#     default arch.conf
#     timeout 4
#     console-mode max
#     editor no
#
#     esp/loader/entries/arch.conf
#
#     title Arch Linux
#     linux /vmlinuz-linux
#     initrd /intel-ucode.img
#     initrd /initramfs-linux.img
#     options root=UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx rw
#
#     grep -q "ILoveCandy" /etc/pacman.conf || sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf
#
#     pacstrap /mnt linux linux-firmware networkmanager vim base base-devel git man efibootmgr grub
#     # Enable tap to click
#     [ ! -f /etc/X11/xorg.conf.d/40-libinput.conf ] && printf 'Section "InputClass"
#   Identifier "libinput touchpad catchall"
#   MatchIsTouchpad "on"
#   MatchDevicePath "/dev/input/event*"
#   Driver "libinput"
#   # Enable left mouse button by tapping
#   Option "Tapping" "on"
#     EndSection' >/etc/X11/xorg.conf.d/40-libinput.conf
#
#     pacman -S --noconfirm xf86-video-amdgpu
#     pacman -S --noconfirm nvidia nvidia-utils nvidia-settings
#
#     systemctl enable NetworkManager
#     systemctl enable bluetooth
#     systemctl enable cups.service
#     systemctl enable sshd
#     systemctl enable avahi-daemon
#     systemctl enable reflector.timer
#     systemctl enable fstrim.timer
#     systemctl enable libvirtd
#     systemctl enable firewalld
#     systemctl enable acpid
#
#     firewall-cmd --add-port=1025-65535/tcp --permanent
#     firewall-cmd --add-port=1025-65535/udp --permanent
#     firewall-cmd --reload
#     virsh net-autostart default
#
#     cd /tmp
#     git clone https://aur.archlinux.org/paru.git
#     cd paru/
#     cd
#     makepkg -si --noconfirm
#
#     # Install packages
#     sudo pacman -S xorg firefox polkit-gnome nitrogen lxappearance thunar
#
#     # Install fonts
#     sudo pacman -S --noconfirm dina-font tamsyn-font bdf-unifont ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-droid gnu-free-fonts ttf-ibm-plex ttf-liberation ttf-linux-libertine noto-fonts ttf-roboto tex-gyre-fonts ttf-ubuntu-font-family ttf-anonymous-pro ttf-cascadia-code ttf-fantasque-sans-mono ttf-fira-mono ttf-hack ttf-fira-code ttf-inconsolata ttf-jetbrains-mono ttf-monofur adobe-source-code-pro-fonts cantarell-fonts inter-font ttf-opensans gentium-plus-font ttf-junicode adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts noto-fonts-cjk noto-fonts-emoji
#
#     # Pull Git repositories and install
#     cd /tmp
#     export repos="dmenu dwm dwmstatus st slock"
#     for repo in $repos; do
#         git clone git://git.suckless.org/$repo
#         cd $repo
#         make
#         sudo make install
#         cd ..
#     done
#
#     # XSessions and dwm.desktop
#     if [[ ! -d /usr/share/xsessions ]]; then
#         sudo mkdir /usr/share/xsessions
#     fi
#
#     cat >./temp <<"EOF"
#   [Desktop Entry]
#   Encoding=UTF-8
#   Name=Dwm
#   Comment=Dynamic window manager
#   Exec=dwm
#   Icon=dwm
#   Type=XSession
#   EOF
#     sudo cp ./temp /usr/share/xsessions/dwm.desktop
#     rm ./temp
#
#     # Install ly
#     if [[ $install_ly = true ]]; then
#         git clone https://aur.archlinux.org/ly
#         cd ly
#         makepkg -si
#         sudo systemctl enable ly
#     fi
#
#     # .xprofile
#     if [[ $gen_xprofile = true ]]; then
#         cat <<EOF >~/.xprofile
#     setxkbmap $kbmap
#     nitrogen --restore
#     xrandr --output $output --mode $resolution
# EOF
#     fi
#
#     for PKG in "${PKGS[@]}"; do
#         paru -S --noconfirm $PKG
#     done
#
#     # --- Setup UFW rules
#     ufw allow 80/tcp
#     ufw allow 443/tcp
#     ufw default deny incoming
#     ufw default allow outgoing
#     ufw enable
#
#     # --- Harden /etc/sysctl.conf
#     sysctl kernel.modules_disabled=1
#     sysctl -a
#     sysctl -A
#     sysctl mib
#     sysctl net.ipv4.conf.all.rp_filter
#     sysctl -a --pattern 'net.ipv4.conf.(eth|wlan)0.arp'
#
#     # --- PREVENT IP SPOOFS
#     cat <<EOF >/etc/host.conf
#   order bind,hosts
#   multi on
#   EOF
#
#     # --- Enable ufw
#     systemctl enable ufw
#     systemctl start ufw
#
#     # Generate the .xinitrc file so we can launch Awesome from the
#     # terminal using the "startx" command
#     cat <<EOF >${HOME}/.xinitrc
#   #!/bin/bash
#   # Disable bell
#   xset -b
#
#   # Disable all Power Saving Stuff
#   xset -dpms
#   xset s off
#
#   # X Root window color
#   xsetroot -solid darkgrey
#
#   # Merge resources (optional)
#   #xrdb -merge $HOME/.Xresources
#
#   # Caps to Ctrl, no caps
#   setxkbmap -layout us -option ctrl:nocaps
#   if [ -d /etc/X11/xinit/xinitrc.d ] ; then
#     for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
#       [ -x "\$f" ] && . "\$f"
#     done
#     unset f
#   fi
#
#   variety &
#
#   exit 0
#   EOF
#
#     echo "Disabling buggy cursor inheritance"
#     # When you boot with multiple monitors the cursor can look huge. This fixes it.
#     sudo cat <<EOF >/usr/share/icons/default/index.theme
#   [Icon Theme]
#   #Inherits=Theme
#   EOF
#
#     echo
#     echo "Enable AMD Tear Free"
#
#     sudo cat <<EOF >/etc/X11/xorg.conf.d/20-amdgpu.conf
#   Section "Device"
#   Identifier "AMD"
#   Driver "amdgpu"
#   Option "TearFree" "true"
#   EndSection
# EOF
#
#
#     echo "Enabling bluetooth daemon and setting it to auto-start"
#     sudo sed -i 's|#AutoEnable=false|AutoEnable=true|g' /etc/bluetooth/main.conf
#
#     sudo systemctl enable bluetooth.service
#     sudo systemctl start bluetooth.service
#     sudo systemctl disable dhcpcd.service
#     sudo systemctl stop dhcpcd.service
#     sudo systemctl disable ssh.service
#     sudo systemctl stop ssh.service
#     sudo systemctl enable NetworkManager.service
#     sudo systemctl start NetworkManager.service
#
#     # FIND GRAPHICS CARD
#     find_card() {
#         card=$(lspci | grep VGA | sed 's/^.*: //g')
#         echo "You're using a $card" && echo
#     }
#
#     #pkglist=(
#     #  "https://raw.githubusercontent.com/mietinen/archer/master/pkg/pkglist.txt"
#     #  # "https://raw.githubusercontent.com/mietinen/archer/master/pkg/dev.txt"
#     #  # "https://raw.githubusercontent.com/mietinen/archer/master/pkg/desktop.txt"
#     #  # "https://raw.githubusercontent.com/mietinen/archer/master/pkg/carbon.txt"
#     #  # "https://raw.githubusercontent.com/mietinen/archer/master/pkg/gaming.txt"
#     #  # "https://raw.githubusercontent.com/mietinen/archer/master/pkg/pentest.txt"
#     #)
#
#     #dotfilesrepo=(
#     #  "https://github.com/mietinen/dots.git"
#     #)
#
#     https://github.com/LukeSmithxyz/LARBS
#
#     inf "Post installation complete."
# }
#
# pacman --noconfirm --needed -S  ${pacman_packages[@]}
# pacman_packages=()
#
# chsh -s /bin/zsh
#
# rustup default stable
#
# # Install linux headers
# pacman_packages+=( linux-headers )
#
# # Install X essentials
# pacman_packages+=( xorg-server xorg-apps xorg-xinit xorg-fonts-misc dbus xsel acpi xbindkeys libva-utils )
#
# # Install font essentials
# pacman_packages+=( cairo fontconfig freetype2 )
#
# # Install linux fonts
# pacman_packages+=( ttf-dejavu ttf-liberation ttf-inconsolata ttf-anonymous-pro ttf-ubuntu-font-family )
#
# # Install google fonts
# pacman_packages+=( ttf-croscore ttf-droid ttf-roboto )
#
# # Install adobe fonts
# pacman_packages+=( adobe-source-code-pro-fonts adobe-source-sans-pro-fonts adobe-source-serif-pro-fonts )
#
# # Install bitmap fonts
# pacman_packages+=( terminus-font )
#
# # Install admin tools
# pacman_packages+=( sudo man pacman-contrib git zsh grml-zsh-config tmux openssh sysstat tree jq htop )
#
# # Install rust admin tools
# pacman_packages+=( ripgrep exa fd bat dust alacritty zenith bottom )
#
# # Install network tools
# pacman_packages+=( ifplugd syncthing )
#
# # Install window manager
# pacman_packages+=( slock dmenu libnotify dunst arc-gtk-theme arc-icon-theme papirus-icon-theme )
#
# # Install dev tools
# pacman_packages+=( vim emacs-nativecomp stow editorconfig-core-c patch make pkgconf devtools base-devel )
#
# # Work tools
# pacman_packages+=( nodejs npm typescript-language-server rustup optipng go )
#
# # Install audio
# pacman_packages+=( alsa-utils pipewire pipewire-audio pipewire-alsa pipewire-pulse pavucontrol )
#
# # Install useful apps
# pacman_packages+=( keepass mpv vlc gimp firefox chromium scribus rtorrent scrot feh mupdf )
# pacman_packages+=( libreoffice-fresh thunar lxappearance redshift unrar unzip )
#
#
# # Generate locales
# sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
# sed -i 's/^#fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen
# locale-gen
#
# # Set timezone
# timedatectl --no-ask-password set-timezone Europe/Paris
#
# # Set NTP clock
# timedatectl --no-ask-password set-ntp 1
#
# # Set locale
# localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_COLLATE="C" LC_TIME="fr_FR.UTF-8"
#
# # Set keymaps
# localectl --no-ask-password set-keymap us
# localectl --no-convert set-x11-keymap us,us pc104 ,intl grp:caps_toggle
#
# # Hostname
# hostnamectl --no-ask-password set-hostname $hostname
#
# # Disable PC speaker beep
# echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf
#
# # Create user with home
# if ! id -u $username; then
#     useradd -m --groups users,wheel $username
#     echo "$username:$password" | chpasswd
#     chsh -s /bin/zsh $username
# fi
#
# # Add sudo no password rights
# sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
#
# # Remove no password sudo rights
# sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
# # Add sudo rights
# sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
#
# ##uncomment the line below if you have AMD GPU
# #sudo pacman -Sy xf86-video-amdgpu
#
# ##uncomment the line below if you have Nvidia GPU
# #sudo pacman -Sy nvidia nvidia-utils
#
# ##uncomment the line below if you have Intel GPU
# #sudo pacman -Sy xf86-video-intel
#
# /etc/pacman.conf
# uncomment #Color
# uncomment #ParallelDownloads = 5
# add ILoveCandy
#
# /boot/loader/loader.conf
# set timeout 0
#
# /etc/sudoers
# add Defaults !env_reset, pwfeedback

inf() {
  printf "\033[1m\033[34m:: \033[37m%s\033[0m\n" "$*"
}

err() {
  printf "\033[1m\033[91m:: %s\033[0m\n" "$*" >&2
}

die() {
  err "$*"
  exit 1
}

get() {
  printf "\n\033[1m\033[32m:: \033[37m%s\033[0m" "$2"
  read -r "$1"
}

silent() {
  "$@" >/dev/null 2>&1
}

write_to_file() {
  if [ $# -ne 3 ]; then
    die "Usage: write_to_file <write_mode(w,a)> <file_path> <text>"
  fi
  write_mode=$1
  original_path=$2
  text=$3
  temp_path=/tmp/$(basename "$original_path")
  if [ "$write_mode" != "w" ] && [ "$write_mode" != "a" ]; then
    die "Invalid write mode. Please specify 'w(rite)' or 'a(ppend)'."
  fi
  if [ "$write_mode" = "w" ]; then
    echo "$text" >"$temp_path"
  else
    echo "$text" >>"$temp_path"
  fi
  mv "$temp_path" "$original_path"
  rm -f "$temp_path"
}

replace_in_file() {
  if [ $# -ne 3 ]; then
    die "Usage: replace_in_file <file_path> <text_to_replace> <new_text>"
  fi
  file_path=$1
  text_to_replace=$2
  new_text=$3
  temp_path=/tmp/$(basename "$file_path")
  if [ ! -f "$file_path" ]; then
    die "File $file_path does not exist."
  fi
  sed -i "s/$text_to_replace/$new_text/g" "$file_path"
}

installpkg() {
  pacman --noconfirm --needed -S "$@"
}

log() {
  log_file="installation_$(date +%Y%m%d_%H%M%S).log"
  wd="$PWD"
  main 2>&1 | tee "$wd"/"$log_file"
}

log
