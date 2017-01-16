(define-module (tumashu fcitx)
  #:use-module ((guix licenses) #:select (gpl2+))
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system cmake)
  #:use-module (gnu packages documentation)
  #:use-module (gnu packages fcitx)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages iso-codes)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xorg))

(define-public fcitx-configtool
  (package
   (name "fcitx-configtool")
   (version "0.4.8")
   (source (origin
            (method url-fetch)
            (uri (string-append "https://download.fcitx-im.org/fcitx-configtool/"
                                name "-" version ".tar.xz"))
            (sha256
             (base32
              "1vaim0namw58bfafbvws1vgd4010p19zwqfbx6bd1zi5sgchdg0f"))))
   (build-system cmake-build-system)
   (arguments
    `(#:configure-flags
      (list
       "-DENABLE_GTK2=ON"
       "-DENABLE_GTK3=ON"
       )
      #:tests? #f))
   (native-inputs
    `(("doxygen"    ,doxygen)
      ("glib:bin"   ,glib "bin")    ; for glib-genmarshal
      ("pkg-config" ,pkg-config)))
   (inputs
    `(("fcitx"      ,fcitx)
      ("dbus"       ,dbus)
      ("dbus-glib"  ,dbus-glib)
      ("gettext"    ,gettext-minimal)
      ("gtk2"       ,gtk+-2)
      ("gtk3"       ,gtk+)
      ("iso-codes"  ,iso-codes)))
   (home-page "http://fcitx-im.org")
   (synopsis "Graphic Fcitx configuration tool")
   (description
    "Fcitx is an input method framework with extension support.  It has
Pinyin, Quwei and some table-based (Wubi, Cangjie, Erbi, etc.) input methods
built-in. This package provides GTK+ 3 version of the graphic configuration
tool.")
   (license gpl2+)))
