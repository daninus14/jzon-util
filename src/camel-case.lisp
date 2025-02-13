(in-package :jzon-util)

(defvar *serialize-lisp-case-to-camel-case* nil)
(defvar *deserialize-camel-case-to-lisp-case* nil)

(defun check-prefix (l special-words)
  "From CFFI https://github.com/cffi/cffi/blob/22762bf8d2febac519733b8242963707c46b3148/src/functions.lisp#L271"
  (let ((pl (loop for i from (1- (length l)) downto 0
                  collect (apply #'concatenate 'simple-string (butlast l i)))))
    (loop for w in special-words
          for p = (position-if #'(lambda (s) (string= s w)) pl)
          when p do (return-from check-prefix (values (nth p pl) (1+ p))))
    (values (first l) 1)))

(defun collapse-prefix (l special-words)
  "From https://github.com/cffi/cffi/blob/22762bf8d2febac519733b8242963707c46b3148/src/functions.lisp#L266"
  (unless (null l)
    (multiple-value-bind (newpre skip) (check-prefix l special-words)
      (cons newpre (collapse-prefix (nthcdr skip l) special-words)))))

(defun split-if (test seq &optional (dir :before))
  "From CFFI https://github.com/cffi/cffi/blob/22762bf8d2febac519733b8242963707c46b3148/src/utils.lisp#L69"
  (remove-if #'(lambda (x) (equal x (subseq seq 0 0)))
             (loop with stop
                   for start fixnum = 0
                     then (if (eq dir :before)
                              stop
                              (the fixnum (1+ (the fixnum stop))))
                   while (< start (length seq))
                   do (setf stop (position-if test seq
                                              :start (if (eq dir :elide)
                                                         start
                                                         (the fixnum (1+ start)))))
                   collect (subseq seq start
                                   (if (and stop (eq dir :after))
                                       (the fixnum (1+ (the fixnum stop)))
                                       stop))
                   while stop)))

(defgeneric translate-camelcase-name (name &key upper-initial-p special-words)
  (:documentation "Lisp case to camel case From CFFI  https://github.com/cffi/cffi/blob/22762bf8d2febac519733b8242963707c46b3148/src/functions.lisp#L279C1-L304C60")
  (:method ((name string) &key upper-initial-p special-words)
    (declare (ignore upper-initial-p))
    (values (intern (reduce #'(lambda (s1 s2)
                                (concatenate 'simple-string s1 "-" s2))
                            (mapcar #'string-upcase
                                    (collapse-prefix
                                     (split-if #'(lambda (ch)
                                                   (or (upper-case-p ch)
                                                       (digit-char-p ch)))
                                               name)
                                     special-words))))))
  (:method ((name symbol) &key upper-initial-p special-words)
    (apply #'concatenate
           'string
           (loop for str in (split-if #'(lambda (ch) (eq ch #\-))
                                      (string name)
                                      :elide)
                 for first-word-p = t then nil
                 for e = (member str special-words
                                 :test #'equal :key #'string-upcase)
                 collect (cond
                           ((and first-word-p (not upper-initial-p))
                            (string-downcase str))
                           (e (first e))
                           (t (string-capitalize str)))))))

;; Enabling Lisp Case to Camel Case conversion 
(defmethod com.inuoe.jzon:coerced-fields ((obj standard-object))
  (if *serialize-lisp-case-to-camel-case*
      (let* (;; Call the base method which grabs all bound slots 
             (fields (com.inuoe.jzon::%coerced-fields-slots obj)))
        ;; Alter them by replacing the name part (the `car')
        (mapcar
         (lambda (f) (cons (translate-camelcase-name (car f)) (cdr f)))
         fields))
      (com.inuoe.jzon::%coerced-fields-slots obj)))

(defun parse-to-lisp-case (in &key
                                (max-depth 128)
                                (allow-comments nil)
                                (allow-trailing-comma nil)
                                (allow-multiple-content nil)
                                (max-string-length (min #x100000 (1- array-dimension-limit)))
                                (key-fn t))
  (if *deserialize-camel-case-to-lisp-case*
      (let ((new-key-fn (if (functionp key-fn)
                            (lambda (x) (funcall key-fn (camel-case-to-lisp x)))
                            #'camel-case-to-lisp)))
        (format t "~%deserializing to lisp case~%")
        (com.inuoe.jzon:parse in
                              :max-depth max-depth
                              :allow-comments allow-comments
                              :allow-trailing-comma allow-trailing-comma
                              :allow-multiple-content allow-multiple-content
                              :max-string-length max-string-length
                              :key-fn new-key-fn))
      (com.inuoe.jzon:parse in
                            :max-depth max-depth
                            :allow-comments allow-comments
                            :allow-trailing-comma allow-trailing-comma
                            :allow-multiple-content allow-multiple-content
                            :max-string-length max-string-length
                            :key-fn key-fn)))

;; (let ((original-parse #'com.inuoe.jzon:parse))
;;   (defun com.inuoe.jzon:parse (in &key
;;                                     (max-depth 128)
;;                                     (allow-comments nil)
;;                                     (allow-trailing-comma nil)
;;                                     (allow-multiple-content nil)
;;                                     (max-string-length (min #x100000 (1- array-dimension-limit)))
;;                                     (key-fn t))
;;     (if *deserialize-camel-case-to-lisp-case*
;;         (let ((new-key-fn (if (functionp key-fn)
;;                               (lambda (x) (funcall key-fn (camel-case-to-lisp x)))
;;                               #'camel-case-to-lisp)))
;;           (funcall original-parse in
;;                    :max-depth max-depth
;;                    :allow-comments allow-comments
;;                    :allow-trailing-comma allow-trailing-comma
;;                    :allow-multiple-content allow-multiple-content
;;                    :max-string-length max-string-length
;;                    :key-fn new-key-fn))
;;         (funcall original-parse in
;;                  :max-depth max-depth
;;                  :allow-comments allow-comments
;;                  :allow-trailing-comma allow-trailing-comma
;;                  :allow-multiple-content allow-multiple-content
;;                  :max-string-length max-string-length
;;                  :key-fn key-fn))))
