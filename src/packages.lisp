(cl:in-package #:common-lisp-user)

(defpackage jzon-util
  (:use :cl)
  (:export
   #:sensitive-metaclass
   #:sensitive-standard-direct-slot-definition
   #:sensitive-standard-effective-slot-definition
   #:sensitive-slot-value))
