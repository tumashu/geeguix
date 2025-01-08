(define-module (geesystem tinydesk)
  #:use-module (gee packages display-managers)
  #:use-module (gee services lightdm)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu home services shells)
  #:use-module (gnu home services xdg)
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
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:duplicates (replace last)
  #:export (os))

(define substitute-urls
  (list "https://mirror.sjtu.edu.cn/guix/"
	"https://ci.guix.gnu.org"))

(define bash-profile
  (mixed-text-file
   "bash-profile" "
if [ -f ~/.Xresources ]; then
    xrdb -merge -I $HOME ~/.Xresources;
fi

# Merge search-paths from multiple profiles, the order matters.
eval \"$(guix package --search-paths \\
-p $HOME/.config/guix/current        \\
-p $HOME/.guix-home/profile          \\
-p $HOME/.guix-profile               \\
-p /run/current-system/profile)\"

# Prepend setuid programs.
export PATH=/run/setuid-programs:$PATH
"))

(define guest-home
  (home-environment
   (services
    (list (service
           home-dotfiles-service-type
           (home-dotfiles-configuration
            (layout 'stow)
            (packages '("xrdb" "fonts-core" "gtk2" "gtk3"))
            (directories (list "../geehome/dotfiles"))))
          (service
           home-xdg-mime-applications-service-type
           (home-xdg-mime-applications-configuration
            (desktop-entries
             (list (xdg-desktop-entry
                    (file "xterm")
                    (name "XTerm")
                    (type 'application)
                    (config
                     '((exec . "xterm")
                       (icon . "utilities-terminal")
                       (categories . "System;"))))))))
          (service
           home-bash-service-type
           (home-bash-configuration
            (guix-defaults? #t)
            (bash-profile (list bash-profile))))))))

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
    (label (string-append
            "GNU Guix "
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
     (append (map (compose list specification->package+output)
                  (list
                   "elementary-xfce-icon-theme"
                   "guix-backgrounds"
                   "font-wqy-microhei"
                   "icecat"
                   "icecat-l10n:zh-CN"
                   "icewm"
                   "thunar"
                   "x-resize"
                   "xrandr"
                   "xkill"
                   "xterm"
                   "xrdb"))
             %base-packages))

    ;; Our /etc/sudoers file.  Since 'guest' initially has an empty password,
    ;; allow for password-less sudo.
    (sudoers-file (plain-file "sudoers" "\
root ALL=(ALL) ALL
%wheel ALL=NOPASSWD: ALL\n"))

    (services
     (cons*
      (service guix-home-service-type
               `(("guest" ,guest-home)))
      
      (service lightdm-service-type
               (lightdm-configuration
                (greeters
                 (list (lightdm-greeter-general-configuration
                        (greeter-package slick-greeter)
                        (greeter-session-name "slick-greeter")
                        (greeter-config-name "slick-greeter.conf")
                        (config (list "[Greeter]"
                                      "font-name = Sans 12"
                                      "background = /run/current-system/profile/share/backgrounds/guix/guix-checkered-16-9.svg")))
                       (lightdm-greeter-general-configuration
                        (greeter-package pi-greeter)
                        (greeter-session-name "pi-greeter")
                        (greeter-config-name "pi-greeter.conf")
                        (config (list "[greeter]"
                                      "gtk-font-name = San 12"
                                      "wallpaper = /run/current-system/profile/share/backgrounds/guix/guix-checkered-16-9.svg"
                                      "show-indicators = true")))
                       (lightdm-greeter-general-configuration
                        (greeter-package lightdm-mini-greeter)
                        (greeter-session-name "lightdm-mini-greeter")
                        (greeter-config-name "lightdm-mini-greeter.conf")
                        (config (list "[greeter]"
                                      "user = guest"
                                      "[greeter-hotkeys]"
                                      "mod-key = control"
                                      "session-key = e")))
                       (lightdm-greeter-general-configuration
                        (greeter-package (customize-lightdm-tiny-greeter
                                          #:user_text "用户"
                                          #:pass_text "密码"
                                          #:fontname "Sans"
                                          #:fontsize "40"
                                          #:session "icewm"))
                        (greeter-session-name "lightdm-tiny-greeter")
                        (greeter-config-name "lightdm-tiny-greeter.conf")
                        (config (list "## Lightdm-mini-greeter have no config, ignore it!")))
                       (lightdm-greeter-general-configuration)
                       (lightdm-gtk-greeter-configuration
                        (lightdm-gtk-greeter lightdm-gtk-greeter-gee)
                        (extra-config
                         (list "font-name = San 10"
                               "icon-size = 64"
                               "xft-dpi = 140"
                               "clock-format = %Y-%m-%d %H:%M"
                               ;; We need to use "~~" to generate a tilde, for
                               ;; extra-config sting will be handle as
                               ;; control-string of format function.
                               "indicators = ~~host;~~spacer;~~session;~~a11y;~~clock;~~power")))))
                (seats
                 (list (lightdm-seat-configuration
                        (name "*")
                        (greeter-session 'lightdm-tiny-greeter))))

                (xorg-configuration
                 (xorg-configuration
                  ;; The QXL virtual GPU driver is added to provide a better
                  ;; SPICE experience.
                  (modules (cons xf86-video-qxl
                                 %default-xorg-modules))
                  (keyboard-layout keyboard-layout)
                  (server-arguments
                   ;; 使用较大字体
                   (append %default-xorg-server-arguments
                           '("-dpi" "140")))))))

      ;; Add support for the SPICE protocol, which enables dynamic resizing of
      ;; the guest screen resolution, clipboard integration with the host,
      ;; etc.
      (service spice-vdagent-service-type)

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
