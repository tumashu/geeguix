(define-module (geesystem tinydesk)
  #:use-module (gee packages display-managers)
  #:use-module (gee services lightdm)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu packages)
  #:use-module (gnu packages display-managers)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages xorg)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services desktop)
  #:use-module (gnu services guix)
  #:use-module (gnu services linux)
  #:use-module (gnu services mcron)
  #:use-module (gnu services networking)
  #:use-module (gnu services pm)
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
  #:export (os))

(define substitute-urls
  (list "https://mirror.sjtu.edu.cn/guix/"
	"https://ci.guix.gnu.org"))

;;; XXX: Xfce does not implement what is needed for the SPICE dynamic
;;; resolution to work (see: https://gitlab.xfce.org/xfce/xfce4-settings/-/issues/142).
;;; Workaround it by manually invoking xrandr every second.
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
            %default-locale-definitions))

    ;; Label for the GRUB boot menu.
    (label (string-append "GNU Guix "
                          (or (getenv "GUIX_DISPLAYED_VERSION")
                              (package-version guix))))

    (firmware '())

    ;; Below we assume /dev/vda is the VM's hard disk.  Adjust as needed.
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
                  ;; Password is "q" (without quotes)
                  (password "a2l/LaE8AKHIY")
                  (group "users")
                  (supplementary-groups
                   '("wheel"
                     "netdev"
                     "audio"
                     "video")))
                 %base-user-accounts))

    (packages
     (append (map specification->package
                  (list "font-wqy-microhei"
                        "jwm"
                        "icewm"
                        "xrandr"
                        "xterm"
                        "xorg-server"
                        "glibc"
                        "strace"
                        ))
             %base-packages))

    ;; Our /etc/sudoers file.  Since 'guest' initially has an empty password,
    ;; allow for password-less sudo.
    (sudoers-file (plain-file "sudoers" "\
root ALL=(ALL) ALL
%wheel ALL=NOPASSWD: ALL\n"))

    (services
     (cons*
      (service lightdm-service-type
               (lightdm-configuration
                (lightdm lightdm-gee)
                (debug? #t)
                (greeters
                 (list (lightdm-gtk-greeter-configuration
                        (lightdm-gtk-greeter lightdm-gtk-greeter-gee))))
                (seats
                 (list (lightdm-seat-configuration
                        (name "*")
                        (greeter-session 'lightdm-gtk-greeter)
                        (user-session "jwm")
                        )))))

      ;; Add support for the SPICE protocol, which enables dynamic resizing of
      ;; the guest screen resolution, clipboard integration with the host,
      ;; etc.
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

;; Let 'guix system /path/to/file.scm' to work well.
os
