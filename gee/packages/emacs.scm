(define-module (gee packages emacs)
  #:use-module (gee packages)
  #:use-module (guix packages)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages xorg)
  #:use-module (guix gexp)
  #:use-module (guix utils))

(define-public emacs-gee
  (package
    (inherit emacs-next)
    (name "emacs-gee")
    (inputs (modify-inputs (package-inputs emacs-next)
              (delete "gtk+")
              (prepend libxaw)))
    (arguments
     (substitute-keyword-arguments (package-arguments emacs-next)
       ((#:configure-flags flags #~'())
        #~(cons* "--with-x-toolkit=lucid" #$flags))
       ((#:phases phases)
        #~(modify-phases #$phases
            (add-after 'install 'rename-ctags
              (lambda* (#:key outputs #:allow-other-keys)
                (with-directory-excursion (assoc-ref outputs "out")
                  ;; Emacs 自带的 ctags 会和 universal-ctags 冲突，这里将其重
                  ;; 命名。
                  (rename-file "bin/ctags" "bin/ctags-emacs"))))))))))
