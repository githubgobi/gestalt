(in-package :gstutils.test)

(def-suite gstutils-suite
    :description "The Gestalt utils test suite")

(in-suite gstutils-suite)

(test replace-free-vars-test

  (is (equalp
       (replace-freevars '()
			 '(print "hola")
			 (lambda (x) x))
       '(print "hola")))

  (is (equalp
       (replace-freevars '()
			 '(let ((x 2) (y x))
			   (+ 1 2)
			   (print "hola" x)
			   'hoa)
			 (lambda (x) 2))
       '(LET ((X 2) (Y 2))
	 (+ 1 2)
	 (PRINT "hola" X)
	 'HOA)))

  (is (equalp
       (replace-freevars '()
			 '(let* ((x  (print "hola"))
				 (y (adsf))
				 (z 34))
			   (+ 1 2)
			   (print "hola" x)
			   'hoa)
			 (lambda (x) 2))
       '(LET* ((X (PRINT "hola")) (Y (ADSF)) (Z 34))
	 (+ 1 2)
	 (PRINT "hola" X)
	 'HOA)))

  (is (equalp
       (replace-freevars '()
			 '(lambda (x &optional (y 4))
			   (print x)
			   (print y))
			 (lambda (x) 2))
       '(LAMBDA (X &OPTIONAL (Y 4))
	 (PRINT X) (PRINT Y))))
  
  (is (equal
       (replace-freevars '()
			 '(flet ((my-f () (print x) my-f)
				 (other-f (x) my-f x))
			   my-f other-f)
			 (lambda (x) 2))
       '(FLET ((MY-F ()
		(PRINT 2)
		2)
	       (OTHER-F (X)
		2
		X))
	 MY-F
	 OTHER-F)))

  (is (equal
       (replace-freevars '()
			 '(labels ((my-f () (print x) my-f)
				   (other-f (x) my-f x))
			   my-f other-f)
			 (lambda (x) 2))
       '(LABELS ((MY-F ()
		  (PRINT 2)
		  MY-F)
		 (OTHER-F (X)
		  MY-F
		  X))
	 MY-F
	 OTHER-F)))
       
  )

#| Example:
(wlambda (button)
	 (declare (ignore button))
	 (declare (external those))
	 (setf (color button) 'black)
	 (set-color this 'red)
	 (setf (color that) 'blue)
	 (print (message this))
	 (print those))

|#
