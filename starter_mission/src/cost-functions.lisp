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

(defvar *tf* NIL)
(defvar *pub* NIL)


(defun init-tf ()
  (setf *tf* (make-instance 'cl-tf:transform-listener))
  (setf *pub* (cl-tf:make-transform-broadcaster)))

(roslisp-utilities:register-ros-init-function init-tf)

(defun make-spatial-relations-cost-function (location axis pred threshold)
  (roslisp:ros-info (sherpa-spatial-relations) "calculate the costmap")
  (let* ((new-loc (cl-transforms:make-pose
                   (cl-transforms:origin location)
                   (cl-transforms:make-identity-rotation)))
         (transformation (cl-transforms:pose->transform new-loc)) 
         (world->location-transformation (cl-transforms:transform-inv transformation)))
    (lambda (x y)
      (let* ((point (cl-transforms:transform-point world->location-transformation
                                                   (cl-transforms:make-3d-vector x y 0)))
             (coord (ecase axis
                      (:x (cl-transforms:x point))
                      (:y (cl-transforms:y point))))
             (mode (sqrt (+   (* (cl-transforms:x point) (cl-transforms:x point))
                             (* (cl-transforms:y point) (cl-transforms:y point))))))
        (if (funcall pred coord 0.0d0)
            (if (> (abs (/ coord mode)) threshold)
                (abs (/ coord mode))
                0.0d0)
            0.0d0)))))

(defun make-location-function (loc std-dev)
  (let ((loc (cl-transforms:origin loc)))
    (make-gauss-cost-function loc `((,(float (* std-dev std-dev) 0.0d0) 0.0d0)
                                    (0.0d0 ,(float (* std-dev std-dev)))))))

(defun get-objects-closeto-pose (geom-objects param object-pose)
  (let*((geom-list geom-objects)
	(objects NIL))
    (loop while (/= (length geom-list) 0) 
	  do(cond ((and T
			(compare-distance-between-objects (slot-value (car geom-list) 'sem-map-utils:pose) object-pose param))
		   (setf objects
			 (append objects (list (first geom-list))))
		   (setf geom-list (cdr geom-list)))
		  (t (setf geom-list (cdr geom-list)))))
    objects))

(defun compare-distance-between-objects (obj_position pose param)
  (let*((vector (cl-transforms:origin pose))
        (x-vec (cl-transforms:x vector))
        (y-vec (cl-transforms:y vector))
        (z-vec (cl-transforms:z vector))
        (ge-vector (cl-transforms:origin obj_position))
        (x-ge (cl-transforms:x ge-vector))
        (y-ge (cl-transforms:y ge-vector))
        (z-ge (cl-transforms:z ge-vector))
        (test NIL))
    (if (>= param (sqrt (+ (square (- x-vec x-ge))
                          (square (- y-vec y-ge))
                          (square (- z-vec z-ge)))))
     (setf test T)
     (setf test NIL))
    test))

(defun square (x)
  (* x x))
