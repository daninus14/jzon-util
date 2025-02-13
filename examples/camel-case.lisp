(ql:quickload "com.inuoe.jzon")

(defclass c4 ()
  ((first-name :accessor name :initarg :first-name :initform nil)
   (hello-world :accessor hello :initarg :hello-world :initform nil)))

;; Serialization Example without Camel Case
(com.inuoe.jzon:stringify
 (make-instance 'c4 :first-name "john" :hello-world "Miami"))

;; "{\"first-name\":\"john\",\"hello-world\":\"Miami\"}"

(ql:quickload "jzon-util")

(setf jzon-util:*serialize-lisp-case-to-camel-case* t)
;; T

(com.inuoe.jzon:stringify
 (make-instance 'c4 :first-name "john" :hello-world "Miami"))
;; "{\"firstName\":\"john\",\"helloWorld\":\"Miami\"}"

(com.inuoe.jzon:parse
 "{\"firstName\":\"john\",\"helloWorld\":\"Miami\"}")

(setf jzon-util:*deserialize-camel-case-to-lisp-case* t)

(jzon-util:parse-to-lisp-case
 "{\"firstName\":\"john\",\"helloWorld\":\"Miami\"}")

CL-USER> (serapeum:pretty-print-hash-table
          (com.inuoe.jzon:parse
           "{\"firstName\":\"john\",\"helloWorld\":\"Miami\"}"))
(SERAPEUM:DICT
 "firstName" "john"
 "helloWorld" "Miami"
 ) 
#<HASH-TABLE :TEST EQUAL :COUNT 2 {1005AA5413}>
CL-USER> (serapeum:pretty-print-hash-table
          (jzon-util:parse-to-lisp-case
           "{\"firstName\":\"john\",\"helloWorld\":\"Miami\"}"))

deserializing to lisp case
(SERAPEUM:DICT
 "FIRST-NAME" "john"
 "HELLO-WORLD" "Miami"
 ) 
#<HASH-TABLE :TEST EQUAL :COUNT 2 {1005AC9873}>
CL-USER> 
