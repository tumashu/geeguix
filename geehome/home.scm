(define-module (geehome home)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services dotfiles)
  #:use-module (gnu home services fontutils)
  #:use-module (gnu home services guix)
  #:use-module (gnu home services mcron)
  #:use-module (gnu home services shells)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services syncthing)
  #:use-module (gnu home services xdg)
  #:use-module (gnu packages)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages ibus)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages syncthing)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xfce)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (guix build utils)
  #:use-module (guix channels)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module ((srfi srfi-1) :select (find))
  #:use-module (srfi srfi-13)
  #:duplicates (replace last)
  #:export (home))

(define packages
  (map (compose list specification->package+output)
       (list
        ;; 基本工具
        "bash-completion"
        "htop"
        "p7zip-gee"
        "unrar"
        "unzip-gee"
        "zile"

        ;; 开发工具
        "make"
        "mumi"

        ;; Emacs
        "emacs-gee"
        "Emacs-helper"

        ;; 邮件工具
        "notmuch"

        ;; 安全
        "gnome-keyring"
        "gnupg"
        "pinentry"
        "seahorse"

        ;; 版本管理
        "git"
        "git:credential-libsecret"
        "git:credential-netrc"
        "git:send-email"

        ;; 网页浏览器
        "icecat"
        "icecat-l10n:zh-CN"
        "ungoogled-chromium"

        ;; 中文输入法
        "ibus"
        "ibus-libpinyin"
        ;; NOTE: 几个比较好的 rime 配置，可以作为参考。
        ;; 1. [三十年河东的 RIME 配置](https://github.com/ssnhd/rime)
        ;; 2. [王院长的 RIME 配置](https://github.com/wongdean/rime-settings)
        ;; 3. [四叶草 RIME 配置](https://github.com/fkxxyz/rime-cloverpinyin)
        "ibus-rime"

        ;; 办公软件
        "libreoffice"

        ;; 硬件管理
        "brightnessctl"
        "gparted"

        ;; 主题字体
        "elementary-xfce-icon-theme"
        "font-wqy-microhei"
        "font-gnu-freefont"
        "gnome-themes-extra"   ; gtk2 theme

        ;; 桌面工具
        "atril"
        "catfish"
        "dconf" ;ibus-setup 运行时依赖 dconf.
        "dconf-editor"
        "engrampa"
        "mousepad"
        "ristretto"
        "xdg-utils"
        "xfce4-screenshooter"
        "xhost"
        "xkill"
        "xrdb"

        ;; 同步和备份工具
        "grsync"
        "syncthing"
        "rsync"

        ;; 声音图像多媒体
        "cheese"
        "gimp"
        "mcomix"
        "mpv"
        "rhythmbox"

        ;; 虚拟机
        "virt-manager"

        ;; 游戏
        "supertuxkart")))

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

(define xautolock-service
  (shepherd-service
   (provision '(xautolock))
   (documentation "Run 'xautolock'")
   (start #~(make-forkexec-constructor
             (list #$(file-append xautolock "/bin/xautolock")
                   "-detectsleep")))
   (stop #~(make-kill-destructor))))

(define ibus-daemon-service
  (shepherd-service
   (provision '(ibus-daemon))
   (documentation "Run 'ibus-daemon --drxR'")
   (respawn? #f)
   (one-shot? #t)
   (start #~(make-forkexec-constructor
             (list #$(file-append ibus "/bin/ibus-daemon")
                   "--daemonize"
                   "--replace"
                   "--xim"
                   "--restart")))
   (stop #~(make-kill-destructor))))

(define rime-sync-setup-service
  (shepherd-service
   (provision '(rime-sync-setup-service))
   (documentation "Link rime sync directory.")
   (respawn? #f)
   (one-shot? #t)
   (start #~(lambda args
              (let* ((home (getenv "HOME"))
                     (rime-sync-dir (string-append home "/.rime-sync"))
                     (liberime-dir  (string-append home "/.emacs.d/rime"))
                     (ibus-rime-dir (string-append home "/.config/ibus/rime")))
                (mkdir-p liberime-dir)
                (mkdir-p ibus-rime-dir)
                (call-with-output-file (string-append liberime-dir "/installation.yaml")
                  (lambda (port)
                    (format port
                            "installation_id: notebook-guix-emacs-liberime~@
                             sync_dir: ~a"
                            rime-sync-dir)))
                (call-with-output-file (string-append ibus-rime-dir "/installation.yaml")
                  (lambda (port)
                    (format port
                            "installation_id: notebook-guix-ibus-rime~@
                             sync_dir: ~a"
                            rime-sync-dir))))))
   (stop #~(make-kill-destructor))))

(define desktop-entries-update-service
  (shepherd-service
   (provision '(desktop-entries-update-service))
   (documentation "Update xfce4 desktop entries in xfce panel.")
   (respawn? #f)
   (one-shot? #t)
   (start #~(lambda args
              (let* ((home-dir (getenv "HOME"))
                     (config-dir (string-append home-dir "/.config"))
                     (xfce4-panel-dir (string-append config-dir "/xfce4/panel"))
                     (desktop-dir (string-append home-dir "/desktop")))
                (for-each
                 (lambda (dir)
                   (substitute* (find-files dir "\\.desktop$")
                     (("Exec=/gnu/store/[^/]+/bin/") "Exec=")
                     (("TryExec=/gnu/store/[^/]+/bin/") "TryExec=")))
                 (list xfce4-panel-dir desktop-dir)))))
   (stop #~(make-kill-destructor))))

(define (webvm-desktop-entry)
  (let* ((webvm-dir (string-append (getenv "HOME") "/.config/webvm/guest"))
         (webvm-cmd
          (string-append
           "bash -c '$(guix system vm -e \"(@ (geesystem webvm) os)\" "
           "--share=" webvm-dir "=/home/guest) "
           "-m 4096 -vga virtio -audio pa,model=hda "
           "-display gtk,show-menubar=off'")))
    (mkdir-p webvm-dir)
    (xdg-desktop-entry
     (file "webvm")
     (name "网络浏览器(虚拟机)")
     (type 'application)
     (config
      `((exec . ,webvm-cmd)
        (icon . "chromium")
        (categories . "System;")
        (comment . "在虚拟机中运行网络浏览器来访问互联网"))))))

(define (webvm-fallback-desktop-entry)
  (let* ((webvm-dir (string-append (getenv "HOME") "/.config/webvm/guest"))
         (webvm-cmd
          (string-append
           "bash -c '/gnu/store/$(ls /gnu/store | grep -m 1 run-vm.sh$) "
           "-m 4096 -vga virtio -audio pa,model=hda "
           "-display gtk,show-menubar=off'")))
    (mkdir-p webvm-dir)
    (xdg-desktop-entry
     (file "webvm-fallback")
     (name "网络浏览器(虚拟机)-备用")
     (type 'application)
     (config
      `((exec . ,webvm-cmd)
        (icon . "chromium")
        (categories . "System;")
        (comment . "在虚拟机中运行网络浏览器来访问互联网"))))))

(define home
  (home-environment
   (packages packages)
   (services
    (append
     (list
      (service
       home-xdg-mime-applications-service-type
       (home-xdg-mime-applications-configuration
        (desktop-entries
         (list (webvm-desktop-entry)
               (webvm-fallback-desktop-entry)))))

      (service
       home-dotfiles-service-type
       (home-dotfiles-configuration
        (layout 'stow)
        (directories
         (list "dotfiles"))))

      (service
       home-channels-service-type
       (cons* (channel
               (name 'nonguix)
               (url "https://gitlab.com/nonguix/nonguix")
               ;; Enable signature verification:
               (introduction
                (make-channel-introduction
                 "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
                 (openpgp-fingerprint
                  "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
              %default-channels))

      (service
       home-xdg-user-directories-service-type
       (home-xdg-user-directories-configuration
        (desktop     "$HOME/desktop")
        (documents   "$HOME/documents")
        (download    "$HOME/downloads")
        (music       "$HOME/music")
        (pictures    "$HOME/pictures")
        (publicshare "$HOME/public")
        (templates   "$HOME/templates")
        (videos      "$HOME/videos")))

      (service
       home-syncthing-service-type)

      (service
       home-shepherd-service-type
       (home-shepherd-configuration
        (services
         (list xautolock-service
               brightnessctl-service
               ibus-daemon-service
               rime-sync-setup-service
               desktop-entries-update-service))))

      (service
       home-bash-service-type
       (home-bash-configuration
        (guix-defaults? #t)
        (bash-profile
         (list
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
")))
        (bashrc
         (list
          (mixed-text-file
           "emacs-eat" "
if [ -n \"$EAT_SHELL_INTEGRATION_DIR\" ]; then
    source \"$EAT_SHELL_INTEGRATION_DIR/bash\";
fi
")))
        (aliases
         '(("la" . "ls -A")
           ("l"  . "ls -CF")
           ("isystem-reconfig" .
            "sudo -E guix system reconfigure -e '(@ (geesystem thinkpad-t14-amd) os)'")
           ("ihome-test"       .
            "guix home container -e '(@ (geehome home) home)'")
           ("ihome-reconfig"   .
            "guix home reconfigure -e '(@ (geehome home) home)'")))
        (environment-variables
         `(;; Guix 使用环境变量
           ("GUIX_PACKAGE_PATH" . ,(dirname (current-source-directory)))

           ;; Ibus 输入法
           ("GTK_IM_MODULE" . "ibus")
           ("QT_IM_MODULE"  . "ibus")
           ("XMODIFIERS"    . "@im=ibus")
           ;; 如果使用非 Gnome 桌面, 可能会导致 dconf 不可用，需要加上这行。
           ("GSETTINGS_BACKEND" . "keyfile")

           ;; GTK 输入法模块
           ("GUIX_GTK2_IM_MODULE_FILE" .
            "${HOME}/.guix-home/profile/lib/gtk-2.0/2.10.0/immodules-gtk2.cache")
           ("GUIX_GTK3_IM_MODULE_FILE" .
            "${HOME}/.guix-home/profile/lib/gtk-3.0/3.0.0/immodules-gtk3.cache")

           ;; Notmuch 搜索中文邮件设置： Notmuch 使用 Xapian 创建邮
           ;; 件索引，Xapian (version < 1.5) 支持 CJK 需要设置下面的
           ;; 环境变量，Xapian (version >= 1.5) 如果启用了 LIBICU,
           ;; 会自动识别 CJK, 不需要额外设置。
           ("XAPIAN_CJK_NGRAM"  .  "1"))))))
     %base-home-services))))

;; Let 'guix home /path/to/file.scm' to work well.
home
