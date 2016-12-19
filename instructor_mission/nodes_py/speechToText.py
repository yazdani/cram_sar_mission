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
import re
import sys

import pygtk
pygtk.require('2.0')
import gtk
import string 
import os
import commands
from std_msgs.msg import String

action=''
property=''
description=''
order=''
pointer=''
speech_output = ""


def callTheService(speech_output):
     rospy.wait_for_service("callInstruction")
     try:
          callInstruction = rospy.ServiceProxy("callInstruction", text_parser)
          result = callInstruction(speech_output)
          return result.result
     except rospy.ServiceExcepton, e:
          print "Service call failes %s"%e


def start_server():
     rospy.init_node('speechToText')
     action_param = "~action"
     order_param = "~order"
     description_param = "~description"
     property_param = "~property"
     pointer_param = "~pointer"
     
     if rospy.has_param(action_param) and rospy.has_param(order_param) and rospy.has_param(description_param) and rospy.has_param(pointer_param) and rospy.has_param(property_param):
          start_recognizer(action_param, order_param, description_param, pointer_param, property_param)
     else:
          rospy.logwarn("action and order and description parameters need to be set to start recognizer.")
          
def subscriberCB(data):
     file_action = open(action,'r')
     file_order = open(order, 'r')
     file_description = open(description,'r')
     file_property = open(property,'r')
     file_pointer = open(pointer,'r')
     speech_input = data.data
     speech_input = re.sub(' to ', ' ', speech_input)
     speech_input = re.sub(' of ', ' ', speech_input)
     speech = speech_input.split(' ')
     read_action = file_action.read()
     read_order = file_order.read()
     read_description = file_description.read()
     read_property = file_property.read()
     read_pointer = file_pointer.read()
     speech_output = ""
     if len(speech) > 1:
          if speech[0] in read_action:
               speech_output = speech_output + speech[0]
               if len(speech) == 1:
                    print "end"
               elif speech[1] in read_description and speech[1] == "picture":
                    speech_output = speech_output + " " + speech[1]
               elif speech[1] in read_description and speech[1] != "picture":
                    speech_output = speech_output + " to " + speech[1]
                    if len(speech) == 2:
                         print "end"
                    elif speech[2] in read_description:
                         speech_output = speech_output +" to " +speech[2]
               elif speech[1] in read_order:
                    speech_output = speech_output + " "+ speech[1]
                    if len(speech) == 2:
                         print "final"
                    elif speech[2] in read_description:
                         speech_output = speech_output + " "+ speech[2]
                         if len(speech) == 3:
                              print "break"
                         elif speech[3] in read_order:
                              print "order"
                              speech_output = speech_output + " "+ speech[3]
                                                       
                              if len(speech) == 4:
                                   print "break"
                              elif speech[4] in read_description:
                                   print "description"
                                   speech_output = speech_output + " "+ speech[4]

                              elif speech[4] in read_pointer:
                                   print "pointer"
                                   speech_output = speech_output + " "+ speech[4]

                                   if len(speech) == 5:
                                        print "break"
                                   elif speech[5] in read_description:
                                        print "description"
                                        speech_output = speech_output + " "+ speech[5]

                              elif speech[4] in read_property:
                                   print "property"
                                   speech_output = speech_output + " "+ speech[4]
                         
                                   if len(speech) == 5:
                                        print "break"
                                   elif speech[5] in read_description:
                                        print "description"
                                        speech_output = speech_output + " "+ speech[5]
                         elif speech[3] in read_description:
                              speech_output = speech_output + " to "+ speech[3]

                    elif speech[2] in read_property:
                         speech_output = speech_output + " "+ speech[2]
                         
                         if speech[3] in read_description:
                              print "description"
                              speech_output = speech_output + " "+ speech[3]
                         
                              if len(speech) == 4:
                                   print "break"
                              elif speech[4] in read_order:
                                   print "order"
                                   speech_output = speech_output + " "+ speech[4]

                                   if len(speech) == 5:
                                        print "break"
                                   elif speech[5] in read_description:
                                        print "description"
                                        speech_output = speech_output + " "+ speech[5]

                                   elif speech[5] in read_property:
                                        print "property"
                                        speech_output = speech_output + " "+ speech[5]

                                        if len(speech) == 6:
                                             print "break"
                                        elif speech[6] in read_description:
                                             print "description"
                                             speech_output = speech_output + " "+ speech[6]

                                   elif speech[5] in read_pointer:
                                        speech_output = speech_output + " "+ speech[5]
                         
                                        if len(speech) == 6:
                                             print "break"
                                        elif speech[6] in read_description:
                                             print "description"                     
                                             speech_output = speech_output + " "+ speech[6]
         
                    elif speech[2] in read_pointer: 
                         speech_output = speech_output + " "+ speech[2]
                         
                         if speech[3] in read_description:        # ------------------- AOPD
                              print "description"
                              speech_output = speech_output + " "+ speech[3]
                         
                              if len(speech) == 4:
                                   print "break"
                              elif speech[4] in read_order:
                                   print "order"
                                   speech_output = speech_output + " "+ speech[4]
                         
                                   if len(speech) == 5:
                                        print "break"
                                   elif speech[5] in read_description:
                                        print "description"
                                        speech_output = speech_output + " "+ speech[5]

                                   elif speech[5] in read_pointer:
                                        print "pointer"
                                        speech_output = speech_output + " "+ speech[5]

                                        if len(speech) == 6:
                                             print "break"
                                        elif speech[6] in read_description:
                                             print "description"
                                             speech_output = speech_output + " "+ speech[6]

                                        elif speech[5] in read_property:
                                             print "property"
                                             speech_output = speech_output + " "+ speech[5]

                                             if len(speech) == 6:
                                                  print "break"
                                             elif speech[6] in read_description:
                                                  print "description"
                                                  speech_output = speech_output + " "+ speech[6]

                         else:
                              print "Something is wrong"
               else:
                    print "Please, repeat the command!"
     print "speech_output: "
     speech_output = speech_output.capitalize()
     callTheService(speech_output)
                    

        # Go to tree next to that rock

        # get input from publisher and checking if words are fitting
        # get input of publisher and storing them in an array...
        # rospy.init_node('speech_recognizer')
        # s = rospy.Service('speech_recognizer', speech_recognizer, initialize)
        # print "Ready for getting the instructions"
        # rospy.spin()
     
     
def start_recognizer(action_param, order_param, description_param, pointer_param, property_param):
     global action
     global order
     global description
     global property
     global pointer

     rospy.loginfo("Starting recognizer... ")
     action = rospy.get_param(action_param)
     order = rospy.get_param(order_param)
     description = rospy.get_param(description_param)
     property = rospy.get_param(property_param)
     pointer = rospy.get_param(pointer_param)
     
     rospy.Subscriber("/recognizer/output", String, subscriberCB)
     rospy.spin()


     

if __name__ == "__main__":
     start_server()
    
