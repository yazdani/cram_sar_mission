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

(defvar *sem-map* NIL)
(defvar *wasp-pose* NIL)
(defun start-my-ros ()
  (roslisp-utilities:startup-ros)
  (setf *sem-map* (sem-map-utils:get-semantic-map)))

;; ROSSERVICE FOR DOING REASONING
(defun start_reasoning_service ()
  (hmidesig-call))
 
;; DEFINITION OF ROSSERVICE SERVER FOR CRAM
(defun hmidesig-call ()
 (roslisp-utilities:startup-ros :name "start_hmidesig_service")
  (roslisp:register-service "service_cram_reasoning" 'instructor_mission-srv:HMIDesig)
  (roslisp:ros-info (basics-system) "start hmireasoning service")
  (roslisp:spin-until nil 1000))

;; This function generates out of a highlevel-instruction the cram-designator
;; and fill it with specific values coming from the semantic map.
;; Besides of semantical annotated objects, this function is also logging the
;; high-level designator
(roslisp:def-service-callback instructor_mission-srv::HMIDesig (desigs)
  (setf *sem-map* (sem-map-utils:get-semantic-map))
  (if (null *wasp-pose*)
       (setf *wasp-pose* (get-robot-pose)))
  (let ((id  (beliefstate:start-node "INTERPRET-INSTRUCTION-DESIGNATOR" NIL 2))
        (newliste '())
        (felem NIL) (sample NIL)
        (created_desigs (create-desigs-based-on-hmi-msgs desigs)))
    (cond ((not (null (length created_desigs)))
           (dotimes (incr (length created_desigs))
             do(cond((not (null (desig-prop-value (nth incr created_desigs) :goal)))
                     (let*((action-desig (assign-semantics-to-desig (nth incr created_desigs)))
                           (viewpoint  (desig-prop-value action-desig :viewpoint)))
                           (sleep 8.0)
                           (format t "test ~a~%" (cadar (desig:properties (desig-prop-value action-desig :goal))))
                       (cond ((and (not (equal (caar (desig:properties (desig-prop-value action-desig :goal))) :null))
                                   (not (null (cadar (desig:properties (desig-prop-value action-desig :goal))))))
                              (setf felem (cadar (desig:properties (desig-prop-value action-desig :goal))))     
                              (setf sample (reference-by-agent-frame (desig-prop-value action-desig :goal) viewpoint))
                              (setf newliste (append newliste
                                                     (list (make-designator :action `((:type ,(desig-prop-value action-desig :type))
                                                                                      (:actor ,(desig-prop-value action-desig :actor))
                                                                                      (:operator ,(desig-prop-value action-desig :operator))
                                                                                      (:viewpoint ,(desig-prop-value action-desig :viewpoint))
                                                                                      (:goal ,sample))))))
                              (beliefstate:add-designator-to-active-node (nth incr created_desigs))
                              (beliefstate:add-designator-to-active-node action-desig)
                              (beliefstate:add-designator-to-active-node (make-designator :action
                                                                                          `((:type ,(desig-prop-value action-desig :type))
                                                                                            (:actor ,(desig-prop-value action-desig :actor))
                                                                                            (:operator ,(desig-prop-value action-desig :operator))
                                                                                            (:viewpoint ,(desig-prop-value action-desig :viewpoint))
                                                                                            (:goal ,sample)))))
                             ((and (not (equal (caar (desig:properties (desig-prop-value action-desig :goal))) :null))
                                   (string-equal "come" (cadar (desig:properties action-desig)))
                                   (null  (cadar (desig:properties (desig-prop-value action-desig :goal)))))
                               (format t "relations123 ~a~%" action-desig)
                               (setf newliste (append newliste
                                                     (list (make-designator :action `((:type "moving")
                                                                                      (:actor ,(desig-prop-value action-desig :actor))
                                                                                      (:operator ,(desig-prop-value action-desig :operator))
                                                                                      (:viewpoint ,(desig-prop-value action-desig :viewpoint))
                                                                                      (:goal ,*wasp-pose*)))))))
                              ((and (not (equal (caar (desig:properties (desig-prop-value action-desig :goal))) :null))
                                   (null  (cadar (desig:properties (desig-prop-value action-desig :goal)))))
                               (format t "relations ~a~%" action-desig)
                              (setf sample (checking-relation (desig-prop-value action-desig :viewpoint) (caar (desig:properties (desig-prop-value action-desig :goal)))))
                              (setf newliste (append newliste
                                                     (list (make-designator :action `((:type "moving")
                                                                                      (:actor ,(desig-prop-value action-desig :actor))
                                                                                      (:operator ,(desig-prop-value action-desig :operator))
                                                                                      (:viewpoint ,(desig-prop-value action-desig :viewpoint))
                                                                                      (:goal ,sample)))))))
                             (t (setf newliste (append newliste
                                                     (list (make-designator :action `((:type ,(desig-prop-value action-desig :type))
                                                                                      (:actor ,(desig-prop-value action-desig :actor))
                                                                                      (:operator ,(desig-prop-value action-desig :operator))
                                                                                      (:viewpoint ,(desig-prop-value action-desig :viewpoint))
                                                                                      (:goal NIL))))))))))
                    (t (setf newliste (append newliste (list (nth incr created_desigs))))
                        (beliefstate:add-designator-to-active-node (nth incr created_desigs))))))
          (t (setf newliste NIL)))
    (format t "newliste ~a~%" newliste)
    (beliefstate:stop-node id)
    (beliefstate:extract-files :name "INTERPRET-INSTRUCTION-DESIGNATOR")
    (format t "hieeeer ~a ~%" newliste)
    (gazebo-functions newliste))
    (roslisp:make-response :result "Done!")) 
   

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
  ;;(format t "object-name ~a~%" object-name)
 ;;(setf cram-tf:*fixed-frame* "human")
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


(defun forward-movingcmd-to-gazebo (x y z qx qy qz qw)
 ;; (roslisp:with-ros-node ("setRobotPoints_nodecall")
    (if (roslisp:wait-for-service "setRobotRelation" 10)
        (format t "~a~%" (roslisp:call-service "setRobotRelation"
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
 ;; (if (not (equal *pub-intern* NIL))
 ;;     (remove-local-tf-publisher *pub-intern*))
 ;; (setf *pub-intern* (create-local-tf-publisher pose "pub-intern"))
 ;; (roslisp:with-ros-node ("setRobotPoints_nodecall")
  (format t "pose ~a~%" pose)
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
  (format t "value is : ~a~%" tmp)
  (let((value NIL))
    (if (roslisp:wait-for-service "show_image" 10)
        (setf value (img_mission-srv:result (roslisp:call-service "show_image"
                                                                  'img_mission-srv::returnString
                                                                  :goal tmp))))
    value))

(defun forward-takeoff-to-gazebo (tmp)
 ;; (roslisp:with-ros-node ("setRobotPoints_nodecall")
    (if (roslisp:wait-for-service "takeOff" 10)
        (roslisp:call-service "takeOff"
                              'quadrotor_controller-srv::scan_reg                                                                  :start tmp)))
