(defpackage cl-url-system
  (:use :cl :asdf))

(in-package :cl-url-system)

(defsystem cl-url
    :description "cl-url: A Common Lisp library for handling URLs"
    :version "0.1"
    :author "Mariano Montone <mariano@copyleft.no>"
    :maintainer "Mariano Montone <mariano@copyleft.no>"
    :licence "Public Domain"
    :components
    ((:file "package")
     (:file "cl-url"))
    :serial t
    :depends-on
    (:alexandria
     :cl-ppcre
     :split-sequence))