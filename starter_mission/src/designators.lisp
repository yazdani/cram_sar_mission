;;; Copyright (c) 2016, Fereshta Yazdani <yazdani@cs.uni-bremen.de>
;;; All rights reserved.
;; 
;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions are met:
;;; 
;;;     * Redistributions of source code must retain the above copyright
;;;       notice, this list of conditions and the following disclaimer.
;;;     * Redistributions in binary form must reproduce the above copyright
;;;       notice, this list of conditions and the following disclaimer in the
;;;       documentation and/or other materials provided with the distribution.
;;;     * Neither the name of the Institute for Artificial Intelligence/
;;;       Universitaet Bremen nor the names of its contributors may be used to 
;;;       endorse or promote products derived from this software without 
;;;       specific prior written permission.
;;; 
;;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;;; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;;; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
;;; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;;; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;;; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;;; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;;; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;;; POSSIBILITY OF SUCH DAMAGE.

(in-package :starter-mission)


(defun one-desig-move (cmd elem property)
  (format t "one-desig-move~%")
  (let*((computed-object NIL)
        (desig NIL))
   (if(string-equal (split-property cmd) "pointed_at")
      (setf computed-object NIL) ;;gesture calculation TODO
      (setf computed-object ;; did not consider small, big etc.
            (get-value-basedon-type->get-objects-infrontof-human (split-object cmd))))
    (cond((or (string-equal (split-object cmd)  (get-elem-type elem))
              (equal elem NIL))
          (setf elem computed-object)
          (setf property (split-spatial-relation cmd))
          (setf desig
                (make-designator :location `((,(direction-symbol (split-spatial-relation cmd)) ,computed-object)))))
         (t 
          (setf elem (calculate-the-specific-object elem property (split-object cmd)))
          (setf property (split-object cmd))
         (setf desig
            (make-designator :location `((,(direction-symbol (split-spatial-relation cmd)) ,elem))))))
    (list elem property desig)))

;; take(picture,NIL,NIL);take(right,NIL,tree)
(defun multiple-desig-take (index seqs elem property)
  ;;(format t "index ~a und seqs ~a und elem ~a and property ~a~%" index seqs elem property)
  (let*((computed-object NIL)
        (jndex (+ 1 index))
        (desig NIL)
        (new-elem NIL))
    (if(string-equal (split-property (nth jndex seqs)) "pointed_at")
       (setf computed-object NIL) ;;gesture calculation TODO
       (setf computed-object ;; did not consider small, big etc.
             (get-value-basedon-type->get-objects-infrontof-human (split-object (nth jndex seqs)))))
    (cond ((string-equal (split-object (nth jndex seqs)) (get-elem-type elem))
           (setf elem computed-object)
           (setf desig  (make-designator :location `((,(direction-symbol (split-spatial-relation (nth jndex seqs))) ,computed-object)))))
          ((string-equal elem NIL)
           (setf new-elem (get-value-basedon-type->get-objects-infrontof-human (split-object (nth jndex seqs))))
           (setf desig
                 (make-designator :location `((,(direction-symbol (split-spatial-relation (nth jndex seqs))) ,new-elem)))))
          (t (setf new-elem (get-obj-located-obj-with-depend-property elem (split-object (nth jndex seqs)) property))
             (setf elem new-elem)
             (setf desig
                   (make-designator :location `((,(direction-symbol (split-spatial-relation (nth jndex seqs))) ,new-elem))))))
        (format t "desig ~a~%" desig)
    desig))
        
;; move(right,NIL,rock);move(left,NIL,tree)
(defun multiple-desig-move (index seqs elem property)
  ;;(format t "index ~a und seqs ~a und elem ~a and property ~a~%" index seqs elem property)
  (format t "multiple ~a~%" index)
   (format t "multiple ~a~%" (nth index seqs))
  (let*((desig '())
        (computed-object NIL))
   (cond ((equal elem NIL)      
          (if(string-equal (split-property (nth index seqs)) "pointed_at")
             (setf computed-object NIL) ;;gesture calculation TODO
             (setf computed-object ;; did not consider small, big etc.
                   (get-value-basedon-type->get-objects-infrontof-human (split-object (nth index seqs)))))
          (setf elem computed-object)
          (setf desig  (cons (list (make-designator :location `((,(direction-symbol (split-spatial-relation (nth index seqs))) ,computed-object))) elem (split-spatial-relation (nth index seqs))) desig)))
         (t
          (cond((string-equal (split-property (nth index seqs)) "pointed_at")
                (setf computed-object NIL)
                (setf desig (cons (list (make-designator :location `((,(direction-symbol (split-spatial-relation (nth index seqs))) ,computed-object)))  computed-object (split-spatial-relation (nth index seqs))) desig))) ;;gesture calculation TODO
               (t
                (setf elem (get-obj-located-obj-with-depend-property elem (split-object (nth index seqs)) property))    
                (setf desig (cons (list (make-designator :location `((,(direction-symbol (split-spatial-relation (nth index seqs))) ,elem)))  elem (split-spatial-relation (nth index seqs))) desig)))
               )))
    (format t "desig ~a~%" desig)
    desig))
        

(defun one-desig-take (cmd elem property)
  (let*((computed-object NIL)
        (desig NIL)
        (new-elem NIL))
   (if(string-equal (split-property cmd) "pointed_at")
      (setf computed-object NIL) ;;gesture calculation TODO
      (setf computed-object ;; did not consider small, big etc.
            (get-value-basedon-type->get-objects-infrontof-human (split-object cmd))))
    (cond((or (string-equal (split-object cmd)  (get-elem-type elem))
              (equal elem NIL))
          (setf elem computed-object)
          (setf desig  (make-designator :location `((:to ,computed-object)))))
         (t  
          (setf new-elem (calculate-the-specific-object elem property (split-object cmd)))
         (setf desig
            (make-designator :location `((:to ,new-elem))))))
desig))

(defun one-desig-take-based-on-prev (elem property)
  (make-designator :location `((,(direction-symbol property) ,elem))))


;;Methods to call objectname by querying the objecttype
;;START objectType
(defun get-elem-by-type->get-objects-infrontof-agent (type viewpoint)
(let((seqs (get-objects-infrontof-agent viewpoint))
      (check 1000)
      (elem NIL))
   (dotimes (index (length seqs))
      (let*((liste  (split-sequence:split-sequence #\: (nth index seqs)))
            (typ (get-elem-type (first liste)))
            (num (parse-integer (second liste))))
        (cond ((and (string-equal typ type)
                    (>= check num))
               (setf check num)
               (setf elem (first liste))))))
    elem))

(defun get-objects-infrontof-agent (viewpoint)
  (let((liste '()))
    (dotimes (index 80)
      (if (>= 40 (length liste))
          (setf liste (get-objects-infrontof-agent-with-distance-viewpoint index viewpoint)) 
        (return)))
  (reverse liste)))

(defun get-objects-infrontof-agent-with-distance-viewpoint (num viewpoint)
  (let* ((sem-map (sem-map-utils:get-semantic-map))
         (sem-hash (slot-value sem-map 'sem-map-utils:parts))
         (sem-keys (hash-table-keys sem-hash))
         (poses '()) (dist NIL) (liste '())
         (obj-pose2 NIL)(obj-pose NIL))
    (dotimes (index (length sem-keys))
          (setf liste (cons (nth index sem-keys) liste)))
    (dotimes (index (length liste))
      (if (string-equal "human" viewpoint)
          (setf obj-pose (cl-transforms-stamped:transform->pose (cl-tf:lookup-transform *tf* "human" (format NIL "~a_link" (nth index liste)))))
          (setf obj-pose (cl-transforms-stamped:transform->pose (cl-tf:lookup-transform *tf* "base_link" (format NIL "~a_link" (nth index liste))))))
         (setf obj-pose2 (cl-transforms-stamped:transform->pose (cl-tf:lookup-transform *tf* "map" (format NIL "~a_link" (nth index liste)))))
      (setf dist (get-distance (tf-human-to-map) obj-pose2))
      (if (and (>= num dist)
               (plusp (cl-transforms:x (cl-transforms:origin obj-pose))))
               (setf poses (append (list (format NIL"~a:~a" (nth index liste) dist)) poses))))
       poses))
;; END objectType

;;Method for calculating the property of an object
(defun get-elem-by-size->get-objects-infrontof-agent (type size viewpoint)
 (let*((seqs (get-objects-infrontof-agent viewpoint))
        (check 1000)
        (elem NIL))
   (dotimes (index (length seqs))
      (let*((liste  (split-sequence:split-sequence #\: (nth index seqs)))
            (typ (get-real-type (first liste)))
            (num (parse-integer (second liste))))
        (cond ((and (not (null (search size typ)))
                    (not (null (search type typ)))
                    (>= check num))
                       (setf check num)
                      (setf elem (first liste))))))
    elem))

(defun get-elem-by-color->get-objects-infrontof-agent (type color viewpoint)
;;TODO
  "tree01")

(defun calculate-all-specific-object (obj property type)
  (let*((liste (get-specific-elements-close-to-object obj type))
        (rel-list '())
        (small-obj NIL)
        (check 1000))
    (dotimes (index (length liste))
      (if (equal T (checking-objects-relation (first (split-sequence:split-sequence #\: (nth index liste))) obj property))
          (setf rel-list (cons (list (nth index liste)) rel-list))))
    (if (= 0 (length rel-list))
        (setf rel-list (cons (list (get-smallest-of-liste liste)) rel-list)))

    (setf rel-list (reverse rel-list))
    (dotimes (index (length rel-list))
      (cond((<= (parse-integer (second (split-sequence:split-sequence #\: (first (nth index rel-list))))) check)
          (setf check (parse-integer (second (split-sequence:split-sequence #\: (first (nth index rel-list))))))
          (setf small-obj (first (split-sequence:split-sequence #\: (first (nth index rel-list))))))
           (t())))
    rel-list))

(defun calculate-second-object-basedon-objectname (objname spatial objtype)
  (let*((liste (get-specific-elements-close-to-object objname objtype))
        (rel-list '())
        (small-obj NIL)
        (check 1000))
    (dotimes (index (length liste))
      (if (equal T (checking-objects-relation (first (split-sequence:split-sequence #\: (nth index liste))) objname spatial))
          (setf rel-list (cons (list (nth index liste)) rel-list))))
    (if (= 0 (length rel-list))
        (setf rel-list (cons (list (get-smallest-of-liste liste)) rel-list)))
    (setf rel-list (reverse rel-list))
    (dotimes (index (length rel-list))
      (cond((<= (parse-integer (second (split-sequence:split-sequence #\: (first (nth index rel-list))))) check)
          (setf check (parse-integer (second (split-sequence:split-sequence #\: (first (nth index rel-list))))))
          (setf small-obj (first (split-sequence:split-sequence #\: (first (nth index rel-list))))))))
    (if (>= check 40)
        (setf small-obj  (first (split-sequence:split-sequence #\: (get-smallest-of-liste liste)))))
    small-obj))

(defun calculate-object-by-size-nextto-objectname (objname spatial objtype size)
  (let*((liste (get-specific-elements-close-to-object objname objtype))
        (rel-list '())
        (small-obj NIL)
        (check 1000))
    (dotimes (index (length liste))
      (if (equal T (checking-objects-relation (first (split-sequence:split-sequence #\: (nth index liste))) objname spatial))
          (setf rel-list (cons (list (nth index liste)) rel-list))))
    (if (= 0 (length rel-list))
        (setf rel-list (cons (list (get-smallest-of-liste liste)) rel-list)))
    (setf rel-list (reverse rel-list))
    (dotimes (index (length rel-list))
      (cond((and (<= (parse-integer (second (split-sequence:split-sequence #\: (first (nth index rel-list))))) check)
                 (search shape (get-real-type (first (split-sequence:split-sequence #\: (first (nth index rel-list)))))))
         
          (setf check (parse-integer (second (split-sequence:split-sequence #\: (first (nth index rel-list))))))
          (setf small-obj (first (split-sequence:split-sequence #\: (first (nth index rel-list))))))))
    (if (>= check 40)
        (setf small-obj  (first (split-sequence:split-sequence #\: (get-smallest-of-liste liste)))))
    small-obj))

(defun calculate-the-specific-object-with-distance (obj property type)
  (let*((liste (get-specific-elements-close-to-object obj type))
        (rel-list '())
        (small-obj NIL)
        (check 1000))
    (dotimes (index (length liste))
      (if (equal T (checking-objects-relation (first (split-sequence:split-sequence #\: (nth index liste))) obj property))
          (setf rel-list (cons (list (nth index liste)) rel-list))))
    (if (= 0 (length rel-list))
        (setf rel-list (cons (list (get-smallest-of-liste liste)) rel-list)))

    (setf rel-list (reverse rel-list))
    (dotimes (index (length rel-list))
      (cond((<= (parse-integer (second (split-sequence:split-sequence #\: (first (nth index rel-list))))) check)
          (setf check (parse-integer (second (split-sequence:split-sequence #\: (first (nth index rel-list))))))
          (setf small-obj (first (nth index rel-list))))
           (t())))
    small-obj))

;; each objtype which is 'right of' obj-name
(defun get-obj-located-obj-with-depend-property (obj-name obj-type property)
  (let((all-human (get-objects-infrontof-human))
        (all-obj (get-specific-elements-close-to-object obj-name obj-type))
        (liste '())
        (liste2 '())
       (result NIL)         
        (obj-list (unnest (calculate-all-specific-object obj-name property obj-type))))
    (dotimes (index (length all-obj))
      (dotimes (jndex (length all-human))
      (let ((test (first (split-sequence:split-sequence #\: (nth index all-obj))))
            (test2 (first (split-sequence:split-sequence #\: (nth jndex all-human)))))
      (if(string-equal test test2)
         (setf liste (cons  (nth index all-obj) liste))))))
    (dotimes (pointer (length liste))
      (dotimes (pointer2 (length obj-list))
        (let ((tmp1 (first (split-sequence:split-sequence #\: (nth pointer liste))))
              (tmp2 (first (split-sequence:split-sequence #\: (nth pointer2  obj-list)))))
           (if (string-equal tmp1 tmp2)
               (setf liste2 (cons (nth pointer liste) liste2))))))
    (if (> (length liste2) 1)
        (setf result (first (split-sequence:split-sequence #\: (get-smallest-of-liste liste2))))
        (setf result (first (split-sequence:split-sequence #\: (first liste2)))))
    result))

;; ((:right tree) (:to rock01))
;; property ; right
;; objtype tree
;; objname rock01
(defun get-objname-based-on-spatial-and-objname2 (spatial objtyp objname)
   (let*((liste (get-specific-elements-close-to-object objname objtyp))
        (rel-list '())
        (small-obj NIL)
        (check 1000))
    (dotimes (index (length liste))
      (if (equal T (checking-objects-relation objname (first (split-sequence:split-sequence #\: (nth index liste))) spatial))
          (setf rel-list (cons (list (nth index liste)) rel-list))))
    (if (= 0 (length rel-list))
        (setf rel-list (cons (list (get-smallest-of-liste liste)) rel-list)))
    (setf rel-list (reverse rel-list))
    (dotimes (index (length rel-list))
      (cond((<= (parse-integer (second (split-sequence:split-sequence #\: (first (nth index rel-list))))) check)
          (setf check (parse-integer (second (split-sequence:split-sequence #\: (first (nth index rel-list))))))
          (setf small-obj (first (split-sequence:split-sequence #\: (first (nth index rel-list))))))))
    (if (>= check 40)
        (setf small-obj  (first (split-sequence:split-sequence #\: (get-smallest-of-liste liste)))))
    small-obj))

(defun get-objname-based-on-property-and-objname2-and-size (property objtyp objname shape)
   (let*((liste (get-specific-elements-close-to-object objname objtyp))
        (rel-list '())
        (small-obj NIL)
        (check 1000))
    (dotimes (index (length liste))
      (if (equal T (checking-objects-relation objname (first (split-sequence:split-sequence #\: (nth index liste))) property))
          (setf rel-list (cons (list (nth index liste)) rel-list))))
    (if (= 0 (length rel-list))
        (setf rel-list (cons (list (get-smallest-of-liste liste)) rel-list)))
    (setf rel-list (reverse rel-list))
    (dotimes (index (length rel-list))
      (cond((and (<= (parse-integer (second (split-sequence:split-sequence #\: (first (nth index rel-list))))) check)
                  (search shape (get-real-type (first (split-sequence:split-sequence #\: (first (nth index rel-list)))))))
          (setf check (parse-integer (second (split-sequence:split-sequence #\: (first (nth index rel-list))))))
          (setf small-obj (first (split-sequence:split-sequence #\: (first (nth index rel-list))))))
           (t())))
  ;;  (format t "liste ~a~%" liste)
    (if (>= check 40)
        (setf small-obj  (first (split-sequence:split-sequence #\: (get-smallest-of-liste liste)))))
    small-obj))

;; objtype2 is right of objtype1 (right,typ2,typ1)
(defun get-objs-based-on-relation-towards-other-obj (objtype2 property objtype1)
  (let* ((objtype1-list (get-all-obj-with-specific-type objtype1))
         (felem NIL)
         (selem NIL)
         (tmpelem NIL)
         (num 100)
         (typenum 100))
    (dotimes(index (length objtype1-list))
      do (setf tmpelem (calculate-the-specific-object-with-distance (first (split-sequence:split-sequence #\: (nth index objtype1-list))) property objtype2))
      (cond ((or(and (> num (read-from-string (second (split-sequence:split-sequence #\: tmpelem))))
                  (> typenum (read-from-string (second (split-sequence:split-sequence #\: (nth index objtype1-list))))))
             (and (> num (read-from-string (second (split-sequence:split-sequence #\: tmpelem))))
                  (= typenum (read-from-string (second (split-sequence:split-sequence #\: (nth index objtype1-list))))))
             (and (= num (read-from-string (second (split-sequence:split-sequence #\: tmpelem))))
                  (> typenum (read-from-string (second (split-sequence:split-sequence #\: (nth index objtype1-list))))))
             (and (= num (read-from-string (second (split-sequence:split-sequence #\: tmpelem))))
                  (= typenum (read-from-string (second (split-sequence:split-sequence #\: (nth index objtype1-list)))))))
             (setf num (read-from-string (second (split-sequence:split-sequence #\: tmpelem))))
             (setf felem (first (split-sequence:split-sequence #\: (nth index objtype1-list))))
             (setf typenum (read-from-string (second (split-sequence:split-sequence #\: (nth index objtype1-list)))))
             (setf selem (first (split-sequence:split-sequence #\: tmpelem)))))
      (format t "num: ~a und ~a und ~a~%" num felem selem))
    (list felem selem)))




(defun get-all-obj-with-specific-type (objtype)
  (let ((all-objs-human (get-objects-infrontof-human))
        (liste '()))
   ;; (format t "all-objs ~a~%" all-objs-human)
    (dotimes(index (length all-objs-human))
      do(if (string-equal (get-elem-type (first (split-sequence:split-sequence #\: (nth index all-objs-human)))) objtype)
            (setf liste (cons  (nth index all-objs-human) liste))))
    (format t "liste ~a~%" liste)
    liste))

(defun unnest (x)
  (labels ((rec (x acc)
    (cond ((null x) acc)
      ((atom x) (cons x acc))
      (t (rec (car x) (rec (cdr x) acc))))))
    (rec x nil)))
