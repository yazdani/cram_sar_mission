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

;; This function is checking if the instructions are
;; based on 'take' and 'move' actions and is forwarding
;; them to the correct function calls
;; It returns a list of (action location objname)
(defun parsing-instruction (cmd)
  (let*((seqs (split-sequence:split-sequence #\; cmd))
        (desig NIL)
        (elem NIL)
        (property NIL)
        (tmp-desig NIL)(tmp-liste NIL)(tmp-value NIL)
        (sequences '()))
    (dotimes (index (length seqs))
       (cond((string-equal (split-action (nth index seqs)) "show")
             (setf desig (list "show" NIL NIL)))                         
            ((string-equal (split-action (nth index seqs)) "move")
             (setf tmp-liste (car (multiple-desig-move index seqs elem property)))
             (setf elem (second tmp-liste))
             (setf property (third tmp-liste))
             (setf tmp-desig (first tmp-liste))
             (setf desig (list "move"
                           (reference-by-human-frame tmp-desig elem)
                                              elem)))           
            ((and (string-equal (split-action (nth index seqs)) "take")
                  (not (= index (- (length seqs) 1)))
                  (string-equal "show" (split-action (nth (+ index 1) seqs))))
                (setf desig (list "take" NIL NIL)))
                 ((string-equal (split-action (nth index seqs)) "take")
             (cond ((= index (- (length seqs) 1)) ;;if there exist just one take
    
                 (cond((string-equal "NIL" (split-object (nth index seqs))) ;;if (take, NIL, NIL)
                     (setf desig  (list (list "take" NIL NIL))))
                      ((string-equal elem NIL) ;; if prev elem==NIL
                       (setf tmp-value (get-value-basedon-type->get-objects-infrontof-human (split-object (nth index seqs))))
                       (setf tmp-desig (one-desig-take (nth index seqs) elem property))
                       (setf desig (list (list
                                          "take"
                                           (reference-by-human-frame tmp-desig
                                                                    tmp-value)
                                          (get-value-basedon-type->get-objects-infrontof-human
                                    (split-object (nth index seqs)))))))
                      (t (setf tmp-value (get-obj-located-obj-with-depend-property elem (split-object (nth index seqs)) property))
                       (setf tmp-desig (make-designator :location `((:to ,tmp-value))))                         
                       (setf desig (list (list
                                          "take"
                                           (reference-by-human-frame tmp-desig tmp-value) 
                                             tmp-desig))))))
                   (t 
                    (setf tmp-desig (multiple-desig-take index seqs elem property))
                    (setf tmp-value (get-value-basedon-type->get-objects-infrontof-human (split-object (nth (+ index 1) seqs))))
                 (setf desig (list (list (split-action (nth index seqs))
                                          (reference-by-human-frame tmp-desig
                                                                    tmp-value)
                                          (get-obj-located-obj-with-depend-property elem (split-object (nth (+ index 1) seqs)) property)      
                                       )))))
             (dotimes (jindex (length desig))
               (setf sequences (cons (nth jindex desig) sequences)))
             (return))
            (t (setf property NIL)
               (setf desig NIL)
               (setf elem NIL)))
     
      (setf sequences (cons desig sequences)))
   (reverse sequences)))


(defun parser-instruction (seqs)
 (let*((cmd (split-sequence:split-sequence #\; seqs))
       (elem NIL)
       (action NIL)
       (all NIL)
       (referenced-desig NIL)
       (designator-list NIL)
       (property NIL))
   (dotimes (index (length cmd))
     (cond ((string-equal "take" (split-action (nth index cmd)))
            (setf all (take-sequence cmd index elem property designator-list))
            (format t "all is ~a~%" all)
            (setf designator-list (first all))
            (setf elem (second all))
            (setf action (fourth all))
            (setf property (third all)))
           ((string-equal "move" (split-action (nth index cmd)))
            (setf all (move-sequence cmd index elem property designator-list))
            (setf designator-list (first all))
            (setf elem (second all))
            (setf action (fourth all))
            (setf property (third all)))
           ((string-equal "show" (split-action (nth index cmd)))
            (setf action "show"))))
    (format t "~a jkdjkdjd~%"(type-of  designator-list))
   (if (not (equal (type-of designator-list) 'cons))
       (if (not(equal designator-list NIL))
           (setf referenced-desig (reference-by-human-frame designator-list elem))))
   (format t "end parser instruction ~%")
   (list action referenced-desig)))   

(defun move-sequence (action-list index elem property desig-list)
  (let ((compute-gesture NIL)
        (desig NIL))
    (cond((= 1 (length action-list)) ;;If action-list includes one action
          (if (string-equal (split-property (first action-list)) "pointed_at")
              (setf compute-gesture NIL) ;;TODO: Calculating pointing gesture
              (setf compute-gesture (get-value-basedon-type->get-objects-infrontof-human (split-object (nth index action-list)))));;Otherwiese: Calculating all then objects in-front-of humans
          (setf property (split-spatial-relation (nth index action-list)))
          (setf elem compute-gesture)
          (setf desig-list (list (make-designator :location `((,(direction-symbol (split-spatial-relation (nth index action-list))) ,elem))) elem property "move"))) ;;(designator, desig-props, element, property)
         (t (cond((equal elem NIL) ;;If elem is nill, happens when asking the first elem of list
                   (if (string-equal (split-property (nth index action-list)) "pointed_at")
                       (setf elem NIL) ;;TODO: Calculating pointing gesture
                       (setf elem (get-value-basedon-type->get-objects-infrontof-human (split-object (nth index action-list)))));;Otherwiese: Calculating all then objects in-front-of humans
                  (setf property (split-spatial-relation (nth index action-list)))
                  (setf desig-list (list (make-designator :location`((,(direction-symbol property) ,elem))) elem property "move")))
                 (t
                  (if (string-equal (split-property (nth index action-list)) "pointed_at")
                       (setf elem NIL) ;;TODO: Calculating pointing gesture
                       (setf elem (get-obj-located-obj-with-depend-property elem (split-object (nth index action-list)) property)))
                  (setf property (split-spatial-relation (nth index action-list)))
                  (setf desig (append (desig:properties desig-list) (list (list (direction-symbol property) elem))))
                  (setf desig-list (list (make-designator :location desig) elem property "move"))))))
    (format t "desig-list ~a~%" desig-list)
    desig-list))
          
(defun take-sequence (action-list index elem property desig-list)
  (format t "take-sequence ~a~%" action-list)
  (let ((compute-gesture NIL)
        (desig NIL))
    (cond((= 1 (length action-list)) ;;take(pic NIL NIL) or take(pic NIL tree) or take(pic pointed tree)
          (cond((string-equal "NIL" (split-object (nth index action-list)))
                (setf desig-list (list desig-list elem property "take")))
               (t
                (if (string-equal (split-property (first action-list)) "pointed_at")
                    (setf compute-gesture NIL) ;;TODO: Calculating pointing gesture
                    (setf compute-gesture (get-value-basedon-type->get-objects-infrontof-human (split-object (nth index action-list))))) 
                (setf elem compute-gesture)
                (setf desig-list (list (make-designator :location `((:to ,elem))) elem property "take")))))
         (t ;;take(pic NIL NIL):+ or +;take(pic NIL NIL) or +;take(pic NIL tree) or take(pic NIL tree);+ or take(pic pointed tree);+ etc.
          (cond((equal NIL elem) ;; take(pic NIL NIL):++++
                (cond((string-equal "NIL" (split-object (nth index action-list))) ;;take(pic NIL NIL);++++
                      (setf desig-list (list desig-list elem property "take")))
                     (t ;;take(pic pointed/NIL tree);++++
                      (if (string-equal (split-property (first action-list)) "pointed_at")
                          (setf compute-gesture NIL)
                          (setf compute-gesture (get-value-basedon-type->get-objects-infrontof-human (split-object (nth index action-list)))))
                      (setf elem compute-gesture)
                      (cond((and (string-equal (split-spatial-relation (nth index action-list)) "picture")
                                 (not (string-equal (split-spatial-relation (nth index action-list)) "NIL")))
                            (setf desig (list (list (direction-symbol "to") elem)))
                            (setf property "to")
                            (setf desig-list (list (make-designator :location desig) elem property "take")))
                           ((and (string-equal (split-spatial-relation (nth index action-list)) "picture")
                                (string-equal (split-spatial-relation (nth index action-list)) "NIL"))
                            (setf desig-list (list desig-list NIL NIL "take")))
                           (t
                             (setf property (split-spatial-relation (nth index action-list)))
                             (cond((equal desig-list NIL)
                                   (setf desig-list (list  (make-designator :location `((,(direction-symbol property) ,elem))) elem property "take")))
                                  (t
                                   (setf desig (append (desig:properties desig-list) (list (list (direction-symbol property) elem))))
                                   (setf desig-list (list (make-designator :location desig) elem property "take"))))
                                 )))))
               (t ;;++++;take(pic pointed/NIL NIL) or ++++;take(right pointed/NIL tree
                   (cond((string-equal "picture" (split-spatial-relation (nth index action-list)))
                      (if (string-equal (split-property (first action-list)) "pointed_at")
                          (setf elem NIL)
                          (if(not (string-equal "NIL" (split-object (nth index action-list))))
                             (if (not (string-equal (split-object (nth index action-list)) (get-elem-type elem)))
                                 (setf elem (get-obj-located-obj-with-depend-property elem (split-object (nth index action-list)) property)))
                             (setf desig "test")))
                         (setf property "to")
                         (format t "liste ~a~% ~a~% ~a~%"  (split-object (nth index action-list))
                             (get-elem-type elem) property)    
                      (if (string-equal desig "test")
                          (setf desig (desig:properties desig-list))
                          (setf desig (append (desig:properties desig-list) (list (list (direction-symbol property) elem)))))
                      (setf desig-list (list (make-designator :location desig) elem property "take")))
                     (t ;;++++;take(right pointed/NIL tree
                      (if (string-equal (split-property (first action-list)) "pointed_at")
                          (setf elem NIL)
                          (if (string-equal (split-object (nth index action-list)) (get-elem-type elem))
                              (setf elem elem)
                              (setf elem (get-obj-located-obj-with-depend-property elem (split-object (nth index action-list)) property))))
                      (setf property  (split-spatial-relation (nth index action-list)))
                      (setf desig (append (desig:properties desig-list) (list (list (direction-symbol property) elem))))
                      (setf desig-list (list (make-designator :location desig) elem property "take"))))))))
         desig-list))


(defun get-objects-infrontof-human ()
(let((liste '())
      (sem-map (sem-map-utils:get-semantic-map))
      (aliste '()))
  (dotimes (index 80)
    (if (>= 30 (length liste))
        (setf liste (get-elements-infrontof-human-with-distance index)) 
        (return)))
  (reverse liste)))

(defun get-elements-infrontof-human-with-distance (num)
  (let* ((sem-map (sem-map-utils:get-semantic-map))
         (sem-hash (slot-value sem-map 'sem-map-utils:parts))
         (sem-keys (hash-table-keys sem-hash))
         (poses '()) (dist NIL) (liste '())
         (pub NIL)(obj-pub NIL)(obj-pose NIL) (obj-map NIL)(obj-pose2))
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
    ;; (format t "all poses: ~a~%" poses)
       poses))


  
(defun tf-human-to-map ()
  (cl-transforms:transform->pose (tf:lookup-transform *tf* "map" "human")))

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
;;(format t " und ~a und ~a~%" desig objname)
  (let*((result NIL)
        (cam (cam-depth-tf-transform))
        (temp NIL)
        (tmp NIL)
        (tom NIL))
    (setf cram-tf:*fixed-frame* "human")
    (cond((not(equal NIL desig))
          (setf result (reference desig))
          (if (equal *puby* NIL)
              ()
              (remove-local-tf-publisher *puby*))
                   
          (setf temp (look-at-object-x (cl-transforms:make-pose (cl-transforms:origin (cl-transforms-stamped:pose-stamped->pose result)) (cl-transforms:orientation (cl-transforms:transform->pose cam)))  (get-human-elem-pose objname)))

          (setf tmp (cl-transforms-stamped:make-pose-stamped "human"
                                                             0.0 (cl-transforms:origin temp)
                                                             (cl-transforms:orientation temp)))

          (setf tom (cl-transforms-stamped:pose-stamped->pose (cl-tf:transform-pose *tf* :pose tmp :target-frame "map")))
        (setf *puby* (create-local-tf-publisher tom "test")))
         (t ()))

    tom))

(defun cam-depth-tf-transform ()
  (cl-transforms-stamped:lookup-transform *tf* "human" "camera_depth_frame"))

(defun create-local-tf-publisher (robot-pose name)
   (let*((pub (cl-tf:make-transform-broadcaster)))
 (cl-tf:send-static-transforms pub 1.0 "quadpose" (cl-transforms-stamped:make-transform-stamped "map" name (roslisp:ros-time) (cl-transforms:origin robot-pose) (cl-transforms:orientation robot-pose)))))

(defun remove-local-tf-publisher (thread)
  (when (sb-thread:thread-alive-p thread)
    (handler-case
        (prog1 t (sb-thread:terminate-thread thread))
      (error () nil))))


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
         (semm-hash (copy-hash-table sem-hash))
         (new-hash (make-hash-table))(name NIL)
         (pub NIL)(pose NIL)(obj-pub NIL)(obj-pose NIL))
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


(defun correct-parsing (full-command)
   (let*((sequences (split-sequence:split-sequence #\; full-command))
         (element NIL)
         (action NIL)
         (all NIL)
         (referenced-designator NIL)
         (designator-property-list NIL)
         (spatial-relation NIL))
   (dotimes (index (length sequences))
     (format t "sequences ~a~%" (nth index sequences))
     (cond ((string-equal "move" (split-action (nth index sequences)))
            (format t "move entering~%")
            (setf all (move-action (nth index sequences) designator-property-list))
            (setf designator-property-list (third all))
            (format t "all is ~a~%" all))
           ((string-equal "take" (split-action (nth index sequences)))
            (format t "take entering~%"))
           ((string-equal "show" (split-action (nth index sequences)))
            (format t "show entering~%"))
     ))
     
  ))

(defun move-action (action-list desig-list)
  (let((action (split-action action-list))
       (spatial-property (split-spatial-relation action-list))
       (element (split-object action-list))
       (desig-prop-list NIL))
    (if(not(equal desig-list NIL))
       (setf desig-prop-list (append (list (list (direction-symbol spatial-property) element))  desig-list))
       (setf desig-prop-list (list (list (direction-symbol spatial-property) element))))
    (list  action (make-designator :location desig-prop-list) desig-prop-list)))

(defun take-action (sequences index element spatial-relation designator-property-list)
  )

(defun show-action (sequences index element spatial-relation designator-property-list)
  )
