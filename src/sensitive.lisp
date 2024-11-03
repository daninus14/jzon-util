(in-package :jzon-util)

(defgeneric sensitive-slot-value (given-object))
(defmethod sensitive-slot-value (given-object) NIL)

(defclass sensitive-slot-definition ()
  ((sensitive :initform nil
              :initarg :sensitive
              :type boolean
              :accessor sensitive-slot-value
              :documentation "A slot option used to mark slots as sensitive to skip encoding them as json and exposing sensitive data.")))

(defclass sensitive-standard-direct-slot-definition (sensitive-slot-definition
                                                     c2mop:standard-direct-slot-definition)
  ())

(defclass sensitive-standard-effective-slot-definition
    (sensitive-slot-definition
     closer-mop:standard-effective-slot-definition)
  ())

(defclass sensitive-metaclass (standard-class)
  ())

(defmethod closer-mop:direct-slot-definition-class ((class sensitive-metaclass)
                                                    &rest initargs)
  (declare (ignorable initargs))
  (find-class 'sensitive-standard-direct-slot-definition))

(defmethod closer-mop:effective-slot-definition-class ((class sensitive-metaclass)
                                                       &rest initargs)
  (declare (ignorable initargs))
  (find-class 'sensitive-standard-effective-slot-definition))

(defmethod closer-mop:validate-superclass ((class sensitive-metaclass)
                                           (superclass closer-mop:standard-class))
  t)

(defmethod closer-mop:compute-effective-slot-definition
    :around ((class sensitive-metaclass) name direct-slot-definitions)
  (declare (ignore name))
  (let ((result (call-next-method)))
    (when result
      (setf (sensitive-slot-value result)
            (some #'sensitive-slot-value direct-slot-definitions)))
    result))

(defmethod com.inuoe.jzon::get-slots-to-encode ((class sensitive-metaclass) element)
  (remove-if-not
   (lambda (s) (slot-boundp element (c2mop:slot-definition-name s)))
   (remove-if (lambda (x) (sensitive-slot-value x))
              (c2mop:class-slots class))))
