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

(defun set-stream (num pose)
  (publish-pose pose :id 1000)
  (let*((id1 0)
        (limiter NIL)
        (fvector NIL)
        (liste '()))
    (loop for index from 0 to (- num 1)
          do(setf limiter (cl-transforms:make-3d-vector 1.0d0 0.0d0 0.0d0))
            (setf fvector (cam-get-pose->relative-map
                                     (cl-transforms:make-3d-vector
                                      ( * index (cl-transforms:x limiter))
                                      (* (cl-transforms:y limiter) index)
                                      (* (cl-transforms:z limiter) 1))))         
            (publish-pose fvector :id (+ 5000 (+ id1 1)))
            (setf liste (append liste (list fvector)))
            (setf id1 (+ id1 1)))
    (last liste)))

(defun publish-body (pose)
  (setf *marker-publisher*
        (roslisp:advertise "~location_marker" "visualization_msgs/Marker"))
  (let* ((point (cl-transforms:origin pose))
         (rot (cl-transforms:orientation pose)))
    (when *marker-publisher*
      (publish-pose-color pose (cl-transforms:make-3d-vector 1 1 0))
      (roslisp:publish *marker-publisher*
               (roslisp:make-message "visualization_msgs/Marker"
                             (stamp header) (roslisp:ros-time)
                             (frame_id header)
                             (typecase pose
                               (cl-transforms-stamped:pose-stamped (cl-transforms-stamped:frame-id  pose))
                               (t cram-tf:*fixed-frame*))

                             ns "kipla_locations"
                             id 200000
                             type (roslisp:symbol-code 
                                   'visualization_msgs-msg:<marker> :cylinder)
                             action (roslisp:symbol-code
                                     'visualization_msgs-msg:<marker> :add)
                             (x position pose) (cl-transforms:x point)
                             (y position pose) (cl-transforms:y point)
                             (z position pose) 1.0
                             (x orientation pose) (cl-transforms:x rot)
                             (y orientation pose) (cl-transforms:y rot)
                             (z orientation pose) (cl-transforms:z rot)
                             (w orientation pose) (cl-transforms:w rot)
                             (x scale) 0.3
                             (y scale) 0.3
                             (z scale) 2
                             (r color) 1.0
                             (g color) 1.0
                             (b color) 0.0
                             (a color) 1.0))
      (roslisp:publish *marker-publisher*
               (roslisp:make-message "visualization_msgs/Marker"
                             (stamp header) (roslisp:ros-time)
                             (frame_id header) cram-tf:*fixed-frame*
                             ns "kipla_locations"
                             id 100000
                             type (roslisp:symbol-code 
                                   'visualization_msgs-msg:<marker> :sphere)
                             action (roslisp:symbol-code
                                     'visualization_msgs-msg:<marker> :add)
                             (x position pose) (cl-transforms:x point)
                             (y position pose) (cl-transforms:y point)
                             (z position pose) (+ 2 (cl-transforms:z point))
                             (w orientation pose) 1.0
                             (x scale) 0.5
                             (y scale) 0.5
                             (z scale) 0.5
                             (r color) 1.0 ; (random 1.0)
                             (g color) 1.0 ; (random 1.0)
                             (b color) 0.0 ; (random 1.0)
                             (a color) 1.0)))))

(defun cam-set-markers ()
  (format t "cl-tf:*fixed-frame* ~a~%" cram-tf:*fixed-frame* )
  (publish-pose (cl-transforms:transform->pose (cam-depth-tfmap-transform)) :id 0)
  (let*((id1 0)(id2 0)
        (limiter NIL)
        (fvector NIL)
        (svec NIL))
    (loop for index from 1 to 15
          do(setf limiter (cl-transforms:make-3d-vector 0.25d0 -0.1d0 -0.1d0))
            (cond((<= index 4)                  
             (loop for jindex from (* index -1) to index
                   do (setf fvector (cam-get-pose->relative-map
                                     (cl-transforms:make-3d-vector
                                      ( * index (cl-transforms:x limiter))
                                      (* (* (cl-transforms:y limiter) (* 0.7 jindex)) index)
                                      (* (cl-transforms:z limiter) 1))))                                 (loop for mindex from -4 to 5
                             do(setf svec fvector)
                               (setf svec (cl-transforms:make-pose
                                           (cl-transforms:make-3d-vector
                                            (cl-transforms:x (cl-transforms:origin svec))
                                            (cl-transforms:y (cl-transforms:origin svec))
                                            (+ (cl-transforms:z (cl-transforms:origin svec)) (* mindex 0.2)))
                                           (cl-transforms:orientation svec)))
                               (publish-pose svec :id (+ 1000 (+ id2 1)))
                               (setf id2 (+ id2 1))) 
                    ;;  (publish-pose fvector :id (+ 100 (+ id1 (+ id1 (* index 2)))))
                      (setf id1 (+ id1 1))))
                 ((<= index 10)
                  (loop for jindex from -10 to 10
                   do            
                      (setf fvector (cam-get-pose->relative-map
                                    (cl-transforms:make-3d-vector
                                    ( * index (cl-transforms:x limiter))
                                     (* (* (cl-transforms:y limiter) (* 0.7 jindex)) 5)
                                     (* (cl-transforms:z limiter) 1))))
                                             (loop for mindex from -4 to 5
                             do(setf svec fvector)
                               (setf svec (cl-transforms:make-pose
                                           (cl-transforms:make-3d-vector
                                            (cl-transforms:x (cl-transforms:origin svec))
                                            (cl-transforms:y (cl-transforms:origin svec))
                                            (+ (cl-transforms:z (cl-transforms:origin svec)) (* mindex 0.2)))
                                           (cl-transforms:orientation svec)))
                               (publish-pose svec :id (+ 1000 (+ id2 1)))
                               (setf id2 (+ id2 1)))
                 ;;  (publish-pose fvector :id (+ 100 (+ id1 (+ id1 (* index 2)))))
                     (setf id1 (+ id1 1))))
                 (t
                  (loop for jindex from -15 to 15
                   do            
                      (setf fvector (cam-get-pose->relative-map
                                    (cl-transforms:make-3d-vector
                                    ( * index (cl-transforms:x limiter))
                                     (* (* (cl-transforms:y limiter) (* 0.3 jindex)) 9)
                                     (* (cl-transforms:z limiter) 1))))
                                             (loop for mindex from -7 to 8
                             do(setf svec fvector)
                               (setf svec (cl-transforms:make-pose
                                           (cl-transforms:make-3d-vector
                                            (cl-transforms:x (cl-transforms:origin svec))
                                            (cl-transforms:y (cl-transforms:origin svec))
                                            (+ (cl-transforms:z (cl-transforms:origin svec)) (* mindex 0.2)))
                                           (cl-transforms:orientation svec)))
                                (publish-pose svec :id (+ 3000 (+ id2 1)))
                             
                               (setf id2 (+ id2 1)))
                     ;;(publish-pose fvector :id (+ 100 (+ id1 (+ id1 (* index 2)))))
                      (setf id1 (+ id1 1))))))))

(defun publish-pose-color (pose vec)
  (setf *marker-publisher*
        (roslisp:advertise "~location_marker" "visualization_msgs/Marker"))
    (let ((point (cl-transforms:origin pose))
          (rot (cl-transforms:orientation pose)))
    (when *marker-publisher*
      (roslisp:publish *marker-publisher*
                       (roslisp:make-message "visualization_msgs/Marker"
                                             (stamp header) (roslisp:ros-time)
                                             (frame_id header)
                             (typecase pose
                               (cl-transforms-stamped:pose-stamped (cl-transforms-stamped:frame-id  pose))
                               (t cram-tf:*fixed-frame*))
                             ns "kipla_locations"
                             id 500000
                             type (roslisp:symbol-code 
                                   'visualization_msgs-msg:<marker> :arrow)
                             action (roslisp:symbol-code 
                                     'visualization_msgs-msg:<marker> :add)
                             (x position pose) (cl-transforms:x point)
                             (y position pose) (cl-transforms:y point)
                             (z position pose) (+ (cl-transforms:z point) 2)
                             (x orientation pose) (cl-transforms:x rot)
                             (y orientation pose) (cl-transforms:y rot)
                             (z orientation pose) (cl-transforms:z rot)
                             (w orientation pose) (cl-transforms:w rot)
                             (x scale) 0.40
                             (y scale) 0.15
                             (z scale) 0.15
                             (r color) (cl-transforms:x vec) ; (random 1.0)
                             (g color) (cl-transforms:y vec) ; (random 1.0)
                             (b color) (cl-transforms:z vec) ; (random 1.0)
                             (a color) 1.0)))))
