(define-module (gee packages display-managers)
  #:use-module (gee packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system glib-or-gtk)
  #:use-module (guix build-system meson)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (gnu packages)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages cinnamon)
  #:use-module (gnu packages display-managers)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages libcanberra)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:export (customize-lightdm-tiny-greeter))


(define-public lightdm-gtk-greeter-gee
  (package
    (inherit lightdm-gtk-greeter)
    (name "lightdm-gtk-greeter-gee")
    (source (origin
              (inherit (package-source lightdm-gtk-greeter))
              (patches (geeguix-search-patches
                        "lightdm-gtk-greeter-icon-size-option.patch"))))))

(define-public slick-greeter
  (package
    (name "slick-greeter")
    (version "2.0.9")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/linuxmint/slick-greeter")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0d7w0pmjl6b67bgdakg27ivl2s1kj6g9khkfwxj7bkcsgqa80931"))))
    (build-system meson-build-system)
    (arguments
     (list
      #:glib-or-gtk? #t
      #:configure-flags
      #~(list
         ;; Put the binary under /bin rather than /sbin, so that it gets
         ;; wrapped by the glib-or-gtk-wrap phase.
         (string-append "--sbindir=" #$output "/bin"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'patch-hardcoded-paths
            (lambda* (#:key inputs #:allow-other-keys)
              (substitute* '("src/slick-greeter.vala"
                             "src/session-list.vala"
                             "src/user-list.vala")
                (("/usr/bin/numlockx")
                 (search-input-file inputs "/bin/numlockx"))
                (("/usr/bin/slick-greeter-")
                 (string-append #$output "/bin/slick-greeter-"))
                (("/usr/share/slick-greeter/badges/")
                 (string-append #$output "/share/slick-greeter/badges/"))
                (("/usr/share/xsessions/")
                 "/run/current-system/profile/share/xsessions/")
                (("/usr/share/wayland-sessions/")
                 "/run/current-system/profile/share/wayland-sessions/")
                (("/usr/share/backgrounds/")
                 "/run/current-system/profile/share/backgrounds/"))))
          (add-after 'glib-or-gtk-wrap 'custom-wrap
            (lambda _
              (wrap-script (string-append #$output "/bin/slick-greeter")
                ;; Wrap GDK_PIXBUF_MODULE_FILE, so that the SVG loader is
                ;; available at all times even outside of profiles, such as
                ;; when used in the lightdm-service-type.  Otherwise, it
                ;; wouldn't be able to display its own icons.
                `("GDK_PIXBUF_MODULE_FILE" =
                  (,(string-append
                     #$output
                     "/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache")))
                `("XDG_DATA_DIRS" ":" prefix
                  (,(string-append "/run/current-system/profile/share:"
                                   (getenv "XDG_DATA_DIRS"))))
                '("XCURSOR_PATH" ":" prefix
                  ("/run/current-system/profile/share/icons")))))
          (add-after 'install 'wrap-program
            (lambda _
              (for-each
               (lambda (prog)
                 (wrap-program (string-append #$output "/bin/" prog)
                   `("GUIX_PYTHONPATH" ":" prefix (,(getenv "GUIX_PYTHONPATH")))
                   `("GI_TYPELIB_PATH" ":" prefix (,(getenv "GI_TYPELIB_PATH")))))
               '("slick-greeter-check-hidpi"
                 "slick-greeter-set-keyboard-layout"
                 "slick-greeter-enable-tap-to-click"))))
          (add-after 'install 'fix-.desktop-file
            (lambda _
              (substitute* (string-append
                            #$output
                            "/share/xgreeters/slick-greeter.desktop")
                (("Exec=slick-greeter")
                 (string-append "Exec="
                                (string-append
                                 #$output "/bin/slick-greeter")))))))))
    (native-inputs
     (list gettext-minimal
           (list glib "bin")
           pkg-config
           vala))
    (inputs
     (list dbus
           gtk+
           guile-3.0
           libcanberra
           libgnomekbd
           libxapp
           libxkbfile
           lightdm
           numlockx
           pixman
           python-pygobject
           python-wrapper))
    (synopsis "A slick-looking LightDM greeter")
    (home-page "https://github.com/linuxmint/slick-greeter")
    (description "Slick-Greeter is a fork of Unity Greeter 16.04.2, it is
cross-distribution and work pretty much anywhere, it supports HiDPI, If a
default/chosen session isn't present on the system, it will scans for known
sessions dirs and replaces the invalid session choice with a valid session.")
    (license license:gpl3)))

(define-public lightdm-tiny-greeter
  (let ((commit "6717c5853315ebd8164b1ddf85b9483f92cbcae8")
        (revision "0"))
    (package
      (name "lightdm-tiny-greeter")
      ;; Version 1.2 release in 2021, so we use a recent commit.
      (version (git-version "1.2" revision commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/tobiohlala/lightdm-tiny-greeter")
                      (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "1n970d6525fd918i1j09akxiacqbpxni8apkfi542bq5zg5crjbs"))))
      (build-system glib-or-gtk-build-system)
      (arguments
       (list
        #:tests? #f ; No test target.
        #:phases
        #~(modify-phases %standard-phases
            (delete 'configure)
            (add-after 'unpack 'patch-hardcoded-paths
              (lambda _
                (substitute* "Makefile"
                  (("PREFIX = /usr")
                   (string-append "PREFIX = " #$output))
                  (("/usr/share/xgreeters")
                   (string-append #$output "/share/xgreeters"))
                  (("cp lightdm-tiny-greeter")
                   "mkdir -p $(PREFIX)/bin; cp lightdm-tiny-greeter"))))
            (add-after 'glib-or-gtk-wrap 'custom-wrap
              (lambda _
                (wrap-script (string-append #$output "/bin/lightdm-tiny-greeter")
                  ;; Wrap GDK_PIXBUF_MODULE_FILE, so that the SVG loader is
                  ;; available at all times even outside of profiles, such as
                  ;; when used in the lightdm-service-type.  Otherwise, it
                  ;; wouldn't be able to display its own icons.
                  `("GDK_PIXBUF_MODULE_FILE" =
                    (,(string-append
                       #$output
                       "/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache")))
                  `("XDG_DATA_DIRS" ":" prefix
                    (,(string-append "/run/current-system/profile/share:"
                                     (getenv "XDG_DATA_DIRS"))))
                  '("XCURSOR_PATH" ":" prefix
                    ("/run/current-system/profile/share/icons")))))
            (add-after 'install 'fix-.desktop-file
              (lambda _
                (substitute* (string-append
                              #$output "/share/xgreeters/lightdm-tiny-greeter.desktop")
                  (("Exec=lightdm-tiny-greeter")
                   (string-append "Exec="
                                  (string-append
                                   #$output "/bin/lightdm-tiny-greeter")))))))))
      (native-inputs
       (list autoconf automake pkg-config))
      (inputs
       (list gtk+ guile-3.0 lightdm))
      (synopsis "Tiny Greeter for LightDM")
      (home-page "https://github.com/tobiohlala/lightdm-tiny-greeter")
      (description "A tiny yet customizable GTK3 LightDM Greeter with focus on code and
minimalism.")
      (license license:bsd-3))))

(define* (customize-lightdm-tiny-greeter #:key name session
                                         user_text pass_text
                                         fontname fontsize)
  "Make a customized lightdm-tiny-greeter package which name is NAME.

This function will change SESSION, USER_TEXT, PASS_TEXT, FONTNAME and FONTSIZE
in config.h of lightdm-tiny-greeter."
  (package
    (inherit lightdm-tiny-greeter)
    (name (or name (string-append
                    (package-name lightdm-tiny-greeter)
                    "-" (or session "default"))))
    (arguments
     (substitute-keyword-arguments
         (package-arguments lightdm-tiny-greeter)
       ((#:phases phases)
        #~(modify-phases #$phases
            (add-after 'unpack 'patch-config-h
              (lambda _
                (when #$user_text
                  (substitute* "config.h"
                    (("\\*user_text = .*;")
                     (string-append "*user_text = \"" #$user_text "\";"))))
                (when #$pass_text
                  (substitute* "config.h"
                    (("\\*pass_text = .*;")
                     (string-append "*pass_text = \"" #$pass_text "\";"))))
                (when #$session
                  (substitute* "config.h"
                    (("\\*session = .*;")
                     (string-append "*session = \"" #$session "\";"))))
                (when #$fontname
                  (substitute* "config.h"
                    (("font: .*px .*;")
                     (string-append "font: 16px \\\"" #$fontname "\\\";"))))
                (when #$fontsize
                  (substitute* "config.h"
                    (("font: .*px")
                     (string-append "font: " #$fontsize "px"))))))))))))
