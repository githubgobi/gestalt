(in-package :gst.view)

(defclass view-node (xml-node tracked-xml-node dom-xml-node)
  ((print-cache
    :accessor print-cache
    :initform nil
    :documentation
    "We hold a cached printed representation of
     this node in this variable. It is cleaned
     whenever the node changes")
   (encoded-node-id :accessor encoded-node-id
		    :initform ""
		    :documentation "The encoded node id (for dom browser handling)")
   (handler :initarg :handler
	    :accessor handler
	    :initform nil
	    :documentation "The view handler")
   (controller :initarg :controller
	       :accessor controller
	       :initform nil
	       :documentation "The associated controller"))
  (:documentation "A node of the view is an xml-node
                   with changes tracked"))

(defclass view-container (view-node xml-container)
  ())

;----------------------
; Operations wrappers
;----------------------

;; node-id encoding
(defmethod (setf node-id) :after (value (node view-node))
  (declare (ignore value))
  (setf (encoded-node-id node)
	(encode-node-id (node-id node))))

  
(defvar *root-view* nil "The view of the system")

(defmethod make-base-tree ((node view-node) &rest args)
  (declare (ignore args))
  (call-next-method)
  (setf *root-view* node))
  
;; printing caching
(defmethod print-object :around ((node view-node) stream)
  (when (not (print-cache node))
    (let ((aux-stream (make-string-output-stream)))
      (funcall #'call-next-method node aux-stream)
      (setf (print-cache node) (get-output-stream-string aux-stream))))
  (format stream "~A" (print-cache node)))

(defvar *flush-print-cache* t)

(defun flush-local-print-cache (node)
  (when node
    (setf (print-cache node) nil)
    (flush-local-print-cache (parent node))))

(defun flush-all-print-cache (node)
  (labels ((find-root (node)
	     (if (null (parent node))
		 node
		 (find-root (parent node))))
	   (flush-down (node)
	     (setf (print-cache node) nil)
	     (do-children (child node)
	       (flush-down child))))
    (flush-down (find-root node))))
    
(defun flush-print-cache (node &key all)
  (if all
      (flush-all-print-cache node)
      (flush-local-print-cache node)))

(defmacro flushing-in-the-end ((node) &body body)
  "This macro is for making modifications to the tree
postponing the print-cache flush to the end to avoid performance overhead"
  `(progn
     (let ((*flush-print-cache* nil))
       ,@body)
     (flush-print-cache ,node :all t)))

(defmethod append-child :after ((node view-container) child)
  (declare (ignore child))
  (when *flush-print-cache*
    (flush-print-cache node)))

(defmethod replace-child :after ((node view-container) child new-child)
  (declare (ignore child new-child))
  (when *flush-print-cache*
    (flush-print-cache node)))

(defmethod insert-child-after :after ((node view-container) child reference-child)
  (declare (ignore child reference-child))
  (when *flush-print-cache*
    (flush-print-cache node)))

(defmethod insert-child-before :after ((node view-container) child reference-child)
  (declare (ignore child reference-child))
  (when *flush-print-cache*
    (flush-print-cache node)))

(defmethod remove-child :after ((node view-container) child)
  (declare (ignore child))
  (when *flush-print-cache*
    (flush-print-cache node)))

(defvar *node-id-delimiter* #\:)

(defun node-id-to-string (node-id)
  (foldl (lambda (pos str)
	   (concatenate 'string
			(string *node-id-delimiter*)
			(princ-to-string pos)
			str))
	 node-id ""))

(defun string-to-node-id (string)
  (nreverse
   (mapcar #'parse-integer
	  (cdr
	   (split-sequence:split-sequence
	    *node-id-delimiter*
	    string)))))


(defun encode-node-id (node-id)
  (usb8-array-to-base64-string
   (encrypt
    (string-to-octets (node-id-to-string node-id)))
   :uri t))

(defun decode-node-id (encoded-node-id)
  (string-to-node-id
   (octets-to-string
    (decrypt
     (base64-string-to-usb8-array
      encoded-node-id :uri t)))))

;---------------------------
; Applying modifications
;---------------------------

(defmethod apply-modifications (modifications (tree xml-node))
  (loop for modification in modifications
        do (apply-modification modification tree)))

(defmethod apply-modification ((mod append-child-modification) tree)
  (let ((target
 	 (get-node-with-id (node-id (target mod)) tree)))
    (assert target nil "Node with id ~A not found in ~A when applying ~A"
	    (node-id (target mod)) tree mod)
    (append-child target (copy-xml-tree (child mod)))))

(defmethod apply-modification ((mod insert-child-modification) tree)
  (let ((target
 	 (get-node-with-id (node-id (target mod)) tree))
 	(reference-child
 	 (get-node-with-id (node-id (reference-child mod)) tree)))
    (assert target nil "~A not found when applying ~A" (target mod) mod)
    (assert reference-child nil "~A not found when applying ~A"
	    (reference-child mod) mod)
    (insert-child target
                  (copy-xml-tree (child mod))
		  (place mod)
		  reference-child)))

(defmethod apply-modification ((mod replace-child-modification) tree)
  (let ((target
 	 (get-node-with-id (node-id (target mod)) tree))
	(child (get-node-with-id (node-id (child mod)) tree)))
    (assert target nil "~A not found when applying ~A" (target mod) mod)
    (replace-child target child (copy-xml-tree (replacement mod)))))

(defmethod apply-modification ((mod remove-child-modification) tree)
  (let ((target
 	 (get-node-with-id (node-id (target mod)) tree))
	(child (get-node-with-id (node-id (child mod)) tree)))
    (assert target nil "~A not found when applying ~A" (target mod) mod)
    (assert child nil "~A not found when applying ~A" (child mod) mod)
    (remove-child target child)))

(defmethod apply-modification :around ((mod xml-node-modification)
				       (tree tracked-xml-node))
  ; disable modifications tracking when applying modifications
  (let ((*register-modifications* nil))
    (call-next-method)))

(defmethod apply-modification :around ((mod xml-node-modification)
				       (tree dom-xml-node))
  ; disable id assignation when applying modifications
  (let ((*assign-ids* nil))
    (call-next-method)))


;------------------------------
;   XMLisp Glue
;------------------------------

(defmethod xml:print-slot-with-name-p ((view-node view-node) name)
  (and (call-next-method)
       (not (one-of ("print-cache" "handler" "controller") name
		    :test #'string-equal))))