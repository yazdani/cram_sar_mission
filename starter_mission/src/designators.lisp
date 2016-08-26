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

(defun multiple-desig-take (index seqs elem property)
  (let*((computed-object NIL)
        (index (+ 1 index)))
    (if(string-equal (split-property (nth index seqs)) "pointed_at")
       (setf computed-object NIL) ;;gesture calculation TODO
       (setf computed-object ;; did not consider small, big etc.
             (get-value-basedon-type->get-objects-infrontof-human (split-object (nth index seqs)))))
        computed-object))
        
    

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

  

