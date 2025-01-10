(define-module (gee services lightdm)
  #:use-module (gee packages display-managers)
  #:use-module (gnu artwork)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages display-managers)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages vnc)
  #:use-module (gnu packages xorg)
  #:use-module (gnu services configuration)
  #:use-module (gnu services dbus)
  #:use-module (gnu services desktop)
  #:use-module (gnu services shepherd)
  #:use-module (gnu services xorg)
  #:use-module (gnu services)
  #:use-module (gnu system pam)
  #:use-module (gnu system shadow)
  #:use-module (guix diagnostics)
  #:use-module (guix gexp)
  #:use-module (guix i18n)
  #:use-module (guix records)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-26)
  #:export (lightdm-seat-configuration
            lightdm-seat-configuration?
            lightdm-seat-configuration-name
            lightdm-seat-configuration-type
            lightdm-seat-configuration-user-session
            lightdm-seat-configuration-autologin-user
            lightdm-seat-configuration-greeter-session
            lightdm-seat-configuration-xserver-command
            lightdm-seat-configuration-session-wrapper
            lightdm-seat-configuration-extra-config

            lightdm-gtk-greeter-configuration
            lightdm-gtk-greeter-configuration?
            lightdm-gtk-greeter-configuration-lightdm-gtk-greeter
            lightdm-gtk-greeter-configuration-greeter-package
            lightdm-gtk-greeter-configuration-assets
            lightdm-gtk-greeter-configuration-greeter-config-name
            lightdm-gtk-greeter-configuration-greeter-session-name
            lightdm-gtk-greeter-configuration-theme-name
            lightdm-gtk-greeter-configuration-icon-theme-name
            lightdm-gtk-greeter-configuration-cursor-theme-name
            lightdm-gtk-greeter-configuration-allow-debug
            lightdm-gtk-greeter-configuration-background
            lightdm-gtk-greeter-configuration-a11y-states
            lightdm-gtk-greeter-configuration-reader
            lightdm-gtk-greeter-configuration-extra-config

            lightdm-greeter-general-configuration
            lightdm-greeter-general-configuration?
            lightdm-greeter-general-configuration-greeter-package
            lightdm-greeter-general-configuration-assets
            lightdm-greeter-general-configuration-greeter-config-name
            lightdm-greeter-general-configuration-greeter-session-name
            lightdm-greeter-general-configuration-config

            greeter-configuration-file-info

            lightdm-configuration
            lightdm-configuration?
            lightdm-configuration-lightdm
            lightdm-configuration-allow-empty-passwords?
            lightdm-configuration-xorg-configuration
            lightdm-configuration-greeters
            lightdm-configuration-seats
            lightdm-configuration-xdmcp?
            lightdm-configuration-xdmcp-listen-address
            lightdm-configuration-vnc-server?
            lightdm-configuration-vnc-server-command
            lightdm-configuration-vnc-server-listen-address
            lightdm-configuration-vnc-server-port
            lightdm-configuration-extra-config

            lightdm-service-type))

;;;
;;; Greeters.
;;;

(define list-of-file-likes?
  (list-of file-like?))

(define %a11y-states '(contrast font keyboard reader))

(define (a11y-state? value)
  (memq value %a11y-states))

(define list-of-a11y-states?
  (list-of a11y-state?))

(define-maybe boolean)

(define (serialize-boolean name value)
  (define (strip-trailing-? name)
    ;; field? -> field
    (let ((str (symbol->string name)))
      (if (string-suffix? "?" str)
          (string-drop-right str 1)
          str)))
  (format #f "~a=~:[false~;true~]~%" (strip-trailing-? name) value))

(define-maybe file-like)

(define (serialize-file-like name value)
  #~(format #f "~a=~a~%" '#$name #$value))

(define (serialize-list-of-a11y-states name value)
  (format #f "~a=~a~%" name (string-join (map symbol->string value) ";")))

(define-maybe string)

(define (serialize-string name value)
  (format #f "~a=~a~%" name value))

(define (serialize-number name value)
  (format #f "~a=~a~%" name value))

(define (serialize-list-of-strings _ value)
  (string-join value "\n"))

(define-configuration lightdm-gtk-greeter-configuration
  (greeter-session-name
   (string "lightdm-gtk-greeter")
   "Session name used in lightdm.conf"
   empty-serializer)
  (lightdm-gtk-greeter
   maybe-file-like
   "Keep it for compatibility, use greeter-package field instead."
   empty-serializer)
  (greeter-package
   (file-like lightdm-gtk-greeter)
   "The greeter package to use."
   empty-serializer)
  (assets
   (list-of-file-likes (list adwaita-icon-theme
                             gnome-themes-extra
                             ;; FIXME: hicolor-icon-theme should be in the
                             ;; packages of the desktop templates.
                             hicolor-icon-theme))
   "The list of packages complementing the greeter, such as package providing
icon themes."
   empty-serializer)
  (greeter-config-name
   (string "lightdm-gtk-greeter.conf")
   "Greeter config file name in /etc/lightdm directory."
   empty-serializer)
  (theme-name
   (string "Adwaita")
   "The name of the theme to use.")
  (icon-theme-name
   (string "Adwaita")
   "The name of the icon theme to use.")
  (cursor-theme-name
   (string "Adwaita")
   "The name of the cursor theme to use.")
  (cursor-theme-size
   (number 16)
   "The size to use for the cursor theme.")
  (allow-debugging?
   maybe-boolean
   "Set to #t to enable debug log level.")
  (background
   (file-like (file-append %artwork-repository
                           "/backgrounds/guix-checkered-16-9.svg"))
   "The background image to use.")
  ;; FIXME: This should be enabled by default, but it currently doesn't work,
  ;; failing to connect to D-Bus, causing the login to fail.
  (at-spi-enabled?
   (boolean #f)
   "Enable accessibility support through the Assistive Technology Service
Provider Interface (AT-SPI).")
  (a11y-states
   (list-of-a11y-states %a11y-states)
   "The accessibility features to enable, given as list of symbols.")
  (reader
   maybe-file-like
   "The command to use to launch a screen reader.")
  (extra-config
   (list-of-strings '())
   "Extra configuration values to append to the LightDM GTK Greeter
configuration file."))

(define-configuration lightdm-greeter-general-configuration
  (greeter-package
   maybe-file-like
   "The greeter package to use."
   empty-serializer)
  (assets
   (list-of-file-likes (list adwaita-icon-theme
                             gnome-themes-extra
                             ;; FIXME: hicolor-icon-theme should be in the
                             ;; packages of the desktop templates.
                             hicolor-icon-theme))
   "The list of packages complementing the greeter, such as package providing
icon themes."
   empty-serializer)
  (greeter-config-name
   maybe-string
   "Greeter config file name in /etc/lightdm directory."
   empty-serializer)
  (greeter-session-name
   maybe-string
   "Session name used in lightdm.conf"
   empty-serializer)
  (config
   (list-of-strings '())
   "Configuration values of the LightDM Greeter configuration file."))

(define (strip-record-type-name-brackets name)
  "Remove the '<' and '>' brackets from NAME, a symbol."
  (let ((name (symbol->string name)))
    (if (and (string-prefix? "<" name)
             (string-suffix? ">" name))
        (string-drop (string-drop-right name 1) 1)
        (error "unexpected record type name" name))))

(define (config->type-name config)
  "Return the type name of CONFIG."
  (strip-record-type-name-brackets
   (record-type-name (struct-vtable config))))

(define (greeter-configuration-field config field)
  "Return the value of FIELD in CONFIG."
  (let ((rtd (struct-vtable config)))
    ((record-accessor rtd field) config)))

(define (greeter-configuration->session-name config)
  "Return the session name of CONFIG, a greeter configuration."
  (greeter-configuration-field config 'greeter-session-name))

(define (greeter-configuration->conf-name config)
  "Return the file name of CONFIG, a greeter configuration."
  (greeter-configuration-field config 'greeter-config-name))

(define (greeter-configuration-valid? config)
  "Check greeter-configuration CONFIG valid or not."
  (let ((conf-name (greeter-configuration->conf-name config))
        (session-name (greeter-configuration->session-name config)))
    (and (string? conf-name)
         (string? session-name)
         (> (string-length conf-name) 0)
         (> (string-length session-name) 0))))

(define (greeter-configuration->packages config)
  "Return the list of greeter packages, including assets, used by CONFIG, a
greeter configuration."
  (filter file-like?
          (cons (greeter-configuration->greeter-package config)
                (greeter-configuration-field config 'assets))))

(define (greeter-configuration->greeter-package config)
  "Return greeter package used by CONFIG, a greeter configuration."
  (let ((type-name (config->type-name config))
        (pkg1 (greeter-configuration-field config 'greeter-package)))
    (if (eq? type-name "lightdm-gtk-greeter-configuration")
        ;; Handle lightdm-gtk-greeter field for keeping it for compatibility.
        (let ((pkg2 (greeter-configuration-field config 'lightdm-gtk-greeter)))
          (if (file-like? pkg2) pkg2 pkg1))
        pkg1)))

(define (lightdm-gtk-greeter-configuration->file config)
  "Serialize CONFIG (lightdm-gtk-greeter-configuration) into a file under the
output directory, so that it can be easily added to XDG_CONF_DIRS."
  (computed-file
   (greeter-configuration->conf-name config)
   #~(begin
       (call-with-output-file #$output
         (lambda (port)
           (format port (string-append
                         "[greeter]\n"
                         #$(serialize-configuration
                            config
                            lightdm-gtk-greeter-configuration-fields))))))))

(define (lightdm-greeter-general-configuration->file config)
  "Serialize CONFIG (lightdm-greeter-general-configuration) into a file under the
output directory, so that it can be easily added to XDG_CONF_DIRS."
  (computed-file
   (greeter-configuration->conf-name config)
   #~(begin
       (call-with-output-file #$output
         (lambda (port)
           (format port #$(serialize-configuration
                           config
                           lightdm-greeter-general-configuration-fields)))))))

;; The info used by greeter-configuration->file.
(define greeter-configuration-file-info
  `(("lightdm-gtk-greeter-configuration" .
     ,lightdm-gtk-greeter-configuration->file)
    ("lightdm-greeter-general-configuration" .
     ,lightdm-greeter-general-configuration->file)))

(define (greeter-configuration->file config)
  "Serialize CONFIG into a file under the output directory, so that it can be
easily added to XDG_CONF_DIRS."
  (let* ((type-name (config->type-name config))
         (func (assoc-ref greeter-configuration-file-info type-name)))
    (if (procedure? func)
        (func config)
        (leave (G_ "Can not find serialize function for greeter config type: ~a~%") type-name))))


;;;
;;; Seats.
;;;

(define seat-name? string?)

(define (serialize-seat-name _ value)
  (format #f "[Seat:~a]~%" value))

(define (seat-type? type)
  (memq type '(local xremote)))

(define (serialize-seat-type name value)
  (format #f "~a=~a~%" name value))

(define-maybe seat-type)

(define (greeter-session? value)
  (and (or (symbol? value) (string? value))
       (string-contains (format #f "~a" value) "greeter")))

(define (serialize-greeter-session name value)
  (format #f "~a=~a~%" name value))

(define-maybe greeter-session)

;;; Note: all the fields except for the seat name should be 'maybe's, since
;;; the real default value is set by the %lightdm-seat-default define later,
;;; and this avoids repeating ourselves in the serialized configuration file.
(define-configuration lightdm-seat-configuration
  (name
   seat-name
   "The name of the seat.  An asterisk (*) can be used in the name
to apply the seat configuration to all the seat names it matches.")
  (user-session
   maybe-string
   "The session to use by default.  The session name must be provided as a
lowercase string, such as @code{\"gnome\"}, @code{\"ratpoison\"}, etc.")
  (type
   (seat-type 'local)
   "The type of the seat, either the @code{local} or @code{xremote} symbol.")
  (autologin-user
   maybe-string
   "The username to automatically log in with by default.")
  (greeter-session
   (greeter-session 'lightdm-gtk-greeter)
   "The greeter session to use, specified as a symbol.  Currently, only
@code{lightdm-gtk-greeter} is supported.")
  ;; Note: xserver-command must be lazily computed, so that it can be
  ;; overridden via 'lightdm-configuration-xorg-configuration'.
  (xserver-command
   maybe-file-like
   "The Xorg server command to run.")
  (session-wrapper
   (file-like (xinitrc))
   "The xinitrc session wrapper to use.")
  (extra-config
   (list-of-strings '())
   "Extra configuration values to append to the seat configuration section."))

(define list-of-seat-configurations?
  (list-of lightdm-seat-configuration?))


;;;
;;; LightDM.
;;;

(define (greeter-configuration? config)
  ((record-predicate (struct-vtable config)) config))

(define (list-of-greeter-configurations? greeter-configs)
  (and ((list-of greeter-configuration?) greeter-configs)
       ;; Greeter configurations must also not be provided more than once.
       (let* ((conf-names (map greeter-configuration->conf-name greeter-configs))
              (dupes (filter (lambda (conf-name)
                               (< 1 (count (cut eq? conf-name <>) conf-names)))
                             conf-names)))
         (unless (null? dupes)
           (leave (G_ "Duplicate greeter configurations: ~a~%") dupes)))))

(define-configuration/no-serialization lightdm-configuration
  (lightdm
   (file-like lightdm)
   "The lightdm package to use.")
  (allow-empty-passwords?
   (boolean #f)
   "Whether users not having a password set can login.")
  (debug?
   (boolean #f)
   "Enable verbose output.")
  (xorg-configuration
   (xorg-configuration (xorg-configuration))
   "The default Xorg server configuration to use to generate the Xorg server
start script.  It can be refined per seat via the @code{xserver-command} of
the @code{<lightdm-seat-configuration>} record, if desired.")
  (greeters
   (list-of-greeter-configurations
    (list (lightdm-gtk-greeter-configuration)
          (lightdm-greeter-general-configuration)))
   "The LightDM greeter configurations specifying the greeters to use.")
  (seats
   (list-of-seat-configurations (list (lightdm-seat-configuration
                                       (name "*"))))
   "The seat configurations to use.  A LightDM seat is akin to a user.")
  (xdmcp?
   (boolean #f)
   "Whether a XDMCP server should listen on port UDP 177.")
  (xdmcp-listen-address
   maybe-string
   "The host or IP address the XDMCP server listens for incoming connections.
When unspecified, listen on for any hosts/IP addresses.")
  (vnc-server?
   (boolean #f)
   "Whether a VNC server is started.")
  (vnc-server-command
   (file-like (file-append tigervnc-server "/bin/Xvnc"))
   "The Xvnc command to use for the VNC server, it's possible to provide extra
options not otherwise exposed along the command, for example to disable
security:
@lisp
(vnc-server-command
 (file-append tigervnc-server \"/bin/Xvnc\"
             \" -SecurityTypes None\" ))
@end lisp

Or to set a PasswordFile for the classic (unsecure) VncAuth mechanism:
@lisp
(vnc-server-command
 (file-append tigervnc-server \"/bin/Xvnc\"
             \" -PasswordFile /var/lib/lightdm/.vnc/passwd\"))
@end lisp
The password file should be manually created using the @command{vncpasswd}
command.

Note that LightDM will create new sessions for VNC users, which means they
need to authenticate in the same way as local users would.
")
  (vnc-server-listen-address
   maybe-string
   "The host or IP address the VNC server listens for incoming connections.
When unspecified, listen for any hosts/IP addresses.")
  (vnc-server-port
   (number 5900)
   "The TCP port the VNC server should listen to.")
  (extra-config
   (list-of-strings '())
   "Extra configuration values to append to the LightDM configuration file."))

(define (lightdm-configuration->packages config)
  "Return all the greeter packages and their assets defined in CONFIG, a
<lightdm-configuration> object, as well as the lightdm package itself."
  (cons (lightdm-configuration-lightdm config)
        (append-map greeter-configuration->packages
                    (lightdm-configuration-greeters config))))

(define (validate-lightdm-configuration config)
  "Sanity check CONFIG, a <lightdm-configuration> record instance."
  ;; This is required to make inter-field validations, such as between the
  ;; seats and greeters.
  (let* ((seats (lightdm-configuration-seats config))
         (greeter-sessions (delete-duplicates
                            (map lightdm-seat-configuration-greeter-session
                                 seats)
                            eq?))
         (greeter-configurations (lightdm-configuration-greeters config))
         (missing-greeters
          (filter-map
           (lambda (id)
             (if (find (lambda (greeter-config)
                         (let* ((id (format #f "~a" id))
                                (name (greeter-configuration->session-name greeter-config)))
                           (equal? id name)))
                       greeter-configurations)
                 #f                     ;happy path
                 id))
           greeter-sessions)))
    (unless (null? missing-greeters)
      (leave (G_ "no greeter configured for seat greeter sessions: ~a~%")
             missing-greeters))))

(define (lightdm-configuration-file config)
  (match-record config <lightdm-configuration>
    (xorg-configuration
     seats xdmcp? xdmcp-listen-address
     vnc-server? vnc-server-command vnc-server-listen-address vnc-server-port
     extra-config)
    (apply
     mixed-text-file
     "lightdm.conf" "
#
# General configuration
#
[LightDM]
greeter-user=lightdm
sessions-directory=/run/current-system/profile/share/xsessions\
:/run/current-system/profile/share/wayland-sessions
remote-sessions-directory=/run/current-system/profile/share/remote-sessions
"
     #~(string-join '#$extra-config "\n")
     "
#
# XDMCP Server configuration
#
[XDMCPServer]
enabled=" (if xdmcp? "true" "false") "\n"
(if (maybe-value-set? xdmcp-listen-address)
    (format #f "xdmcp-listen-address=~a" xdmcp-listen-address)
    "") "

#
# VNC Server configuration
#
[VNCServer]
enabled=" (if vnc-server? "true" "false") "
command=" vnc-server-command "
port=" (number->string vnc-server-port) "\n"
(if (maybe-value-set? vnc-server-listen-address)
    (format #f "vnc-server-listen-address=~a" vnc-server-listen-address)
    "") "

#
# Seat configuration.
#
"
    (map (lambda (seat)
           ;; This complication exists to propagate a default value for
           ;; the 'xserver-command' field of the seats.  Having a
           ;; 'xorg-configuration' field at the root of the
           ;; lightdm-configuration enables the use of
           ;; 'set-xorg-configuration' and can be more convenient.
           (let ((seat* (if (maybe-value-set?
                             (lightdm-seat-configuration-xserver-command seat))
                            seat
                            (lightdm-seat-configuration
                             (inherit seat)
                             (xserver-command (xorg-start-command
                                               xorg-configuration))))))
             (serialize-configuration seat*
                                      lightdm-seat-configuration-fields)))
         seats))))

(define (lightdm-configuration-directory config)
  "Return a directory containing the serialized lightdm configuration
and all the serialized greeter configurations from CONFIG."
  (file-union "etc-lightdm"
              (cons `("lightdm.conf" ,(lightdm-configuration-file config))
                    (map (lambda (g)
                           `(,(greeter-configuration->conf-name g)
                             ,(greeter-configuration->file g)))
                         (filter greeter-configuration-valid?
                                 (lightdm-configuration-greeters config))))))

(define %lightdm-accounts
  (list (user-group (name "lightdm") (system? #t))
        (user-account
         (name "lightdm")
         (group "lightdm")
         (system? #t)
         (comment "LightDM user")
         (home-directory "/var/lib/lightdm")
         (shell (file-append shadow "/sbin/nologin")))))

(define %lightdm-activation
  ;; Ensure /var/lib/lightdm is owned by the "lightdm" user.  Adapted from the
  ;; %gdm-activation.
  (with-imported-modules '((guix build utils))
    #~(begin
        (use-modules (guix build utils))

        (define (ensure-ownership directory)
          (let* ((lightdm (getpwnam "lightdm"))
                 (uid (passwd:uid lightdm))
                 (gid (passwd:gid lightdm))
                 (st  (stat directory #f)))
            ;; Recurse into directory only if it has wrong ownership.
            (when (and st
                       (or (not (= uid (stat:uid st)))
                           (not (= gid (stat:gid st)))))
              (for-each (lambda (file)
                          (chown file uid gid))
                        (find-files directory #:directories? #t)))))

        (when (not (stat "/var/lib/lightdm-data" #f))
          (mkdir-p "/var/lib/lightdm-data"))
        (for-each ensure-ownership
                  '("/var/lib/lightdm"
                    "/var/lib/lightdm-data")))))

(define (lightdm-pam-service config)
  "Return a PAM service for @command{lightdm}."
  (unix-pam-service "lightdm"
                    #:login-uid? #t
                    #:allow-empty-passwords?
                    (lightdm-configuration-allow-empty-passwords? config)))

(define (lightdm-greeter-pam-service)
  "Return a PAM service for @command{lightdm-greeter}."
  (pam-service
   (name "lightdm-greeter")
   (auth (list
          ;; Load environment from /etc/environment and ~/.pam_environment.
          (pam-entry (control "required") (module "pam_env.so"))
          ;; Always let the greeter start without authentication.
          (pam-entry (control "required") (module "pam_permit.so"))))
   ;; No action required for account management
   (account (list (pam-entry (control "required") (module "pam_permit.so"))))
   ;; Prohibit changing password.
   (password (list (pam-entry (control "required") (module "pam_deny.so"))))
   ;; Setup session.
   (session (list (pam-entry (control "required") (module "pam_unix.so"))))))

(define (lightdm-autologin-pam-service)
  "Return a PAM service for @command{lightdm-autologin}}."
  (pam-service
   (name "lightdm-autologin")
   (auth
    (list
     ;; Block login if user is globally disabled.
     (pam-entry (control "required") (module "pam_nologin.so"))
     (pam-entry (control "required") (module "pam_succeed_if.so")
                (arguments (list "uid >= 1000")))
     ;; Allow access without authentication.
     (pam-entry (control "required") (module "pam_permit.so"))))
   ;; Stop autologin if account requires action.
   (account (list (pam-entry (control "required") (module "pam_unix.so"))))
   ;; Prohibit changing password.
   (password (list (pam-entry (control "required") (module "pam_deny.so"))))
   ;; Setup session.
   (session (list (pam-entry (control "required") (module "pam_unix.so"))))))

(define (lightdm-pam-services config)
  (list (lightdm-pam-service config)
        (lightdm-greeter-pam-service)
        (lightdm-autologin-pam-service)))

(define (lightdm-shepherd-service config)
  "Return a <lightdm-service> for LightDM using CONFIG."

  (validate-lightdm-configuration config)

  (define lightdm-command
    #~(list #$(file-append (lightdm-configuration-lightdm config)
                           "/sbin/lightdm")
            #$@(if (lightdm-configuration-debug? config)
                   #~("--debug")
                   #~())))

  (define lightdm-paths
    (let ((lightdm (lightdm-configuration-lightdm config)))
      #~(string-join
         '#$(map (lambda (dir)
                   (file-append lightdm dir))
                 '("/bin" "/sbin" "/libexec"))
         ":")))

  (define data-dirs
    ;; LightDM itself needs to be in XDG_DATA_DIRS for the accountsservice
    ;; interface it provides to be picked up.  The greeters must also be in
    ;; XDG_DATA_DIRS to be found.
    (let ((packages (lightdm-configuration->packages config)))
      #~(string-join '#$(map (cut file-append <> "/share") packages)
                     ":")))

  (list
   (shepherd-service
    (documentation "LightDM display manager")
    (requirement '(pam dbus-system user-processes host-name))
    (provision '(lightdm display-manager xorg-server))
    (respawn? #f)
    (start
     ;; Note: sadly, environment variables defined for 'lightdm' are
     ;; cleared and/or overridden by /etc/profile by its spawned greeters,
     ;; so an out-of-band means such as /etc is required.
     #~(make-forkexec-constructor #$lightdm-command
                                  ;; Lightdm needs itself in its PATH.
                                  #:environment-variables
                                  (list
                                   ;; It looks for greeter .desktop files as
                                   ;; well as lightdm accountsservice
                                   ;; interface in XDG_DATA_DIRS.
                                   (string-append "XDG_DATA_DIRS="
                                                  #$data-dirs)
                                   (string-append "PATH=" #$lightdm-paths))))
    (stop #~(make-kill-destructor)))))

(define (lightdm-etc-service config)
  "Return a list of FILES for @var{etc-service-type} to build the
/etc/lightdm directory using CONFIG"
  (list `("lightdm" ,(lightdm-configuration-directory config))))

(define lightdm-service-type
  (handle-xorg-configuration
   lightdm-configuration
   (service-type
    (name 'lightdm)
    (default-value (lightdm-configuration))
    (extensions
     (list (service-extension pam-root-service-type lightdm-pam-services)
           (service-extension shepherd-root-service-type
                              lightdm-shepherd-service)
           (service-extension activation-service-type
                              (const %lightdm-activation))
           (service-extension dbus-root-service-type
                              (compose list lightdm-configuration-lightdm))
           (service-extension polkit-service-type
                              (compose list lightdm-configuration-lightdm))
           (service-extension account-service-type
                              (const %lightdm-accounts))
           ;; Add 'lightdm' to the system profile, so that its
           ;; 'share/accountsservice' D-Bus service extension directory can be
           ;; found via the 'XDG_DATA_DIRS=/run/current-system/profile/share'
           ;; environment variable set in the wrapper of the
           ;; libexec/accounts-daemon binary of the accountsservice package.
           ;; This daemon is spawned by D-Bus, and there's little we can do to
           ;; affect its environment.  For more reading, see:
           ;; https://github.com/NixOS/nixpkgs/issues/45059.
           (service-extension profile-service-type
                              lightdm-configuration->packages)
           ;; This is needed for lightdm and greeter
           ;; to find their configuration
           (service-extension etc-service-type
                              lightdm-etc-service)))
    (description "Run @code{lightdm}, the LightDM graphical login manager."))))


;;;
;;; Generate documentation.
;;;
(define (generate-doc)
  (configuration->documentation 'lightdm-configuration)
  (configuration->documentation 'lightdm-gtk-greeter-configuration)
  (configuration->documentation 'lightdm-greeter-general-configuration)
  (configuration->documentation 'lightdm-seat-configuration))
