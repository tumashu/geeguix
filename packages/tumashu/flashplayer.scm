(define-module (tumashu flashplayer)
  #:use-module (ice-9 regex)
  #:use-module (guix utils)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages zip))

(define-public flash-player-npapi
  (package
    (name "flash-player-npapi")
    (version "24.0.0.194")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://fpdownload.adobe.com/get/flashplayer/pdc/"
                    version
                    "/flash_player_npapi_linux.i386.tar.gz"))
              (sha256
               (base32
                "1lrfwwhl18411bk9qsizhch8n3ilcvhmj4i7sak5zjv5r6mwnqgl"))))
    (build-system trivial-build-system)
    (arguments
     `(#:modules ((guix build utils))
       #:builder
       (begin
         (use-modules (guix build utils))
         (let* ((PATH (string-append
                       (assoc-ref %build-inputs "coreutils") "/bin:"
                       (assoc-ref %build-inputs "tar")  "/bin:"
                       (assoc-ref %build-inputs "gzip") "/bin"))
                (dir (assoc-ref %outputs "out"))
                (plugin-dir (string-append dir "/usr/lib/icecat/plugins")))
           (setenv "PATH" PATH)
           (mkdir-p dir)
           (mkdir-p plugin-dir)
           (system* "tar" "xvf" (assoc-ref %build-inputs "source"))
           (system* "cp" "-rf" "usr" dir)
           (system* "cp" "libflashplayer.so" plugin-dir)))))
    (native-inputs
     `(("gzip" ,gzip)
       ("tar"  ,tar)
       ("coreutils" ,coreutils)))
    (home-page "")
    (synopsis "Adobe Flash Player")
    (description
     "Adobe Flash Player.")
    ;; GPLv3 with font embedding exception
    (license license:gpl3)))
