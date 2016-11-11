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

(defun start-my-ros ()
  (roslisp-utilities:startup-ros ))

;; ROSSERVICE FOR DOING REASONING

(defun start_reasoning_service ()
(hmidesig-call))
 ;; (reasoning-call))


(defun hmidesig-call ()
 (roslisp-utilities:startup-ros :name "start_hmidesig_service")
  (roslisp:register-service "service_cram_reasoning" 'instructor_mission-srv:HMIDesig)
  (roslisp:ros-info (basics-system) "start hmireasoning service")
 (roslisp:spin-until nil 1000))

(roslisp:def-service-callback instructor_mission-srv::HMIDesig (desigs)
  (let ((id  (beliefstate:start-node "INTERPRET-INSTRUCTION-DESIGNATOR" NIL 2))
        (newliste '())
        (logged_desigs (create-logged-designator desigs)))
    (format t "create logged work with~a~%" logged_desigs)
    (cond ((not (null (length logged_desigs)))
           (dotimes (incr (length logged_desigs))
             do (cond((not (null (desig-prop-value (nth incr logged_desigs) :loc)))
                      (let*((design (fill-desig-property-list (first (desig-prop-values
                                                               (nth incr logged_desigs) :perspective))
                                                              (desig-prop-value  (nth incr logged_desigs) :loc)))
                            (actionprop  (desig-prop-value (nth incr logged_desigs) :type))
                            (actiondesig (make-designator :action `((:type ,actionprop)
                                                                    (:loc ,design))))
                            (position (reference-by-human-frame design (second (first (last (desig:properties design)))))))
                        (setf newliste (append newliste (list  (make-designator :action `((:type ,actionprop)
                                                                                          (:loc ,position))))))
                       ;; (format t "wuaaat ~a~%" (nth incr logged_desigs))
                        (beliefstate:add-designator-to-active-node (nth incr logged_desigs))
                       ;;  (format t "wuaaat3 ~a~%" actiondesig)
                        (beliefstate:add-designator-to-active-node actiondesig)
                       ;;  (format t "wuaaat4 ~%")
                        (beliefstate:add-designator-to-active-node (make-designator :action `((:type ,actionprop)
                                                                                          (:loc ,position))))))
                     (t (setf newliste (append newliste (list (nth incr logged_desigs))))
                        (beliefstate:add-designator-to-active-node (nth incr logged_desigs))))))
          (t (setf newliste NIL)))
    (beliefstate:stop-node id)
    (beliefstate:extract-files :name "INTERPRET-INSTRUCTION-DESIGNATOR")
   ;; (format t "wuaaat ~a~%" newliste)
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
  (format t "object-name ~a~%" object-name)
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
 ;; (if (not (equal *pub-intern* NIL))
 ;;     (remove-local-tf-publisher *pub-intern*))
 ;; (setf *pub-intern* (create-local-tf-publisher pose "pub-intern"))
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
