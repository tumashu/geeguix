(define-module (geeguix xfce)
  #:use-module (gnu artwork)
  #:use-module (gnu packages)
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

(define-public thunar-geeguix
  (package
    (inherit thunar)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'fix-thunarx-directory
            (lambda _
              (substitute* "thunarx/Makefile.in"
                (("THUNARX_DIRECTORY=.*")
                 (string-append "THUNARX_DIRECTORY="
                                "\\\"/run/current-system/profile/lib/thunarx-3\\\" \\\n"))))))))))

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
    (native-inputs
     (list pkg-config intltool))
    (inputs
     (list exo
           thunar
           gtk+
           libxfce4ui))
    (home-page "https://www.xfce.org/")
    (synopsis "Adds archive operations to the Thunar file context menus")
    (description "This plugin allows you to create and extract archive files
using the file context menus in the Thunar file manager.")
    (license gpl2+)))
