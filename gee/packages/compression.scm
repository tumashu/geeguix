(define-module (gee packages compression)
  #:use-module (gee packages)
  #:use-module (guix packages)
  #:use-module (gnu packages)
  #:use-module (gnu packages compression))

(define-public unzip-gee
  (package
    (inherit unzip)
    (name "unzip-gee")
    (source
     (origin (inherit (package-source unzip))
             (patches (append
                       (origin-patches (package-source unzip))
                       (geeguix-search-patches
                        ;; 这个补丁可以让中文 ZIP 压缩包解压缩时不出现乱码，是
                        ;; 从 https://github.com/unxed/oemcp 移植过来的，原补
                        ;; 丁只能打在 unzip610b 上面，注意：这个补丁依赖下面两
                        ;; 个补丁：
                        ;; 1. unzip-alt-iconv-utf8.patch
                        ;; 2. unzip-alt-iconv-utf8-print.patch
                        "unzip-support-OEM-code-page-auto-detection.patch")))))))

(define-public p7zip-gee
  (package
    (inherit 7zip)
    (name "p7zip-gee")
    (source
     (origin (inherit (package-source 7zip))
             (patches (append
                       (origin-patches (package-source 7zip))
                       (geeguix-search-patches
                        ;; 这个补丁可以让中文 ZIP 压缩包解压缩时不出现乱码，是
                        ;; 从 https://github.com/unxed/oemcp 移植过来的。
                        "7zip-support-OEM-code-page-auto-detection.patch")))))))
