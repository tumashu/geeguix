(define-module (gee home services dotfiles)
  #:use-module (gnu services)
  #:use-module (gnu services configuration)
  #:use-module (gnu home services)
  #:use-module (gnu home services dotfiles)
  #:use-module (guix gexp)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 textual-ports)
  #:re-export (home-dotfiles-configuration)
  #:export (home-dotfiles-template-service-type

            home-dotfiles-template-configuration
            home-dotfiles-template-configuration?
            home-dotfiles-template-configuration-dotfiles-config
            home-dotfiles-template-configuration-template-rules))

(define-configuration/no-serialization home-dotfiles-template-configuration
  (dotfiles-config
   (home-dotfiles-configuration (home-dotfiles-configuration))
   "The @code{home-dotfiles-configuration} to use.")
  (template-rules
   (list '())
   "Template rules."))

(define (template-handle dotfile template-rules)
  (let* ((label (car dotfile))
         (file-like (cadr dotfile))
         (rule (assoc-ref template-rules label)))
    (if (and rule (local-file? file-like))
        (let* ((name (local-file-name file-like))
               (file (local-file-file file-like))
               (template (call-with-input-file file get-string-all)))
          (list label (plain-file name (template-expand template rule))))
        dotfile)))

(define (template-expand template rule)
  (let ((string template))
    (map (lambda (item)
           (let ((var (string-append "{{{" (car item) "}}}"))
                 (value (cdr item)))
             (set! string (string-replace-substring string var value))))
         rule)
    string))

(define (home-dotfiles-template-configuration->files config)
  (let ((dotfiles-config (home-dotfiles-template-configuration-dotfiles-config config))
        (template-rules (home-dotfiles-template-configuration-template-rules config)))
    (when dotfiles-config
      (map (lambda (dotfile)
             (template-handle dotfile template-rules))
           (home-dotfiles-configuration->files dotfiles-config)))))

(define-public home-dotfiles-template-service-type
  (service-type
   (name 'home-dotfiles-template)
   (extensions
    (list (service-extension
           home-files-service-type
           (lambda (config)
             (when config
               (home-dotfiles-template-configuration->files config))))))
   (default-value (home-dotfiles-template-configuration))
   (description "Handle files of home-dotfiles-service-type as template.")))
