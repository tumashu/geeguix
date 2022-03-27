(define-module (gee packages image-viewers)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system meson)
  #:use-module (guix build-system python)
  #:use-module (guix build-system qt)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages backup)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages boost)
  #:use-module (gnu packages check)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages documentation)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages ghostscript)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages graphics)
  #:use-module (gnu packages image)
  #:use-module (gnu packages image-processing)
  #:use-module (gnu packages imagemagick)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages pdf)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages perl-check)
  #:use-module (gnu packages photo)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages suckless)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages video)
  #:use-module (gnu packages web)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages))

(define-public mcomix
  (package
    (name "mcomix")
    (version "2.0.1")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "mirror://sourceforge/mcomix/MComix-" version "/"
                           "mcomix-" version ".tar.gz"))
       (sha256
        (base32
         "187ca815vxb2in1ryvfiaf1zapi0bc9jxdac3c1bky0kr6x7xyap"))))
    (build-system python-build-system)
    (inputs
     (list p7zip python python-pillow python-pygobject python-pycairo gtk+))
    (arguments
     (list
      #:imported-modules `(,@%python-build-system-modules
                           (guix build glib-or-gtk-build-system))
      #:modules '((guix build python-build-system)
                  ((guix build glib-or-gtk-build-system) #:prefix glib-or-gtk:)
                  (guix build utils))
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'unpack 'patch-source
            (lambda* (#:key inputs #:allow-other-keys)
              (substitute* "mcomix/archive/sevenzip_external.py"
                ;; Ensure that 7z is found by hardcoding its absolute path.
                (("_7z_executable = -1")
                 (format #f "_7z_executable = ~s"
                         (search-input-file inputs "/bin/7z"))))
              (substitute* "mcomix/image_tools.py"
                (("assert name not in supported_formats_gdk")
                 "if name in supported_formats_gdk: continue"))))
          (add-after 'install 'install-data
            (lambda* (#:key outputs #:allow-other-keys)
              (copy-recursively
               "mcomix/images"
               (string-append (assoc-ref outputs "out")
                              "/lib/python"
                              #$(version-major+minor
                                 (package-version (this-package-input "python")))
                              "/site-packages/mcomix/images"))
              (copy-recursively
               "mcomix/messages"
               (string-append (assoc-ref outputs "out")
                              "/lib/python"
                              #$(version-major+minor
                                 (package-version (this-package-input "python")))
                              "/site-packages/mcomix/messages"))))
          (add-after 'glib-or-gtk-compile-schemas 'glib-or-gtk-wrap
            (assoc-ref glib-or-gtk:%standard-phases 'glib-or-gtk-wrap))
          (add-after 'wrap 'gi-wrap
            (lambda* (#:key outputs #:allow-other-keys)
              (let ((bin (string-append (assoc-ref outputs "out") "/bin")))
                (for-each
                 (lambda (prog)
                   (wrap-program prog
                     `("GI_TYPELIB_PATH" = (,(getenv "GI_TYPELIB_PATH")))))
                 (list (string-append bin "/mcomix")))))))))
    (home-page "https://sourceforge.net/p/mcomix/wiki/Home/")
    (synopsis "Image viewer for comics")
    (description "MComix is a customizable image viewer that specializes as
a comic and manga reader.  It supports a variety of container formats
including CBZ, CB7, CBT, LHA.

For PDF support, install the @emph{mupdf} package.")
    (license license:gpl2+)))
