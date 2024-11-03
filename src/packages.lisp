(cl:in-package #:common-lisp-user)

(defpackage jzon-util
  (:use :cl)
  (:export
   #:sensitive-metaclass
   #:sensitive-slot-value))
