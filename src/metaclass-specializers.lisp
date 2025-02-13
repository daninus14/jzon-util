(in-package :jzon-util)

(in-package #:com.inuoe.jzon)

(defgeneric %coerced-fields-slots (element))

(defmethod %coerced-fields-slots (element)
  (let ((class (class-of element)))
    (c2mop:ensure-finalized class)
    (mapcar (lambda (s)
              (let ((slot-name (c2mop:slot-definition-name s)))
                (list slot-name
                      (slot-value element slot-name)
                      (c2mop:slot-definition-type s))))
            (get-slots-to-encode class element))))

(defgeneric get-slots-to-encode (class element)
  (:documentation "This function is used to get the slots to be json encoded. The class is the first parameter in order to allow for extending the dispatch based on the metaclass of the object."))

(defmethod get-slots-to-encode (class element)  
  (remove-if-not (lambda (s) (slot-boundp element (c2mop:slot-definition-name s)))
                 (c2mop:class-slots class)))

(defgeneric coerced-fields (element)
  (:documentation "Return a list of key definitions for `element'.
 A key definition is a three-element list of the form
  (name value &optional type)
 name is the key name and will be coerced if not already a string
 value is the value, and will be written per `write-value'
 type is a type for the key, in order to handle ambiguous `nil' interpretations.

Example return value:
  ((name :zulu)
   (hobbies nil list))
")
  (:method (element)
    nil)
  #+(or ccl clisp sbcl lispworks8)
  (:method ((element structure-object))
    (%coerced-fields-slots element))
  (:method ((element standard-object))
    (%coerced-fields-slots element)))
