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
  #:use-module (guix utils)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1))

(define-public emacs28
  (let ((commit "968af794ba84d90d547de463448de57b7dff3787")
        (revision "0"))
    (package
      (inherit emacs)
      (name "emacs28")
      (version (git-version "28.0.92" revision commit))
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
           "1mjkw0ras4g8g51dc4a6g8jw7zgyfmmi063ljkm77cdn7jg2pgx4"))
         (patches (search-patches "emacs-exec-path.patch"
                                  "emacs-fix-scheme-indent-function.patch"
                                  "emacs-source-date-epoch.patch"))))
      (native-inputs
       (modify-inputs (package-native-inputs emacs)
         (prepend autoconf))))))

(define-public emacs29
  (let ((commit "f5adb2584a9e25e3bbf01d1ca1c7fc6e511a4012")
        (revision "0"))
    (package
      (inherit emacs28)
      (name "emacs29")
      (version (git-version "29.0.50" revision commit))
      (source
       (origin
         (inherit (package-source emacs28))
         (method git-fetch)
         (uri (git-reference
               (url "https://mirrors.nju.edu.cn/git/emacs.git")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32
           "1dsywvd306r69rgx3w1w27qyg1ncnwxx7mpmxs0dcx92h21k5k4h")))))))
