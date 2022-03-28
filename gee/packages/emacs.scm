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
  #:use-module (gnu packages)
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

(define-public emacs29
  (let ((commit "0e7314f6f15a20cb2ae712c09bb201f571823a6f")
        (revision "0"))
    (package
      (inherit emacs-next)
      (name "emacs29")
      (version (git-version "git" revision commit))
      (source
       (origin
         (inherit (package-source emacs-next))
         (method git-fetch)
         (uri (git-reference
               (url "https://git.savannah.gnu.org/git/emacs.git")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32
           "0xqwn96s1a4li3vanran2kmdm3dn47lpz2b9rhgvc58mpw3m61as"))
         (patches (search-patches "emacs-exec-path-1.patch"
                                  "emacs-fix-scheme-indent-function.patch"
                                  "emacs-ignore-empty-xim-styles.patch"
                                  "emacs-source-date-epoch.patch"))))
      (arguments
       (substitute-keyword-arguments (package-arguments emacs-next)
         ((#:configure-flags flags ''())
          `(cons* "--with-xwidgets" ,flags))))
      (native-inputs
       (modify-inputs (package-native-inputs emacs)
         (prepend autoconf)))
      (inputs
       `(("webkitgtk" ,webkitgtk-with-libsoup2)
         ,@(package-inputs emacs-next))))))
