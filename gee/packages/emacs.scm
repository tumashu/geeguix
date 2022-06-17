(define-module (gee packages emacs)
  #:use-module (gee packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module ((gnu packages)
                #:hide (search-patch
                        search-patches
                        %patch-path))
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system glib-or-gtk)
  #:use-module (gnu packages acl)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages fribidi)
  #:use-module (gnu packages gd)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages ghostscript)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)     ; for librsvg
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages image)
  #:use-module (gnu packages linux)     ; alsa-lib, gpm
  #:use-module (gnu packages mail)      ; for mailutils
  #:use-module (gnu packages multiprecision)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages pdf)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages web)       ; for jansson
  #:use-module (gnu packages webkit)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xorg)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1))

(define-public emacs29-without-ctags
  (let ((commit "4ce2322894a21a1bd3045a6c0dcb2069b31a9c05")
        (revision "0"))
    (package
      (inherit emacs)
      (name "emacs29-without-ctags")
      (version (git-version "29.0.92" revision commit))
      (source
       (origin
         (inherit (package-source emacs))
         (method git-fetch)
         (uri (git-reference
               ;; Emacs git 下载速度太慢了，使用南京大学的 Emacs 镜像，同步延
               ;; 迟大概 8 小时。https://git.savannah.gnu.org/git/emacs.git
               (url "https://mirrors.nju.edu.cn/git/emacs.git")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32
           "1g3bsprzk0biq7l6aqkh1gzp1gjmn4c9yv9hd7jrk31z4s81mxpd"))))
      (arguments
       (substitute-keyword-arguments (package-arguments emacs)
         ((#:phases phases)
          #~(modify-phases #$phases
              (add-after 'install 'remove-ctags
                (lambda* (#:key outputs #:allow-other-keys)
                  (with-directory-excursion (assoc-ref outputs "out")
                    ;; Emacs 自带的 ctags 会和 universal-ctags 冲突，这里将其重
                    ;; 命名。
                    (rename-file "bin/ctags" "bin/ctags-emacs"))))))))
      (native-inputs
       (modify-inputs (package-native-inputs emacs)
         (prepend autoconf))))))

