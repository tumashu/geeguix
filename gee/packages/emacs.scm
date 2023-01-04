(define-module (gee packages emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gee packages)
  #:use-module (guix build-system emacs)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages sqlite)
  #:use-module (gnu packages text-editors)
  #:use-module (gnu packages xorg)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (srfi srfi-9)
  #:use-module (srfi srfi-9 gnu))

(define-public emacs-gee
  (let ((commit "d26b523886ee52548648ca660fc2933eadf49a55")
        (revision "2"))
    (package
      (inherit emacs)
      (name "emacs-gee")
      (version (git-version "29.0.50" revision commit))
      (source
       (origin
         (inherit (package-source emacs))
         (method git-fetch)
         (uri (git-reference
               ;; Emacs git 下载速度太慢了，使用南京大学的 Emacs 镜像，同步延
               ;; 迟大概 8 小时。
               ;; (url "https://git.savannah.gnu.org/git/emacs.git")
               (url "https://mirrors.nju.edu.cn/git/emacs.git")
               (commit commit)))
         (file-name (git-file-name name version))
         ;; emacs-source-date-epoch.patch is no longer necessary
         (patches (search-patches "emacs-exec-path.patch"
                                  "emacs-fix-scheme-indent-function.patch"
                                  "emacs-native-comp-driver-options.patch"))
         (sha256
          (base32
           "1kchshxmaw72bn2ds0b2cq1pxhxrfqm2v7k8qxycn8c0awl2xff2"))))
      (inputs
       (modify-inputs (package-inputs emacs)
         (delete "gtk+")
         (prepend tree-sitter)
         (prepend libxaw)
         (prepend sqlite)))
      (arguments
       (substitute-keyword-arguments (package-arguments emacs)
         ((#:configure-flags flags #~'())
          #~(list "--with-modules"
                  "--with-cairo"
                  "--with-x-toolkit=lucid"
                  "--with-native-compilation=no"
                  "--disable-build-details"))
         ((#:phases phases)
          #~(modify-phases #$phases
              (add-after 'install 'rename-ctags
                (lambda* (#:key outputs #:allow-other-keys)
                  (with-directory-excursion (assoc-ref outputs "out")
                    ;; Emacs 自带的 ctags 会和 universal-ctags 冲突，这里将其重
                    ;; 命名。
                    (rename-file "bin/ctags" "bin/ctags-emacs")))))))))))

(define-public emacs-helper
  (let ((commit "4146ee6b23ea1f3532b4ea40781a9f28b9ea2bda")
        (revision "0"))
    (package
      (name "emacs-helper")
      (version (git-version "0.1" revision commit))
      (source
       (origin
         (uri (git-reference
               (url "https://github.com/tumashu/emacs-helper")
               (commit commit)))
         (method git-fetch)
         (sha256
          (base32 "1q77dvr2zfbhnlyjs6w23dcv547r7mad4n0fxs03ngplgr371cvj"))
         (file-name (git-file-name name version))))
      (build-system emacs-build-system)
      (propagated-inputs
       (list emacs-adaptive-wrap
             emacs-aggressive-indent
             ;; emacs-cal-china-x
             ;; emacs-citre
             emacs-cnfonts
             emacs-company
             emacs-company-posframe
             emacs-consult
             emacs-eat
             emacs-ebdb
             ;; emacs-ebdb-i18n-chn
             emacs-el2org
             emacs-emms
             emacs-flycheck
             emacs-geiser-guile
             emacs-guix
             emacs-magit
             emacs-marginalia
             emacs-markdown-mode
             emacs-modus-themes
             emacs-orderless
             emacs-org-contrib
             emacs-org-download
             emacs-org-ql
             emacs-org-super-agenda
             emacs-ox-gfm
             emacs-package-lint
             emacs-paredit
             emacs-popon
             emacs-pos-tip
             emacs-projectile
             emacs-pyim
             emacs-pyim-basedict
             emacs-rainbow-delimiters
             emacs-rainbow-mode
             emacs-switch-window
             emacs-tempel
             emacs-vertico
             emacs-vundo
             emacs-wgrep
             emacs-xmlgen
             emacs-xr))
      (synopsis "Tumashu's Emacs configure")
      (home-page "https://github.com/tumashu/emacs-helper")
      (description
       "Emacs-Helper is Tumashu's Emacs configure.")
      (license license:gpl3+))))
