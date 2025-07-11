(define-module (gee packages emacs)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gee packages)
  #:use-module (guix build gnu-build-system)
  #:use-module (guix build utils)
  #:use-module (guix build-system emacs)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (gnu packages)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-build)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages sqlite)
  #:use-module (gnu packages tree-sitter)
  #:use-module (gnu packages xorg)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (srfi srfi-9)
  #:use-module (srfi srfi-9 gnu))

(define-public emacs-gee
  (let ((commit "0c6b8643aec24935f82c63d43219f26378e3e578")
        (revision "0"))
    (package
      (inherit emacs)
      (name "emacs-gee")
      (version (git-version "30.1" revision commit))
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
         (sha256
          (base32
           "1sg7bqw0kbr2gazb2pdgaz7glqjgdn6wp96dhyj6klwqd3a8r9fk"))))
      (inputs
       (modify-inputs (package-inputs emacs-next)
         (delete "gtk+")
         (prepend tree-sitter)
         (prepend libxaw)
         (prepend sqlite)))
      (arguments
       (substitute-keyword-arguments (package-arguments emacs-next)
         ((#:configure-flags flags #~'())
          #~(list "--with-modules"
                  "--with-cairo"
                  "--with-x-toolkit=lucid"
                  "--with-native-compilation=no"
                  "--disable-build-details"))
         ((#:phases phases)
          #~(modify-phases #$phases
              (delete 'validate-comp-integrity)
              (add-after 'install 'rename-ctags
                (lambda* (#:key outputs #:allow-other-keys)
                  (with-directory-excursion (assoc-ref outputs "out")
                    ;; Emacs 自带的 ctags 会和 universal-ctags 冲突，这里将其重
                    ;; 命名。
                    (rename-file "bin/ctags" "bin/ctags-emacs")))))))))))

(define-public emacs-helper
  (let ((commit "de966739aa922d7ccaf5d8849461215497867fa6")
        (revision "7"))
    (package
      ;; 如果使用 emacs-helper 作为名称, 安装的时候 'emacs-' 前缀会被
      ;; emacs-build-system 特殊处理，所以这里使用 'Emacs-helper'.
      (name "Emacs-helper")
      (version (git-version "0.1" revision commit))
      (source
       (origin
         (uri (git-reference
                (url "https://github.com/tumashu/emacs-helper")
                (commit commit)))
         (method git-fetch)
         (sha256
          (base32 "09gbwxpiknnyd3dl6l21ph8kxivc6yhgbbl76yvnh8gh8pcwpw5v"))
         (file-name (git-file-name name version))))
      (build-system emacs-build-system)
      (arguments
       (list
        #:emacs emacs-gee
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'install 'install-tempel-files
              (lambda _
                (for-each (lambda (file)
                            (install-file file
                                          (string-append
                                           #$output "/share/emacs/site-lisp/"
                                           #$name "-" #$version "/tempel")))
                          (find-files "tempel" ".*")))))))
      (propagated-inputs
       (list emacs-adaptive-wrap
             emacs-aggressive-indent
             emacs-cal-china-x
             emacs-cnfonts
             emacs-company
             emacs-company-posframe
             emacs-consult
             emacs-ebdb
             emacs-ebdb-i18n-chn
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
       "Emacs-helper is Tumashu's Emacs configure.")
      (license license:gpl3+))))
