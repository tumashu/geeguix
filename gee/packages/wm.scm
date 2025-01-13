(define-module (gee packages wm)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages fribidi)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages image)
  #:use-module (gnu packages markup)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages xorg))

(define-public icewm-gee
  (let ((commit "ecec0429a25aa34f426a9c8ba2abe04579f496a3")
        (revision "0"))
    (package
      (name "icewm-gee")
      (version (git-version "3.6.0" revision commit))
      (source (origin
                (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/bbidulock/icewm.git")
                      (commit commit)))
                (file-name (git-file-name name version))
                (sha256
                 (base32
                  "07nddq800z0sb9pirmyh9m5z9aivwd4mw605x8q7bbcnnks9lifr"))))
      (build-system gnu-build-system)
      (native-inputs
       (list autoconf
             automake
             gettext-minimal
             libtool
             markdown
             which
             pkg-config))
      (inputs
       (list fontconfig
             fribidi
             glib                  ;for icewm-menu-fdo
             imlib2
             libice
             libjpeg-turbo
             libsm
             (librsvg-for-system)  ;for svg support
             libxcomposite
             libxdamage
             libxext
             libxfixes
             libxft
             libxinerama
             libxpm
             libxrandr
             libxrender
             libx11
             lzip
             perl))
      (arguments
       (list
        #:tests? #f
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'skip-failing-test
              ;; strtest.cc tests failing due to $HOME and /etc setup
              ;; difference under guix
              (lambda _
                (substitute* "src/Makefile.am"
                  (("TESTS = strtest\\$\\(EXEEXT\\)")
                   "TESTS = ")))))))
      (home-page "https://ice-wm.org/")
      (synopsis "Window manager for the X Window System")
      (description
       "IceWM is a window manager for the X Window System.  The goal of IceWM is
speed, simplicity, and not getting in the user’s way.  It comes with a taskbar
with pager, global and per-window keybindings and a dynamic menu system.
Application windows can be managed by keyboard and mouse.  Windows can be
iconified to the taskbar, to the tray, to the desktop or be made hidden.  They
are controllable by a quick switch window (Alt+Tab) and in a window list.  A
handful of configurable focus models are menu-selectable.  Setups with
multiple monitors are supported by RandR and Xinerama.  IceWM is very
configurable, themeable and well documented.  It includes an optional external
background wallpaper manager with transparency support, a simple session
manager and a system tray.")
      (license license:lgpl2.0))))
