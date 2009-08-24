(defpackage dataflow
  (:nicknames :df)
  (:use :common-lisp
	:gstutils
	:sb-mop
	:log5
	:trivial-garbage)
  (:export
   #:wlambda
   #:dfcell
   #:dfvaluecell
   #:value
   #:test
   #:add-listener
   #:df
   #:df-lambda
   #:trigger-event
   #:run-listener
   #:dataflow-class
   #:with-df-slots
   #:*track*))

(defpackage dataflow.test
  (:nicknames :df.test)
  (:use :cl :dataflow :fiveam)
  (:shadowing-import-from :fiveam #:test)
  (:export #:run-tests))

(defpackage dataflow.examples
  (:nicknames :df.ex)
  (:use :cl :dataflow))