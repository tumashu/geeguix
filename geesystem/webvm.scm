(define-module (geesystem webvm)
  #:use-module (gee packages wm)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu packages)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages xfce)
  #:use-module (gnu packages xorg)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services cups)
  #:use-module (gnu services dbus)
  #:use-module (gnu services desktop)
  #:use-module (gnu services guix)
  #:use-module (gnu services linux)
  #:use-module (gnu services mcron)
  #:use-module (gnu services networking)
  #:use-module (gnu services pm)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services sound)
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
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:export (os))

(define webvm-font-name "WenQuanYi Micro Hei")
(define webvm-font-size "16")

(define webvm-gtk3-settings
  (let ((font (string-append webvm-font-name " " webvm-font-size))
        (cursor-size webvm-font-size))
    (mixed-text-file "webvm-gtk3-settings.ini" "\
[Settings]
gtk-theme-name=Adwaita
gtk-icon-theme-name=elementary-xfce
gtk-font-name=" font "
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=" cursor-size)))

(define webvm-jwmrc
  (let ((font (string-append webvm-font-name "-" webvm-font-size))
        (chromium "pkill -9 chromium; chromium"))
    (mixed-text-file "webvm-jwmrc" "\
<?xml version=\"1.0\"?>
<JWM>

  <StartupCommand>" chromium "</StartupCommand>
  <RestartCommand>" chromium "</RestartCommand>

  <Group>
    <Option>maximized</Option>
    <Option>tiled</Option>
    <Option>nomove</Option>
    <Option>notitle</Option>
  </Group>

  <RootMenu onroot=\"123\">
    <Program label=\"1 Open Web Browser \">" chromium "</Program>
    <Separator/>
    <Program label=\"2 Xkill a Window\">xkill</Program>
    <Separator/>
    <Restart label=\"3 Restart JWM\"/>
    <Separator/>
    <Exit    label=\"4 Exit JWM\" confirm=\"false\" />
  </RootMenu>

  <MenuStyle>
    <Font>" font "</Font>
  </MenuStyle>

  <WindowStyle>
    <Width>2</Width>
    <Corner>0</Corner>
    <Active>
      <Foreground>white</Foreground>
      <Background>white</Background>
    </Active>
  </WindowStyle>

  <Mouse context=\"border\" button=\"1\">root:1</Mouse>
  <Mouse context=\"border\" button=\"2\">root:1</Mouse>
  <Mouse context=\"border\" button=\"3\">window</Mouse>

</JWM>")))

(define webvm-xsession
  (mixed-text-file "webvm-xsession.sh" "\
mkdir -p ${HOME}/.config/gtk-3.0
cp -f " webvm-jwmrc " ${HOME}/.jwmrc
cp -f " webvm-gtk3-settings " ${HOME}/.config/gtk-3.0/settings.ini
jwm"))

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
    (host-name "Guix-WebVM")
    (locale "zh_CN.utf8")

    ;; Below we assume /dev/vda is the VM's hard disk.
    ;; Adjust as needed.
    (bootloader (bootloader-configuration
                 (bootloader grub-bootloader)
                 (targets '("does-not-matter"))))

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
                   '("audio")))
                 %base-user-accounts))

    (packages
     (append
      (map specification->package
           (list
            ;; 窗口管理器
            "jwm"
            "xkill"

            ;; 网页浏览器
            "ungoogled-chromium"
            "ublock-origin-chromium"

            ;; 字体主题
            "elementary-xfce-icon-theme"
            "font-wqy-microhei"))
      %base-packages))

    (services
     (cons*
      ;; Choose SLiM, which is lighter than the default GDM.
      (service slim-service-type
               (slim-configuration
                (auto-login? #t)
                (auto-login-session
                 (program-file
                  "run-webvm-xsession.sh"
                  #~(execl #$(file-append bash "/bin/sh")
                           "sh" #$webvm-xsession)))
                (default-user "guest")
                (xorg-configuration
                 (xorg-configuration
                  (modules (list
                            ;; The QXL virtual GPU driver is added to provide a
                            ;; better SPICE experience.
                            xf86-video-qxl
                            xf86-video-vesa
                            xf86-input-libinput
                            xf86-input-evdev
                            xf86-input-keyboard
                            xf86-input-mouse))
                  (keyboard-layout keyboard-layout)))))

      ;; Add support for the SPICE protocol, which enables dynamic
      ;; resizing of the guest screen resolution, clipboard
      ;; integration with the host, etc.
      (service spice-vdagent-service-type)

      (simple-service
       'cron-jobs mcron-service-type
       (list auto-update-resolution-crutch))

      (service dhcp-client-service-type)
      (dbus-service)
      (service pulseaudio-service-type)
      (service alsa-service-type)

      (modify-services %base-services
        (delete login-service-type)
        (delete virtual-terminal-service-type)
        (delete mingetty-service-type)
        (delete agetty-service-type)
        (delete console-font-service-type))))))
