(define-module (gee packages ibus)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages ibus)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix download)
  #:use-module (guix build utils)
  #:use-module (guix build-system copy))

(define-public rime-cloverpinyin
  (package
    (name "rime-cloverpinyin")
    (version "1.1.4")
    (source
     (origin
       (method url-fetch)
       (uri (string-append "https://github.com/fkxxyz/" name "/releases/download/"
                           version "/clover.schema-" version ".zip"))
       (sha256
        (base32 "12s7zlbg2ksq4z9j4l98g00a9az0v8frdr4w35028xv7k9pnlz9j"))))
    (build-system copy-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (replace 'unpack
            (lambda* (#:key source #:allow-other-keys)
              (and (invoke "unzip" source "-d" "cloverpinyin")
                   (chdir "cloverpinyin")))))
      #:install-plan
      #~'(("." "share/rime-data/" #:include-regexp ("\\.yaml$")))))
    (native-inputs (list unzip))
    (propagated-inputs (list rime-data))
    (home-page "https://github.com/fkxxyz/rime-cloverpinyin")
    (synopsis "Clover Simplified pinyin input for rime")
    (description "Clover Simplified pinyin input for rime.")
    (license license:lgpl2.0)))

