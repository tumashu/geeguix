;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2020 Andrew Whatson <whatson@gmail.com>
;;;
;;; This file is NOT part of GNU Guix.
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
;;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(define-module (gee packages)
  #:use-module ((gnu packages) #:prefix gnu:)
  #:use-module (guix diagnostics)
  #:use-module (guix i18n)
  #:use-module (srfi srfi-1)
  #:export (geeguix-search-patch
            geeguix-search-patches
            geeguix-patch-path))

(define-syntax-rule (geeguix-search-patches file-name ...)
  "Return the list of absolute file names corresponding to each
FILE-NAME found in GEEGUIX-PATCH-PATH."
  (list (geeguix-search-patch file-name) ...))

(define (geeguix-search-patch file-name)
  "Search the patch FILE-NAME.  Raise an error if not found."
  (or (search-path (geeguix-patch-path) file-name)
      (raise (formatted-message
              (G_ "~a: patch not found")
              file-name))))

(define geeguix-root
  (find (lambda (path)
          (file-exists? (string-append path "/gee/packages.scm")))
        %load-path))

(define geeguix-patch-path
  (make-parameter
   (cons
    (string-append geeguix-root "/gee/packages/patches")
    (gnu:%patch-path))))
