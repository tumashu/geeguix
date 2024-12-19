;; (define-module (gee packages display-managers)
;;   #:use-module (gee packages)
;;   #:use-module (guix packages)
;;   #:use-module (guix download)
;;   #:use-module (gnu packages display-managers))

(define-module (gee packages display-managers)
  #:use-module (gee packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system qt)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system glib-or-gtk)
  #:use-module (guix build-system meson)
  #:use-module (guix build-system trivial)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (gnu packages)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages crypto)
  #:use-module (gnu packages cinnamon)
  #:use-module (gnu packages display-managers)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages image)
  #:use-module (gnu packages kde-frameworks)
  #:use-module (gnu packages libcanberra)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xfce)
  #:use-module (gnu packages xorg))


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
    (version "2.0.8")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/linuxmint/slick-greeter")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "0pk8d8mpnrh70xdi9mfn1h5xkrf09v06vbi1p1wzqdskzfh3ci1n"))))
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
            (lambda _
              (substitute* '("src/slick-greeter.vala"
                             "src/session-list.vala")
                (("/usr/bin/slick-greeter-")
                 (string-append #$output "/bin/slick-greeter-"))
                (("/usr/share/slick-greeter/badges/")
                 (string-append #$output "/share/slick-greeter/badges/"))
                (("/usr/share/xsessions/")
                 "/run/current-system/profile/share/xsessions/")
                (("/usr/share/wayland-sessions/")
                 "/run/current-system/profile/share/wayland-sessions/"))))
          (add-after 'glib-or-gtk-wrap 'custom-wrap
            (lambda* (#:key outputs #:allow-other-keys)
              (wrap-script (search-input-file
                            outputs "bin/slick-greeter")
                ;; Wrap GDK_PIXBUF_MODULE_FILE, so that the SVG loader is
                ;; available at all times even outside of profiles, such as
                ;; when used in the lightdm-service-type.  Otherwise, it
                ;; wouldn't be able to display its own icons.
                `("GDK_PIXBUF_MODULE_FILE" =
                  (,(search-input-file
                     outputs
                     "lib/gdk-pixbuf-2.0/2.10.0/loaders.cache")))
                `("XDG_DATA_DIRS" ":" prefix
                  (,(string-append "/run/current-system/profile/share:"
                                   (getenv "XDG_DATA_DIRS"))))
                '("XCURSOR_PATH" ":" prefix
                  ("/run/current-system/profile/share/icons")))))
          (add-after 'install 'wrap-program
            (lambda* (#:key outputs #:allow-other-keys)
              (for-each (lambda (prog)
                          (wrap-program (string-append #$output "/bin/" prog)
                            `("GUIX_PYTHONPATH"      ":" prefix (,(getenv "GUIX_PYTHONPATH")))
                            `("GI_TYPELIB_PATH" ":" prefix (,(getenv "GI_TYPELIB_PATH")))))
                        '("slick-greeter-check-hidpi"
                          "slick-greeter-set-keyboard-layout"
                          "slick-greeter-enable-tap-to-click"))))
          (add-after 'install 'fix-.desktop-file
            (lambda* (#:key outputs #:allow-other-keys)
              (substitute* (search-input-file
                            outputs
                            "share/xgreeters/slick-greeter.desktop")
                (("Exec=slick-greeter")
                 (string-append "Exec="
                                (search-input-file
                                 outputs "bin/slick-greeter")))))))))
    (native-inputs
     (list gettext-minimal
           gnome-common
           (list glib "bin")
           pkg-config
           vala))
    (inputs
     (list at-spi2-core
           bash-minimal                 ;for wrap-program
           dbus
           dbus-glib
           gtk+
           guile-3.0
           libcanberra
           libgnomekbd
           libxapp
           libxkbfile
           lightdm
           pixman
           python-wrapper
           python-pygobject
           shared-mime-info
           xvfb-run))
    (synopsis "A slick-looking LightDM greeter")
    (home-page "https://github.com/linuxmint/slick-greeter")
    (description "Slick-Greeter is a fork of Unity Greeter 16.04.2, it is
cross-distribution and work pretty much anywhere, it supports HiDPI, If a
default/chosen session isn't present on the system, it will scans for known
sessions dirs and replaces the invalid session choice with a valid session.")
    (license license:gpl3)))


(define-public lightdm-mini-greeter
  (package
    (name "lightdm-mini-greeter")
    (version "0.5.1-ead793")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/prikhi/lightdm-mini-greeter")
                    (commit "ead7936993b4e9e067d73fa49dec7edfb46c73a8")))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "17iy1jkllmi2xc95csb18wcfvbk44gyva2in2k5f29fy362ppz25"))))
    (build-system glib-or-gtk-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'customize-default-config-path
            (lambda _
              (substitute* "Makefile.am"
                ;; Have the default config directory sourced from
                ;; /etc/lightdm/lightdm-mini-greeter.conf, which is where the
                ;; lightdm service writes it.
                (("\\$\\(sysconfdir)/lightdm/lightdm-mini-greeter.conf")
                 "/etc/lightdm/lightdm-mini-greeter.conf"))))
          (add-after 'install 'fix-.desktop-file
            (lambda* (#:key outputs #:allow-other-keys)
              (substitute* (search-input-file
                            outputs
                            "share/xgreeters/lightdm-mini-greeter.desktop")
                (("Exec=lightdm-mini-greeter")
                 (string-append "Exec="
                                (search-input-file
                                 outputs "bin/lightdm-mini-greeter")))))))))
    (native-inputs
     (list autoconf automake pkg-config))
    (inputs
     (list gtk+ lightdm))
    (synopsis "Mini Greeter for LightDM")
    (home-page "https://github.com/prikhi/lightdm-mini-greeter")
    (description "This package provide a minimal but highly configurable single-user GTK3
greeter for LightDM, this greeter is inspired by the SLiM Display Manager and
LightDM GTK3 Greeter.")
    (license license:gpl3)))
