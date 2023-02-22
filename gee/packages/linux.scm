(define-module (gee packages linux)
  #:use-module (gnu)
  #:use-module (gnu packages linux)
  #:use-module (guix download)
  #:use-module (guix packages)
  #:use-module (nongnu packages linux))

(define-public linux-thinkpad-t14-amd
  (customize-linux
   #:name "linux-thinkpad-t14-amd"
   #:linux linux
   #:configs
   '("# Add by linux-thinkpad-t14-amd."
     "CONFIG_MT7921E=m")))

(define-public linux-firmware-gee
  (package
    (inherit linux-firmware)
    (name "linux-firmware-gee")
    (version "20221214")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://mirrors.nju.edu.cn/kernel/firmware/"
                                  "linux-firmware-" version ".tar.gz"))
              (sha256
               (base32
                "1f93aq0a35niv8qv8wyy033palpplbgr2cq0vihb97wxfkk5wmr2"))))))
