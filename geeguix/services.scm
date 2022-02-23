;;; Copyright © 2022 Feng Shu <tumashu@163.com>
;;;
;;; This file is not part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix. If not, see <http://www.gnu.org/licenses/>.

(define-module (geeguix services)
  #:use-module (guix gexp)
  #:use-module (gnu packages)
  #:use-module (gnu packages linux)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:export (mt7921e-service-type))

(define mt7921e-shepherd-service
  (lambda (config)
    (list (shepherd-service
           (documentation "Modprobe/rmmod mt7921e.")
           (provision '(mt7821e))
           (requirement '(networking))
           (start #~(make-forkexec-constructor
                     (list (string-append #$kmod "/sbin/modprobe" "mt7921e"))))
           (stop #~(lambda (_)
                     ;; Return #f if successfully stopped.
                     (not (zero? (system* #$(file-append kmod "/sbin/rmmod")
                                          "mt7921e")))))))))

(define-public mt7921e-service-type
  (service-type
   (name 'mt7921e)
   (extensions
    (list (service-extension shepherd-root-service-type
                             mt7921e-shepherd-service)))))
