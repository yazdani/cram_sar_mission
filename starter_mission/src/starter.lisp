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

(defun starter-mission ()
  (let*((desig (make-designator :location `((:left-of "bigtree03")))))
    (reference desig)
    (setf cram-tf:*fixed-frame* "/map")))


(defun get-human-pose ()
  (cl-transforms-stamped:transform->pose (cl-tf:lookup-transform *tf* "/map" "/human")))

(defun get-elem-pose (name &optional (sem-map (sem-map-utils::get-semantic-map)))
 (let*((pose NIL)
       (sem-hash (slot-value sem-map 'sem-map-utils:parts))
       (new-hash (copy-hash-table sem-hash))
       (sem-keys (hash-table-keys sem-hash)))
       (dotimes (i (length sem-keys))
         do(if (string-equal name (nth i sem-keys))
               (setf pose (slot-value (gethash name new-hash) 'sem-map-utils:pose))
               (format t "")))
   pose))

(defun copy-hash-table (hash-table)
                 (let ((ht (make-hash-table
                            :test 'equal
                            :size (hash-table-size hash-table))))
                   (loop for key being each hash-key of hash-table
                         using (hash-value value)
                         do (setf (gethash key ht) value)
                            finally (return ht))))

(defun hash-table-keys (hash-table)
                   "Return a list of keys in HASH-TABLE."
                   (let ((keys '()))
                     (maphash (lambda (k _v) (push k keys)) hash-table)
                     keys))

(defun get-human-elem-pose (object-name)
  (setf cram-tf:*fixed-frame* "human")
  (cl-transforms-stamped:transform->pose (cl-tf:lookup-transform *tf* "human" (format NIL "~a_link" object-name))))
