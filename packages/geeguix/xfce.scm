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

(define-public gtk-xfce-engine
  (package
    (name "gtk-xfce-engine")
    (version "3.2.0")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://archive.xfce.org/src/archive/"
                                  name "/" (version-major+minor version) "/"
                                  name "-" version ".tar.bz2"))
              (sha256
               (base32
                "1va71f3gpl8gikfkmqsd5ikgp7qj8b64jii2l98g1ylnv8xrqp47"))))
    (build-system gnu-build-system)
    (arguments
     (list #:configure-flags #~(list "--enable-gtk3")))
    (native-inputs
     (list pkg-config
           intltool
           (list glib "bin") ; glib-mkenums
           gdk-pixbuf ; gdk-pixbuf+svg isn't needed
           gtk+-2
           gtk+))
    (home-page "https://www.xfce.org/")
    (synopsis "GTK+ theme engine for Xfce")
    (description
     "Default GTK+ engine and themes for Xfce Desktop Environment.")
    (license gpl2+)))

