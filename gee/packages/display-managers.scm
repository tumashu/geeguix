(define-module (gee packages display-managers)
  #:use-module (gee packages)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (gnu packages display-managers))

(define-public lightdm-gtk-greeter-gee
  (package
    (inherit lightdm-gtk-greeter)
    (name "lightdm-gtk-greeter-gee")
    (source (origin
              (inherit (package-source lightdm-gtk-greeter))
              (patches (geeguix-search-patches
                        "lightdm-gtk-greeter-icon-size-option.patch"))))))
