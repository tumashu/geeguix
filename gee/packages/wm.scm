(define-module (gee packages wm)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages fribidi)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages image)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xorg))

(define-public jwm
  (package
    (name "jwm")
    (version "2.4.3")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/joewing/jwm/releases/download/"
                    "v" version "/jwm-" version ".tar.xz"))
              (sha256
               (base32
                "1av7r9sp26r5l74zvwdmyyyzav29mw5bafihp7y33vsjqkh4wfzf"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:tests? #f   ;no check
      #:phases
      #~(modify-phases %standard-phases
          (add-after 'install 'install-xsession
            (lambda* (#:key outputs #:allow-other-keys)
              (let* ((out (assoc-ref outputs "out"))
                     (xsessions (string-append out "/share/xsessions")))
                (mkdir-p xsessions)
                (call-with-output-file
                    (string-append xsessions "/jwm.desktop")
                  (lambda (port)
                    (format port "~
                     [Desktop Entry]~@
                     Name=jwm~@
                     Comment=Joe's Window Manager~@
                     Exec=~a/bin/jwm~@
                     Type=XSession~%" out))))
              #t)))))
    (native-inputs (list pkg-config))
    (inputs (list fribidi
                  libjpeg-turbo
                  libpng
                  librsvg
                  libxext
                  libxft
                  libxinerama
                  libxmu
                  libxpm
                  libxrandr
                  freetype
                  libxt
                  cairo))
    (home-page "http://joewing.net/projects/jwm")
    (synopsis "Joe's Window Manager")
    (description
     "JWM is a light-weight window manager for the X11 Window System.  it is
written in C and uses only Xlib at a minimum.  Because of its small footprint,
it makes a good window manager for older computers and less powerful systems,
such as the Raspberry Pi, though it is perfectly capable of running on modern
systems.")
    (license license:expat)))
