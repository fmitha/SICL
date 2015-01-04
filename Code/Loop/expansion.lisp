;;;; Copyright (c) 2014
;;;;
;;;;     Robert Strandh (robert.strandh@gmail.com)
;;;;
;;;; all rights reserved. 
;;;;
;;;; Permission is hereby granted to use this software for any 
;;;; purpose, including using, modifying, and redistributing it.
;;;;
;;;; The software is provided "as-is" with no warranty.  The user of
;;;; this software assumes any responsibility of the consequences. 

(in-package #:sicl-loop)

;;; The purpose of this generic function is to generate a list of all
;;; bound variables in a clause.  The same variable occurs as many
;;; times in the list as the number of times it is bound in the
;;; clause.
(defgeneric bound-variables (clause))

(defgeneric declarations (clause)
  (:method (clause)
    (declare (ignore clause))
    '()))

(defgeneric initial-bindings (clause)
  (:method (clause)
    (declare (ignore clause))
    '()))

(defgeneric final-bindings (clause)
  (:method (clause)
    (declare (ignore clause))
    '()))

(defgeneric bindings (clause)
  (:method (clause)
    (append (initial-bindings clause) (final-bindings clause))))

(defgeneric prologue-form (clause end-tag)
  (:method (clause end-tag)
    (declare (ignore clause end-tag))
    nil))

(defgeneric termination-form (clause end-tag)
  (:method (clause end-tag)
    (declare (ignore clause end-tag))
    nil))

(defgeneric body-form (clause end-tag)
  (:method (clause end-tag)
    (declare (ignore clause end-tag))
    nil))

(defgeneric step-form (clause)
  (:method (clause)
    (declare (ignore clause))
    nil))

(defgeneric epilogue (clause)
  (:method (clause)
    (declare (ignore clause))
    nil))

;;; Determine the initial value for the main loop accumulation
;;; variable.  If there is a default SUM or a default COUNT clause,
;;; then the initial value is 0.  Otherwise it is NIL.
(defun accumulation-initial-value (clauses)
  (if (find-if (lambda (clause)
		 (or (typep clause 'count-form-clause)
		     (typep clause 'sum-form-clause)))
	       clauses)
      0
      nil))

(defvar *accumulation-variable*)

(defvar *list-tail-accumulation-variable*)

(defvar *loop-name*)

(defun prologue-body-epilogue (clauses)
  (let ((start-tag (gensym))
	(end-tag (gensym)))
    `(tagbody
	(progn ,@(mapcar (lambda (clause)
			   (prologue-form clause end-tag))
			 clauses))
	,start-tag
	(progn ,@(mapcar (lambda (clause)
			   (body-form clause end-tag))
			 clauses))
	(progn ,@(mapcar (lambda (clause)
			   (termination-form clause end-tag))
			 clauses))
	(progn ,@(mapcar #'step-form clauses))
	(go ,start-tag)
	,end-tag
	(progn ,@(mapcar #'epilogue clauses)
	       (return-from ,*loop-name*
		 ,*accumulation-variable*)))))

(defgeneric wrap-clause (clause inner-form))

(defgeneric wrap-subclause (subclause inner-form))

(defmethod wrap-subclause (subclause inner-form)
  `(let ,(final-bindings subclause)
     ,inner-form))

(defmethod wrap-clause (clause inner-form)
  `(let* ,(bindings clause)
     ,inner-form))

(defmethod wrap-clause ((clause subclauses-mixin) inner-form)
  (let ((result inner-form))
    (mapc (lambda (subclause)
	    (setf result (wrap-subclause subclause result)))
	  (reverse (subclauses clause)))
    `(let ,(initial-bindings clause)
       ,result)))

(defun do-clauses (all-clauses)
  (let ((result (prologue-body-epilogue all-clauses)))
    (mapc (lambda (clause)
	    (setf result (wrap-clause clause result)))
	  (reverse all-clauses))
    result))

(defun expand-clauses (all-clauses)
  `(let ((,*accumulation-variable*
	   ,(accumulation-initial-value all-clauses))
	 (,*list-tail-accumulation-variable* nil))
     (declare (ignorable ,*list-tail-accumulation-variable*))
     ,(do-clauses all-clauses)))

(defun expand-body (loop-body)
  (if (every #'consp loop-body)
      (let ((tag (gensym)))
	`(block nil
	   (tagbody
	      ,tag
	      ,@loop-body
	      (go ,tag))))
      (let ((clauses (parse-loop-body loop-body)))
	(analyse-clauses clauses)
	(let* ((name (if (typep (car clauses) 'name-clause)
			 (name (car clauses))
			 nil))
	       (*loop-name* name)
	       (*accumulation-variable* (gensym))
	       (*list-tail-accumulation-variable* (gensym)))
	  `(block ,name
	     ,(expand-clauses clauses))))))
