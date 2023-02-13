(define-module (gee packages wm)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages image)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xorg))

(define-public jwm
  (package
    (name "jwm")
    (version "2.4.3")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/joewing/jwm/releases/download/"
                    "v" version "/jwm-" version ".tar.xz"))
              (sha256
               (base32
                "1av7r9sp26r5l74zvwdmyyyzav29mw5bafihp7y33vsjqkh4wfzf"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f   ; no check target
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'patch-example.jwmrc
            (lambda* (#:key inputs #:allow-other-keys)
              (substitute* "example.jwmrc"
                ;; Ignore existing menus in example.jwmrc.
                (("<Menu ") "<!-- <Menu ")
                (("</Menu>") "</Menu> -->")
                ;; Adjust xterm path in terminal menu item.
                ((">xterm</Program>")
                 (string-append
                  ">" (search-input-file inputs "/bin/xterm")
                  "</Program>"))
                ;; Replace xscreensaver with xlock, which has been configured
                ;; well by desktop-service.
                (("xscreensaver-command -lock") "xlock")
                ;; Adjust icons search paths.
                (("/usr/local/share/jwm")
                 (string-append #$output "/share/jwm"))
                (("/usr/local/share/icons")
                 "/run/current-system/profile/share/icons")
                ;; Include menu created by mjwm command.
                (("<RootMenu .*>" all)
                 (string-append
                  all "\n        "
                  "<Program icon=\"jwm-red\" label=\"Update JWM Menu\">"
                  (search-input-file inputs "/bin/mjwm")
                  " --iconize --no-backup "
                  " --output-file $HOME/.jwmrc-mjwm-guix"
                  "</Program>\n        "
                  "<Dynamic icon=\"folder\" label=\"Applications\">"
                  "$HOME/.jwmrc-mjwm-guix"
                  "</Dynamic>\n")))))
          (add-after 'install 'install-tango-icon-files
            ;; Copy icon files used by example.jwm to share/jwm dir, this way
            ;; may be better than adding tango-icon-theme to inputs.
            (lambda* (#:key inputs #:allow-other-keys)
              (let ((icon-dir (search-input-directory
                               inputs "share/icons/Tango/scalable"))
                    (icon-install-dir (string-append #$output "/share/jwm")))
                (for-each
                 (lambda (icon)
                   (for-each (lambda (icon-file)
                               (install-file icon-file icon-install-dir))
                             (find-files icon-dir (string-append "^" icon "\\.svg$"))))
                 '("calc" "email" "exit" "folder" "font" "help-browser"
                   "image" "info" "lock" "reload" "sound"
                   "system-file-manager" "utilities-terminal"
                   "web-browser" "gnome-settings" "applications-.*"))
                (with-directory-excursion icon-install-dir
                  ;; tango-icon-theme have no applications-science icon.
                  (copy-file "help-browser.svg" "applications-science.svg")))))
          (add-after 'install 'install-xsession
            (lambda* (#:key outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (xsessions (string-append out "/share/xsessions")))
                (mkdir-p xsessions)
                (call-with-output-file
                    (string-append xsessions "/jwm.desktop")
                  (lambda (port)
                    (format port "~
                     [Desktop Entry]~@
                     Name=jwm~@
                     Comment=Joe's Window Manager~@
                     Exec=~a/bin/jwm~@
                     Type=XSession~%" out)))))))))
    (native-inputs (list pkg-config tango-icon-theme))
    (inputs
     (list cairo
           libjpeg-turbo
           libpng
           librsvg
           libxext
           libxinerama
           libxmu
           libxpm
           libxrandr
           libxt
           mjwm
           pango
           xterm))
    (home-page "http://joewing.net/projects/jwm")
    (synopsis "Joe's Window Manager")
    (description
     "JWM is a light-weight window manager for the X11 Window System.  it is
written in C and uses only Xlib at a minimum.  Because of its small footprint,
it makes a good window manager for older computers and less powerful systems,
such as the Raspberry Pi, though it is perfectly capable of running on modern
systems.")
    (license license:expat)))

(define-public mjwm
  (package
    (name "mjwm")
    (version "4.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/chiku/mjwm")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0lgfp2xidhvmbj4zqvzz9g8zwbn6mz0pgacc57b43ha523vamsjq"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f   ; no check target
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'patch-subcategory.h
            (lambda* (#:key inputs #:allow-other-keys)
              (substitute* "include/subcategory.h"
                ;; icon name should be application-other instead of
                ;; application-others.
                (("applications-others") "applications-other")))))))
    (home-page "https://github.com/chiku/mjwm")
    (synopsis "Create menu for JWM.")
    (description
     "MJWM can create JWM's menu from (freedesktop) desktop files and the
generated file can be include in the rootmenu section of your jwm config
file.")
    (license license:gpl2)))

