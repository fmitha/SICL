(cl:in-package #:cleavir-mir)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Data.

(defclass raw-datum (datum)
  ((%size :initarg :size :reader size)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instructions.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; MEMREF1-INSTRUCTION
;;;
;;; This instruction loads a memory location.  It takes a single input
;;; containing the address of the word to load.  It has a single
;;; output which is set to the contents of the memory location at the
;;; address.

(defclass memref1-instruction (instruction one-successor-mixin)
  ())

(defun make-memref1-instruction (input output &optional successor)
  (make-instance 'memref1-instruction
    :inputs (list input)
    :outputs (list output)
    :successors (if (null successor) '() (list successor))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; MEMREF1-INSTRUCTION
;;;
;;; This instruction loads a memory location.  It takes a two inputs.
;;; The first input contains the base address of the datum to load.
;;; The second input contains constant offset.  This instruction has a
;;; single output which is set to the contents of the memory location
;;; at the address computed as the sum of the base address and the
;;; offset.

(defclass memref2-instruction (instruction one-successor-mixin)
  ())

(defun make-memref2-instruction (input1 input2 output &optional successor)
  (make-instance 'memref2-instruction
    :inputs (list input1 input2)
    :outputs (list output)
    :successors (if (null successor) '() (list successor))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; MEMSET1-INSTRUCTION
;;;
;;; This instruction stores an item in a memory location.  It takes
;;; two inputs.  The first input is the address of a location in
;;; memory.  The second input is the item to be stored in that
;;; location.

(defclass memset1-instruction (instruction one-successor-mixin)
  ())

(defun make-memset1-instruction (input1 input2 &optional successor)
  (make-instance 'memset1-instruction
    :inputs (list input1 input2)
    :outputs '()
    :successors (if (null successor) '() (list successor))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; MEMSET2-INSTRUCTION
;;;
;;; This instruction stores an item in a memory location.  It takes
;;; three inputs.  The first input is the base address of a location
;;; in memory.  The second input is an offset.  The third input is the
;;; item to be stored in the location in memory whose address is the
;;; sum of the base address and the offset.

(defclass memset2-instruction (instruction one-successor-mixin)
  ())

(defun make-memset2-instruction (input1 input2 input3 &optional successor)
  (make-instance 'memset2-instruction
    :inputs (list input1 input2 input3)
    :outputs '()
    :successors (if (null successor) '() (list successor))))