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

(defmethod costmap-generator-name->score ((name (eql 'collisions))) 10)

(defclass reasoning-generator () ())
(defmethod costmap-generator-name->score ((name reasoning-generator)) 7)

(defclass gaussian-generator () ())     
(defmethod costmap-generator-name->score ((name gaussian-generator)) 6)
(defclass range-generator () ())
(defmethod costmap-generator-name->score ((name range-generator)) 2)
(defmethod costmap-generator-name->score ((name (eql 'semantic-map-free-space))) 11)

(def-fact-group cognitive-reasoning-costmap (desig-costmap)
  (<- (desig-costmap ?desig ?costmap)
    (costmap ?costmap)
    (prepositions ?desig ?costmap))
  
  (<- (prepositions ?desig ?costmap)
    (or (desig-prop ?desig (:right ?object-name))
        (desig-prop ?desig (:right-of ?object-name)))
    (lisp-fun get-human-elem-pose ?object-name ?object-pose)
    (instance-of reasoning-generator ?reasoning-generator-id)
    (costmap-add-function
     ?reasoning-generator-id
     (make-spatial-relations-cost-function ?object-pose :Y < 0.1)
     ?costmap)
    (adjust-map ?costmap ?object-name ?object-pose))
  

  (<- (prepositions ?desig ?costmap)
    (or (desig-prop ?desig (:left ?object-name))
        (desig-prop ?desig (:left-of ?object-name)))
    (lisp-fun get-human-elem-pose ?object-name ?object-pose)
    (instance-of reasoning-generator ?reasoning-generator-id)
    (costmap-add-function
     ?reasoning-generator-id
     (make-spatial-relations-cost-function ?object-pose :Y > 0.1)
     ?costmap)
    (adjust-map ?costmap ?object-name ?object-pose)) 


  (<- (prepositions ?desig ?costmap)
    (or (desig-prop ?desig (:front-of ?object-name))
        (desig-prop ?desig (:in-front-of ?object-name)))
    (lisp-fun get-human-elem-pose ?object-name ?object-pose)
    (instance-of reasoning-generator ?reasoning-generator-id)
    (costmap-add-function
     ?reasoning-generator-id
     (make-spatial-relations-cost-function ?object-pose :X < 0.1)
     ?costmap)
    (adjust-map ?costmap ?object-name ?object-pose))
   
  
    (<- (prepositions ?desig ?costmap)
    (or (desig-prop ?desig (:behind ?object-name))
        (desig-prop ?desig (:behind-of ?object-name)))
    (lisp-fun get-human-elem-pose ?object-name ?object-pose)
    (instance-of reasoning-generator ?reasoning-generator-id)
    (costmap-add-function
     ?reasoning-generator-id
     (make-spatial-relations-cost-function ?object-pose :X > 0.1)
     ?costmap)
      (adjust-map ?costmap ?object-name ?object-pose))

      (<- (prepositions ?desig ?costmap)
    (or (desig-prop ?desig (:to ?object-name))
        (desig-prop ?desig (:next ?object-name))
        (desig-prop ?desig (:close-to ?object-name)))
        (lisp-fun get-human-elem-pose ?object-name ?object-pose)
        (adjust-map ?costmap ?object-name ?object-pose))

  
  (<- (prepositions ?desig ?costmap)
    (desig-prop ?desig (:ontop ?object-name))
    (semantic-map-costmap::semantic-map-objects ?all-objects)
    (lisp-fun get-elem-pose ?object-name ?pose)
    (costmap-padding ?padding)
    (lisp-fun get-the-exact-object-to-pose ?all-objects 10 ?pose ?object-name ?w-objects)
    (costmap-add-function semantic-map-free-space
                          (make-semantic-map-costmap-by-human
                           ?w-objects :invert t :padding ?padding)
                          ?costmap)
    (costmap ?costmap)
    (lisp-fun get-human-elem-pose ?object-name ?object-pose)
    (instance-of gaussian-generator ?gaussian-generator-id)
    (costmap-add-function ?gaussian-generator-id
                          (make-location-cost-function ?object-pose  1.0)
                          ?costmap))
  ;;
  ;; Watch out, for the free-space you generated
  ;; a new generator which is based on the human-frame
  ;;
  (<- (adjust-map ?costmap ?object-name ?object-pose)
   (semantic-map-costmap::semantic-map-objects ?all-objects)
   (lisp-fun get-elem-pose ?object-name ?pose)
   (lisp-fun get-objects-closeto-pose ?all-objects 10 ?pose ?objects)
   (costmap-padding ?padding)
   (costmap-add-function semantic-map-free-space
                        (make-semantic-map-costmap-by-human
                         ?objects :invert t :padding ?padding)
                        ?costmap)
   (costmap ?costmap)
   (instance-of gaussian-generator ?gaussian-generator-id)
   (costmap-add-function ?gaussian-generator-id
                        (make-location-cost-function ?object-pose  2.5)
                        ?costmap)))

;; TODO
;; (perform (vector (make-designator :action `((:operator :busy-genius)
;;                                    (:type :moving)
;;                                    (:actor :blue-wasp)
;;                                    (:goal ,(make-designator :location `((:right "rock07")
;;                                                                         (:to "tree01")
;;                                                                         (:reference-frame pose-stamped-by-human))))))
;;          (make-designator :action `((:operator :busy-genius)
;;                                    (:type :taking-picture)
;;                                    (:actor :blue-wasp)))))
;; progn (perform act1)
;; progn (perform act2)
;; cpl:seq (perform act1)
;;         (perform act2)

;; DONE
;; (vector (action (:action_type :move)
;;                 (vector (propkeys (spatial_relation :right)
;;                                   (language_object :tree)
                                  

;;                                   (:loc ,(make-designator :location `((:right "rock")
;;                                                                        (:to "tree"))))\
;;                                    (:flag 
;;                          (make-designator :action `((:operator :busy-genius)
;;                                                     (:type :taking-picture)
;;                                                     (:actor :blue-wasp))))
