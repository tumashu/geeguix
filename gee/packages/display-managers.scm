(define-module (gee packages display-managers)
  #:use-module (gee packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system cmake)
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
