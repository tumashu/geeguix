;;; -*- mode: scheme; -*-

(use-modules (geeguix linux)
             (geeguix services)
             (gnu)
             (gnu packages audio)
             (gnu packages linux)
             (gnu services pm)
             (gnu services shepherd)
             (gnu system locale)
             (nongnu packages linux)
             (nongnu system linux-initrd))

(use-service-modules
 cups guix desktop networking ssh xorg virtualization)

(define %my-substitute-urls
  (list "https://mirror.sjtu.edu.cn/guix/"
	"https://ci.guix.gnu.org"))

(operating-system
  (kernel linux/thinkpad-t14-amd)
  (firmware (list linux-firmware))
  (initrd microcode-initrd)

  (timezone "Asia/Shanghai")
  (keyboard-layout (keyboard-layout "cn"))
  (host-name "Guix")

  (locale "zh_CN.utf8")
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

  (bootloader
   (bootloader-configuration
    (bootloader grub-efi-bootloader)
    (targets (list "/boot/efi"))
    (keyboard-layout keyboard-layout)))

  (file-systems
   (cons* (file-system
            (mount-point "/boot/efi")
            (device (uuid "DD72-08F1" 'fat32))
            (type "vfat"))
          (file-system
            (mount-point "/")
            (device
             (uuid "90dff9e2-8684-4c7f-8527-8dfa009c4602"
                   'ext4))
            (type "ext4"))
          (file-system
            (mount-point "/home")
            (device
             (uuid "7dee8949-57d4-4e05-bbbe-9a96e38e903c"
                   'ext4))
            (type "ext4"))
          (file-system
            (mount-point "/debian")
            (device
             (uuid "7760e06b-8a7c-4beb-8e26-fcc3cc1a9fbe"
                   'ext4))
            (type "ext4"))
          %base-file-systems))

  (swap-devices
   (list (swap-space
          (target (uuid "d73637af-7341-45fc-8e72-3210706a1a11")))))

  (users (cons* (user-account
                 (name "feng")
                 (comment "Feng Shu")
                 (group "users")
                 (home-directory "/home/feng")
                 (supplementary-groups
                  '("wheel"
                    "netdev"
                    "kvm"
                    "libvirt"
                    "lp"
                    "audio"
                    "video")))
                %base-user-accounts))

  (packages
   (append (map specification->package
                (list
                 ;; 基本工具
                 "git"
                 "zile"

                 ;; 文件系统
                 "exfat-utils"
                 "fuse-exfat"
                 "ntfs-3g"
                 "nss-certs"

                 ;; 硬件管理
                 "bluez"
                 "bluez-alsa"
                 "thermald"
                 "tlp"

                 ;; 桌面基础工具
                 "dconf"
                 "dconf-editor"
                 "gvfs"
                 "network-manager-applet"

                 ;; 声音
                 "pulseaudio"

                 ;; 屏幕保护和锁屏
                 "xautolock"
                 ;; xfce-screensaver 好像没有和 guix system 集成好，锁住之后无
                 ;; 法解锁，所以这里使用 xautolock|xss-lock + xlock 的方案，
                 ;; Guix system 已经自动安装并且设置好 xlock 程序了。
                 "xlockmore"

                 ;; Xfce4-panel 插件
                 "xfce4-cpufreq-plugin"
                 "xfce4-cpugraph-plugin"
                 "xfce4-systemload-plugin"

                 ;; 字体主题
                 "font-gnu-unifont"
                 "font-wqy-microhei"
                 "gnome-icon-theme"
                 "gnome-themes-standard"))
           %base-packages))

  (services
   (cons* (service mt7921e-service-type)
          (service xfce-desktop-service-type)
          (service openssh-service-type)
          (service cups-service-type)
          (service slim-service-type)
          (service tlp-service-type)
          (service thermald-service-type
                   (thermald-configuration
                    (ignore-cpuid-check? #t)))
          (service libvirt-service-type
                   (libvirt-configuration
                    (unix-sock-group "libvirt")
                    (tls-port "16555")))
          (service virtlog-service-type
                   (virtlog-configuration
                    (max-clients 1000)))
          (modify-services %desktop-services
            (delete gdm-service-type)
            (guix-service-type
             config => (guix-configuration
		        (inherit config)
		        (substitute-urls %my-substitute-urls))))))

  ;; Allow resolution of '.local' host names with mDNS.
  (name-service-switch %mdns-host-lookup-nss))

