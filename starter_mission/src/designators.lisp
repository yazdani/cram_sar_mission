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
(defvar *recalculate* NIL)
(defvar *selem* NIL)
(defvar *telem* NIL)


(defun create-desigs-based-on-hmi-msgs (msgs)
  (let ((action-list '()))
    (format t "msgs are ~a~%" msgs)
    (loop for index being the elements of msgs
          do(let ((property-list NIL)
                  (loc_desig NIL)
                  (action (std_msgs-msg:data
                           (instructor_mission-msg:action_type index)))
                  (actor (std_msgs-msg:data
                          (instructor_mission-msg:actor index)))
                  (operator (std_msgs-msg:data
                             (instructor_mission-msg:instructor index)))
                  (viewpoint (std_msgs-msg:data
                              (instructor_mission-msg:viewpoint index)))
                  (propkeys (instructor_mission-msg:propkeys index)))
              (loop for jndex being the elements of propkeys
                    do(format t "jndex is ~a~%" jndex)
                      (format t "propkeys ~a~%" propkeys)
                       (let((pose NIL)(obj NIL)
                           (spatial
                             (std_msgs-msg:data
                              (instructor_mission-msg::object_relation jndex)))
                           (object
                               (std_msgs-msg:data
                              (instructor_mission-msg::object jndex)))
                           (color
                               (std_msgs-msg:data
                              (instructor_mission-msg::object_color jndex)))
                           (size
                             (std_msgs-msg:data
                              (instructor_mission-msg::object_size jndex)))
                           (num
                             (std_msgs-msg:data
                              (instructor_mission-msg::object_num jndex)))
                           (flag
                             (std_msgs-msg:data
                              (instructor_mission-msg::flag jndex))))
                        (if (and (string-equal spatial "null")
                                 (not (string-equal "null" object)))
                            (setf spatial "ontop"))
                        (cond((string-equal "true" flag)
                              (setf pose (cl-transforms:make-3d-vector
                                          (geometry_msgs-msg:x
                                           (instructor_mission-msg:pointing_gesture jndex))
                                          (geometry_msgs-msg:y
                                           (instructor_mission-msg:pointing_gesture jndex))
                                                                       (geometry_msgs-msg:z
                                           (instructor_mission-msg:pointing_gesture jndex))))
                              (setf obj (give-pointed-obj-based-on-language-obj object pose)))
                             (t (setf obj NIL)))
                        (if (null obj)
                            (setf obj object))
                        (setf property-list (append (list  (list (list (direction-symbol spatial) obj)
                                                                 (list :color color)
                                                                 (list :size size)
                                                                 (list :num num))) property-list))))   
                        (setf loc_desig (make-designator :location property-list))
                        (setf action-list (append action-list (list (make-designator :action `((:type ,action)
                                                                                             (:actor ,actor)
                                                                                             (:operator ,operator)
                                                                                             (:viewpoint ,viewpoint)
                                                                                             (:goal ,loc_desig))))))
                        ))
                        ;;     (t (setf action-list (append action-list (list (make-designator :action `((:type ,action)
                        ;;                                                                        (:actor ,actor)
                        ;;                                                                              (:operator ,operator)
                        ;;                                                                              (:viewpoint ,viewpoint))))))))))))
                        
    (format t "actionlist is ~a~%" action-list)
action-list))
    
(defun assign-semantics-to-desig (actiondesig)
  (format t "actiondesig in assign ~a~%" actiondesig)
  (let* ((action (desig-prop-value actiondesig :type))
         (actor (desig-prop-value actiondesig :actor))
         (operator (desig-prop-value actiondesig :operator))
         (viewpoint (desig-prop-value actiondesig :viewpoint))
         (goal (desig-prop-value actiondesig :goal))
         (proplist (desig:properties goal))
         (tmpproplist '())
         (felem NIL)
         (result NIL))
    (format t "proplist ~a~%" proplist)
         (cond((= 1 (length proplist))
               (cond((not (null (get-elem-pose (second (first (first (last proplist))))))) ;;;name
                     (setf felem (second (first (first (last proplist)))))
                     (setf tmpproplist (append tmpproplist (list (list (first (first (first (last proplist))))
                                                                       felem)))))
                    ((not (string-equal "null" (second (third (first (last proplist)))))) ;;;size
                     (setf felem (get-elem-by-bboxsize->get-elems-agent-front-by-dist
                                  (second (first (first (last proplist))))
                                  (second (third (first (last proplist))))))
                     (setf tmpproplist (append tmpproplist (list (list  (first (first (first (last proplist))))
                                                                        felem)))))
                    ((not (string-equal "null" (second (fourth (first (last proplist)))))) ;;num
                     (setf felem (get-elem-by-range->get-elems-by-type
                                  (second (first (first proplist)))
                                  (second (fourth (first proplist)))))                   (setf tmpproplist (append tmpproplist (list (list  (first (first (first (last proplist)))) felem)))))
                    ((null (get-elem-pose (second (first (first proplist))))) ;;;name
                     (setf felem  (get-elem-by-type->get-elems-by-type
                                   (second (first (first (last proplist))))))
                     (setf tmpproplist (append tmpproplist (list (list (first (first (first (last proplist))))
                                                                       felem)))))))
              ((= 2 (length proplist))
               (setf tmpproplist (assign-semantics-two-desig proplist)))
              ((= 3 (length proplist))
               (setf tmpproplist (assign-semantics-three-desig proplist))))
  ;;  (format t "end ~%")
    (cond((not (string-equal "null" (cadar tmpproplist)))
          (if  (not (null (cadar tmpproplist)))
          (publish-elempose (get-elem-by-pose (cadar tmpproplist)) 2222222 (cl-transforms:make-3d-vector 1 0 0)))))
    (setf result (make-designator :action `((:type ,action)
                               (:actor ,actor)
                               (:operator ,operator)
                               (:viewpoint ,viewpoint)
                               (:goal ,(make-designator :location tmpproplist)))))
    result))
                     
(defun assign-semantics-two-desig  (proplist)
      (format t "proplist ~a ~%"proplist)
  (let*((list2 (first (last proplist)))
        (list1 (first proplist))
        (typelist1 (get-elems-agent-front-by-type (second (first list1))))
        (tmpproplist '())
        (selem NIL)(checker NIL)(felem NIL))   
          (cond((and (get-elem-by-pose (second (first list1))) ;;name1 ;;typ2-shape2
                     (not (string-equal "null" (second (third list2)))))
                (setf selem (first
                             (split-sequence:split-sequence #\:
                                                            (get-new-elem-by-name-type-shape-spatial
                                                              (second (first list1))
                                                              (second (first list2))
                                                              (second (third list2))
                                                              (first (first list1))))))
                (setf tmpproplist (append tmpproplist (list(list (first (first list1))
                                                                  (second (first list1)))
                                                            (list (first (first list2))
                                                                  selem)))))
               ((get-elem-by-pose (second (first list1))) ;;name1
                (setf selem
                      (first
                       (split-sequence:split-sequence #\:
                                                      (first
                                                       (get-next-elem-depend-on-prev-elem-no-con
                                                        (second (first list2))
                                                        (first (first list1))
                                                        (second (first list1)))))))
                 (setf tmpproplist (append tmpproplist (list (list (first (first list1))
                                                                   (second (first list1)))
                                                             (list (first (first list2))
                                                                   selem)))))
               ((and (get-elem-by-pose (second (first list2)))   ;;name2 ;;typ1-shape1
                     (not (string-equal "null" (second (third list1)))))
                (setf felem (first
                             (split-sequence:split-sequence #\:
                                                            (get-first-elem-by-name-type-shape-spatial-
                                                              (second (first list2))
                                                              (second (first list1))
                                                              (second (third list1))
                                                              (first (first list1))))))   
                (setf tmpproplist (append tmpproplist (list (list (first (first list1))
                                                                  felem)
                                                            (list (first (first list2))
                                                                  (first (second list2)))))))
                ((get-elem-by-pose (second (first list2))) ;;name2
                 (setf felem (first
                             (split-sequence:split-sequence #\:
                                                            (first
                                                             (get-prev-elem-depend-on-next-elem-no-con
                                                              (second (first list1))
                                                              (first (first list1))
                                                              (second (first list2)))))))
                (setf tmpproplist (append tmpproplist (list (list (first (first list1))
                                                                  felem)
                                                            (list (first (first list2))
                                                                  (second (first list2)))))))
                (t (dotimes (index (length typelist1))
                     (format t "typelist1 ~a~%" typelist1)
                     (if (null checker)
                         (cond((null (get-elem-pose (second (first list2))))
                               (setf selem
                                     (first
                                      (split-sequence:split-sequence #\:
                                                                     (first
                                                                      (get-next-elem-depend-on-prev-elem
                                                                       (second (first list2))
                                                                       (first (first list1))
                                                                       (nth index typelist1))))))
                               (cond ((null selem)
                                      (setf checker NIL))
                                     (t (setf checker T)
                                        (setf tmpproplist (list (list (first (first list1))
                                                                      (nth index typelist1))
                                                                (list (first (first list2))
                                                                            selem)))))))
                         (return)))))
      (cond ((and (not (string-equal "null" (cadar tmpproplist)))
                  (not (string-equal "null" (cadadr tmpproplist))))
             (cond ((and (not (null (cadar tmpproplist)))
                         (not (null (cadadr tmpproplist))))
                    (publish-elempose (get-elem-by-pose (cadar tmpproplist)) 2222222 (cl-transforms:make-3d-vector 1 0 0))
                    (sleep 2.0)
                    (publish-elempose (get-elem-by-pose (cadadr tmpproplist)) 2222232 (cl-transforms:make-3d-vector 1 1 0))))))                    
tmpproplist))

(defun assign-semantics-three-desig (proplist)
  (let*((list1 (first (last proplist)))
        (list3 (first proplist))
        (list2 (second proplist))
        (typelist1 (get-elems-agent-front-by-type (second (first list1))))
        (tmpproplist '())
        (checker NIL)(selem NIL)(telem NIL)
        (result NIL))
    (dotimes (index (length typelist1))
      (if (null checker)
          (cond((null (get-elem-by-pose (second (first list1)))) ;;;not name
                (cond ((null (get-elem-pose (second (first list2))))
                       (setf telem (first
                                    (split-sequence::split-sequence #\:
                                                                    (first
                                                                    (get-next-elem-depend-on-prev-elem
                                                                      (second (first list2))
                                                                      (first (first list2))
                                                                      (nth index typelist1))))))
                       (cond ((null telem)
                              (setf checker NIL))
                             (t (setf checker T)
                                (cond ((null (get-elem-pose (second (first list3))))
                                       (setf selem (first
                                                    (split-sequence:split-sequence #\:
                                                                                   (first
                                                                                    (get-next-elem-depend-on-prev-elem
                                                                                     (second (first list3))
                                                                                     (first (first list3))
                                                                                     (nth index typelist1))))))
                                       (cond ((null selem)
                                              (setf checker NIL))
                                              (t                                      
                                                 (setf tmpproplist (list (list (first (first list1))
                                                                               (nth index typelist1))
                                                                         (list (first (first list2))
                                                                               selem)
                                                                         (list (first (first list3))
                                                                               telem)))))))))))))
          (return)))
    (setf result (reverse tmpproplist))
   (cond ((and (not (string-equal "null" (cadar tmpproplist)))
               (not (string-equal "null" (cadadr tmpproplist)))
               (not (string-equal "null" (cadr (caddr tmpproplist)))))
            (cond ((and (not (null (cadar tmpproplist)))
                        (not (null (cadadr tmpproplist)))
                        (not (null (cadr (caddr tmpproplist)))))
                   (publish-elempose (get-elem-by-pose (cadar tmpproplist)) 2222222 (cl-transforms:make-3d-vector 1 0 0))
                   (sleep 2.0)
                   (publish-elempose (get-elem-by-pose (cadadr tmpproplist)) 2222232 (cl-transforms:make-3d-vector 1 1 0))
                   (sleep 2.0)
                   (publish-elempose (get-elem-by-pose (cadr (caddr tmpproplist))) 2222242 (cl-transforms:make-3d-vector 0 0 1))))))
    result))



 (defun gazebo-functions (newliste)
   ;;(format t "newliste ~a~%" newliste)
   (dotimes (index (length newliste))
      ;;(format t "~a~%" (desig-prop-value (nth index newliste) :type))
     do(let((pose  (desig-prop-value (nth index newliste) :goal)))
         (cond((string-equal "move" (desig-prop-value (nth index newliste) :type))
               (setf value (forward-movecmd-to-gazebo (cl-transforms:x (cl-transforms:origin pose))
                                                             (cl-transforms:y (cl-transforms:origin pose))
                                                             (cl-transforms:z (cl-transforms:origin pose))
                                                             (cl-transforms:x (cl-transforms:orientation pose))
                                                             (cl-transforms:y (cl-transforms:orientation pose))
                                                             (cl-transforms:z (cl-transforms:orientation pose))
                                                             (cl-transforms:w (cl-transforms:orientation pose))))
               (let((quad-pose (cl-transforms:transform->pose (cl-tf:lookup-transform *tf* "map" "base_footprint"))))
                 (setf new-quad-pose (look-at-object-x (cl-transforms:make-pose (cl-transforms:origin quad-pose)(cl-transforms:orientation (cl-transforms:transform->pose (cam-depth-tf-human-transform )))) *obj-pose*))
                 (setf rotation-cmd (forward-rotatecmd-to-gazebo new-quad-pose))))
              ((string-equal "moving" (desig-prop-value (nth index newliste) :type))
               (tf-human-to-map)
               (setf value (forward-movingcmd-to-gazebo (cl-transforms:x (cl-transforms:origin pose))
                                                             (cl-transforms:y (cl-transforms:origin pose))
                                                             (cl-transforms:z (cl-transforms:origin pose))
                                                             (cl-transforms:x (cl-transforms:orientation pose))
                                                             (cl-transforms:y (cl-transforms:orientation pose))
                                                             (cl-transforms:z (cl-transforms:orientation pose))
                                                             (cl-transforms:w (cl-transforms:orientation pose)))))
              ((and (string-equal "take-picture" (desig-prop-value (nth index newliste) :type))
                    (equal NIL (desig-prop-value (nth index newliste) :goal)))
              
               (setf *value* (forward-takecmd-to-gazebo "go")))
              ((string-equal "take-off" (desig-prop-value (nth index newliste) :type))
               (setf *value* (forward-takeoff-to-gazebo "go")))
              ((and (string-equal "take-picture" (desig-prop-value (nth index newliste) :type))
                    (not (null (desig-prop-value (nth index newliste) :goal))))
               (setf pose (desig-prop-value (nth index newliste) :goal))
               (setf value (forward-movecmd-to-gazebo (cl-transforms:x (cl-transforms:origin pose))
                                                      (cl-transforms:y (cl-transforms:origin pose))
                                                      (cl-transforms:z (cl-transforms:origin pose))
                                                      (cl-transforms:x (cl-transforms:orientation pose))
                                                      (cl-transforms:y (cl-transforms:orientation pose))
                                                      (cl-transforms:z (cl-transforms:orientation pose))
                                                      (cl-transforms:w (cl-transforms:orientation pose))))
               (let((quad-pose (cl-transforms:transform->pose (cl-tf:lookup-transform *tf* "map" "base_footprint"))))
                 (setf new-quad-pose (look-at-object-x (cl-transforms:make-pose (cl-transforms:origin quad-pose)(cl-transforms:orientation (cl-transforms:transform->pose (cam-depth-tf-human-transform )))) *obj-pose*))
                 (setf rotation-cmd (forward-rotatecmd-to-gazebo new-quad-pose)))
               (roslisp:wait-duration 2)
               (setf *value* (forward-takecmd-to-gazebo "go")))
               ((and (or (string-equal "show"  (desig-prop-value (nth index newliste) :type))
                      (string-equal "show-picture"  (desig-prop-value (nth index newliste) :type)))
                    (equal (desig-prop-value (nth index newliste) :goal) NIL))
                (cond((or (string-equal *value* "") (string-equal *value* "value"))
                      (setf *value* (forward-takecmd-to-gazebo "go"))
                      (roslisp:wait-duration 2)
                      (setf value (forward-showcmd-to-gazebo *value*)))
                     (t (roslisp:wait-duration 2)
                        (setf value (forward-showcmd-to-gazebo *value*)))))
                ((and (or (string-equal "show"  (desig-prop-value (nth index newliste) :type))
                      (string-equal "show-picture"  (desig-prop-value (nth index newliste) :type)))
                  (not (equal (desig-prop-value (nth index newliste) :goal) NIL)))
             (setf pose (desig-prop-value (nth index newliste) :goal))
             (setf value (forward-movecmd-to-gazebo (cl-transforms:x (cl-transforms:origin pose))
                                                     (cl-transforms:y (cl-transforms:origin pose))
                                                     (cl-transforms:z (cl-transforms:origin pose))
                                                     (cl-transforms:x (cl-transforms:orientation pose))
                                                     (cl-transforms:y (cl-transforms:orientation pose))
                                                     (cl-transforms:z (cl-transforms:orientation pose))
                                                     (cl-transforms:w (cl-transforms:orientation pose))))
             (let((quad-pose (cl-transforms:transform->pose (cl-tf:lookup-transform *tf* "map" "base_footprint"))))
               (setf new-quad-pose (look-at-object-x (cl-transforms:make-pose (cl-transforms:origin quad-pose)(cl-transforms:orientation (cl-transforms:transform->pose (cam-depth-tf-human-transform )))) *obj-pose*))
                (setf rotation-cmd (forward-rotatecmd-to-gazebo new-quad-pose)))
             (roslisp:wait-duration 2)       
              (setf *value* (forward-takecmd-to-gazebo "go"))
                 (format t "*value ~a~%" *value*)
                   (roslisp:wait-duration 2)
                   (setf value (forward-showcmd-to-gazebo *value*)))))))
