;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2016 Fabian Harfert <fhmgufs@web.de>
;;; Copyright © 2016, 2017 Efraim Flashner <efraim@flashner.co.il>
;;; Copyright © 2017 Nikita <nikita@n0.is>
;;; Copyright © 2018, 2019, 2020 Tobias Geerinckx-Rice <me@tobias.gr>
;;; Copyright © 2019, 2020, 2021 Ludovic Courtès <ludo@gnu.org>
;;; Copyright © 2019 Guy Fleury Iteriteka <hoonandon@gmail.com>
;;; Copyright © 2020 Jonathan Brielmaier <jonathan.brielmaier@web.de>
;;; Copyright © 2020 Mathieu Othacehe <m.othacehe@gmail.com>
;;; Copyright © 2021 Guillaume Le Vaillant <glv@posteo.net>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (geeguix mate)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system glib-or-gtk)
  #:use-module (guix build-system meson)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages)
  #:use-module (gnu packages attr)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages backup)
  #:use-module (gnu packages base)
  #:use-module (gnu packages check)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages djvu)
  #:use-module (gnu packages docbook)
  #:use-module (gnu packages documentation)
  #:use-module (gnu packages enchant)
  #:use-module (gnu packages file)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages ghostscript)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages image)
  #:use-module (gnu packages imagemagick)
  #:use-module (gnu packages iso-codes)
  #:use-module (gnu packages javascript)
  #:use-module (gnu packages libcanberra)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages messaging)
  #:use-module (gnu packages multiprecision)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages pdf)
  #:use-module (gnu packages photo)
  #:use-module (gnu packages polkit)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages samba)
  #:use-module (gnu packages tex)
  #:use-module (gnu packages webkit)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg))

(define-public mate-common
(package
  (name "mate-common")
  (version "1.26.0")
  (source
   (origin
     (method url-fetch)
     (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                         name "-" version ".tar.xz"))
     (sha256
      (base32
       "014wpfqpqmfkzv81paap4fz15mj1gsyvaxlrfqsp9a3yxw4f7jaf"))))
  (build-system gnu-build-system)
  (home-page "https://mate-desktop.org/")
  (synopsis "Common files for development of MATE packages")
  (description
   "Mate Common includes common files and macros used by
MATE applications.")
  (license license:gpl3+)))

(define-public mate-power-manager
  (package
    (name "mate-power-manager")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           "mate-power-manager-" version ".tar.xz"))
       (sha256
        (base32 "0ybvwv24g8awxjl2asgvx6l2ghn4limcm48ylha68dkpy3607di6"))))
    (build-system gnu-build-system)
    (native-inputs
     (list pkg-config
           yelp-tools
           gettext-minimal
           `(,glib "bin") ; glib-gettextize
           polkit)) ; for ITS rules
    (inputs
     (list gtk+
           glib
           dbus-glib
           libgnome-keyring
           cairo
           dbus
           libnotify
           mate-panel
           libxrandr
           libsecret
           libcanberra
           upower))
    (home-page "https://mate-desktop.org/")
    (synopsis "Power manager for MATE")
    (description
     "MATE Power Manager is a MATE session daemon that acts as a policy agent on
top of UPower.  It listens to system events and responds with user-configurable
actions.")
    (license license:gpl2+)))

(define-public mate-icon-theme
  (package
    (name "mate-icon-theme")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           name "-" version ".tar.xz"))
       (sha256
        (base32
         "0nha555fhhn0j5wmzmdc7bh93ckzwwdm8mwmzma5whkzslv09xa1"))))
    (build-system gnu-build-system)
    (native-inputs
     (list pkg-config intltool icon-naming-utils))
    (home-page "https://mate-desktop.org/")
    (synopsis "The MATE desktop environment icon theme")
    (description
     "This package contains the default icon theme used by the MATE desktop.")
    (license license:lgpl3+)))

(define-public mate-icon-theme-faenza
  (package
    (name "mate-icon-theme-faenza")
    (version "1.20.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           name "-" version ".tar.xz"))
       (sha256
        (base32
         "000vr9cnbl2qlysf2gyg1lsjirqdzmwrnh6d3hyrsfc0r2vh4wna"))))
    (build-system gnu-build-system)
    (arguments
     (list #:phases
           #~(modify-phases %standard-phases
               (add-after 'unpack 'autoconf
                 (lambda _
                   (setenv "SHELL" (which "sh"))
                   (setenv "CONFIG_SHELL" (which "sh"))
                   (invoke "sh" "autogen.sh"))))))
    (native-inputs
     ;; autoconf-wrapper is required due to the non-standard
     ;; 'autoconf phase.
     (list autoconf-wrapper
           automake
           intltool
           icon-naming-utils
           libtool
           mate-common
           pkg-config
           which))
    (home-page "https://mate-desktop.org/")
    (synopsis "MATE desktop environment icon theme faenza")
    (description
     "Icon theme using Faenza and Faience icon themes and some
customized icons for MATE.  Furthermore it includes some icons
from Mint-X-F and Faenza-Fresh icon packs.")
    (license license:gpl2+)))

(define-public mate-themes
  (package
    (name "mate-themes")
    (version "3.22.23")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/themes/" (version-major+minor version)
                           "/mate-themes-" version ".tar.xz"))
       (sha256
        (base32 "1avgzccdmr7y18rnp3xrhwk82alv2dlig3wh7ivgahcqdiiavrb1"))))
    (build-system gnu-build-system)
    (native-inputs
     (list pkg-config intltool gdk-pixbuf ; gdk-pixbuf+svg isn't needed
           gtk+-2))
    (home-page "https://mate-desktop.org/")
    (synopsis
     "Official themes for the MATE desktop")
    (description
     "This package includes the standard themes for the MATE desktop, for
example Menta, TraditionalOk, GreenLaguna or BlackMate.  This package has
themes for both gtk+-2 and gtk+-3.")
    (license (list license:lgpl2.1+ license:cc-by-sa3.0 license:gpl3+
                   license:gpl2+))))

(define-public mate-desktop
  (package
    (name "mate-desktop")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           "mate-desktop-" version ".tar.xz"))
       (sha256
        (base32 "18sj8smf0b998m5qvki37hxg0agcx7wmgz9z7cwv6v48i2dnnz2z"))))
    (build-system gnu-build-system)
    (native-inputs
     (list pkg-config
           intltool
           `(,glib "bin")
           gobject-introspection
           yelp-tools
           gtk-doc))
    (inputs
     (list gtk+ libxrandr iso-codes startup-notification))
    (propagated-inputs
     (list dconf)) ; mate-desktop-2.0.pc
    (home-page "https://mate-desktop.org/")
    (synopsis "Library with common API for various MATE modules")
    (description
     "This package contains a public API shared by several applications on the
desktop and the mate-about program.")
    (license (list license:gpl2+ license:lgpl2.0+ license:fdl1.1+))))

(define-public libmateweather
  (package
    (name "libmateweather")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           "libmateweather-" version ".tar.xz"))
       (sha256
        (base32 "05bvc220p135l6qnhh3qskljxffds0f7fjbjnrpq524w149rgzd7"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:configure-flags
      #~(list (string-append "--with-zoneinfo-dir=" #$tzdata "/share/zoneinfo"))
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'check 'fix-tzdata-location
            (lambda* (#:key inputs #:allow-other-keys)
              (substitute* "data/check-timezones.sh"
                (("/usr/share/zoneinfo/zone.tab")
                 (search-input-file inputs "/share/zoneinfo/zone.tab"))))))))
    (native-inputs
     (list pkg-config
           intltool
           dconf
           (list glib "bin")))
    (inputs
     (list gtk+ tzdata))
    (propagated-inputs
     ;; both of these are requires.private in mateweather.pc
     (list libsoup-minimal-2 libxml2))
    (home-page "https://mate-desktop.org/")
    (synopsis "MATE library for weather information from the Internet")
    (description
     "This library provides access to weather information from the internet for
the MATE desktop environment.")
    (license license:lgpl2.1+)))

(define-public mate-terminal
  (package
    (name "mate-terminal")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           "mate-terminal-" version ".tar.xz"))
       (sha256
        (base32 "08mgxbviik2dwwnbclp0518wlag2fhcr6c2yadgcbhwiq4aff9vp"))))
    (build-system glib-or-gtk-build-system)
    (native-inputs
     (list pkg-config
           intltool
           itstool
           gobject-introspection
           libxml2
           yelp-tools))
    (inputs
     (list dconf
           gtk+
           libice
           libsm
           libx11
           mate-desktop
           pango
           vte))
    (home-page "https://mate-desktop.org/")
    (synopsis "MATE Terminal Emulator")
    (description
     "MATE Terminal is a terminal emulation application that you can
use to access a shell.  With it, you can run any application that
is designed to run on VT102, VT220, and xterm terminals.
MATE Terminal also has the ability to use multiple terminals
in a single window (tabs) and supports management of different
configurations (profiles).")
    (license license:gpl3)))

(define-public mate-session-manager
  (package
    (name "mate-session-manager")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           "mate-session-manager-" version ".tar.xz"))
       (sha256
        (base32 "05hqi8wlwjr07mp5njhp7h06mgnv98zsxaxkmxc5w3iwb3va45ar"))))
    (build-system glib-or-gtk-build-system)
    (arguments
     (list
      #:configure-flags
      #~(list "--with-elogind" "--disable-schemas-compile")
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'update-xsession-dot-desktop
            (lambda _
              ;; Record the absolute file name of 'mate-session' in the
              ;; '.desktop' file.
              (substitute* (string-append #$output"/share/xsessions/mate.desktop")
                (("^Exec=.*$")
                 (string-append "Exec=" #$output "/bin/mate-session\n"))
                (("^TryExec=.*$")
                 (string-append "Exec=" #$output "/bin/mate-session\n"))))))))
    (native-inputs
     (list pkg-config intltool libxcomposite xtrans
           gobject-introspection))
    (inputs
     (list gtk+ dbus-glib elogind libsm mate-desktop))
    (home-page "https://mate-desktop.org/")
    (synopsis "Session manager for MATE")
    (description
     "Mate-session contains the MATE session manager, as well as a
configuration program to choose applications starting on login.")
    (license license:gpl2)))

(define-public mate-settings-daemon
  (package
    (name "mate-settings-daemon")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           "mate-settings-daemon-" version ".tar.xz"))
       (sha256
        (base32 "0hbdwqagxh1mdpxfdqr1ps3yqvk0v0c5zm0bwk56y6l1zwbs0ymp"))))
    (build-system glib-or-gtk-build-system)
    (native-inputs
     (list pkg-config intltool gobject-introspection))
    (inputs
     (list cairo
           dbus
           dbus-glib
           dconf
           fontconfig
           gtk+
           libcanberra
           libmatekbd
           libmatemixer
           libnotify
           libx11
           libxext
           libxi
           libxklavier
           mate-desktop
           nss
           polkit
           startup-notification))
    (home-page "https://mate-desktop.org/")
    (synopsis "Settings Daemon for MATE")
    (description
     "Mate-settings-daemon is a fork of gnome-settings-daemon.")
    (license (list license:lgpl2.1 license:gpl2))))

(define-public libmatemixer
  (package
    (name "libmatemixer")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           "libmatemixer-" version ".tar.xz"))
       (sha256
        (base32 "1wcz4ppg696m31f5x7rkyvxxdriik2vprsr83b4wbs97bdhcr6ws"))))
    (build-system glib-or-gtk-build-system)
    (native-inputs
     (list pkg-config intltool gobject-introspection))
    (inputs
     (list glib pulseaudio alsa-lib))
    (home-page "https://mate-desktop.org/")
    (synopsis "Mixer library for the MATE desktop")
    (description
     "Libmatemixer is a mixer library for MATE desktop.  It provides an abstract
API allowing access to mixer functionality available in the PulseAudio and ALSA
sound systems.")
    (license license:lgpl2.1)))

(define-public libmatekbd
  (package
    (name "libmatekbd")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           "libmatekbd-" version ".tar.xz"))
       (sha256
        (base32 "1b8iv2hmy8z2zzdsx8j5g583ddxh178bq8dnlqng9ifbn35fh3i2"))))
    (build-system glib-or-gtk-build-system)
    (native-inputs
     (list pkg-config intltool gobject-introspection))
    (inputs
     (list cairo
           (librsvg-for-system)
           glib
           gtk+
           libx11
           libxklavier))
    (home-page "https://mate-desktop.org/")
    (synopsis "MATE keyboard configuration library")
    (description
     "Libmatekbd is a keyboard configuration library for the
MATE desktop environment.")
    (license license:lgpl2.1)))

(define-public mozo
  (package
    (name "mozo")
    (version "1.26.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           "mozo-" version ".tar.xz"))
       (sha256
        (base32 "0fgsy9g2rrzi1bjzaigk7sr447kqv3cr3hy4irld0yq37fd4490g"))
       (patches (search-patches "geeguix/patches/mozo-import-and-use-locale-package.patch"))))
    (build-system meson-build-system)
    (arguments
     (list #:phases
           #~(modify-phases %standard-phases
               (add-after 'unpack 'skip-gtk-update-icon-cache
                 ;; Don't create 'icon-theme.cache'.
                 (lambda _
                   (substitute* "post_install.py"
                     (("gtk-update-icon-cache") "true")
                     (("update-desktop-database") "true")))))))
    (native-inputs
     (list gettext-minimal gobject-introspection intltool pkg-config))
    (inputs
     (list gtk+ glib))
    (propagated-inputs
     (list python-wrapper python-pygobject mate-menus))
    (home-page "https://mate-desktop.org/")
    (synopsis "Easy MATE menu editing tool")
    (description
     "Mozo is an easy-to-use menu editor for MATE that can add and edit new
entries and menus. It works with the freedesktop.org menu specification and
should work with any desktop environment that uses the spec.")
    (license (list license:gpl2+ license:lgpl2.0+))))

(define-public mate-menus
  (package
    (name "mate-menus")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           "mate-menus-" version ".tar.xz"))
       (sha256
        (base32 "1r7zf64aclaplz77hkl9kq0xnz6jk1l49z64i8v56c41pm59c283"))))
    (build-system gnu-build-system)
    (arguments
     (list #:phases
           #~(modify-phases %standard-phases
               (add-after
                   'unpack 'fix-introspection-install-dir
                 (lambda _
                   (substitute* '("configure")
                     (("`\\$PKG_CONFIG --variable=girdir gobject-introspection-1.0`")
                      (string-append "\"" #$output "/share/gir-1.0/\""))
                     (("\\$\\(\\$PKG_CONFIG --variable=typelibdir gobject-introspection-1.0\\)")
                      (string-append #$output "/lib/girepository-1.0/"))))))))
    (native-inputs
     (list pkg-config intltool gobject-introspection))
    (inputs
     (list glib python-2))
    (home-page "https://mate-desktop.org/")
    (synopsis "Freedesktop menu specification implementation for MATE")
    (description
     "The package contains an implementation of the freedesktop menu
specification, the MATE menu layout configuration files, .directory files and
assorted menu related utility programs.")
    (license (list license:gpl2+ license:lgpl2.0+))))

(define-public mate-applets
  (package
    (name "mate-applets")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           "mate-applets-" version ".tar.xz"))
       (sha256
        (base32 "0xy9dwiqvmimqshbfq80jxq65aznlgx491lqq8rl4x8c9sdl7q5p"))))
    (build-system glib-or-gtk-build-system)
    (arguments
     (list #:configure-flags
           #~(list (string-append "--libexecdir=" #$output "/lib/mate-applets"))))
    (native-inputs
     (list pkg-config
           intltool
           libxslt
           yelp-tools
           scrollkeeper
           gettext-minimal
           docbook-xml
           gobject-introspection))
    (inputs
     (list atk
           dbus
           dbus-glib
           glib
           gucharmap
           gtk+
           gtksourceview-3
           libgtop
           libmateweather
           libnl
           libnotify
           libx11
           libxml2
           libwnck
           mate-panel
           pango
           polkit ; either polkit or setuid
           python-2
           upower
           wireless-tools))
    (propagated-inputs
     (list python-pygobject))
    (home-page "https://mate-desktop.org/")
    (synopsis "Various applets for the MATE Panel")
    (description
     "Mate-applets includes various small applications for Mate-panel:

@enumerate
@item accessx-status: indicates keyboard accessibility settings,
including the current state of the keyboard, if those features are in use.
@item Battstat: monitors the power subsystem on a laptop.
@item Character palette: provides a convenient way to access
non-standard characters, such as accented characters,
mathematical symbols, special symbols, and punctuation marks.
@item MATE CPUFreq Applet: CPU frequency scaling monitor
@item Drivemount: lets you mount and unmount drives and file systems.
@item Geyes: pair of eyes which follow the mouse pointer around the screen.
@item Keyboard layout switcher: lets you assign different keyboard
layouts for different locales.
@item Modem Monitor: monitors the modem.
@item Invest: downloads current stock quotes from the Internet and
displays the quotes in a scrolling display in the applet. The
applet downloads the stock information from Yahoo! Finance.
@item System monitor: CPU, memory, network, swap file and resource.
@item Trash: lets you drag items to the trash folder.
@item Weather report: downloads weather information from the
U.S National Weather Service (NWS) servers, including the
Interactive Weather Information Network (IWIN).
@end enumerate\n")
    (license (list license:gpl2+ license:lgpl2.0+ license:gpl3+))))

(define-public mate-media
  (package
    (name "mate-media")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           "mate-media-" version ".tar.xz"))
       (sha256
        (base32 "0fiwzsir8i1bqz7g7b20g5zs28qq63j41v9c5z69q8fq7wh1nwwb"))))
    (build-system glib-or-gtk-build-system)
    (native-inputs
     (list pkg-config intltool gettext-minimal gobject-introspection))
    (inputs
     (list cairo
           gtk+
           libcanberra
           libmatemixer
           libxml2
           mate-applets
           mate-desktop
           mate-panel
           pango
           startup-notification))
    (home-page "https://mate-desktop.org/")
    (synopsis "Multimedia related programs for the MATE desktop")
    (description
     "Mate-media includes the MATE media tools for MATE, including
mate-volume-control, a MATE volume control application and applet.")
    (license (list license:gpl2+ license:lgpl2.0+ license:fdl1.1+))))

(define-public mate-panel
  (package
    (name "mate-panel")
    (version "1.26.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           name "-" version ".tar.xz"))
       (sha256
        (base32 "042lw29y816hr0hhyrncvvs14afqy6109van0v67d7n5i66gki5f"))))
    (build-system glib-or-gtk-build-system)
    (arguments
     (list
      #:configure-flags
      #~(list (string-append "--with-zoneinfo-dir="
                             #$tzdata
                             "/share/zoneinfo")
              "--with-in-process-applets=all")
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'configure 'fix-timezone-path
            (lambda _
              (substitute* "applets/clock/system-timezone.h"
                (("/usr/share/lib/zoneinfo/tab")
                 (string-append #$tzdata "/share/zoneinfo/zone.tab"))
                (("/usr/share/zoneinfo")
                 (string-append #$tzdata "/share/zoneinfo")))))
          (add-after 'unpack 'fix-introspection-install-dir
            (lambda _
              (substitute* '("configure")
                (("`\\$PKG_CONFIG --variable=girdir gobject-introspection-1.0`")
                 (string-append "\"" #$output "/share/gir-1.0/\""))
                (("\\$\\(\\$PKG_CONFIG --variable=typelibdir gobject-introspection-1.0\\)")
                 (string-append #$output "/lib/girepository-1.0/"))))))))
    (native-inputs
     (list pkg-config intltool itstool xtrans gobject-introspection))
    (inputs
     (list dconf
           cairo
           dbus-glib
           gtk-layer-shell
           gtk+
           libcanberra
           libice
           libmateweather
           (librsvg-for-system)
           libsm
           libx11
           libxau
           libxml2
           libxrandr
           libwnck
           mate-desktop
           mate-menus
           pango
           tzdata
           wayland))
    (native-search-paths
     (list (search-path-specification
            (variable "MATE_PANEL_APPLETS_DIR")
            (files (list "share/mate-panel/applets")))))
    (home-page "https://mate-desktop.org/")
    (synopsis "Panel for MATE")
    (description
     "Mate-panel contains the MATE panel, the libmate-panel-applet library and
several applets.  The applets supplied here include the Workspace Switcher,
the Window List, the Window Selector, the Notification Area, the Clock and the
infamous 'Wanda the Fish'.")
    (license (list license:gpl2+ license:lgpl2.0+))))

(define-public atril
  (package
    (name "atril")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           name "-" version ".tar.xz"))
       (sha256
        (base32
         "0pz44k3axhjhhwfrfvnwvxak1dmjkwqs63rhrbcaagyymrp7cpki"))))
    (build-system glib-or-gtk-build-system)
    (arguments
     (list
      #:configure-flags
      #~(list (string-append "--with-openjpeg=" #$openjpeg "openjpeg")
              "--enable-introspection"
              "--disable-schemas-compile")
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'fix-mathjax-path
            (lambda _
              (substitute* "backend/epub/epub-document.c"
                (("/usr/share/javascript/mathjax")
                 (string-append #$js-mathjax "/share/javascript/mathjax")))))
          (add-after 'unpack 'fix-introspection-and-caja-extension-install-dir
            (lambda _
              (substitute* '("configure")
                (("`\\$PKG_CONFIG --variable=extensiondir libcaja-extension`")
                 (string-append "\"" #$output "/lib/caja/extensions-2.0\""))
                (("\\$\\(\\$PKG_CONFIG --variable=girdir gobject-introspection-1.0\\)")
                 (string-append #$output "/share/gir-1.0/"))
                (("\\$\\(\\$PKG_CONFIG --variable=typelibdir gobject-introspection-1.0\\)")
                 (string-append #$output "/lib/girepository-1.0/")))))
          (add-before 'install 'skip-gtk-update-icon-cache
            ;; Don't create 'icon-theme.cache'.
            (lambda _
              (substitute* "data/Makefile"
                (("gtk-update-icon-cache") "true")))))))
    (native-inputs
     (list pkg-config
           intltool
           itstool
           yelp-tools
           (list glib "bin")
           gobject-introspection
           gtk-doc
           texlive-bin ;synctex
           libxml2
           zlib))
    (inputs
     (list atk
           cairo
           caja
           dconf
           dbus
           dbus-glib
           djvulibre
           fontconfig
           freetype
           ghostscript
           glib
           gtk+
           js-mathjax
           libcanberra
           libsecret
           libspectre
           libtiff
           libx11
           libice
           libsm
           libgxps
           libjpeg-turbo
           libxml2
           python-dogtail
           shared-mime-info
           gdk-pixbuf
           gsettings-desktop-schemas
           libgnome-keyring
           libarchive
           marco
           openjpeg
           pango
           ;; texlive
           ;; TODO:
           ;;   Build libkpathsea as a shared library for DVI support.
           ;; ("libkpathsea" ,texlive-bin)
           poppler
           webkitgtk))
    (home-page "https://mate-desktop.org")
    (synopsis "Document viewer for Mate")
    (description
     "Document viewer for Mate")
    (license license:gpl2)))

(define-public caja
  (package
    (name "caja")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           name "-" version ".tar.xz"))
       (sha256
        (base32
         "1m0ai2r8b2mvlr8bqj9n6vg1pwzlwa46fqpq206wgyx5sgxac052"))))
    (build-system glib-or-gtk-build-system)
    (arguments
     (list
      #:configure-flags #~(list "--disable-update-mimedb")
      #:tests? #f ; tests fail even with display set
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'check 'pre-check
            (lambda _
              ;; Tests require a running X server.
              (system "Xvfb :1 &")
              (setenv "DISPLAY" ":1")
              ;; For the missing /etc/machine-id.
              (setenv "DBUS_FATAL_WARNINGS" "0"))))))
    (native-inputs
     (list pkg-config
           intltool
           `(,glib "bin")
           xorg-server
           gobject-introspection))
    (inputs
     (list exempi
           gtk+
           gvfs
           libexif
           libnotify
           libsm
           libxml2
           mate-desktop
           startup-notification))
    (native-search-paths
     (list (search-path-specification
            (variable "CAJA_EXTENSION_DIRS")
            (files (list "lib/caja/extensions-2.0")))))
    (home-page "https://mate-desktop.org/")
    (synopsis "File manager for the MATE desktop")
    (description
     "Caja is the official file manager for the MATE desktop.
It allows for browsing directories, as well as previewing files and launching
applications associated with them.  Caja is also responsible for handling the
icons on the MATE desktop.  It works on local and remote file systems.")
    ;; There is a note about a TRADEMARKS_NOTICE file in COPYING which
    ;; does not exist. It is safe to assume that this is of no concern
    ;; for us.
    (license license:gpl2+)))

(define-public caja-actions
  (package
    (name "caja-actions")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           "caja-actions-" version ".tar.xz"))
       (sha256
        (base32 "0iv8pl61kg8csdcby4f4iyswdb8bnhmydbkxhwd6mj7gsgh0mf6c"))))
    (build-system glib-or-gtk-build-system)
    (arguments
     (list #:configure-flags
           #~(list (string-append "--with-caja-extdir=" #$output
                                  "/lib/caja/extensions-2.0"))))
    (native-inputs
     (list intltool
           gettext-minimal
           (list glib "bin")
           gobject-introspection
           gtk-doc
           libxml2
           pkg-config))
    (inputs
     (list caja
           gtk+
           libgtop
           libsm
           mate-desktop
           (list util-linux "lib") ;libuuid
           yelp-tools))
    (home-page "https://mate-desktop.org/")
    (synopsis "Extension for the File manager Caja")
    (description
     "Caja-actions is an extension for Caja file manager.
which allows the user to add arbitrary program to be launched through the
Caja file manager popup menu of selected files.")
    (license license:gpl2+)))


(define-public caja-extensions
  (package
    (name "caja-extensions")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           "caja-extensions-" version ".tar.xz"))
       (sha256
        (base32 "03zwv3yl5553cnp6jjn7vr4l28dcdhsap7qimlrbvy20119kj5gh"))
       (patches (search-patches "geeguix/patches/caja-extensions-call-bindtextdomain-in-library.patch"))))
    (build-system glib-or-gtk-build-system)
    (arguments
     (list #:configure-flags
           #~(list "--disable-gksu"
                   (string-append "--with-sendto-plugins=removable-devices,"
                                  "caja-burn,emailclient,pidgin,gajim")
                   (string-append "--with-cajadir=" #$output
                                  "/lib/caja/extensions-2.0/"))))
    (native-inputs
     (list gettext-minimal
           gtk-doc
           intltool
           libxml2
           pkg-config))
    (inputs
     (list attr
           brasero
           caja
           dbus
           dbus-glib
           gajim ;runtime only?
           gtk+
           mate-desktop
           pidgin ;runtime only?
           startup-notification))
    (propagated-inputs
     (list imagemagick samba))
    (home-page "https://mate-desktop.org/")
    (synopsis "Extensions for the File manager Caja")
    (description
     "Caja is the official file manager for the MATE desktop.
It allows for browsing directories, as well as previewing files and launching
applications associated with them.  Caja is also responsible for handling the
icons on the MATE desktop.  It works on local and remote file systems.")
    (license license:gpl2+)))

(define-public mate-control-center
  (package
    (name "mate-control-center")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           "mate-control-center-" version ".tar.xz"))
       (sha256
        (base32 "0jhkn0vaz8glji4j5ar6im8l2wf40kssl07gfkz40rcgfzm18rr8"))))
    (build-system glib-or-gtk-build-system)
    (arguments
     (list #:phases
           #~(modify-phases %standard-phases
               (add-before 'build 'fix-password-command-path
                 (lambda _
                   (substitute* "capplets/about-me/mate-about-me-password.c"
                     (("/usr/bin/passwd")
                      "/run/setuid-programs/passwd"))))
               (add-before 'build 'fix-polkit-action
                 (lambda _
                   ;; Make sure the polkit file refers to the right
                   ;; executable.
                   (substitute*
                       '("capplets/display/org.mate.randr.policy.in"
                         "capplets/display/org.mate.randr.policy")
                     (("/usr/sbin")
                      (string-append #$output "/sbin"))))))))
    (native-inputs
     (list pkg-config
           intltool
           yelp-tools
           desktop-file-utils
           xorgproto
           xmodmap
           gobject-introspection))
    (inputs
     (list atk
           cairo
           dconf
           dbus
           dbus-glib
           fontconfig
           freetype
           glib
           gsettings-desktop-schemas
           gtk+
           libcanberra
           libmatekbd
           libx11
           libxcursor
           libxext
           libxi
           libxklavier
           libxml2
           libxrandr
           libxrender
           libxscrnsaver
           marco
           mate-desktop
           mate-menus
           mate-settings-daemon
           ;; FIXME: Move caja behind mate-*, if not, its path will not be
           ;; included into $XDG_DATA_DIRS in wrap programs.
           caja
           pango
           polkit
           startup-notification))
    (propagated-inputs
     (list (librsvg-for-system)))        ;mate-slab.pc
    (home-page "https://mate-desktop.org/")
    (synopsis "MATE Desktop configuration tool")
    (description
     "MATE control center is MATE's main interface for configuration
of various aspects of your desktop.")
    (license license:gpl2+)))

(define-public marco
  (package
    (name "marco")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           name "-" version ".tar.xz"))
       (sha256
        (base32 "01avxrg2fc6grfrp6hl8b0im4scy9xf6011swfrhli87ig6hhg7n"))))
    (build-system glib-or-gtk-build-system)
    (native-inputs
     (list pkg-config
           intltool
           itstool
           glib
           gobject-introspection
           libxft
           libxml2
           zenity))
    (inputs
     (list gtk+
           libcanberra
           libgtop
           libice
           libsm
           libx11
           libxcomposite
           libxcursor
           libxdamage
           libxext
           libxfixes
           libxinerama
           libxrandr
           libxrender
           mate-desktop
           pango
           startup-notification))
    (home-page "https://mate-desktop.org/")
    (synopsis "Window manager for the MATE desktop")
    (description
     "Marco is a minimal X window manager that uses GTK+ for drawing
window frames.  It is aimed at non-technical users and is designed to integrate
well with the MATE desktop.  It lacks some features that may be expected by
some users; these users may want to investigate other available window managers
for use with MATE or as a standalone window manager.")
    (license license:gpl2+)))

(define-public mate-user-guide
  (package
    (name "mate-user-guide")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           name "-" version ".tar.xz"))
       (sha256
        (base32
         "1h620ngryqc4m8ybvc92ba8404djnm0l65f34mlw38g9ad8d9085"))))
    (build-system gnu-build-system)
    (arguments
     (list #:phases
           #~(modify-phases %standard-phases
               (add-after 'unpack 'adjust-desktop-file
                 (lambda _
                   (substitute* "mate-user-guide.desktop.in.in"
                     (("yelp")
                      (string-append #$yelp "/bin/yelp"))))))))
    (native-inputs
     (list pkg-config
           intltool
           gettext-minimal
           yelp-tools
           yelp-xsl))
    (inputs
     (list yelp))
    (home-page "https://mate-desktop.org/")
    (synopsis "User Documentation for Mate software")
    (description
     "MATE User Guide is a collection of documentation which details
general use of the MATE Desktop environment.  Topics covered include
sessions, panels, menus, file management, and preferences.")
    (license (list license:fdl1.1+ license:gpl2+))))

(define-public mate-calc
  (package
    (name "mate-calc")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           "mate-calc-" version ".tar.xz"))
       (sha256
        (base32 "0mddfh9ixhh60nfgx5kcprcl9liavwqyina11q3pnpfs3n02df3y"))))
    (build-system glib-or-gtk-build-system)
    (native-inputs
     (list gettext-minimal intltool pkg-config yelp-tools))
    (inputs
     (list atk
           glib
           gtk+
           libxml2
           libcanberra
           mpc
           mpfr
           pango))
    (home-page "https://mate-desktop.org/")
    (synopsis "Calculator for MATE")
    (description
     "Mate Calc is the GTK+ calculator application for the MATE Desktop.")
    (license license:gpl2+)))

(define-public mate-backgrounds
  (package
    (name "mate-backgrounds")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           name "-" version ".tar.xz"))
       (sha256
        (base32
         "0379hngy3ap1r5kmqvmzs9r710k2c9nal2ps3hq765df4ir15j8d"))))
    (build-system glib-or-gtk-build-system)
    (native-inputs
     (list intltool))
    (home-page "https://mate-desktop.org/")
    (synopsis "Calculator for MATE")
    (description
     "This package contains a collection of graphics files which
can be used as backgrounds in the MATE Desktop environment.")
    (license license:gpl2+)))

(define-public mate-netbook
  (package
    (name "mate-netbook")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           name "-" version ".tar.xz"))
       (sha256
        (base32
         "12gdy69nfysl8vmd8lv8b0lknkaagplrrz88nh6n0rmjkxnipgz3"))))
    (build-system glib-or-gtk-build-system)
    (native-inputs
     (list gettext-minimal intltool pkg-config))
    (inputs
     (list cairo
           glib
           gtk+
           libfakekey
           libwnck
           libxtst
           libx11
           mate-panel
           xorgproto))
    (home-page "https://mate-desktop.org/")
    (synopsis "Tool for MATE on Netbooks")
    (description
     "Mate Netbook is a simple window management tool which:

@enumerate
@item Allows you to set basic rules for a window type, such as maximise|undecorate
@item Allows exceptions to the rules, based on string matching for window name
and window class.
@item Allows @code{reversing} of rules when the user manually changes something:
Re-decorates windows on un-maximise.
@end enumerate\n")
    (license license:gpl3+)))

(define-public mate-screensaver
  (package
    (name "mate-screensaver")
    (version "1.26.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           "mate-screensaver-" version ".tar.xz"))
       (sha256
        (base32 "1g5qb6bf08726166c12n554kwxb9v1vgg6za6ggai7m5lhgb5gag"))))
    (build-system glib-or-gtk-build-system)
    (arguments
     (list
      #:configure-flags
      ;; FIXME: There is a permissions problem with screen locking
      ;; which effectively locks you out completely. Enable locking
      ;; once this has been fixed.
      #~(list "--enable-locking" "--with-kbd-layout-indicator"
              "--with-xf86gamma-ext" "--enable-pam"
              "--disable-schemas-compile" "--without-console-kit")
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'autoconf
            (lambda _
              (setenv "SHELL" (which "sh"))
              (setenv "CONFIG_SHELL" (which "sh"))
              (substitute* "configure"
                (("dbus-1") "")))))))
    (native-inputs
     (list automake
           autoconf
           gettext-minimal
           intltool
           mate-common
           pkg-config
           which
           xorgproto))
    (inputs
     (list cairo
           dconf
           dbus
           dbus-glib
           glib
           gtk+
           (librsvg-for-system)
           libcanberra
           libglade
           libmatekbd
           libnotify
           libx11
           libxext
           libxklavier
           libxrandr
           libxrender
           libxscrnsaver
           libxxf86vm
           linux-pam
           mate-desktop
           mate-menus
           pango
           startup-notification))
    (home-page "https://mate-desktop.org/")
    (synopsis "Screensaver for MATE")
    (description
     "MATE backgrounds package contains a collection of graphics files which
can be used as backgrounds in the MATE Desktop environment.")
    (license license:gpl2+)))

(define-public mate-utils
  (package
    (name "mate-utils")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           name "-" version ".tar.xz"))
       (sha256
        (base32
         "0bkqj8qwwml9xyvb680yy06lv3dzwkv89yrzz5jamvz88ar6m9bw"))))
    (build-system glib-or-gtk-build-system)
    (native-inputs
     (list gettext-minimal
           gtk-doc
           intltool
           libice
           libsm
           pkg-config
           scrollkeeper
           xorgproto
           yelp-tools))
    (inputs
     (list atk
           cairo
           glib
           gtk+
           (librsvg-for-system)
           libcanberra
           libgtop
           libx11
           libxext
           mate-panel
           pango
           udisks
           zlib))
    (home-page "https://mate-desktop.org/")
    (synopsis "Utilities for the MATE Desktop")
    (description
     "Mate Utilities for the MATE Desktop containing:

@enumerate
@item mate-system-log
@item mate-search-tool
@item mate-dictionary
@item mate-screenshot
@item mate-disk-usage-analyzer
@end enumerate\n")
    (license (list license:gpl2
                   license:fdl1.1+
                   license:lgpl2.1))))

(define-public eom
  (package
    (name "eom")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           "eom-" version ".tar.xz"))
       (sha256
        (base32 "1nv7q0yw11grgxr5lyvll0f7fl823kpjp05z81bwgnvd76m6kw97"))))
    (build-system glib-or-gtk-build-system)
    (native-inputs
     (list gettext-minimal
           gtk-doc
           gobject-introspection
           intltool
           pkg-config
           yelp-tools))
    (inputs
     (list atk
           cairo
           dconf
           dbus
           dbus-glib
           exempi
           glib
           gtk+
           libcanberra
           libx11
           libxext
           libpeas
           libxml2
           libexif
           libjpeg-turbo
           (librsvg-for-system)
           lcms
           mate-desktop
           pango
           shared-mime-info
           startup-notification
           zlib))
    (home-page "https://mate-desktop.org/")
    (synopsis "Eye of MATE")
    (description
     "Eye of MATE is the Image viewer for the MATE Desktop.")
    (license license:gpl2)))

(define-public engrampa
  (package
    (name "engrampa")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           "engrampa-" version ".tar.xz"))
       (sha256
        (base32 "1qsy0ynhj1v0kyn3g3yf62g31rwxmpglfh9xh0w5lc9j5k1b5kcp"))))
    (build-system glib-or-gtk-build-system)
    (arguments
     (list #:configure-flags
           #~(list "--disable-schemas-compile"
                   "--disable-run-in-place"
                   "--enable-magic"
                   "--enable-packagekit"
                   (string-append "--with-cajadir="
                                  #$output
                                  "/lib/caja/extensions-2.0/"))
           #:phases
           #~(modify-phases %standard-phases
               (add-before 'install 'skip-gtk-update-icon-cache
                 ;; Don't create 'icon-theme.cache'.
                 (lambda _
                   (substitute* "data/Makefile"
                     (("gtk-update-icon-cache") "true")))))))
    (native-inputs
     (list gettext-minimal
           gtk-doc
           intltool
           pkg-config
           yelp-tools))
    (inputs
     (list caja
           file
           glib
           gtk+
           (librsvg-for-system)
           json-glib
           libcanberra
           libx11
           libsm
           packagekit
           pango))
    (home-page "https://mate-desktop.org/")
    (synopsis "Archive Manager for MATE")
    (description
     "Engrampa is the archive manager for the MATE Desktop.")
    (license license:gpl2)))

(define-public pluma
  (package
    (name "pluma")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           name "-" version ".tar.xz"))
       (sha256
        (base32 "0lway12q2xygiwjgrx7chgka838jbnmlzz98g7agag1rwzd481ii"))))
    (build-system glib-or-gtk-build-system)
    (arguments
     `(; Tests can not succeed.
       ;; https://github.com/mate-desktop/mate-text-editor/issues/33
       #:tests? #f))
    (native-inputs
     (list gettext-minimal
           gtk-doc
           gobject-introspection
           intltool
           libtool
           pkg-config
           yelp-tools))
    (inputs
     (list atk
           cairo
           enchant-1.6
           glib
           gtk+
           gtksourceview
           gdk-pixbuf
           iso-codes
           libcanberra
           libx11
           libsm
           libpeas
           libxml2
           libice
           packagekit
           pango
           python
           scrollkeeper))
    (home-page "https://mate-desktop.org/")
    (synopsis "Text Editor for MATE")
    (description
     "Pluma is the text editor for the MATE Desktop.")
    (license license:gpl2)))

(define-public mate-system-monitor
  (package
    (name "mate-system-monitor")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           "mate-system-monitor-" version ".tar.xz"))
       (sha256
        (base32 "13rkrk7c326ng8164aqfp6i7334n7zrmbg61ncpjprbrvlx2qiw3"))))
    (build-system glib-or-gtk-build-system)
    (native-inputs
     (list autoconf gettext-minimal intltool pkg-config yelp-tools))
    (inputs
     (list cairo
           glib
           glibmm
           gtkmm-3
           gtk+
           gdk-pixbuf
           libsigc++
           libcanberra
           libxml2
           libwnck
           libgtop
           (librsvg-for-system)
           polkit))
    (home-page "https://mate-desktop.org/")
    (synopsis "System Monitor for MATE")
    (description
     "Mate System Monitor provides a tool for for the
MATE Desktop to monitor your system resources and usage.")
    (license license:gpl2)))

(define-public mate-polkit
  (package
    (name "mate-polkit")
    (version "1.26.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://mate/" (version-major+minor version) "/"
                           name "-" version ".tar.xz"))
       (sha256
        (base32
         "0kkjv025l1l8352m5ky1g7hmk7isgi3dnfnh7sqg9pyhml97i9dd"))))
    (build-system glib-or-gtk-build-system)
    (native-inputs
     (list gettext-minimal gtk-doc intltool libtool pkg-config))
    (inputs
     (list accountsservice
           glib
           gobject-introspection
           gtk+
           gdk-pixbuf
           polkit))
    (home-page "https://mate-desktop.org/")
    (synopsis "DBus specific service for MATE")
    (description
     "MATE Polkit is a MATE specific DBUS service that is
used to bring up authentication dialogs.")
    (license license:lgpl2.1)))

(define-public mate
  (package
    (name "mate")
    (version (package-version mate-desktop))
    (source #f)
    (build-system trivial-build-system)
    (arguments
     (list #:modules '((guix build union))
           #:builder
           #~(begin
               (use-modules (ice-9 match)
                            (guix build union))
               (match %build-inputs
                 (((names . directories) ...)
                  (union-build #$output directories)
                  #t)))))
    (native-inputs (list desktop-file-utils))
    (inputs
     ;; TODO: Add more packages
     (list at-spi2-core
           atril
           caja
           dbus
           dconf
           engrampa
           eom
           font-abattis-cantarell
           glib-networking
           gnome-keyring
           gvfs
           hicolor-icon-theme
           libmatekbd
           libmateweather
           libmatemixer
           marco
           mate-session-manager
           mate-settings-daemon
           mate-desktop
           mate-terminal
           mate-themes
           mate-icon-theme
           mate-power-manager
           mate-menus
           mate-panel
           mate-control-center
           mate-media
           mate-applets
           mate-user-guide
           mate-calc
           mate-backgrounds
           mate-netbook
           mate-utils
           mate-polkit
           mate-system-monitor
           mate-utils
           pluma
           pinentry-gnome3
           pulseaudio
           shared-mime-info
           yelp
           zenity))
    (propagated-inputs
     ;; Default font that applications such as IceCat require.
     (list font-dejavu))
    (synopsis "The MATE desktop environment")
    (home-page "https://mate-desktop.org/")
    (description
     "The MATE Desktop Environment is the continuation of GNOME 2.  It provides
an intuitive and attractive desktop environment using traditional metaphors for
GNU/Linux systems.  MATE is under active development to add support for new
technologies while preserving a traditional desktop experience.")
    (license license:gpl2+)))
