(define-module (geesystem xfce)
  #:use-module (gee services mt7921e)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu packages)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages xfce)
  #:use-module (gnu packages xorg)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services cups)
  #:use-module (gnu services desktop)
  #:use-module (gnu services guix)
  #:use-module (gnu services linux)
  #:use-module (gnu services mcron)
  #:use-module (gnu services pm)
  #:use-module (gnu services networking)
  #:use-module (gnu services samba)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services spice)
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
  #:export     (os))

(define substitute-urls
  (list "https://mirror.sjtu.edu.cn/guix/"
	"https://ci.guix.gnu.org"))

;;; XXX: Xfce does not implement what is needed for the SPICE dynamic
;;; resolution to work (see:
;;; https://gitlab.xfce.org/xfce/xfce4-settings/-/issues/142).  Workaround it
;;; by manually invoking xrandr every second.
(define auto-update-resolution-crutch
  #~(job '(next-second)
         (lambda ()
           (setenv "DISPLAY" ":0.0")
           (setenv "XAUTHORITY" "/home/guest/.Xauthority")
           (execl (string-append #$xrandr "/bin/xrandr") "xrandr" "-s" "0"))
         #:user "guest"))

(define os
  (operating-system
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

    ;; Label for the GRUB boot menu.
    (label (string-append "GNU Guix "
                          (or (getenv "GUIX_DISPLAYED_VERSION")
                              (package-version guix))))

    (firmware '())

    ;; Below we assume /dev/vda is the VM's hard disk.
    ;; Adjust as needed.
    (bootloader (bootloader-configuration
                 (bootloader grub-bootloader)
                 (targets '("/dev/vda"))
                 (terminal-outputs '(console))))
    (file-systems (cons (file-system
                          (mount-point "/")
                          (device "/dev/vda1")
                          (type "ext4"))
                        %base-file-systems))

    (users (cons (user-account
                  (name "guest")
                  (comment "guest")
                  (password "")                     ;no password
                  (group "users")
                  (supplementary-groups
                   '("wheel"
                     "netdev"
                     "audio"
                     "video"
                     "sambashare")))
                 %base-user-accounts))

    (groups (cons* (user-group
                    (name "sambashare"))
                   %base-groups))

    (packages
     (append (map specification->package
                  (list
                   ;; 基本工具
                   "bash-completion"
                   "curl"
                   "git"
                   "htop"
                   "p7zip"
                   "unzip"

                   ;; 文件系统
                   "exfat-utils"
                   "fuse-exfat"
                   "ntfs-3g"
                   "nss-certs"

                   ;; 桌面基础工具
                   "dconf"
                   "dconf-editor"
                   "engrampa"
                   "gvfs"
                   "network-manager-applet"
                   "samba"

                   ;; 网页浏览器
                   "icecat"
                   "ungoogled-chromium"

                   ;; 中文输入法
                   "ibus"
                   "ibus-libpinyin"

                   ;; 声音
                   "pulseaudio"

                   ;; Xfce4 相关
                   "thunar-shares-plugin"
                   "xfce4-cpufreq-plugin"
                   "xfce4-cpugraph-plugin"
                   "xfce4-eyes-plugin"
                   "xfce4-places-plugin"
                   "xfce4-systemload-plugin"
                   "xfce4-taskmanager"
                   "xfce4-whiskermenu-plugin"

                   ;; 字体主题
                   "elementary-xfce-icon-theme"
                   "font-wqy-microhei"
                   "gnome-themes-extra"   ; gtk2 theme
                   ))
             %base-packages))

    ;; Our /etc/sudoers file.  Since 'guest' initially has an empty password,
    ;; allow for password-less sudo.
    (sudoers-file (plain-file "sudoers" "\
root ALL=(ALL) ALL
%wheel ALL=NOPASSWD: ALL\n"))

    (services
     (cons*
      (service samba-service-type
               (samba-configuration
                (enable-smbd? #t)
                (config-file (plain-file "smb.conf" "\
[global]
workgroup = WORKGROUP
security = user
map to guest = bad user
only guest = yes
logging = syslog@1
usershare path = /var/lib/samba/usershares
usershare max shares = 100
usershare allow guests = yes
usershare owner only = yes\n"))))

      (service xfce-desktop-service-type)

      ;; Choose SLiM, which is lighter than the default GDM.
      (service slim-service-type
               (slim-configuration
                (auto-login? #t)
                (default-user "guest")
                (xorg-configuration
                 (xorg-configuration
                  ;; The QXL virtual GPU driver is added to provide
                  ;; a better SPICE experience.
                  (modules (cons xf86-video-qxl
                                 %default-xorg-modules))
                  (keyboard-layout keyboard-layout)))))

      (service openssh-service-type)

      ;; Add support for the SPICE protocol, which enables dynamic
      ;; resizing of the guest screen resolution, clipboard
      ;; integration with the host, etc.
      (service spice-vdagent-service-type)

      (simple-service 'cron-jobs mcron-service-type
                      (list auto-update-resolution-crutch))

      (modify-services %desktop-services
        (delete gdm-service-type)
        (guix-service-type
         config => (guix-configuration
                    (inherit config)
                    (substitute-urls substitute-urls))))))

    ;; Allow resolution of '.local' host names with mDNS.
    (name-service-switch %mdns-host-lookup-nss)))
