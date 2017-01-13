(define-module (tumashu fonts)
  #:use-module (ice-9 regex)
  #:use-module (guix utils)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages zip))

(define-public font-wqy-microhei
  (package
    (name "font-wqy-microhei")
    (version "0.2.0-beta")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "mirror://sourceforge/wqy/wqy-microhei/" version
                    "/wqy-microhei-" version ".tar.gz"))
              (file-name (string-append "wqy-microhei-" version ".tar.gz"))
              (sha256
               (base32
                "0gi1yxqph8xx869ichpzzxvx6y50wda5hi77lrpacdma4f0aq0i8"))))
    (build-system trivial-build-system)
    (arguments
     `(#:modules ((guix build utils))
       #:builder
       (begin
         (use-modules (guix build utils))
         (let ((PATH (string-append (assoc-ref %build-inputs "tar")  "/bin:"
                                    (assoc-ref %build-inputs "gzip") "/bin"))
               (font-dir (string-append (assoc-ref %outputs "out")
                                        "/share/fonts/wenquanyi/")))
           (setenv "PATH" PATH)
           (mkdir-p font-dir)
           (system* "tar" "xvf" (assoc-ref %build-inputs "source"))
           (chdir "wqy-microhei")
           (copy-file "wqy-microhei.ttc"
                      (string-append font-dir "wqy-microhei.ttc"))))))
    (native-inputs
     `(("gzip" ,gzip)
       ("tar" ,tar)))
    (home-page "http://wenq.org/wqy2/")
    (synopsis "CJK font")
    (description
     "WenQuanYi Micro Hei is a Sans-Serif style (also known as Hei, Gothic
or Dotum among the Chinese/Japanese/Korean users) high quality CJK
outline font. It was derived from \"Droid Sans Fallback\" and \"Droid
Sans\" released by Google Inc. This font contains all the unified CJK
Han glyphs in the range of U+4E00-U+9FC3 defined in Unicode Standard
5.1, together with many other languages unicode blocks, including
Latins, Extended Latins, Hanguls and Kanas. The font file is
extremely compact (~4M) compared with most known CJK fonts. As a
result, it can be used for hand-held devices or embedded systems, or
used for PC with a significantly small memory footprint.

In this font, we merged \"Droid Sans\", which contains a more complete
coverage to Latin/Extended Latin as well as the hinting and kerning
information to these glyphs, to the extended Droid Sans Fallback.
The EM of both fonts were unified to 2048 to retain all the advanced
typesetting features.")
    ;; GPLv3 with font embedding exception
    (license license:gpl3)))
