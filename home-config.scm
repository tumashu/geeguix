;;; -*- mode: scheme; -*-

;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(use-modules (gnu home)
             (gnu home services)
             (gnu home services desktop)
             (gnu home services fontutils)
             (gnu home services shells)
             (gnu home services shepherd)
             (gnu home services xdg)
             (gnu packages)
             (gnu packages admin)
             (gnu packages linux)
             (gnu packages syncthing)
             (gnu packages xdisorg)
             (gnu services)
             (gnu services shepherd)
             (guix gexp)
             (srfi srfi-13))

(define brightnessctl-service
  (shepherd-service
   (provision '(brightnessctl))
   (documentation "Run 'brightnessctl'")
   (one-shot? #t)
   (respawn? #f)
   (start #~(make-forkexec-constructor
             (list #$(file-append brightnessctl "/bin/brightnessctl")
                   "set" "70")))
   (stop #~(make-kill-destructor))))

(define syncthing-service
  (shepherd-service
   (provision '(syncthing))
   (documentation "Run 'syncthing' without calling the browser")
   (respawn? #t)
   (start #~(make-forkexec-constructor
             (list #$(file-append syncthing "/bin/syncthing")
                   "-no-browser"
                   "-logflags=3" ; prefix with date & time
                   "-logfile=/home/feng/.local/var/log/syncthing.log")))
   (stop #~(make-kill-destructor))))

(define xautolock-service
  (shepherd-service
   (provision '(xautolock))
   (documentation "Run 'xautolock'")
   (start #~(make-forkexec-constructor
             (list #$(file-append xautolock "/bin/xautolock")
                   "-detectsleep")))
   (stop #~(make-kill-destructor))))

(home-environment
 (packages
  (map (compose list specification->package+output)
       (list
        ;; 基本工具
        "bash-completion"
        "emacs"
        "mercurial"
        "git"
        "p7zip"
        "unrar"
        "unzip"
        "watchexec"
        "zile"

        ;; 网页浏览器
        "icecat"
        ;; "firefox"
        ;; "ungoogled-chromium"

        ;; 中文输入法
        "fcitx5"
        "fcitx5-chinese-addons"
        "fcitx5-configtool"

        ;; 办公软件
        "libreoffice"

        ;; 硬件管理
        "brightnessctl"
        "gparted"
        
        ;; 主题字体
        "adwaita-icon-theme"
        "elementary-xfce-icon-theme"
        "font-wqy-microhei"
        "gnome-icon-theme"
        "gnome-themes-standard"
        "gnome-themes-extra"
        "mate-themes"

        ;; 桌面工具
        "atril"
        "engrampa"
        "gnome-keyring"
        "mousepad"
        "ristretto"
        ;; Guix system 下 xfce-screensaver 和 mate-screensaver 目前都不可用，
        ;; 即使手工添加 suid 权限，也存在锁住之后无法解锁的问题。目前只知道
        ;; slock 和 xlock 两个可以使用。xdg-utils 包含的屏保工具
        ;; xdg-screensaver，可以让 mate-desktop 支持 xautolock, xautolock 可以
        ;; 设置使用 xlock 或者 slock. xfce4 内置锁屏脚本，可以支持 xlock 和
        ;; slock
        "xdg-utils"
        "xfce4-screenshooter"
        "xkill"

        ;; 同步工具
        "syncthing"

        ;; 声音图像多媒体
        "gimp"
        "mpv"
        "python-mutagen" ; 修复 mp3 乱码
        "vlc"

        ;; Wine
        "wine"
        "winetricks"

        ;; 虚拟机
        "virt-viewer"

        ;; 游戏
        "neverball"
        "supertuxkart"
        "xonotic")))
 (services
  (list (service home-xdg-user-directories-service-type
                 (home-xdg-user-directories-configuration
                  (desktop     "$HOME/desktop")
                  (documents   "$HOME/documents")
                  (download    "$HOME/downloads")
                  (music       "$HOME/music")
                  (pictures    "$HOME/pictures")
                  (publicshare "$HOME/public")
                  (templates   "$HOME/templates")
                  (videos      "$HOME/videos")))
        (service home-shepherd-service-type
                 (home-shepherd-configuration
                  (shepherd shepherd)
                  (services
                   (list syncthing-service
                         xautolock-service
                         brightnessctl-service))))
        (service
         home-bash-service-type
         (home-bash-configuration
          (guix-defaults? #t)
          (aliases
           `(("la" . "ls -A")
             ("l"  . "ls -CF")
             ("iguix"            .
              "${GUIX_CHECKOUT}/pre-inst-env guix")
             ("iguix-make"       .
              ,(string-join
                '("cd ${GUIX_CHECKOUT};"
                  "guix shell -D guix -- make")))
             ("ichannel-link"    .
              ,(string-join
                '("rm -f $HOME/.config/guix/channels.scm;"
                  "ln -s $HOME/geeguix/channels.scm"
                  "$HOME/.config/guix/channels.scm")))
             ("isystem-reconfig" .
              ,(string-join
                '("sudo -E guix system reconfigure"
                  "$HOME/geeguix/system-config.scm")))
             ("ihome-reconfig"   .
              ,(string-join
                '("guix home reconfigure"
                  "$HOME/geeguix/home-config.scm")))))
          (environment-variables
           `(;; Fcitx5 input method
             ("GTK_IM_MODULE" . "fcitx")
	     ("QT_IM_MODULE"  . "fcitx")
	     ("XMODIFIERS"    . "@im=fcitx")

	     ("GUIX_GTK2_IM_MODULE_FILE" .
              "${GUIX_PROFILE}/lib/gtk-2.0/2.10.0/immodules-gtk2.cache")
	     ("GUIX_GTK3_IM_MODULE_FILE" .
              "${GUIX_PROFILE}/lib/gtk-3.0/3.0.0/immodules-gtk3.cache")

             ;; Environment variables use by guix system.
             ("GUIX_CHECKOUT"     . "${HOME}/guix/guix")
             ("GUIX_PACKAGE_PATH" . "${HOME}/geeguix/packages"))))))))
