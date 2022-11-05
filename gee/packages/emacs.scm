(define-module (gee packages emacs)
  #:use-module (gee packages)
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages xorg)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (srfi srfi-9)
  #:use-module (srfi srfi-9 gnu))

(define-public emacs-gee
  (set-fields
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
                   (rename-file "bin/ctags" "bin/ctags-emacs")))))))))
   ((package-source origin-uri git-reference-url)
    ;; Emacs git 下载速度太慢了，使用南京大学的 Emacs 镜像，同步延
    ;; 迟大概 8 小时。https://git.savannah.gnu.org/git/emacs.git
    "https://mirrors.nju.edu.cn/git/emacs.git")))
