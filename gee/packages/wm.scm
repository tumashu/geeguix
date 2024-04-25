(define-module (gee packages wm)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (gnu packages wm))

(define-public icewm-gee
  (package
    (inherit icewm)
    (name "icewm-gee")
    (arguments
     (substitute-keyword-arguments (package-arguments icewm)
       ((#:phases phases)
        #~(modify-phases #$phases
            (add-after 'unpack 'rename-ctags
              (lambda _
                ;; Hack: 解决 fdo 菜单无法显示中文的问题。
                (substitute* "src/fdomenu.cc"
                  (("(ret->title == nullptr)")
                   "(true)"))))))))))
