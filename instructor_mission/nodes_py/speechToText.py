#!/usr/bin/env python

"""
Getting Input from a speech recognizer and checking it
based on the Verb Order Description-Structure
  parameters:
   ~action - filename of action model
   ~order  - filename of order model
   ~description - filename of location model
 
  publications:
   ~speech_input (std_msgs/String) -text input
   ~speech_output(std_msgs/String) -text output

"""

import roslib; roslib.load_manifest('instructor_mission')
from instructor_mission.srv import *
import rospy

import pygtk
pygtk.require('2.0')
import gtk

import os
import commands

class start_server(object):
   
    def __init__(self):
        rospy.init_node('speechToText')
        self._action_param = "~action"
        self._order_param = "~order"
        self._description_param = "~description"
        self._property_param = "~property"
        self._pointer_param = "~pointer"
        
        if rospy.has_param(self._action_param) and rospy.has_param(self._order_param) and rospy.has_param(self._description_param) and rospy.has_param(self._pointer_param) and rospy.has_param(self._property_param):
            self.start_recognizer()
        else:
            rospy.logwarn("action and order and description parameters need to be set to start recognizer.")

    def start_recognizer(self):
        rospy.loginfo("Starting recognizer... ")
        action = rospy.get_param(self._action_param)
        order = rospy.get_param(self._order_param)
        description = rospy.get_param(self._description_param)
        property = rospy.get_param(self._property_param)
        pointer = rospy.get_param(self._pointer_param)
        #print action
        #rospy.loginfo("action is %s", action)
        file_action = open(action,'r')
        #print file_action.read()
        file_order = open(order, 'r')
        #print file_order.read()
        file_description = open(description,'r')
        #print file_description.read()
        file_property = open(property,'r')
        #recognizer_input() as subscriber
        file_pointer = open(pointer,'r')
        speech = "go right"
        print speech
        speech = speech.split(' ')
        #print file_action
        read_action = file_action.read()
        #print read_actionfile
        read_order = file_order.read()
        read_description = file_description.read()
        read_property = file_property.read()
        read_pointer = file_pointer.read()
        
        
        if len(speech) > 1:
            if speech[0] in read_action:
                print "action"
                if len(speech) == 1:
                   print" break"
                elif speech[1] in read_description and speech[1] == "picture":
                    print "description"     #------------------ AD
                elif speech[1] in read_order:
                    print "order"
                    if speech[1] == "right" or speech[1] == "left" or speech[1] == "back" or speech[1] == "ahead":#-------------------AO
                        print "description"
                        if len(speech) == 2:
                            print "final"
                        else:
                            print "order"
                    else:
                        print "order"
                    elif speech[2] in read_description:         # -------------- AOD
                        print "description"
                        if len(speech) == 3:
                            print "break"
                        elif speech[3] in read_order:
                            print "order"
                            if len(speech) == 4:
                                print "break"
                            elif speech[4] in read_description:
                                print "description"
                            elif speech[4] in read_pointer:
                                print "pointer"
                                if len(speech) == 5:
                                    print "break"
                                elif speech[5] in read_description:
                                    print "description"
                            elif speech[4] in read_property:
                                print "property"
                                if len(speech) == 5:
                                    print "break"
                                elif speech[5] in read_description:
                                    print "description"
                    elif speech[2] in read_property:             # ------------------- AO PP
                        print "property"
                        if speech[3] in read_description:        # ------------------- AO PP D
                            print "description"
                            if len(speech) == 4:
                                print "break"
                            elif speech[4] in read_order:
                                print "order"
                                if len(speech) == 5:
                                    print "break"
                                elif speech[5] in read_description:
                                    print "description"
                                elif speech[5] in read_property:
                                    print "property"
                                    if len(speech) == 6:
                                        print "break"
                                    elif speech[6] in read_description:
                                        print "description"
                                elif speech[5] in read_pointer:
                                    if len(speech) == 6:
                                        print "break"
                                    elif speech[6] in read_description:
                                        print "description"                              
                    elif speech[2] in read_pointer:              # -------------------- AOP
                        print "pointer"
                        if speech[3] in read_description:        # ------------------- AOPD
                            print "description"
                            if len(speech) == 4:
                                print "break"
                            elif speech[4] in read_order:
                                print "order"
                                if len(speech) == 5:
                                    print "break"
                                elif speech[5] in read_description:
                                    print "description"
                                elif speech[5] in read_pointer:
                                    print "pointer"
                                    if len(speech) == 6:
                                        print "break"
                                    elif speech[6] in read_description:
                                            print "description"
                                elif speech[5] in read_property:
                                    print "property"
                                    if len(speech) == 6:
                                        print "break"
                                    elif speech[6] in read_description:
                                            print "description"
                            else:
                                print "Something is wrong"
                else:
                    print "Please, repeat the command!"
                            

               
        # Go to tree next to that rock

        # get input from publisher and checking if words are fitting
        # get input of publisher and storing them in an array...
        # rospy.init_node('speech_recognizer')
        # s = rospy.Service('speech_recognizer', speech_recognizer, initialize)
        # print "Ready for getting the instructions"
        # rospy.spin()

if __name__ == "__main__":
     start = start_server()
     gtk.main()
