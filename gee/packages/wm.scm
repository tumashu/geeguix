(define-module (gee packages wm)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system trivial)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bison)
  #:use-module (gnu packages build-tools)
  #:use-module (gnu packages calendar)
  #:use-module (gnu packages check)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages cpp)
  #:use-module (gnu packages docbook)
  #:use-module (gnu packages documentation)
  #:use-module (gnu packages engineering)
  #:use-module (gnu packages flex)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages fribidi)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gperf)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages image)
  #:use-module (gnu packages libevent)
  #:use-module (gnu packages libffi)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages logging)
  #:use-module (gnu packages man)
  #:use-module (gnu packages markup)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages mpd)
  #:use-module (gnu packages pciutils)
  #:use-module (gnu packages music)
  #:use-module (gnu packages pcre)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages pretty-print)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-crypto)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages readline)
  #:use-module (gnu packages regex)
  #:use-module (gnu packages serialization)
  #:use-module (gnu packages sphinx)
  #:use-module (gnu packages suckless)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages textutils)
  #:use-module (gnu packages time)
  #:use-module (gnu packages web)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xml)
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
      (build-system cmake-build-system)
      (native-inputs
       (list autoconf
             automake
             gettext-minimal
             libtool
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
             python-markdown
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
