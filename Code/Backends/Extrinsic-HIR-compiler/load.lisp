(cl:in-package #:sicl-extrinsic-hir-compiler)

;;; The SICL reader defines macros that are generated by the backquote
;;; facility.  These macros must exist in the SICL global environment
;;; so that they can be expanded by the compiler.

(setf (sicl-env:macro-function 'sicl-reader::transform *environment*)
      (macro-function 'sicl-reader::transform))

(setf (sicl-env:macro-function 'sicl-reader::quasiquote *environment*)
      (macro-function 'sicl-reader::quasiquote))

(defun load (file)
  (with-open-file (stream file :direction :input)
    (loop with eof = (list nil)
	  for form = (sicl-reader:read stream nil eof)
	  until (eq form eof)
	  do (eval form))))