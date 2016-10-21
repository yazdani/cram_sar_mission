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

(defvar *puby* NIL)


(defun get-objects-infrontof-human ()
(let((liste '()))
     ;; (sem-map (sem-map-utils:get-semantic-map))
        (dotimes (index 80)
    (if (>= 40 (length liste))
        (setf liste (get-elements-infrontof-human-with-distance index)) 
        (return)))
  (reverse liste)))

(defun get-elements-infrontof-human-with-distance (num)
  (let* ((sem-map (sem-map-utils:get-semantic-map))
         (sem-hash (slot-value sem-map 'sem-map-utils:parts))
         (sem-keys (hash-table-keys sem-hash))
         (poses '()) (dist NIL) (liste '())
         (obj-pose2))
  ;;  (dotimes (index (length sem-keys))
  ;;    (format t "map ~a und ~a~%" (get-distance (tf-human-to-map) (get-elem-pose (nth index sem-keys))) (nth index sem-keys)))
    (dotimes (index (length sem-keys))
      (if (or (string-equal (nth index sem-keys) "human01")
              (string-equal (nth index sem-keys)  "human02")
              (string-equal (nth index sem-keys)  "human03"))
          ()
          (setf liste (cons (nth index sem-keys) liste))))
    (dotimes (index (length liste))
      (setf obj-pose (cl-transforms-stamped:transform->pose (cl-tf:lookup-transform *tf* "human" (format NIL "~a_link" (nth index liste)))))
         (setf obj-pose2 (cl-transforms-stamped:transform->pose (cl-tf:lookup-transform *tf* "map" (format NIL "~a_link" (nth index liste)))))
      (setf dist (get-distance (tf-human-to-map) obj-pose2))
      (if (and (>= num dist)
               (plusp (cl-transforms:x (cl-transforms:origin obj-pose))))
               (setf poses (append (list (format NIL"~a:~a" (nth index liste) dist)) poses))))
       poses))

;; Based on the given obj, we are calculating
;; all those objects which are of a specific
;; type
(defun get-specific-elements-close-to-object (obj type)
 ;; (format t " get-specific-elements-close-to-object ~%")
   (let* ((sem-map (sem-map-utils:get-semantic-map))
          (sem-hash (slot-value sem-map 'sem-map-utils:parts))
          (sem-keys (hash-table-keys sem-hash))
          (poses '())
          (obj-pose NIL)
          (liste NIL))
  ;;    (format t " get-specific-elements-close-to-objec2t ~%")
    (dotimes (index (length sem-keys))
    ;;  (format t "~a~%"(nth index sem-keys))
          (setf liste (cons (nth index sem-keys) liste)))
    (dotimes (index (length liste))
      (setf obj-pose (cl-transforms-stamped:transform->pose (cl-tf:lookup-transform *tf* (format NIL "~a_link" obj) (format NIL "~a_link" (nth index liste)))))
      (if (string-equal (get-elem-type (nth index liste)) type)
          (setf poses (append (list (format NIL "~a:~a"(nth index liste)(get-distance obj-pose (get-elem-pose obj))))  poses))))
     ;;(format t "all poses: ~a~%" poses)
       poses))


  
(defun tf-human-to-map ()
  ;;(setf cram-tf:*fixed-frame* "map")
  (let ((var (cl-transforms:transform->pose (cl-tf:lookup-transform *tf* "map" "human"))))
    (publish-body var)
   ;; (format t "var is ~a~%" var)
 ;;   (publish-pose var :id 112283246723689)
    var))

(defun get-distance (pose1 pose2)
(let*((vector (cl-transforms:origin pose1))
        (x-vec (cl-transforms:x vector))
        (y-vec (cl-transforms:y vector))
        (z-vec (cl-transforms:z vector))
        (ge-vector (cl-transforms:origin pose2))
        (x-ge (cl-transforms:x ge-vector))
        (y-ge (cl-transforms:y ge-vector))
        (z-ge (cl-transforms:z ge-vector)))
    (round (sqrt (+ (square (- x-vec x-ge))
             (square (- y-vec y-ge))
             (square (- z-vec z-ge)))))))

(defun get-elem-type (name)
 (let*((type NIL)
       (sem-map (sem-map-utils:get-semantic-map))
       (sem-hash (slot-value sem-map 'sem-map-utils:parts))
       (new-hash (copy-hash-table sem-hash))
       (sem-keys (hash-table-keys sem-hash)))
       (dotimes(i (length sem-keys))
         (cond ((string-equal name (nth i sem-keys))
                (setf type (slot-value (gethash name new-hash)
                                       'cram-semantic-map-utils::type))
                (if (or
                     (string-equal type "bigtree")
                     (string-equal type "biggesttree")
                     (string-equal type "smalltree")
                     (string-equal type "smallbigtree"))
                    (setf type "tree"))
                (if  (string-equal type "hugerock")
                     (setf type "rock"))
		(if (or
		     (string-equal type "brokepylon")
		     (string-equal type "bluepylon")
		     (string-equal type "redpylon"))
		    (setf type "pylon"))
                (return))
                     (t ())))
   type))

(defun reference-by-human-frame (desig objname)
(format t " und ~a und ~a~%" desig objname)
  (let*((result NIL)
        (cam (cam-depth-tf-transform))
        (temp NIL)
        (tmp NIL)
        (tom NIL))
    (setf cram-tf:*fixed-frame* "human")
    (cond((not(equal NIL desig))
          (setf result (reference desig))
        ;;  (if (equal *puby* NIL)
          ;;    ()
           ;;   (remove-local-tf-publisher *puby*))     
          (setf temp (look-at-object-x (cl-transforms:make-pose (cl-transforms:origin (cl-transforms-stamped:pose-stamped->pose result)) (cl-transforms:orientation (cl-transforms:transform->pose cam)))  (get-human-elem-pose objname)))
          (setf *obj-pose* (get-elem-pose objname))
          (setf tmp (cl-transforms-stamped:make-pose-stamped "human"
                                                             0.0 (cl-transforms:origin temp)
                                                             (cl-transforms:orientation temp)))

          (setf tom (cl-transforms-stamped:pose-stamped->pose (cl-tf:transform-pose *tf* :pose tmp :target-frame "map"))))  
        ;;(setf *puby* (create-local-tf-publisher tom "test")))
         (t ()))
  (setf cram-tf:*fixed-frame* "map")
    tom))


(defun cam-depth-tf-transform ()
  (cl-transforms-stamped:lookup-transform *tf* "human" "camera_depth_frame"))

(defun cam-depth-tfmap-transform ()
  (cl-transforms-stamped:lookup-transform *tf* "map" "camera_depth_frame"))

;; (defun create-local-tf-publisher (robot-pose name)
;;    (let*((pub (cl-tf:make-transform-broadcaster)))
;;  (cl-tf:send-static-transforms pub 1.0 "quadpose" (cl-transforms-stamped:make-transform-stamped "map" name (roslisp:ros-time) (cl-transforms:origin robot-pose) (cl-transforms:orientation robot-pose)))))

;; (defun remove-local-tf-publisher (thread)
;;   (when (sb-thread:thread-alive-p thread)
;;     (handler-case
;;         (prog1 t (sb-thread:terminate-thread thread))
;;       (error () nil))))


;;take(picture,small,tree);move(to,small,tree) => take(picture,small,tree) move(to,small,tree)
(defun split-columns (cmd)
  (split-sequence:split-sequence #\; cmd))

;;take(picture,small,tree) => take
(defun split-action (cmd)
  (first (split-sequence:split-sequence #\( cmd)))

;;move(to,small,tree) => to
(defun split-spatial-relation (cmd)
  (first (split-sequence:split-sequence #\, (second (split-sequence:split-sequence #\( cmd)))))

;;take(picture,small,tree) => small
(defun split-property (cmd)
  (second (split-sequence:split-sequence #\, (second (split-sequence:split-sequence #\( cmd)))))

;;move(to,small,tree) => tree
(defun split-object (cmd)
  (first (split-sequence:split-sequence #\) (third (split-sequence:split-sequence #\, (second (split-sequence:split-sequence #\( cmd)))))))


(defun direction-symbol (sym)
  (intern (string-upcase sym) "KEYWORD"))

(defun look-at-object-x (camera-pose object-pose)
  "this uses the optical-frame but the position of the cam ontop of the
quadrotor, so the rotation is on x-axis"
  (let* ((obj-point-in-camera (cl-transforms:v-
                               (cl-transforms:origin object-pose)
                               (cl-transforms:origin camera-pose)))
         (x-axis (cl-transforms:make-3d-vector 1 0 0))
         (angle (acos (/ (cl-transforms:dot-product
                          obj-point-in-camera x-axis)
                         (cl-transforms:v-norm obj-point-in-camera))))
         (rot-axis (cl-transforms:cross-product
                    x-axis obj-point-in-camera))
         (res-quaternion (cl-transforms:q*
                          (cl-transforms:axis-angle->quaternion rot-axis angle)
                          (cl-transforms:axis-angle->quaternion x-axis (* pi 2) ))));;(/ pi 2)))))
    ;;res-quaternion))
    (cl-transforms:make-pose (cl-transforms:origin camera-pose) res-quaternion)))

(defun look-at-object-y (camera-pose object-pose)
  "this uses the optical-frame but the position of the cam ontop of the
quadrotor, so the rotation is on x-axis"
  (let* ((obj-point-in-camera (cl-transforms:v-
                               (cl-transforms:origin object-pose)
                               (cl-transforms:origin camera-pose)))
         (x-axis (cl-transforms:make-3d-vector 0 1 0))
         (angle (acos (/ (cl-transforms:dot-product
                          obj-point-in-camera x-axis)
                         (cl-transforms:v-norm obj-point-in-camera))))
         (rot-axis (cl-transforms:cross-product
                    x-axis obj-point-in-camera))
         (res-quaternion (cl-transforms:q*
                          (cl-transforms:axis-angle->quaternion rot-axis angle)
                          (cl-transforms:axis-angle->quaternion x-axis (* pi 2) ))));;(/ pi 2)))))
    ;;res-quaternion))
    (cl-transforms:make-pose (cl-transforms:origin camera-pose) res-quaternion)))

;; Checking the relation of the objects. See if obj1 satisfy the
;; property towards obj2 or so... 
(defun checking-objects-relation (obj1 obj2 property)
  (let*((sem-hash (get-all-elements-with-local-tf))
        (obj1-pose (gethash obj1 sem-hash))
        (obj2-pose (gethash obj2 sem-hash))
        (tmp NIL))
    (cond ((string-equal property "behind")
         (setf tmp (and (> (cl-transforms:x (cl-transforms:origin obj1-pose))
                       (cl-transforms:x (cl-transforms:origin obj2-pose)))
                        (plusp (cl-transforms:x (cl-transforms:origin obj1-pose))))))
          ((string-equal property "in-front-of")
         (setf tmp (and (< (cl-transforms:x (cl-transforms:origin obj1-pose))
                           (cl-transforms:x (cl-transforms:origin obj2-pose)))
                        (plusp (cl-transforms:x (cl-transforms:origin obj2-pose))))))
        ((string-equal property "right")
         (setf tmp (< (cl-transforms:y (cl-transforms:origin obj1-pose))
                      (cl-transforms:y (cl-transforms:origin obj2-pose)))))
        ((string-equal property "left")
         (setf tmp (> (cl-transforms:y (cl-transforms:origin obj1-pose))
                      (cl-transforms:y (cl-transforms:origin obj2-pose)))))
        ((string-equal property "close-to")
         (if (>= 4 (get-distance obj1-pose obj2-pose))
             (setf tmp T)
             (setf tmp NIL)))
        ((or (string-equal property "to")
              (string-equal property "around"))
         (if (>= 20 (get-distance obj1-pose obj2-pose))
             (setf tmp T)
             (setf tmp NIL))))
    tmp))

;; Getting all the tf-data of the elements in the world
;; based on the human operator and giving a hash-table
;; with these object names and positions back
(defun get-all-elements-with-local-tf ()
  (let* ((sem-map (sem-map-utils:get-semantic-map))
        (sem-hash (slot-value sem-map 'sem-map-utils:parts))
         (sem-keys (hash-table-keys sem-hash))
       ;;  (semm-hash (copy-hash-table sem-hash))
         (new-hash (make-hash-table))(name NIL)
         (obj-pose NIL))
    (dotimes (index (length sem-keys))
      (setf name (format NIL "~a_link" (nth index sem-keys)))

      (setf obj-pose (cl-transforms-stamped:transform->pose (cl-tf:lookup-transform *tf* "human" name)))
  
      (setf (gethash (nth index sem-keys) new-hash) obj-pose))

    (copy-hash-table new-hash)))

(defun get-smallest-of-liste (liste)
  (let*((checker 1000)
        (elem NIL))
    (dotimes (index (length liste))
      (cond ((<= (parse-integer (second (split-sequence:split-sequence #\: (nth index liste)))) checker)
             (setf checker (parse-integer (second (split-sequence:split-sequence #\: (nth index liste)))))
             (setf elem(nth index liste)))))
    elem))

           
(defun reset-map-frame ()
  (setf cram-tf:*fixed-frame* "map")
  cram-tf:*fixed-frame*)

(defun set-map-frame ()
  (setf cram-tf:*fixed-frame* "human")
  cram-tf:*fixed-frame*)

(defun give-pointed-obj-based-on-language-obj (obj vec)
  ;;(publish-pose-color (get-gesture->relative-world  vec (tf-human-to-map)) (cl-transforms:make-3d-vector 1 1 0))  
  (let((liste (give-pointed-at-not-bboxes vec))
       (elem NIL))
    (dotimes (index (length liste))
      (if (and (equal elem NIL)
           (string-equal (get-elem-type (nth index liste)) obj))
          (setf elem  (nth index liste))))
    (cond((equal elem NIL)
          (let ((new-liste (get-element-with-ground-calculation-based-on-gesture vec)))
            (dotimes (jindex (length new-liste))
                (if (string-equal (get-elem-type (nth jindex new-liste)) obj)
                    (setf elem  (nth jindex liste)))))))
    (if (equal NIL elem)
        (setf elem (get-specific-elem-closeto-human obj)))
    elem))

(defun get-specific-elem-closeto-human (objtype)
  (let*((elems (get-elements-infrontof-human-with-distance 30))
        (liste '())
        (elem NIL))
    (dotimes (index (length elems))
      (setf elem (first (split-sequence:split-sequence #\: (nth index elems))))
      (if (string-equal (get-elem-type elem) objtype)
          (setf liste (cons (nth index elems) liste))))
      (if (not (equal liste NIL))
          (setf elem (get-smallest-of-liste liste))
          (setf elem "No element found in near"))
   (first (split-sequence:split-sequence #\: elem))))
        

(defun fill-desig-property-list (loc)
   (let ((desig-properties (desig:properties loc))
        (desig NIL)
        (e-elem NIL)(z-elem NIL) (d-elem NIL)
        (liste NIL))
     ;;if property-list includes one key,e.g. ((:right tree))
     (cond ((= 1 (length desig-properties))
            ;;if tree is the type not name calculate nearest obj else proceed with name
            (if (null (get-elem-pose (second (first desig-properties))))
                (setf e-elem (get-value-basedon-type->get-objects-infrontof-human (second (first desig-properties))))
                (setf e-elem (second (first desig-properties))))
            (setf liste (list (list (first (first desig-properties)) e-elem)))
            (setf desig (make-designator :location liste)))
           ;;if property-list includes two key,e.g. ((:right tree)(:left rock))
           ((= 2 (length desig-properties))
            ;;if tree is not name and rock is not name calculate both
            (cond ((and (null (get-elem-pose (second (first desig-properties))))
                        (null (get-elem-pose (second (second desig-properties)))))
                   (setf liste (get-objs-based-on-relation-towards-other-obj
                                (second (second desig-properties))
                                (first (first desig-properties))
                                (second (first desig-properties))))
                   (setf e-elem (first liste))
                   (setf z-elem (second liste)))
                  ;;if tree is a type and rock is a name
                  ((and (null (get-elem-pose (second (first desig-properties))))
                        (not (null (get-elem-pose (second (second desig-properties))))))
                   (setf e-elem (get-objname-based-on-property-and-objname2
                                 (first (first desig-properties))
                                 (second (first desig-properties))
                                 (second (second desig-properties))))
                   (setf z-elem (second (second desig-properties))))                                ;;if tree is name and rock is type
                  ((and (not (null (get-elem-pose (second (first desig-properties)))))
                        (null (get-elem-pose (second (second desig-properties)))))
                   (setf e-elem (second (first desig-properties))) 
                   (setf z-elem (calculate-the-specific-object
                                 e-elem
                                 (first (first desig-properties))
                                 (second (second desig-properties)))))
                  ;;if both are names
                  (t (setf e-elem (second (first desig-properties)))
                     (setf z-elem (second (second desig-properties)))))
            (setf liste (list (list (first (first desig-properties)) e-elem)
                              (list (first (second desig-properties)) z-elem)))
           (setf desig (make-designator :location liste)))
           ;; property-list e.g. ((:right tree)(:left rock)(:to house))
           ((= 3 (length desig-properties))
                ;;if tree, rock and house are not names
            (cond ((and (null (get-elem-pose (second (first desig-properties))))
                        (null (get-elem-pose (second (second desig-properties))))
                        (null (get-elem-pose (second (third desig-properties)))))
                   (setf liste (get-objs-based-on-relation-towards-other-obj
                                (second (second desig-properties))
                                (first (first desig-properties))
                                (second (first desig-properties))))
                   (setf e-elem (first liste))
                   (setf z-elem (second liste))
                   (setf d-elem (calculate-the-specific-object
                                 z-elem
                                 (first (second desig-properties))
                                 (second (third desig-properties)))))
                  ;;if tree is name and the others not
                  ((and (not (null (get-elem-pose (second (first desig-properties)))))
                        (null (get-elem-pose (second (second desig-properties))))
                        (null (get-elem-pose (second (third desig-properties)))))
                   (setf e-elem (second (first desig-properties)))
                   (setf z-elem (calculate-the-specific-object
                                 e-elem
                                 (first (first desig-properties))
                                 (second (second desig-properties))))
                   (setf d-elem (calculate-the-specific-object
                                 z-elem
                                 (first (second desig-properties))
                                 (second (third desig-properties)))))
                  ;;if rock is name and the others not
                   ((and (null (get-elem-pose (second (first desig-properties))))
                         (not (null (get-elem-pose (second (second desig-properties)))))
                        (null (get-elem-pose (second (third desig-properties)))))
                    (setf e-elem (get-objname-based-on-property-and-objname2
                                 (first (first desig-properties))
                                 (second (first desig-properties))
                                 (second (second desig-properties))))
                    (setf z-elem (second (second desig-properties)))
                    (setf d-elem (calculate-the-specific-object
                                  z-elem
                                  (first (second desig-properties))
                                  (second (third desig-properties)))))
                   ;;if house is name and the others not
                    ((and (null (get-elem-pose (second (first desig-properties))))
                          (null (get-elem-pose (second (second desig-properties))))
                          (not (null (get-elem-pose (second (third desig-properties))))))
                     (setf d-elem (second (third desig-properties)))
                     (setf z-elem (get-objname-based-on-property-and-objname2
                                   (first (second desig-properties))
                                   (second (second desig-properties))
                                 d-elem))
                     (setf e-elem (get-objname-based-on-property-and-objname2
                                 (first (first desig-properties))
                                 (second (first desig-properties))
                                 z-elem)))
                    ;; if two first are names
                    ((and (not (null (get-elem-pose (second (first desig-properties)))))
                          (not (null (get-elem-pose (second (second desig-properties)))))
                           (null (get-elem-pose (second (third desig-properties)))))
                     (setf e-elem (second (first desig-properties)))
                     (setf z-elem (second (second desig-properties)))
                     (setf d-elem (calculate-the-specific-object
                                   z-elem
                                   (first (second desig-properties))
                                   (second (third desig-properties)))))
                    ;; if first and third are names
                    ((and (not (null (get-elem-pose (second (first desig-properties)))))
                          (null (get-elem-pose (second (second desig-properties))))
                          (not (null (get-elem-pose (second (third desig-properties))))))
                     (setf e-elem (second (first desig-properties)))
                     (setf d-elem (second (third desig-properties)))
                     (setf z-elem (calculate-the-specific-object
                                   e-elem
                                   (first (first desig-properties))
                                   (second (second desig-properties)))))
                    ;;if second and third are names
                    ((and (null (get-elem-pose (second (first desig-properties))))
                          (not (null (get-elem-pose (second (second desig-properties)))))
                          (not (null (get-elem-pose (second (third desig-properties))))))
                     (setf z-elem  (second (second desig-properties)))
                     (setf d-elem  (second (third desig-properties)))
                     (setf e-elem (get-objname-based-on-property-and-objname2
                                   (first (first desig-properties))
                                   (second (first desig-properties))
                                   z-elem)))
                    (t  (setf z-elem  (second (second desig-properties)))
                        (setf d-elem  (second (third desig-properties)))
                        (setf e-elem  (second (third desig-properties)))
                   (setf z-elem (second (second desig-properties)))))        
                     
                           
            (setf liste (list (list (first (first desig-properties)) e-elem)
                                      (list (first (second desig-properties)) z-elem)
                                       (list (first (third desig-properties)) d-elem)))
           (setf desig (make-designator :location liste))))desig))

(defun cam-get-pose->relative-map (vec)
(let((pose-stmp (cl-transforms-stamped:make-pose-stamped "camera_depth_frame"
                                                         0.0 vec
                                                         (cl-transforms:make-identity-rotation))))
  (cl-transforms-stamped:pose-stamped->pose (cl-tf:transform-pose *tf* :pose pose-stmp :target-frame "map"))))

(defun create-logged-designator (msgs)
  (let ((action_list '()))
  (loop for index being the elements of msgs
           do (let ((property_list NIL)
                    (loc_desig NIL)
                    (action (std_msgs-msg:data (instructor_mission-msg:action_type index)))
                    (propliste (instructor_mission-msg:propkeys index)))
                (if (string-equal action "show")
                    (setf action "show-picture"))
                (loop for jndex being the elements of propliste
                      do(let((pointing NIL) (obj NIL)
                             (spatial
                               (std_msgs-msg:data (instructor_mission-msg:spatial_relation jndex)))
                             (object
                               (std_msgs-msg:data (instructor_mission-msg:language_object jndex)))
                             (flag
                               (std_msgs-msg:data (instructor_mission-msg:flag jndex))))
                          (if(and (string-equal spatial "null")
                                  (not (string-equal "null" object)))
                             (setf spatial "ontop"))
                          (cond ((not (and (string-equal "null" object)
                                           (string-equal "null" spatial)))
                                 (cond((string-equal flag "true")
                                       (setf pointing (cl-transforms:make-3d-vector
                                                       (geometry_msgs-msg:x
                                                        (instructor_mission-msg:pointing_gesture jndex))
                                                       (geometry_msgs-msg:y
                                                        (instructor_mission-msg:pointing_gesture jndex))
                                                       (geometry_msgs-msg:z
                                                        (instructor_mission-msg:pointing_gesture jndex))))
                                       (setf obj (give-pointed-obj-based-on-language-obj object pointing)))
                                      (t (setf obj NIL)))
                            (if (equal obj NIL)
                                (setf obj object))                        
                            (setf property_list (append (list (list (direction-symbol spatial) obj)) property_list))))))
                (cond((not (equal NIL property_list))
                      (setf loc_desig (make-designator :location property_list))
                      (setf action_list (append action_list (list (make-designator :action `((:type ,action)
                                                                                       (:loc ,loc_desig)))))))
                     (t (setf action_list (append action_list (list (make-designator :action `((:type ,action))))))))))
    action_list))


                
 (defun gazebo-functions (newliste)
   (dotimes (index (length newliste))
     do(let((pose  (desig-prop-value (nth index newliste) :loc)))
         (cond((string-equal "move" (desig-prop-value (nth index newliste) :type))
               (setf value (forward-movecmd-to-gazebo (cl-transforms:x (cl-transforms:origin pose))
                                                             (cl-transforms:y (cl-transforms:origin pose))
                                                             (cl-transforms:z (cl-transforms:origin pose))
                                                             (cl-transforms:x (cl-transforms:orientation pose))
                                                             (cl-transforms:y (cl-transforms:orientation pose))
                                                             (cl-transforms:z (cl-transforms:orientation pose))
                                                             (cl-transforms:w (cl-transforms:orientation pose))))
               (let((quad-pose (cl-transforms:transform->pose (cl-tf:lookup-transform *tf* "map" "base_footprint"))))
                      (setf new-quad-pose (look-at-object-x (cl-transforms:make-pose (cl-transforms:origin quad-pose)(cl-transforms:orientation (cl-transforms:transform->pose (cam-depth-tf-transform)))) *obj-pose*))
                 (setf rotation-cmd (forward-rotatecmd-to-gazebo new-quad-pose))))
              ((and (string-equal "take-picture" (desig-prop-value (nth index newliste) :type))
                    (equal NIL (desig-prop-value (nth index newliste) :loc)))
               (setf *value* (forward-takecmd-to-gazebo "go")))
              ((and (string-equal "take-picture"   (desig-prop-value (nth index newliste) :type))
                    (not (null (desig-prop-value (nth index newliste) :loc))))
               (setf pose (desig-prop-value (nth index newliste) :loc))
               (setf value (forward-movecmd-to-gazebo (cl-transforms:x (cl-transforms:origin pose))
                                                      (cl-transforms:y (cl-transforms:origin pose))
                                                      (cl-transforms:z (cl-transforms:origin pose))
                                                      (cl-transforms:x (cl-transforms:orientation pose))
                                                      (cl-transforms:y (cl-transforms:orientation pose))
                                                      (cl-transforms:z (cl-transforms:orientation pose))
                                                      (cl-transforms:w (cl-transforms:orientation pose))))
               (let((quad-pose (cl-transforms:transform->pose (cl-tf:lookup-transform *tf* "map" "base_footprint"))))
                 (setf new-quad-pose (look-at-object-x (cl-transforms:make-pose (cl-transforms:origin quad-pose)(cl-transforms:orientation (cl-transforms:transform->pose (cam-depth-tf-transform)))) *obj-pose*))
                 (setf rotation-cmd (forward-rotatecmd-to-gazebo new-quad-pose)))
               (roslisp:wait-duration 2)
               (setf *value* (forward-takecmd-to-gazebo "go")))
               ((and (or (string-equal "show"  (desig-prop-value (nth index newliste) :type))
                      (string-equal "show-picture"  (desig-prop-value (nth index newliste) :type)))
                    (equal (desig-prop-value (nth index newliste) :loc) NIL))
                (cond((or (string-equal *value* "") (string-equal *value* "value"))
                      (setf *value* (forward-takecmd-to-gazebo "go"))
                      (roslisp:wait-duration 2)
                      (setf value (forward-showcmd-to-gazebo *value*)))
                     (t (roslisp:wait-duration 2)
                        (setf value (forward-showcmd-to-gazebo *value*)))))
                ((and (or (string-equal "show"  (desig-prop-value (nth index newliste) :type))
                      (string-equal "show-picture"  (desig-prop-value (nth index newliste) :type)))
                  (not (equal (desig-prop-value (nth index newliste) :loc) NIL)))
             (setf pose (desig-prop-value (nth index newliste) :loc))
             (setf value (forward-movecmd-to-gazebo (cl-transforms:x (cl-transforms:origin pose))
                                                     (cl-transforms:y (cl-transforms:origin pose))
                                                     (cl-transforms:z (cl-transforms:origin pose))
                                                     (cl-transforms:x (cl-transforms:orientation pose))
                                                     (cl-transforms:y (cl-transforms:orientation pose))
                                                     (cl-transforms:z (cl-transforms:orientation pose))
                                                     (cl-transforms:w (cl-transforms:orientation pose))))
             (let((quad-pose (cl-transforms:transform->pose (cl-tf:lookup-transform *tf* "map" "base_footprint"))))
               (setf new-quad-pose (look-at-object-x (cl-transforms:make-pose (cl-transforms:origin quad-pose)(cl-transforms:orientation (cl-transforms:transform->pose (cam-depth-tf-transform)))) *obj-pose*))
                (setf rotation-cmd (forward-rotatecmd-to-gazebo new-quad-pose)))
             (roslisp:wait-duration 2)       
              (setf *value* (forward-takecmd-to-gazebo "go"))
                   (roslisp:wait-duration 2)
                   (setf value (forward-showcmd-to-gazebo *value*)))))))
