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
    (version "2.4.4")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/joewing/jwm")
             (commit "4640d3b48ea64bd57e3cea63e4c4a9cd558e6142")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0xwk54y8q12y3cvbgrjhda6g4jd5f57bvyasyb9qdbczzxfhvxqw"))))
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
    (native-inputs
     (list autoconf
           automake
           gettext-minimal
           pkg-config))
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
