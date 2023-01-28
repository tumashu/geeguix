(define-module (gee packages wm)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gettext)
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
      #:tests? #f   ; no check target
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
    (inputs
     (list cairo
           libjpeg-turbo
           libpng
           librsvg
           libxext
           libxinerama
           libxmu
           libxpm
           libxrandr
           libxt
           pango))
    (home-page "http://joewing.net/projects/jwm")
    (synopsis "Joe's Window Manager")
    (description
     "JWM is a light-weight window manager for the X11 Window System.  it is
written in C and uses only Xlib at a minimum.  Because of its small footprint,
it makes a good window manager for older computers and less powerful systems,
such as the Raspberry Pi, though it is perfectly capable of running on modern
systems.")
    (license license:expat)))

(define-public mjwm
  (package
    (name "mjwm")
    (version "4.1.0")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://github.com/chiku/mjwm/releases/download/"
                    "v" version "/mjwm-" version ".tar.gz"))
              (sha256
               (base32
                "0q1n3jw22hjzas7q75nb0zkw1875kf4k518f8zg13h7si2knyxy3"))))
    (build-system gnu-build-system)
    (home-page "https://github.com/chiku/mjwm")
    (synopsis "Create menu for JWM.")
    (description
     "MJWM can create JWM's menu from (freedesktop) desktop files and the
generated file can be include in the rootmenu section of your jwm config file.")
    (license license:gpl2)))
