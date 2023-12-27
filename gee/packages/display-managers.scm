(define-module (gee packages display-managers)
  #:use-module (gee packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build utils)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gtk)
  #:use-module (guix build-system glib-or-gtk)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages display-managers)
  #:use-module (gnu packages xfce)
  #:use-module (gnu packages python)
  #:use-module (gnu packages cinnamon)
  #:use-module (guix build-system cmake)
  #:use-module (gnu packages libcanberra)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (gnu packages)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages base)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages image)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg))


(define-public lightdm-gee
  (package
    (name "lightdm-gee")
    (version "1.32.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/canonical/lightdm")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1wr60c946p8jz9kb8zi4cd8d4mkcy7infbvlfzwajiglc22nblxn"))
              (patches (geeguix-search-patches
                        "lightdm-test.patch"
                        "lightdm-arguments-ordering.patch"
                        "lightdm-vncserver-check.patch"
                        "lightdm-vnc-color-depth.patch"
                        "lightdm-vnc-ipv6.patch"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f
      #:parallel-tests? #f             ; fails when run in parallel
      #:configure-flags
      #~(list "--localstatedir=/var"
              "--enable-gtk-doc"
              ;; Otherwise the test suite fails on such a warning.
              "CFLAGS=-Wno-error=missing-prototypes")
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'fix-paths
            (lambda* (#:key inputs #:allow-other-keys)
              (substitute* "src/shared-data-manager.c"
                (("/bin/rm")
                 (search-input-file inputs "bin/rm")))
              (substitute* '("data/users.conf"
                             "common/user-list.c")
                (("/bin/false")
                 (search-input-file inputs "bin/false"))
                (("/usr/sbin/nologin")
                 (search-input-file inputs "sbin/nologin")))
              (substitute* "src/seat.c"
                (("/bin/sh")
                 (search-input-file inputs "bin/sh")))))
          (add-before 'check 'pre-check
            (lambda _
              (wrap-program "tests/src/test-python-greeter"
                `("GUIX_PYTHONPATH"      ":" prefix (,(getenv "GUIX_PYTHONPATH")))
                `("GI_TYPELIB_PATH" ":" prefix (,(getenv "GI_TYPELIB_PATH"))))
              ;; Avoid printing locale warnings, which trip up the text
              ;; matching tests.
              (unsetenv "LC_ALL"))))))
    (inputs
     (list audit
           bash-minimal                 ;for cross-compilation
           coreutils-minimal            ;ditto
           linux-pam
           shadow                       ;for sbin/nologin
           libgcrypt
           libxcb
           libxdmcp))
    (native-inputs
     (list accountsservice
           autoconf
           automake
           `(,glib "bin")               ;gio-2.0.
           gobject-introspection
           gtk-doc
           pkg-config
           itstool
           intltool
           libtool
           libx11                       ;
           libxklavier                  ;
           vala                         ;for Vala bindings
           ;; For tests
           dbus
           python-wrapper
           python-pygobject
           which
           yelp-tools))
    ;; Required by liblightdm-gobject-1.pc.
    (propagated-inputs
     (list glib libx11 libxklavier))
    (home-page "https://www.freedesktop.org/wiki/Software/LightDM/")
    (synopsis "Lightweight display manager")
    (description "The Light Display Manager (LightDM) is a cross-desktop
display manager which supports different greeters.")
    (license license:gpl3+)))

(define-public lightdm-gtk-greeter-gee
  (package
    (name "lightdm-gtk-greeter-gee")
    (version "2.0.8")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/xubuntu/lightdm-gtk-greeter"
                    "/releases/download/lightdm-gtk-greeter-" version "/"
                    "lightdm-gtk-greeter-" version ".tar.gz"))
              (sha256
               (base32
                "04q62mvr97l9gv8h37hfarygqc7p0498ig7xclcg4kxkqw0b7yxy"))
              (patches (geeguix-search-patches
                        "lightdm-gtk-greeter-test.patch"
                        ))))
    (build-system glib-or-gtk-build-system)
    (arguments
     (list
      #:configure-flags
      #~(list "--disable-indicator-services-command" ;requires upstart
              ;; Put the binary under /bin rather than /sbin, so that it gets
              ;; wrapped by the glib-or-gtk-wrap phase.
              (string-append "--sbindir=" #$output "/bin")
              (string-append "--with-libxklavier")
              (string-append "--enable-at-spi-command="
                             (search-input-file
                              %build-inputs "libexec/at-spi-bus-launcher")
                             " --launch-immediately"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'customize-default-config-path
            (lambda _
              (substitute* "src/Makefile.in"
                ;; Have the default config directory sourced from
                ;; /etc/lightdm/lightdm-gtk-greeter.conf, which is where the
                ;; lightdm service writes it.
                (("\\$\\(sysconfdir)/lightdm/lightdm-gtk-greeter.conf")
                 "/etc/lightdm/lightdm-gtk-greeter.conf"))))
          (add-after 'install 'fix-.desktop-file
            (lambda* (#:key outputs #:allow-other-keys)
              (substitute* (search-input-file
                            outputs
                            "share/xgreeters/lightdm-gtk-greeter.desktop")
                (("Exec=lightdm-gtk-greeter")
                 (string-append "Exec="
                                (search-input-file
                                 outputs "bin/lightdm-gtk-greeter"))))))
          (add-after 'glib-or-gtk-wrap 'custom-wrap
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (wrap-script (search-input-file
                            outputs "bin/lightdm-gtk-greeter")                
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
                  ("/run/current-system/profile/share/icons"))))))))
    (native-inputs
     (list exo
           intltool
           pkg-config
           xfce4-dev-tools))
    (inputs
     (list at-spi2-core
           bash-minimal                 ;for wrap-program
           gtk+
           guile-3.0
           (librsvg-for-system)
           libxklavier
           lightdm
           shared-mime-info))
    (synopsis "GTK+ greeter for LightDM")
    (home-page "https://github.com/xubuntu/lightdm-gtk-greeter")
    (description "This package provides a LightDM greeter implementation using
GTK+, lets you select a desktop session and log in to it.")
    (license license:gpl3+)))

(define-public lightdm-slick-greeter-gee
  (package
    (name "lightdm-slick-greeter-gee")
    (version "2.0.2")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/linuxmint/slick-greeter")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1mpr6bdn500wzvq466ycrmqywk6yfv7dch07v89ndfycg5i6idvx"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f ;no test
      #:configure-flags
      #~(list (string-append "--sbindir=" #$output "/bin")
              (string-append "--with-libxklavier")
              (string-append "--enable-at-spi-command="
                             (search-input-file
                              %build-inputs "libexec/at-spi-bus-launcher")
                             " --launch-immediately"))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'fix-.desktop-file
            (lambda* (#:key outputs #:allow-other-keys)
              (substitute* (search-input-file
                            outputs
                            "share/xgreeters/slick-greeter.desktop")
                (("Exec=slick-greeter")
                 (string-append "Exec="
                                (search-input-file
                                 outputs "bin/slick-greeter"))))))
          (add-after 'unpack 'fix-autogen.sh
            (lambda* (#:key inputs #:allow-other-keys)
              (substitute* "autogen.sh"
                (("which")
                 (search-input-file inputs "/bin/which"))
                (("gnome-autogen.sh")
                 (search-input-file inputs "/bin/gnome-autogen.sh"))))))))
    (native-inputs
     (list vala
           which
           automake
           autoconf
           intltool
           gnome-common
           `(,glib "bin")
           pkg-config))
    (inputs
     (list at-spi2-core
           dbus
           libxapp
           libgnomekbd
           libxkbfile
           libcanberra
           gtk+
           lightdm
           pixman
           xvfb-run))
    (synopsis "A slick-looking LightDM greeter")
    (home-page "https://github.com/xubuntu/lightdm-gtk-greeter")
    (description "This package provides a LightDM greeter implementation using
GTK+, lets you select a desktop session and log in to it.")
    (license license:gpl3+)))

(define-public slim-gee
  (package
    (name "slim-gee")
    (version "1.4.0")
    (source (origin
	      (method url-fetch)
	      (uri (string-append
                    "mirror://sourceforge/slim-fork/slim-"
                    version ".tar.gz"))
	      (sha256
	       (base32 "011jfmksy0kgw4z0y70mc80bm5kmz5i1sgm6krrfj0h00zak22rm"))
              (patches (geeguix-search-patches "slim-config.patch"
                                               "slim-login.patch"
                                               "slim-display.patch"))))
    (build-system cmake-build-system)
    (inputs (list linux-pam
                  libpng
	          libjpeg-turbo
                  freeglut
                  libxrandr
                  libxrender
                  freetype
                  fontconfig
                  libx11
	          libxft
	          libxmu
	          xauth))
    (native-inputs
     (list pkg-config))
    (arguments
     (list #:phases
           #~(modify-phases %standard-phases
               (add-before 'configure 'set-new-etc-location
                 (lambda _
                   (substitute* "CMakeLists.txt"
                     (("/etc")
                      (string-append #$output "/etc"))))))
           #:configure-flags
           #~(list "-DUSE_PAM=yes"
                   "-DUSE_CONSOLEKIT=no")
           #:tests? #f))
    ;; The original project (https://github.com/iwamatsu/slim) has not been
    ;; maintained since 2013, so we use a slim-fork instead.
    (home-page "https://slim-fork.sourceforge.io/")
    (synopsis "Desktop-independent graphical login manager for X11")
    (description
     "SLiM is a Desktop-independent graphical login manager for X11, derived
from Login.app.  It aims to be light and simple, although completely
configurable through themes and an option file; is suitable for machines on
which remote login functionalities are not needed.

Features included: PNG and XFT support for alpha transparency and antialiased
fonts, External themes support, Configurable runtime options: X server --
login / shutdown / reboot commands, Single (GDM-like) or double (XDM-like)
input control, Can load predefined user at startup, Configurable welcome /
shutdown messages, Random theme selection.")
    (license license:gpl2)))
