(defmacro let1 (var val &body body)
  `(let ((,var ,val))
     ,@body))

(defmacro le1 ((var val) &body body)
  `(let ((,var ,val))
     ,@body))

(defmacro split-list (val &body body)
  (let ((g (gensym)))
    `(let* ((,g ,val)
	   (hd (first ,g))
	   (tl (rest ,g)))
       ,@body)))

(defun pairs (list)
  (labels ((f (list acc)
	     (split-list list
	       (if list
		 (f (cdr tl) (cons (cons hd (first tl)) acc))
		 (reverse acc)))))
    (f list nil)))


(defun print-tag (name alst closingp)
  (princ #\<)
  (when closingp
    (princ #\/))
  (princ (string-downcase name))
  (mapc (lambda (att)
	  (format t " ~a=\"~a\"" (string-downcase (car att)) (rest att)))
	alst)
  (princ #\>))

(defmacro tag (name atts &body body)
  `(progn (print-tag ',name
		     (list ,@(mapcar (lambda (x)
				       (if (cdr x)
					   `(cons ',(car x) ,(cdr x))
					   `(cons ',(car x) "")))
				     (pairs atts)))
		     nil)
	  ,@body
	  (print-tag ',name nil t)))

(defmacro html (&body body)
  `(tag html ()
     ,@body))

(defmacro body (&body body)
  `(tag body ()
     ,@body))

(defmacro svg (&body body)
  `(tag svg (xmlns "http://www.w3.org/2000/svg"
	     "xmlns:xlink" "http://www.w3.org/1999/xlink")
     ,@body))

(defun brightness (col amt)
  (mapcar (lambda (x)
	    (min 255 (max 0 (+ x amt))))
	  col))

(defun svg-style (color)
  (format nil
	  "~{fill:rgb(~a,~a,~a);stroke:rgb(~a,~a,~a)~}"
	  (append color
		  (brightness color -100))))

(defun circle (center radius color)
  (tag circle (cx (car center)
	       cy (cdr center)
	       r radius
	       style (svg-style color))))


(defun polygon (points color)
  (tag polygon
      (points (format nil
		      "~{~a,~a ~}"
		      (mapcan (lambda (tp)
				(list (car tp) (cdr tp)))
			      points))
	      style (svg-style color))))

(defun random-walk (value length)
  (unless (zerop length)
    (cons value
	  (random-walk (if (zerop (random 2))
			   (- value 3)
			   (+ value 3))
		       (1- length)))))

(with-open-file (*standard-output* "random_walk.svg"
				   :direction :output
				   :if-exists :supersede)
  (svg (loop :repeat 10
	     :do (polygon (append '((0 . 200))
				  (pairs (random-walk 100 400))
				  '((400 . 200)))
			  (loop :repeat 3
				:collect (random 256))))))
