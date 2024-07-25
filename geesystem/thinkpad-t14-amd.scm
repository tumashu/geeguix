(define-module (geesystem thinkpad-t14-amd)
  #:use-module (gee services mt7921e)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu packages)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages xfce)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services cups)
  #:use-module (gnu services desktop)
  #:use-module (gnu services guix)
  #:use-module (gnu services linux)
  #:use-module (gnu services mcron)
  #:use-module (gnu services pm)
  #:use-module (gnu services networking)
  #:use-module (gnu services sddm)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services ssh)
  #:use-module (gnu services virtualization)
  #:use-module (gnu services xorg)
  #:use-module (gnu system)
  #:use-module (gnu system accounts)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system keyboard)
  #:use-module (gnu system locale)
  #:use-module (gnu system nss)
  #:use-module (gnu system shadow)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (ice-9 string-fun)
  #:duplicates (replace last)
  #:export (os))

(define substitute-urls
  (list "https://mirror.sjtu.edu.cn/guix/"
	"https://ci.guix.gnu.org"))

(define garbage-collector-job
  #~(job "10 20 * * *"
         "guix gc --free-space=40G --delete-generations=1m"))

(define package-uri-map
  '((("linux"
      "linux-firmware"
      "amd-microcode")
     ("mirror://kernel.org"
      "https://mirror.nju.edu.cn/kernel.org"))))

(define (replace-package-uri pkg)
  (let ((pkg-uri (origin-uri (package-source pkg))))

    (for-each
     (lambda (item)
       (let ((names (car item))
             (from-string (car (cadr item)))
             (to-string (cadr (cadr item))))
         (when (member (package-name pkg) names)
           (set! pkg-uri
                 (string-replace-substring
                  pkg-uri from-string to-string)))))
     package-uri-map)

    (package
      (inherit pkg)
      (source
       (origin
         (inherit (package-source pkg))
         (uri pkg-uri))))))

;; (origin-uri (package-source (replace-package-uri linux)))
;; (origin-uri (package-source (replace-package-uri linux-firmware)))
;; (origin-uri (package-source (replace-package-uri amd-microcode)))

(define linux-gee
  (customize-linux
   #:name "linux-thinkpad-t14-amd"
   #:linux (replace-package-uri linux)
   #:configs
   '("# Add by linux-thinkpad-t14-amd."
     "CONFIG_MT7921E=m")))

(define os
  (operating-system
    (kernel linux-gee)
    (firmware (list (replace-package-uri linux-firmware)))

    (initrd (lambda (file-systems . rest)
              (apply microcode-initrd file-systems
                     #:microcode-packages (list (replace-package-uri amd-microcode))
                     rest)))

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
     (append (map (compose list specification->package+output)
                  (list
                   ;; 基本工具
                   "git"
                   "zile"

                   ;; 文件系统
                   "exfat-utils"
                   "fuse-exfat"
                   "ntfs-3g"

                   ;; 硬件管理
                   "bluez"
                   "bluez-alsa"
                   "thermald"
                   "tlp"

                   ;; 桌面基础工具
                   "dconf"
                   "dconf-editor"
                   "gvfs"
                   "icewm"
                   "network-manager-applet"
                   "xrandr"

                   ;; 声音
                   "pulseaudio"

                   ;; 屏幕保护和锁屏
                   "xautolock"
                   ;; xfce-screensaver 好像没有和 guix system 集成好，锁住之后无
                   ;; 法解锁，所以这里使用 xautolock|xss-lock + xlock 的方案，
                   ;; Guix system 已经自动安装并且设置好 xlock 程序了。
                   "xlockmore"

                   ;; Xfce4 相关
                   "thunar-archive-plugin"
                   "thunar-media-tags-plugin"
                   "xfce4-cpufreq-plugin"
                   "xfce4-cpugraph-plugin"
                   "xfce4-systemload-plugin"
                   "xfce4-taskmanager"
                   "xfce4-whiskermenu-plugin"

                   ;; 字体主题
                   "elementary-xfce-icon-theme"
                   "font-wqy-microhei"
                   "sugar-dark-sddm-theme"
                   ))
             %base-packages))

    (services
     (cons* (service cups-service-type)
            (service earlyoom-service-type)
            (service libvirt-service-type
                     (libvirt-configuration
                      (tls-port "16555")))
            (service mt7921e-service-type)
            (service openssh-service-type)
            (service sddm-service-type
                     (sddm-configuration
                      (theme "sugar-dark")
                      (xorg-configuration
                       (xorg-configuration
                        (server-arguments
                         (append %default-xorg-server-arguments
                                 '("-dpi" "140")))))))
            (service thermald-service-type
                     (thermald-configuration
                      (ignore-cpuid-check? #t)))
            (service tlp-service-type)
            (service virtlog-service-type
                     (virtlog-configuration
                      (max-clients 1000)))
            (service xfce-desktop-service-type)

            (simple-service 'my-cron-jobs
                            mcron-service-type
                            (list garbage-collector-job))

            ;; Remove tty1.
            (service mingetty-service-type (mingetty-configuration
                                            (tty "tty2")))
            (service mingetty-service-type (mingetty-configuration
                                            (tty "tty3")))
            (service console-font-service-type
                     (map (lambda (tty)
                            (cons tty %default-console-font))
                          '("tty2" "tty3")))

            (modify-services %desktop-services
              (delete mingetty-service-type)
              (delete console-font-service-type)
              (delete gdm-service-type)
              (guix-service-type
               config => (guix-configuration
		          (inherit config)
		          (substitute-urls substitute-urls))))))

    ;; Allow resolution of '.local' host names with mDNS.
    (name-service-switch %mdns-host-lookup-nss)))

;; Let 'guix system /path/to/file.scm' to work well.
os
