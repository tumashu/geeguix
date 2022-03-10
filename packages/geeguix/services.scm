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
  #:use-module (gnu packages)
  #:use-module (gnu packages linux)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (guix gexp))

(define-public mt7921e-service-type
  (shepherd-service-type
   'mt7921e
   (lambda _
     (shepherd-service
      (documentation "关机之前运行 'rmmod mt7921e' 命令。
ThinkPad-T14-AMD 笔记本电脑使用 MEDIATEK 7961 无线网卡，所以开机的时候会自动加
载 mt7921e 内核模块，但这个模块会导致关机时间消耗很长时间(> 5分钟), 这个服务的
主要作用就是在关机之前将 mt7921 模块卸载，加快关机。")
      (provision '(mt7921e))
      (requirement '(xorg-server))
      (start #~(lambda _
                 (invoke #$(file-append kmod "/bin/modprobe") "mt7921e")
                 #t))
      (stop  #~(lambda _
                 (invoke #$(file-append kmod "/bin/rmmod") "mt7921e")
                 #f))))
   #f
   (description "关机之前运行 'rmmod mt7921e' 命令。")))
