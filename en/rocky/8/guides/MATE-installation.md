Install MATE on minimal Rocky Linux 8 iso

for this use the UNOFFICIAL repository  stenstorp/MATE

https://copr.fedorainfracloud.org/coprs/stenstorp/MATE/

enable the repository

dnf copr enable stenstorp/MATE

press Y to allow

enable the needed epel repository

sudo dnf config-manager --set-enabled powertools  
sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

install packages

sudo dnf install NetworkManager-adsl NetworkManager-bluetooth NetworkManager-libreswan-gnome NetworkManager-openvpn-gnome NetworkManager-ovs NetworkManager-ppp NetworkManager-team NetworkManager-wifi NetworkManager-wwan abrt-desktop abrt-java-connector adwaita-gtk2-theme alsa-plugins-pulseaudio atril atril-caja atril-thumbnailer caja caja-actions caja-image-converter caja-open-terminal caja-sendto caja-wallpaper caja-xattr-tags dconf-editor engrampa eom firewall-config gnome-disk-utility gnome-epub-thumbnailer gstreamer1-plugins-ugly-free gtk2-engines gucharmap gvfs-afc gvfs-afp gvfs-archive gvfs-fuse gvfs-gphoto2 gvfs-mtp gvfs-smb initial-setup-gui libmatekbd libmatemixer libmateweather libsecret lm_sensors marco mate-applets mate-backgrounds mate-calc mate-control-center mate-desktop mate-dictionary mate-disk-usage-analyzer mate-icon-theme mate-media mate-menus mate-menus-preferences-category-menu mate-notification-daemon mate-panel mate-polkit mate-power-manager mate-screensaver mate-screenshot mate-search-tool mate-session-manager mate-settings-daemon mate-system-log mate-system-monitor mate-terminal mate-themes mate-user-admin mate-user-guide mozo network-manager-applet nm-connection-editor p7zip p7zip-plugins pluma seahorse seahorse-caja xdg-user-dirs-gtk brisk-menu

now you need  stenstorp/lightdm repository 

https://copr.fedorainfracloud.org/coprs/stenstorp/lightdm/

so

sudo dnf copr enable stenstorp/lightdm

and install lightdm-gtk

sudo dnf install lightdm-gtk

set the graphical mode 

sudo systemctl set-default graphical.target


and finally reboot
