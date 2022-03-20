(define-module (geeguix xfce)
  #:use-module (gnu artwork)
  #:use-module (gnu packages)
  #:use-module (gnu packages apr)
  #:use-module (gnu packages base)
  #:use-module (gnu packages calendar)
  #:use-module (gnu packages cdrom)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages image)
  #:use-module (gnu packages imagemagick)
  #:use-module (gnu packages inkscape)
  #:use-module (gnu packages libcanberra)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages mate)
  #:use-module (gnu packages mp3)
  #:use-module (gnu packages pcre)
  #:use-module (gnu packages pdf)
  #:use-module (gnu packages photo)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages polkit)
  #:use-module (gnu packages popt)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages search)
  #:use-module (gnu packages textutils)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages web)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xfce)
  #:use-module (gnu packages xorg)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system glib-or-gtk)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system python)
  #:use-module (guix build-system trivial)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:hide (freetype))
  #:use-module (guix packages)
  #:use-module (guix utils))

(define-public thunar
  (package
    (name "thunar")
    (version "4.16.10")                           ;stable version = even minor
    (source (origin
              (method url-fetch)
              (uri (string-append "https://archive.xfce.org/src/xfce/"
                                  "thunar/" (version-major+minor version) "/"
                                  "thunar-" version ".tar.bz2"))
              (sha256
               (base32
                "14lwi4ax0wj77980kkfhdf18b97339b17y8qc8gl2365mgswh1gi"))
              (patches
               (search-patches
                "geeguix/patches/thunar-support-thunarx-dirs-variable.patch"))))
    (build-system gnu-build-system)
    (native-inputs
     (list pkg-config intltool gobject-introspection))
    (inputs
     (list exo
           gvfs
           libexif
           libgudev
           libnotify
           libxfce4ui
           pcre
           xfce4-panel
           startup-notification))
    (native-search-paths
     (list (search-path-specification
            (variable "THUNARX_DIRS")
            (files (list "lib/thunarx-3")))))
    (home-page "https://www.xfce.org/")
    (synopsis "Xfce file manager")
    (description
     "A modern file manager for graphical desktop, aiming to be easy-to-use and
fast.")
    (license gpl2+)))

(define-public thunar-archive-plugin
  (package
    (name "thunar-archive-plugin")
    (version "0.4.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://archive.xfce.org/src/thunar-plugins/"
                           name "/" (version-major+minor version)
                           "/" name "-" version ".tar.bz2"))
       (sha256
        (base32 "059ikda4hig1iqk0g5kqc4p95chj0z1ljhl5qjrlw4l8lf3gm0mz"))))
    (build-system gnu-build-system)
    (native-inputs (list pkg-config intltool))
    (inputs (list exo thunar gtk+))
    (home-page "https://www.xfce.org/")
    (synopsis "Archive plugin for Thunar file manager")
    (description "The Thunar Archive Plugin allows you to create and extract
archive files using the file context menus in the Thunar file manager.")
    (license gpl2+)))

(define-public thunar-shares-plugin
  (package
    (name "thunar-shares-plugin")
    (version "0.3.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://archive.xfce.org/src/thunar-plugins/"
                           name "/" (version-major+minor version)
                           "/" name "-" version ".tar.bz2"))
       (sha256
        (base32 "182j8jl91735004hbl0i2xxga4r6fk03srfl6g87czkjm9y8q7fw"))))
    (build-system gnu-build-system)
    (native-inputs (list pkg-config intltool))
    (inputs (list thunar gtk+))
    (home-page "https://www.xfce.org/")
    (synopsis "Folder share plugin for Thunar file manager")
    (description
     "The Thunar Shares Plugin allows you to quickly share a folder using
Samba from Thunar (the Xfce file manager) without requiring root access.")
    (license gpl2+)))

(define-public thunar-media-tags-plugin
  (package
    (name "thunar-media-tags-plugin")
    (version "0.3.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://archive.xfce.org/src/thunar-plugins/"
                           name "/" (version-major+minor version)
                           "/" name "-" version ".tar.bz2"))
       (sha256
        (base32 "06sr7b4p9f585gian8vpx7j0pkzg0vvwcrjmrhvh7i5sb90w8rg2"))))
    (build-system gnu-build-system)
    (native-inputs (list pkg-config intltool))
    (inputs (list exo gtk+ thunar taglib))
    (home-page "https://www.xfce.org/")
    (synopsis "Media tags plugin for Thunar file manager")
    (description
     "Media tags plugin allows tags editing from Thunar file manager and
tags-based file renaming from inside Thunar Bulk Renamer.")
    (license gpl2+)))

(define-public thunar-vcs-plugin
  (package
    (name "thunar-vcs-plugin")
    (version "0.2.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://archive.xfce.org/src/thunar-plugins/"
                           name "/" (version-major+minor version)
                           "/" name "-" version ".tar.bz2"))
       (sha256
        (base32 "1f2d1dwfyi6xv3qkd8l8xh0vhz8wh0601cyigjzn426lqga1d29n"))))
    (build-system gnu-build-system)
    (arguments
     (list #:configure-flags
           #~(list (string-append "CPPFLAGS=-I" #$apr-util "/include/apr-1"))))
    (native-inputs (list pkg-config intltool utf8proc))
    (inputs
     (list exo
           gtk+
           thunar
           libxfce4util
           apr
           apr-util
           subversion
           git))
    (home-page "https://www.xfce.org/")
    (synopsis "VCS plugin for Thunar file manager")
    (description
     "Thunar VCS Plugin (formerly known as Thunar SVN Plugin) gives SVN and
GIT integration to Thunar, it adds Subversion and GIT actions to the context
menu.")
    (license gpl2+)))

(define-public gigolo
  (package
    (name "gigolo")
    (version "0.5.2")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://archive.xfce.org/src/apps/"
                                  name "/" (version-major+minor version)
                                  "/" name "-" version ".tar.bz2"))
              (sha256
               (base32
                "1hxv3lla567nnqxxly8xfi8fzmpcdhxb493x9hinr7szfnh1ljp3"))))
    (build-system gnu-build-system)
    (native-inputs (list pkg-config intltool))
    (inputs (list gtk+))
    (propagated-inputs
     (list (list glib "bin")))
    (home-page "https://www.xfce.org/")
    (synopsis "A frontend to easily manage connections to remote filesystems")
    (description
     "A frontend to easily manage connections to remote filesystems using
GIO/GVfs.  It allows you to quickly connect/mount local and remote filesystems
and manage bookmarks of such.")
    (license gpl2+)))
