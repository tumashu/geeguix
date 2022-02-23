;;; Copyright © 2022 Feng Shu <tumashu@163.com>
;;;
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

(define-module (geeguix linux)
  #:use-module (gnu)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages linux)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system copy)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system linux-module)
  #:use-module (guix build-system trivial)
  #:use-module (nongnu packages linux)
  #:use-module (ice-9 match)
  #:use-module (ice-9 textual-ports)
  #:use-module (srfi srfi-1))

(define-public linux/thinkpad-t14-amd
  (let* ((native-inputs (package-native-inputs linux-5.16))
         (orig-config-str
          (call-with-input-file (car (assoc-ref native-inputs "kconfig"))
            get-string-all))
         (config (mixed-text-file
                  "thinkpad-t14-amd.config"
                  orig-config-str
                  "
# Add by linux-feng.
CONFIG_MT7921E=m")))
    (package
      (inherit linux-5.15)
      (name "linux-feng")
      (native-inputs
       `(("kconfig" ,config)
         ,@(alist-delete "kconfig" native-inputs))))))
