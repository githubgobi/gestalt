(require :asdf)

(defpackage gestalt-system
  (:use :cl :asdf))


(in-package :gestalt-system)

(defsystem gestalt
    :description "The Gestalt Common Lisp Web Framework"
    :version "0.1"
    :author "Mariano Montone <marianomontone@gmail.com>"
    :maintainer "Mariano Montone <marianomontone@gmail.com>"
    :licence "
Copyright (c) 2008 - 2009 Mariano Montone

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the \"Software\"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or
sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE."
    :components
    ((:module src
	      :components
	      ((:file "package")
	       (:file "conditions")
	       (:file "dispatcher")
	       (:file "start")
	       (:module component
			:components
			((:file "application")
			 (:file "component")
			 (:file "action")
			 (:file "mop")
			 (:file "uri")
			 (:file "counter")
			 (:file "list")
			 (:file "hunchentoot"))
			:serial t))
	      :serial t))
    :serial t
    :depends-on
    (:anaphora
     :alexandria
     :hunchentoot
     :log5
     :fiveam
     :cl-who
     :parenscript
     :css-lite
     :closer-mop
     :split-sequence
     :ironclad
     :cl-base64
     #+zlib :zlib
     #-zlib :salza2
     #-zlib :chipz))
