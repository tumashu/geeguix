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
    (version (package-version linux-firmware))
    (source (origin
              (inherit (package-source linux-firmware))
              (uri (string-append "https://mirrors.nju.edu.cn/kernel/firmware/"
                                  "linux-firmware-" version ".tar.xz"))
              (sha256
               (base32
                "0r1xrgq512031xz1ysx2a295kvsc7dxf2mrp8x1m6kgvl9dy44fz"))))))

(define-public amdgpu-firmware-gee
  (package
    (inherit amdgpu-firmware)
    (name "amdgpu-firmware-gee")
    (source (package-source linux-firmware-gee))))
