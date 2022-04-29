(define-module (gee packages linux)
  #:use-module (gnu)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages linux)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system linux-module)
  #:use-module (guix build-system trivial)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (ice-9 match)
  #:use-module (ice-9 textual-ports)
  #:use-module (nongnu packages linux)
  #:use-module (srfi srfi-1))

(define-public linux/thinkpad-t14-amd
  (let* ((native-inputs (package-native-inputs linux-5.17))
         (orig-config-str
          (call-with-input-file (car (assoc-ref native-inputs "kconfig"))
            get-string-all))
         (config (mixed-text-file
                  "thinkpad-t14-amd.config"
                  orig-config-str
                  "
# Add by linux-thinkpad-t14-amd.
CONFIG_MT7921E=m")))
    (package
      (inherit linux)
      (name "linux-thinkpad-t14-amd")
      (native-inputs
       `(("kconfig" ,config)
         ,@(alist-delete "kconfig" native-inputs))))))
