(ql:quickload "com.inuoe.jzon")

(defclass c1 ()
  ((name :accessor name :initarg :name :initform nil)
   (secret :accessor secret :initarg :secret :initform nil)
   (hello :accessor hello :initarg :hello :initform nil)))

(com.inuoe.jzon:stringify (make-instance 'c1 :name "john" :secret "hello world!" :hello "Miami"))
;; "{\"name\":\"john\",\"secret\":\"hello world!\",\"hello\":\"Miami\"}"

(ql:quickload "jzon-util")

(defclass c3 ()
  ((name :accessor name :initarg :name :initform nil)
   (secret :accessor secret :initarg :secret :initform nil :sensitive t)
   (hello :accessor hello :initarg :hello :initform nil))
  (:metaclass jzon-util:sensitive-metaclass))

(com.inuoe.jzon:stringify (make-instance 'c3 :name "john" :secret "hello world!" :hello "Miami"))
;; "{\"name\":\"john\",\"hello\":\"Miami\"}"
