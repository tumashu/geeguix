(define-module (gee packages ibus)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages ibus)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build utils)
  #:use-module (guix build-system copy))

(define-public ibus-rime-gee
  (package
    (inherit ibus-rime)
    (name "ibus-rime-gee")
    (arguments
     (substitute-keyword-arguments (package-arguments ibus-rime)
       ;; 这里用 rime-cloverpinyin 替代 rime-data.
       ((#:configure-flags flags #~'())
        #~(list (string-append
                 "-DRIME_DATA_DIR="
                 (assoc-ref %build-inputs "rime-cloverpinyin")
                 "/share/rime-data")))))
    (inputs
     (modify-inputs (package-inputs ibus-rime)
       (prepend rime-cloverpinyin)
       (delete "rime-data")))))

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
      #~'(("." "share/rime-data/"))))
    (native-inputs (list unzip))
    (home-page "https://github.com/fkxxyz/rime-cloverpinyin")
    (synopsis "Clover Simplified pinyin input for rime")
    (description "Clover Simplified pinyin input for rime.")
    (license license:lgpl2.0)))

(define-public rime-settings
  (let ((commit "508b0f373fd1a2475a8f531867550220193b30c5")
        (revision "0"))
    (package
      (name "rime-settings")
      (version (git-version "0.1" revision commit))
      (source
       (origin
         (uri (git-reference
               (url "https://github.com/wongdean/rime-settings")
               (commit commit)))
         (method git-fetch)
         (sha256
          (base32 "0rbf56icp0fr3hc0i137rv596krvqkagz9gzlw9d0vp69404a2b5"))
         (file-name (git-file-name name version))))
      (build-system copy-build-system)
      (arguments
       (list
        #:install-plan
        #~'(("." "share/rime-data/"))))
      (home-page "https://github.com/wongdean/rime-settings")
      (synopsis "Rime Settings of wongdean.")
      (description "Rime Settings of wongdean.")
      (license license:lgpl2.0))))

