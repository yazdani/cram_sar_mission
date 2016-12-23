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

;;;
;;; Get all elements in front of human by a distance
;;;
(defun get-elems-agent-front-by-dist ()
  ;;(format t "get-elems-agent-front-by-dist~%")
  (let* ((sem-hash (slot-value *sem-map* 'sem-map-utils:parts))
         (sem-keys (hash-table-keys sem-hash))
         (viewpoint "human")
         (poses '()))
    (dotimes (index (length sem-keys))
      (let*((pose (get-elem-by-pose (nth index sem-keys)))
            (pub (cl-tf:set-transform *tf* (cl-transforms-stamped:make-transform-stamped "map" (nth index sem-keys) (roslisp:ros-time) (cl-transforms:origin pose) (cl-transforms:orientation pose))))
            (obj-pose2 (cl-transforms-stamped:transform->pose (cl-tf:lookup-transform *tf* "map" (nth index sem-keys))))
            (obj-pose (cl-transforms-stamped:transform->pose (cl-tf:lookup-transform *tf* viewpoint (nth index sem-keys))))   
            (dist (get-distance (tf-human-to-map) obj-pose2)))
      (if (and (>= 40 dist)
               (plusp (cl-transforms:x (cl-transforms:origin obj-pose))))
               (setf poses (append (list (format NIL"~a:~a" (nth index sem-keys) dist)) poses)))))
       (sort-list poses)))

;;;
;;; Calculates the distance of two poses
;;;
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

;;;
;;; Get the type of the elem
;;; @name: Get the elemtype by name
;;;
(defun get-elem-by-type (name)
 (let*((type NIL)
       (sem-hash (slot-value *sem-map* 'sem-map-utils:parts))
       (new-hash (copy-hash-table sem-hash))
       (sem-keys (hash-table-keys sem-hash)))
       (dotimes(i (length sem-keys))
         (if(string-equal name (nth i sem-keys))
            (cond ((search "tree" (slot-value (gethash name new-hash)
                                                        'cram-semantic-map-utils::type))
                   (setf type "tree"))
                  ((search "rock" (slot-value (gethash name new-hash)
                                                        'cram-semantic-map-utils::type))
                   (setf type "rock"))
                  ((search "pylon" (slot-value (gethash name new-hash)
                                                        'cram-semantic-map-utils::type))
                   (setf type "pylon"))
                  ((search "house" (slot-value (gethash name new-hash)
                                                        'cram-semantic-map-utils::type))
                   (setf type "house"))
                  (t (setf type (slot-value (gethash name new-hash)
                                                        'cram-semantic-map-utils::type))))))
   type))


(defun get-elem-by-bboxsize (objname)
   (let*((sem-hash (slot-value *sem-map* 'sem-map-utils:parts))
         (new-hash (copy-hash-table sem-hash))
         (dim (slot-value (gethash objname new-hash) 'sem-map-utils:dimensions))
         (dim-x (cl-transforms:x dim))
         (dim-y (cl-transforms:y dim))
         (dim-z (cl-transforms:z dim)))
     ;;(format t "size ~a~%"  (+ dim-x dim-y dim-z))
   (+ dim-x dim-y dim-z)))
           


(defun get-elem-by-pose (objname)
 (let*((pose NIL)
       (sem-hash (slot-value *sem-map* 'sem-map-utils:parts))
       (new-hash (copy-hash-table sem-hash))
       (sem-keys (hash-table-keys sem-hash)))
       (dotimes (i (length sem-keys))
         do(if (string-equal objname (nth i sem-keys))
               (setf pose (slot-value (gethash objname new-hash) 'sem-map-utils:pose))
               (format t "")))
   pose))

(defun direction-symbol (sym)
  (intern (string-upcase sym) "KEYWORD"))


;;;
;;; 
;;;
(defun get-next-elem-depend-on-prev-elem (typ spatial name)
  ;;(format t "typ ~a~% spatial ~a~% name ~a~%" typ spatial name)
  (let*((liste (get-elems-of-semmap-by-type typ))
        (resultlist '())
        (result NIL))
   ;;(format t "liste ~a~%" liste)
    ;;(format t "typ ~a~% spatial ~a~% name ~a~%" typ spatial name)
   (dotimes (index (length liste))
       (format t "hieer ~%")
     (if (and (not (null (checker-elems-by-relation->get-elems-by-tf
                   (nth index liste) name spatial)))
              (> 5 (get-distance (get-elem-by-pose name) (get-elem-by-pose (nth index liste)))))
         (setf resultlist (append resultlist (list 
                                                   (format NIL "~a:~a"(nth index liste)
                                                           (get-distance
                                                            (get-elem-by-pose
                                                             (nth index liste))
                                                            (get-elem-by-pose name))))))))
    ;;(format t "resultlist ~a~%" resultlist)
    (if (null resultlist)
        (setf result NIL)
        (setf result  (sort-list resultlist)))
    ;;(format t "elem result ~a~%" result)
    result))

(defun get-next-elem-depend-on-prev-elem-no-con (typ spatial name)
 ;; (format t "typ ~a~% spatial ~a~% name ~a~%" typ spatial name)
  (let*((liste (get-elems-of-semmap-by-type typ))
        (resultlist '())
        (result NIL))
   ;; (format t "liste ~a~%" liste)
   ;; (format t "typ ~a~% spatial ~a~% name ~a~%" typ spatial name)
   (dotimes (index (length liste))
       
     (if (not (null (checker-elems-by-relation->get-elems-by-tf
                   (nth index liste) name spatial)))
         (setf resultlist (append resultlist (list 
                                              (format NIL "~a:~a"(nth index liste)
                                                      (get-distance
                                                       (get-elem-by-pose
                                                        (nth index liste))
                                                       (get-elem-by-pose name))))))))
    (setf result (sort-list resultlist))
   ;; (format t "elem result ~a~%" result)
    result))

(defun get-prev-elem-depend-on-next-elem-no-con (typ spatial name)
 ;; (format t "typ ~a~% spatial ~a~% name ~a~%" typ spatial name)
  (let*((liste (get-elems-of-semmap-by-type typ))
        (resultlist '())
        (result NIL))
   (dotimes (index (length liste))
     (if (not (null (checker-elems-by-relation->get-elems-by-tf
                    name (nth index liste) spatial)))
         (setf resultlist (append resultlist (list 
                                              (format NIL "~a:~a"(nth index liste)
                                                      (get-distance
                                                       (get-elem-by-pose
                                                        (nth index liste))
                                                       (get-elem-by-pose name))))))))
    (setf result (sort-list resultlist))
    ;;(format t "elem result ~a~%" result)
    result))

(defun get-prev-elem-depend-on-next-elem (typ spatial name)
  ;;(format t "get-next-elem ~a~%"name)
 (let*((liste (get-elems-of-semmap-by-type typ))
       (resultlist '()))
   (dotimes (index (length liste))
   ;;  (format t "get-next-elem ~a~%" (nth index liste))
        (if  (and (not (null (checker-elems-by-relation->get-elems-by-tf
                   name (nth index liste) spatial)))
                  (> 5 (get-distance (get-elem-by-pose name) (get-elem-by-pose (nth index liste)))))
         (setf resultlist (append resultlist (list 
                                                   (format NIL "~a:~a"(nth index liste)
                                                           (get-distance
                                                            (get-elem-by-pose
                                                             (nth index liste))
                                                            (get-elem-by-pose name))))))))
   ;;(format t "neue luste ~a~%" resultlist)
   (first (split-sequence:split-sequence #\: (first (sort-list resultlist))))))

(defun get-elems-of-semmap-by-type (type)
 ;; (format t "get-elems-of-semmap-by-type ~a~%" type)
  (let*((sem-hash (slot-value *sem-map* 'sem-map-utils:parts))
       (sem-keys (hash-table-keys sem-hash))
       (types '()))
    (dotimes (index (length sem-keys))
      (if (string-equal type (get-elem-by-type (nth index sem-keys)))
          (setf types (append types
                               (list (nth index sem-keys))))))
    ;;(format t "ttype ~a~%" types)
    types))
         


;;Methods to call objectname by querying the objecttype
;;START objectType
(defun get-elem-by-type->get-elems-by-type (type)
;;  (format t "get-elem-by-type->get-elems-by-type ~a~%" type)
 (first (split-sequence:split-sequence #\: (first (get-elems-by-type (get-elems-agent-front-by-dist) type)))))

;;;
;;;
;;;
(defun get-elem-by-bboxsize->get-elems-agent-front-by-dist (objtype shape)
 (let*((liste (get-elems-agent-front-by-dist))
       (objtypliste '())
       (objdistliste '())
       (result NIL))
     (dotimes (index (length liste))
       (cond((string-equal objtype
                           (get-elem-by-type (first (split-sequence:split-sequence #\: (nth index liste)))))
             (setf objtypliste (append objtypliste (list (nth index liste))))
             (cond ((> 3 (length objdistliste))
     ;;               (format t "index ~a~%"  (nth index liste))
                     (setf objdistliste (append objdistliste
                                               (list (get-elem-by-bboxsize (first (split-sequence:split-sequence #\: (nth index liste))))))))))))
   (if(string-equal "small" shape)
       (if (> (first objdistliste)
              (second objdistliste))
              (setf result (first (split-sequence:split-sequence #\: (second objtypliste))))
              (setf result (first (split-sequence:split-sequence #\: (first objtypliste)))))
       (if (> (first objdistliste)
              (second objdistliste))
              (setf result (first (split-sequence:split-sequence #\: (first objtypliste))))
              (setf result (first (split-sequence:split-sequence #\: (second objtypliste))))))
   result))

(defun get-elems-by-type (liste type)
  (let((types '()))
       (dotimes (index (length liste))
         (if(string-equal type (get-elem-by-type (first (split-sequence:split-sequence #\: (nth index liste)))))
         (setf types (cons (nth index liste) types))))
       (reverse types)))
           
 (defun get-elem-by-range->get-elems-by-type (type range)
   (let* ((types (get-elems-agent-front-by-type  type))
          (result NIL))
   (dotimes (index (length types))
     (cond ((string-equal "one" range)
            (setf result (first (split-sequence:split-sequence #\: (first types)))))
           ((string-equal "two" range)
            (setf result (first (split-sequence:split-sequence #\: (second types)))))
           ((string-equal "three" range)
            (setf result (first (split-sequence:split-sequence #\: (third types)))))))
     result))
     

                
;;; Get the pose of human based on tf and map-frame
;;;
(defun tf-human-to-map ()
  (let ((var (cl-transforms:transform->pose (cl-tf:lookup-transform *tf* "map" "human"))))
    (publish-body var)
    var))

;;;
;;;
;;;Sorting the lists by using two functions
;;;
 (defun sort-list (liste)
   (dotimes (index (length liste))
                     (setf liste (sorted-lists liste)))
                   liste)


(defun sorted-lists (liste)
  (let ((sortlist '())
        (tmp  (first liste)))
    (loop for index from 1 to (- (length liste) 1)
          do
            (let((tmpnum (read-from-string
                          (second (split-sequence:split-sequence #\: tmp))))
                 (num (read-from-string
                            (second (split-sequence:split-sequence #\: (nth index liste)))))
                 (value (nth index liste)))
             (cond ((> tmpnum  num)
                    (setf sortlist (cons value sortlist)))
                   (t
                    (setf sortlist (cons tmp sortlist))
                    (setf tmp value)
                    (setf tmpnum (read-from-string
                                  (second (split-sequence:split-sequence #\: tmp))))))))
    (setf sortlist (cons tmp sortlist))
    (reverse sortlist)))

;;;
;;; reference resolution by viewpoint of agent
;;; @desig: location-designator to be resolved
;;; @robotname: for setting the viewpoint
;;;
(defun reference-by-agent-frame (desig robotname)
  (let*((sample NIL)
        (cam (cam-depth-tf-human-transform))
        (temp NIL)
        (tmp NIL)
        (tom NIL)
        (objname (second (first (last (desig:properties desig))))))
    (setf cram-tf:*fixed-frame* robotname)
    (cond((not(null desig))
          (if (> (length (desig:properties desig)) 1)
              (dotimes (index (length (desig:properties desig)))
                (sleep 3.0)
                (reference (make-designator :location (list (nth index (desig:properties desig)))))))
          (setf sample (reference desig))
          (setf robot-pose (look-at-object-x (cl-transforms:make-pose
                                              (cl-transforms:origin (cl-transforms-stamped:pose-stamped->pose sample))
                                              (cl-transforms:orientation (cl-transforms:transform->pose cam)))
                                             (get-human-elem-pose objname)))
          (setf *obj-pose* (get-elem-pose objname))
          (setf tmp (cl-transforms-stamped:make-pose-stamped "human"
                                                             0.0 (cl-transforms:origin robot-pose)
                                                             (cl-transforms:orientation robot-pose)))
          (setf tom (cl-transforms-stamped:pose-stamped->pose (cl-tf:transform-pose *tf* :pose tmp :target-frame "map")))))  
    (setf cram-tf:*fixed-frame* "map")
    tom))


(defun cam-depth-tf-human-transform ()
  (cl-transforms-stamped:lookup-transform *tf* "human" "camera_depth_frame"))

(defun cam-depth-tf-map-transform ()
  (cl-transforms-stamped:lookup-transform *tf* "map" "camera_depth_frame"))

(defun create-local-tf-publisher (robot-pose name)
   (let*((pub (cl-tf:make-transform-broadcaster)))
 (cl-tf:send-static-transforms pub 1.0 "quadpose" (cl-transforms-stamped:make-transform-stamped "map" name (roslisp:ros-time) (cl-transforms:origin robot-pose) (cl-transforms:orientation robot-pose)))))

(defun remove-local-tf-publisher (thread)
  (when (sb-thread:thread-alive-p thread)
    (handler-case
        (prog1 t (sb-thread:terminate-thread thread))
      (error () nil))))



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
                          (cl-transforms:axis-angle->quaternion x-axis (* pi 2) ))))
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
(defun checker-elems-by-relation->get-elems-by-tf (objname1 objname2 property)
  (let*((sem-hash (get-elems-by-tf))
        (obj1-pose (gethash objname1 sem-hash))
        (obj2-pose (gethash objname2 sem-hash))
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
              (string-equal property "around")
              (string-equal property "next"))
         (if (>= 20 (get-distance obj1-pose obj2-pose))
             (setf tmp T)
             (setf tmp NIL))))
    tmp))

(defun get-elems-by-tf ()
  (let* ((sem-map (sem-map-utils:get-semantic-map))
        (sem-hash (slot-value sem-map 'sem-map-utils:parts))
         (sem-keys (hash-table-keys sem-hash))
       ;;  (semm-hash (copy-hash-table sem-hash))
         (new-hash (make-hash-table))(name NIL)
         (obj-pose NIL))
    (dotimes (index (length sem-keys))
      (let*((pose (get-elem-pose (nth index sem-keys)))
            (pub (cl-tf:set-transform *tf* (cl-transforms-stamped:make-transform-stamped "map" (nth index sem-keys) (roslisp:ros-time) (cl-transforms:origin pose) (cl-transforms:orientation pose))))
            (obj-pose (cl-transforms-stamped:transform->pose (cl-tf:lookup-transform *tf* "human" (nth index sem-keys)))))
      (setf (gethash (nth index sem-keys) new-hash) obj-pose)))
(copy-hash-table new-hash)))

(defun get-elem-by-small-dist (liste)
  (let*((checker 1000)
        (elem NIL))
    (dotimes (index (length liste))
      (cond ((<= (parse-integer (second (split-sequence:split-sequence #\: (nth index liste)))) checker)
             (setf checker (parse-integer (second (split-sequence:split-sequence #\: (nth index liste)))))
             (setf elem(nth index liste)))))
    elem))

(defun get-elem-by-big-dist (liste)
  (let*((checker 0)
        (elem NIL))
    (dotimes (index (length liste))
      (cond ((>= (parse-integer (second (split-sequence:split-sequence #\: (nth index liste)))) checker)
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
           (string-equal (get-elem-by-type (nth index liste)) obj))
          (setf elem  (nth index liste))))
    (cond((equal elem NIL)
          (let ((new-liste (get-element-with-ground-calculation-based-on-gesture vec)))
            (dotimes (jindex (length new-liste))
                (if (string-equal (get-elem-by-type (nth jindex new-liste)) obj)
                    (setf elem  (nth jindex liste)))))))
    (if (equal NIL elem)
        (setf elem (get-specific-elem-closeto-human obj)))
    elem))
        

(defun filling-desigs-with-semantics (viewpoint location-designator)
  (let ((desig-properties (desig:properties location-designator))
         (desig NIL))
   ;; (format t "desig-properties ~a~%" desig-properties)
     ;;if property-list includes one key,e.g. ((:property small)(:right tree))
     (cond ((= 1 (length desig-properties))
            (setf desig (one-list-internal-property viewpoint (first desig-properties))))
           ((= 2 (length desig-properties))
            (setf desig (two-lists-internal-property viewpoint desig-properties)))
           ((= 3 (length desig-properties))
            (setf desig (intern-property-list-three viewpoint desig-properties))))
   desig))


   
(defun cam-get-pose->relative-map (vec)
(let((pose-stmp (cl-transforms-stamped:make-pose-stamped "camera_depth_frame"
                                                         0.0 vec
                                                         (cl-transforms:make-identity-rotation))))
  (cl-transforms-stamped:pose-stamped->pose (cl-tf:transform-pose *tf* :pose pose-stmp :target-frame "map"))))

;


(defun get-new-elem-by-name-type-shape-spatial (name type shape spatial)
 ;; (format t "name ~a~%
;;type ~a~% shape ~a~% spatial ~a~%" name type shape spatial)
  (let ((liste (get-elems-agent-front-by-type type)) ;;(get-elems-of-semmap-by-type type))
        (resultlist '())
        (result NIL)
        (tmplist NIL))
  ;; (format t "liste ~a~%" liste)
    (dotimes (index (length liste))
      (if (not (null (checker-elems-by-relation->get-elems-by-tf
                      (nth index liste) name spatial)))
          (setf resultlist (append resultlist (list 
                                                   (format NIL "~a:~a"(nth index liste)
                                                           (get-distance
                                                            (get-elem-by-pose
                                                             (nth index liste))
                                                            (get-elem-by-pose name))))))))
    (setf resultlist (sort-list resultlist))
    (dotimes (jndex (length resultlist))
    ;;    (format t "tmplist1 ~a~%" tmplist)
      (setf tmplist (append tmplist (list (get-elem-by-bboxsize
                             (first (split-sequence:split-sequence #\: (nth jndex resultlist))))))))
;;    (format t "tmplist ~a~%" tmplist)
    (if(string-equal "big" shape)
       (cond((> (first tmplist) (second tmplist))
             (setf result (first resultlist)))
            ((< (first tmplist) (second tmplist))
             (setf result (second resultlist)))
            (t (if(> (second tmplist) (third tmplist))
                  (setf result (second resultlist))
                  (setf result (third resultlist)))))
       (cond((< (first tmplist) (second tmplist))
             (setf result (first resultlist)))
            ((> (first tmplist) (second tmplist))
             (setf result (second resultlist)))
            (t (if(< (second tmplist) (third tmplist))
                  (setf result (second resultlist))
                  (setf result (third resultlist))))))
    result))

(defun get-first-elem-by-name-type-shape-spatial- (name type shape spatial)
  ;;(format t "name ~a~%
;;type ~a~% shape ~a~% spatial ~a~%" name type shape spatial)
  (let ((liste (get-elems-agent-front-by-type type)) ;;(get-elems-of-semmap-by-type type))
        (resultlist '())
        (result NIL)
        (tmplist NIL))
  ;;  (format t "liste ~a~%" liste)
    (dotimes (index (length liste))
      (if (not (null (checker-elems-by-relation->get-elems-by-tf
                      name (nth index liste) spatial)))
          (setf resultlist (append resultlist (list 
                                                   (format NIL "~a:~a"(nth index liste)
                                                           (get-distance
                                                            (get-elem-by-pose
                                                             (nth index liste))
                                                            (get-elem-by-pose name))))))))
    (setf resultlist (sort-list resultlist))
    (dotimes (jndex (length resultlist))
    ;;    (format t "tmplist1 ~a~%" tmplist)
      (setf tmplist (append tmplist (list (get-elem-by-bboxsize
                             (first (split-sequence:split-sequence #\: (nth jndex resultlist))))))))
    ;;(format t "tmplist ~a~%" tmplist)
    (if(string-equal "big" shape)
       (cond((> (first tmplist) (second tmplist))
             (setf result (first resultlist)))
            ((< (first tmplist) (second tmplist))
             (setf result (second resultlist)))
            (t (if(> (second tmplist) (third tmplist))
                  (setf result (second resultlist))
                  (setf result (third resultlist)))))
       (cond((< (first tmplist) (second tmplist))
             (setf result (first resultlist)))
            ((> (first tmplist) (second tmplist))
             (setf result (second resultlist)))
            (t (if(< (second tmplist) (third tmplist))
                  (setf result (second resultlist))
                  (setf result (third resultlist))))))
    result))

(defun unnest (x)
  (labels ((rec (x acc)
    (cond ((null x) acc)
      ((atom x) (cons x acc))
      (t (rec (car x) (rec (cdr x) acc))))))
    (rec x nil)))


(defun get-elem-by-color->get-objects-infrontof-agent (type color viewpoint)
;;TODO
  "tree01")

(defun get-elems-agent-front-by-type (type)
  (let*((liste (get-elems-agent-front-by-dist))
        (resultlist '()))
    (dotimes (index (length liste))
      (if(string-equal type
                       (get-elem-by-type
                        (first (split-sequence:split-sequence #\: (nth index liste)))))
         (setf resultlist (append resultlist (list (first (split-sequence:split-sequence #\: (nth index liste))))))))
    resultlist))
            
(defun checking-relation (robot relation)
  (let* ((human-pose (get-human-pose))
         (human-ori (cl-transforms:orientation human-pose))
         (robot-pose (cl-transforms:transform->pose  (cl-tf:lookup-transform *tf* "map" "base_link")))
         (robot-loc (cl-transforms:origin robot-pose))
         (result NIL)
         (pose NIL))
    (if (string-equal robot "human")
        (setf pose (cl-transforms:make-pose robot-loc human-ori))
        (setf pose (cl-transforms:make-pose robot-loc (cl-transforms:orientation robot-pose))))
    (cl-tf:set-transform *tf*
                         (cl-transforms-stamped:make-transform-stamped
                          "map" "relation"
                          (roslisp:ros-time)
                          (cl-transforms:origin pose)
                          (cl-transforms:orientation pose)))
    (cond((string-equal "right" relation)
          (setf pose (cl-transforms-stamped:make-pose-stamped "relation" 0.0
                                                          (cl-transforms:make-3d-vector 0 -7 0)
                                                          (cl-transforms:make-identity-rotation)))
          (setf result (cl-transforms-stamped:pose-stamped->pose (cl-tf:transform-pose *tf* :pose pose :target-frame "map"))))
         ((string-equal "left" relation)
          (setf pose (cl-transforms-stamped:make-pose-stamped "relation" 0.0
                                                          (cl-transforms:make-3d-vector 0 7 0)
                                                          (cl-transforms:make-identity-rotation)))
          (setf result (cl-transforms-stamped:pose-stamped->pose (cl-tf:transform-pose *tf* :pose pose :target-frame "map"))))
         ((string-equal "straight" relation)
          (setf pose (cl-transforms-stamped:make-pose-stamped "relation" 0.0
                                                          (cl-transforms:make-3d-vector 7 0 0)
                                                          (cl-transforms:make-identity-rotation)))
          (setf result (cl-transforms-stamped:pose-stamped->pose (cl-tf:transform-pose *tf* :pose pose :target-frame "map")))))
    (publish-pose result :id 100)
    result))

(defun get-robot-pose ()
  (cl-transforms-stamped:transform->pose
   (cl-tf:lookup-transform *tf* "map" "base_link")))
  
