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
(defvar *value* "")
(defvar *vec-chain* (cl-transforms:make-identity-vector))
(defun start-my-ros ()
  (roslisp-utilities:startup-ros))

;; ROSSERVICE FOR DOING REASONING

(defun start_reasoning_service ()
  (reasoning-call))

(defun reasoning-call ()
 (roslisp-utilities:startup-ros :name "start_reasoning_service")
  (roslisp:register-service "service_cram_reasoning" 'instructor_mission-srv:cram_reason)
  (roslisp:ros-info (basics-system) "start reasoning service")
 (roslisp:spin-until nil 1000))

 (roslisp:def-service-callback instructor_mission-srv:cram_reason (cmd x y z)
   (let((*vec-chain* (cl-transforms:make-3d-vector x y z))
        (liste (correct-parsing cmd))
        (value NIL)(pose NIL)
        (newliste NIL) (rotation-cmd NIL))
     (cond ((not (equal NIL (second liste)))
            (setf newliste (designator-filled-with-values (second liste)))               
               (setf pose (reference-by-human-frame newliste (second (first (last (desig:properties newliste)))))))
              (t (setf newliste NIL)))
        (cond((string-equal "move" (first liste))
              (setf value (forward-movecmd-to-gazebo (cl-transforms:x (cl-transforms:origin pose))
                                                     (cl-transforms:y (cl-transforms:origin pose))
                                                     (cl-transforms:z (cl-transforms:origin pose))
                                                     (cl-transforms:x (cl-transforms:orientation pose))
                                                     (cl-transforms:y (cl-transforms:orientation pose))
                                                     (cl-transforms:z (cl-transforms:orientation pose))
                                                     (cl-transforms:w (cl-transforms:orientation pose))))
              (let((quad-pose NIL)
                   (new-quad-pose NIL)
                   (lisp-pose NIL))
                   (setf quad-pose (gazebo_msgs-srv:pose (roslisp:call-service "gazebo/get_model_state"
                                                               'gazebo_msgs-srv::GetModelState
                                                               :model_name "quadrotor"
                                                               :relative_entity_name "")))
                (setf lisp-pose (cl-transforms:make-pose (cl-transforms:make-3d-vector
                                                          (geometry_msgs-msg:x
                                                           (geometry_msgs-msg:position quad-pose))
                                                          (geometry_msgs-msg:y
                                                           (geometry_msgs-msg:position quad-pose))
                                                          (geometry_msgs-msg:z
                                                           (geometry_msgs-msg:position quad-pose)))
                                                         (cl-transforms:make-quaternion
                                                          (geometry_msgs-msg:x
                                                           (geometry_msgs-msg:orientation quad-pose))
                                                          (geometry_msgs-msg:y
                                                           (geometry_msgs-msg:orientation quad-pose))
                                                          (geometry_msgs-msg:z
                                                           (geometry_msgs-msg:orientation quad-pose))
                                                          (geometry_msgs-msg:w
                                                           (geometry_msgs-msg:orientation quad-pose)))))
                (setf new-quad-pose (look-at-object-x lisp-pose *obj-pose*))
                (setf rotation-cmd (forward-rotatecmd-to-gazebo new-quad-pose))))
            ((and (string-equal "take" (first liste))
                  (equal NIL pose))
             (setf *value* (forward-takecmd-to-gazebo "go")))
            ((and (string-equal "take" (first liste))
                  (not (equal NIL pose)))
             (setf value (forward-movecmd-to-gazebo (cl-transforms:x (cl-transforms:origin pose))
                                                    (cl-transforms:y (cl-transforms:origin pose))
                                                    (cl-transforms:z (cl-transforms:origin pose))
                                                    (cl-transforms:x (cl-transforms:orientation pose))
                                                    (cl-transforms:y (cl-transforms:orientation pose))
                                                    (cl-transforms:z (cl-transforms:orientation pose))
                                                    (cl-transforms:w (cl-transforms:orientation pose))))
             (let((quad-pose NIL)
                   (new-quad-pose NIL)
                   (lisp-pose NIL))
                   (setf quad-pose (gazebo_msgs-srv:pose (roslisp:call-service "gazebo/get_model_state"
                                                               'gazebo_msgs-srv::GetModelState
                                                               :model_name "quadrotor"
                                                               :relative_entity_name "")))
                (setf lisp-pose (cl-transforms:make-pose (cl-transforms:make-3d-vector
                                                          (geometry_msgs-msg:x
                                                           (geometry_msgs-msg:position quad-pose))
                                                          (geometry_msgs-msg:y
                                                           (geometry_msgs-msg:position quad-pose))
                                                          (geometry_msgs-msg:z
                                                           (geometry_msgs-msg:position quad-pose)))
                                                         (cl-transforms:make-quaternion
                                                          (geometry_msgs-msg:x
                                                           (geometry_msgs-msg:orientation quad-pose))
                                                          (geometry_msgs-msg:y
                                                           (geometry_msgs-msg:orientation quad-pose))
                                                          (geometry_msgs-msg:z
                                                           (geometry_msgs-msg:orientation quad-pose))
                                                          (geometry_msgs-msg:w
                                                           (geometry_msgs-msg:orientation quad-pose)))))
                (setf new-quad-pose (look-at-object-x lisp-pose *obj-pose*))
                (setf rotation-cmd (forward-rotatecmd-to-gazebo new-quad-pose)))
             (roslisp:wait-duration 2)
             (setf *value* (forward-takecmd-to-gazebo "go")))
            ((and (string-equal "show" (first liste))
                  (equal pose NIL))
             (format t "value is ~a~%" *value*)
             (cond((or (string-equal *value* "") (string-equal *value* "value"))
                   (setf *value* (forward-takecmd-to-gazebo "go"))
                   (roslisp:wait-duration 2)
                   (setf value (forward-showcmd-to-gazebo *value*)))
                  (t (roslisp:wait-duration 2)
                     (setf value (forward-showcmd-to-gazebo *value*)))))
            ((and (string-equal "show" (first liste))
                  (not (equal pose NIL)))
             (format t "newliste ~a~%" newliste)
             (setf value (forward-movecmd-to-gazebo (cl-transforms:x (cl-transforms:origin pose))
                                                     (cl-transforms:y (cl-transforms:origin pose))
                                                     (cl-transforms:z (cl-transforms:origin pose))
                                                     (cl-transforms:x (cl-transforms:orientation pose))
                                                     (cl-transforms:y (cl-transforms:orientation pose))
                                                     (cl-transforms:z (cl-transforms:orientation pose))
                                                     (cl-transforms:w (cl-transforms:orientation pose))))
             (roslisp:wait-duration 2)       
              (setf *value* (forward-takecmd-to-gazebo "go"))
                   (roslisp:wait-duration 2)
                   (setf value (forward-showcmd-to-gazebo *value*)))))
   (roslisp:make-response :result "Done!"))

(Defun starter-mission ()
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

;;client-service to gazebo: move quadrotor
(defun forward-movecmd-to-gazebo (x y z qx qy qz qw)
 ;; (roslisp:with-ros-node ("setRobotPoints_nodecall")
    (if (roslisp:wait-for-service "setRobotPoints" 10)
        (format t "~a~%" (roslisp:call-service "setRobotPoints"
                                               'quadrotor_controller-srv::cmd_points
                                               :x x
                                               :y y
                                               :z z
                                               :qx qx
                                               :qy qy
                                               :qz qz
                                               :qw qw))))



;;client-service to gazebo: move quadrotor
(defun forward-rotatecmd-to-gazebo (pose)
 ;; (roslisp:with-ros-node ("setRobotPoints_nodecall")
(let* ((vec (cl-transforms:origin pose))
      (quat (cl-transforms:orientation pose))
      (x (cl-transforms:x vec))
      (y (cl-transforms:y vec))
      (z (cl-transforms:z vec))
      (qx (cl-transforms:x quat))
      (qy (cl-transforms:y quat))
      (qz (cl-transforms:z quat))
      (qw (cl-transforms:w quat)))
(if (roslisp:wait-for-service "setRobotRotation" 10)
        (format t "~a~%" (roslisp:call-service "setRobotRotation"
                                               'quadrotor_controller-srv::cmd_points
                                               :x x
                                               :y y
                                               :z z
                                               :qx qx
                                               :qy qy
                                               :qz qz
                                               :qw qw)))))

;;client-service to gazebo:take-picture quadrotor
(defun forward-takecmd-to-gazebo (tmp)
 ;; (roslisp:with-ros-node ("setRobotPoints_nodecall")
  (let((value NIL))
    (if (roslisp:wait-for-service "store_image" 10)
        (setf value (img_mission-srv:result (roslisp:call-service "store_image"
                                                                  'img_mission-srv::returnString
                                                                  :goal tmp))))
    value))

;;client-service to gazebo:take-picture quadrotor
(defun forward-showcmd-to-gazebo (tmp)
 ;; (roslisp:with-ros-node ("setRobotPoints_nodecall")
  (let((value NIL))
    (if (roslisp:wait-for-service "show_image" 10)
        (setf value (img_mission-srv:result (roslisp:call-service "show_image"
                                                                  'img_mission-srv::returnString
                                                                  :goal tmp))))
    value))
