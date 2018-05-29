(use-modules (gnu) (gnu system nss))
(use-modules (gnu system locale))
(use-service-modules desktop)
(use-package-modules certs gnome)

(operating-system
  (host-name "tumashu")
  (timezone "Asia/Shanghai")
  (locale "zh_CN.UTF-8")
  (locale-definitions
   (cons* (locale-definition
           (name "zh_CN.GB2312")
           (source "zh_CN"))
          (locale-definition
           (name "zh_CN.GBK")
           (source "zh_CN"))
          (locale-definition
           (name "zh_CN.GB18030")
           (source "zh_CN"))
          (locale-definition
           (name "zh_TW.BIG5")
           (source "zh_TW"))
          (locale-definition
           (name "zh_TW.UTF-8")
           (source "zh_TW"))
          %default-locale-definitions))

  ;; Assuming /dev/sdX is the target hard disk
  (bootloader (grub-configuration (target "/dev/sda")))

  (file-systems
   (cons* (file-system
            (device (file-system-label "my-root"))
            (mount-point "/")
            (type "ext4"))
          (file-system
            (device (file-system-label "my-home"))
            (mount-point "/home")
            (type "ext4"))
          (file-system
            (device (file-system-label "my-backup1"))
            (mount-point "/mnt/backup1")
            (type "ext4"))
          (file-system
            (device (file-system-label "my-backup2"))
            (mount-point "/mnt/backup2")
            (type "ext4"))
          %base-file-systems))

  (swap-devices '("/dev/sda8"))

  (users (cons (user-account
                (name "feng")
                (comment "Feng Shu")
                (group "users")
                (supplementary-groups
                 '("wheel" "netdev" "audio" "video"))
                (home-directory "/home/feng"))
               %base-user-accounts))

  ;; This is where we specify system-wide packages.
  (packages
   (append (map specification->package
                '("gvfs" "nss-certs"
                  "network-manager-applet"
                  "gtk-xfce-engine" "adwaita-icon-theme"
                  "gnome-icon-theme" "gnome-themes-standard"
                  "hicolor-icon-theme"
                  "font-wqy-microhei"))
           %base-packages))

  ;; Add GNOME and/or Xfce---we can choose at the log-in
  ;; screen with F1.  Use the "desktop" services, which
  ;; include the X11 log-in service, networking with Wicd,
  ;; and more.
  (services (cons* (xfce-desktop-service)
                   %desktop-services))

  ;; Allow resolution of '.local' host names with mDNS.
  (name-service-switch %mdns-host-lookup-nss))
