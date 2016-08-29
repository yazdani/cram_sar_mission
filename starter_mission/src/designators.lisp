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
  (let*((computed-object NIL)
        (jndex (+ 1 index))
        (desig NIL)
        (new-elem))
    (if(string-equal (split-property (nth jndex seqs)) "pointed_at")
       (setf computed-object NIL) ;;gesture calculation TODO
       (setf computed-object ;; did not consider small, big etc.
             (get-value-basedon-type->get-objects-infrontof-human (split-object (nth jndex seqs)))))
    (cond ((string-equal (split-object (nth jndex seqs)) (get-elem-type elem))
           (setf elem computed-object)
           (setf desig  (make-designator :location `((,(direction-symbol (split-spatial-relation (nth jndex seqs))) ,computed-object)))))
          (t (setf new-elem (calculate-the-specific-object elem property (split-object (nth jndex seqs))))
             (setf elem new-elem)
         (setf desig
            (make-designator :location `((,(direction-symbol (split-spatial-relation (nth jndex seqs))) ,new-elem))))))  
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

  

(defun get-value-basedon-type->get-objects-infrontof-human (obj)
 (let*((seqs (get-objects-infrontof-human))
        (check 1000)
        (elem NIL))
   (dotimes (index (length seqs))
      (let*((liste  (split-sequence:split-sequence #\: (nth index seqs)))
            (typ (get-elem-type (first liste)))
            (num (parse-integer (second liste))))
        (cond ((and (string-equal typ obj)
                    (>= check num))
               (setf check num)
               (setf elem (first liste)))
              (t ()))))
    elem))

(defun calculate-the-specific-object (obj property type)
  (let*((liste (get-specific-elements-close-to-object obj type))
        (rel-list '())
        (small-obj NIL)
        (check 1000))
    (dotimes (index (length liste))
      (if (equal T (checking-objects-relation (first (split-sequence:split-sequence #\: (nth index liste))) obj property))
          (setf rel-list (cons (list (nth index liste)) rel-list))))
   ;; (format t "rel-list ~a~%" rel-list)
    (if (= 0 (length rel-list))
        (setf rel-list (cons (list (get-smallest-of-liste liste)) rel-list)))

;;(format t "liste ~a~%" liste)
;;(format t "get-the-smallest ~a~%" (get-smallest-of-liste liste))
    (setf rel-list (reverse rel-list))
    (dotimes (index (length rel-list))
      (cond((<= (parse-integer (second (split-sequence:split-sequence #\: (first (nth index rel-list))))) check)
          (setf check (parse-integer (second (split-sequence:split-sequence #\: (first (nth index rel-list))))))
          (setf small-obj (first (split-sequence:split-sequence #\: (first (nth index rel-list))))))
           (t())))
 ;;   (format t "~a~%" check)
 ;;   (format t "~a ~a~%" small-obj  (get-distance (get-elem-pose small-obj) (get-elem-pose obj)))
    (if (>= check 40)
        (setf small-obj  (first (split-sequence:split-sequence #\: (get-smallest-of-liste liste)))))
  ;;  (format t "small-obj ~a~%" small-obj)
    small-obj))
