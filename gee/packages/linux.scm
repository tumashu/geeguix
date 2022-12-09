(define-module (gee packages linux)
  #:use-module (gnu)
  #:use-module (gnu packages linux)
  #:use-module (guix packages)
  #:use-module (nongnu packages linux))

(define-public linux/thinkpad-t14-amd
  (customize-linux
   #:name "linux-thinkpad-t14-amd"
   #:linux linux
   #:configs
   '("# Add by linux-thinkpad-t14-amd."
     "CONFIG_MT7921E=m")))
