(cl:in-package #:common-lisp-user)

(defpackage jzon-util
  (:use :cl)
  (:export
   #:*serialize-lisp-case-to-camel-case*
   #:*deserialize-camel-case-to-lisp-case*
   #:parse-to-lisp-case
   #:sensitive-metaclass
   #:sensitive-standard-direct-slot-definition
   #:sensitive-standard-effective-slot-definition
   #:sensitive-slot-value))
