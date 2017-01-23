#!/usr/bin/env python

import roslib; roslib.load_manifest('instructor_mission')
from instructor_mission.srv import *
from instructor_mission.msg import *
import rospy
from std_msgs.msg import String
from geometry_msgs.msg import PoseStamped
from geometry_msgs.msg import Point
import re
import sys
import pygtk
pygtk.require('2.0')
import gtk
import string 
import os
import commands

action=""
order=""
description=""
color=""

def build_msg(read_action, read_order, read_description, read_color, speech_input):

    action1 = ""
    order1 = ""
    description1 = ""
    shape1 = ""
    num1 = ""
    color1 = ""
    viewpoint1 = "busy_genius"
    pointer1 = "false"
    desig = Desig()
    desigs = []
    propkey = Propkey()
    propkeys = []

    for index in range(len(speech_input)):

        if speech_input[index] in read_action:
            if speech_input[index] != "and":
                action1 = speech_input[index]
        
        if speech_input[index] in read_order and order1 == "" and index < (len(speech_input) - 1):
            order1 = speech_input[index]
        elif speech_input[index] in read_order and order1 != "" and index < (len(speech_input) - 1):
            propkey.object_relation.data = order1
            propkey.object.data = description1
            propkey.object_color.data = color1
            propkey.object_size.data = shape1
            propkey.object_num.data = num1
            propkey.flag.data = pointer1
            propkeys.append(propkey)
            propkey = Propkey()
            desig.propkeys = propkeys
            order1 = speech_input[index]

        if speech_input[index] in read_order and order1 == "" and index == (len(speech_input) - 1):
            desig.viewpoint.data = viewpoint1
            desig.action_type.data = action1
            desig.actor.data = "robot"
            desig.instructor.data = "busy_genius"
            propkey.object_relation.data = speech_input[index]
            propkey.object.data = description1
            propkey.object_color.data = color1
            propkey.object_size.data = shape1
            propkey.object_num.data = num1
            propkey.flag.data = pointer1
            propkeys.append(propkey)
            propkey = Propkey()
            desig.propkeys = propkeys
            desigs.append(desig)
            desig = Desig()
            break

        if speech_input[index] == "big" or speech_input[index] == "small" and shape1 == "":
            shape1 = speech_input[index]

        if speech_input[index] in read_color and color1 == "":
            color1 = speech_input[index]

        if speech_input[index] == "first" or speech_input[index] == "second" or speech_input[index] == "third" and num1 == "":
            num1 = speech_input[index]

        if speech_input[index] == "and":
            desig.viewpoint.data = viewpoint1
            desig.action_type.data = action1
            desig.actor.data = "robot"
            desig.instructor.data = "busy_genius"
            propkey = Propkey()
            desig.propkeys = propkeys
            desigs.append(desig)
            propkeys = []
            desig = Desig()
            order1 = ""
            description1 = ""
            action1 = ""
            pointer1 = ""
            num1 = ""
            color1 = ""

        if speech_input[index] in read_description and index == (len(speech_input) - 1):
            if speech_input[index] == "picture":
                desig.viewpoint.data = viewpoint1
                desig.action_type.data = action1+"-picture"
                desig.actor.data = "robot"
                desig.instructor.data = "busy_genius"
                propkey.object_relation.data = order1
                propkey.object.data = description1
                propkey.object_color.data = color1
                propkey.object_size.data = shape1
                propkey.object_num.data = num1
                propkey.flag.data = pointer1
                propkeys.append(propkey)
                propkey = Propkey()
                desig.propkeys = propkeys
                desigs.append(desig)
                desig = Desig()
                order1 = ""
                break
            else:
                description1 = speech_input[index]
                desig.viewpoint.data = viewpoint1
                desig.action_type.data = action1
                desig.actor.data = "robot"
                desig.instructor.data = "busy_genius"
                propkey.object_relation.data = order1
                propkey.object.data = description1
                propkey.object_color.data = color1
                propkey.object_size.data = shape1
                propkey.object_num.data = num1
                propkey.flag.data = pointer1
                propkeys.append(propkey)
                propkey = Propkey()
                desig.propkeys = propkeys
                desigs.append(desig)
                desig = Desig()
                break
        elif speech_input[index] in read_description and index < (len(speech_input) - 1):
            description1 = speech_input[index]
            desig.viewpoint.data = viewpoint1
            desig.action_type.data = action1
            desig.actor.data = "robot"
            desig.instructor.data = "busy_genius"
            propkey.object_relation.data = order1
            propkey.object.data = description1
            propkey.object_color.data = color1
            propkey.object_size.data = shape1
            propkey.object_num.data = num1
            propkey.flag.data = pointer1
            propkeys.append(propkey)
            propkey = Propkey()
            desig.propkeys = propkeys
            order1 = ""
            description1 = ""
            shape1 = ""
            num1 = ""
            pointer = ""
            color1 = ""

        if speech_input[index] == "you" or speech_input[index] == "your":
            viewpoint1 = "robot"

        if speech_input[index] == "that":
            pointer1 = "true"

    if len(desigs) == 1:
        rospy.logwarn(desigs[0])
    elif len(desigs) == 2:
        rospy.logwarn(desigs[0])
        rospy.logwarn(desigs[1])
    elif len(desigs) == 3:
        rospy.logwarn(desigs[0])
        rospy.logwarn(desigs[1])
        rospy.logwarn(desigs[2])

def callback_sub(data):
    global speech_output
    file_action = open(action,'r')
    file_order = open(order, 'r')
    file_description = open(description,'r')
    file_color = open(color,'r')

    read_action = file_action.read()
    read_order = file_order.read()
    read_description = file_description.read()
    read_color = file_color.read()

    speech_input = data.data
    speech_input = speech_input.lower()
    speech_input = re.sub(' the ', ' ', speech_input)
    speech_input = re.sub(' a ', ' ', speech_input)
    speech_input = re.sub(' of ', ' ', speech_input)
    speech_input = re.sub(' next to ', ' next-to ', speech_input)
    speech_input = re.sub('look for', 'look-for', speech_input)
    speech_input = re.sub('look at', 'look-at', speech_input)
    speech_input = re.sub('search for', 'search-for', speech_input)
    speech_input = speech_input.split(' ')
    speech_output= ""

    build_msg(read_action, read_order, read_description, read_color, speech_input)

def start_python_server():
    rospy.init_node('py_parser node')
    action_param = "~action"
    order_param = "~order"
    description_param = "~description"
    color_param = "~color"

    if rospy.has_param(action_param) and rospy.has_param(order_param) and rospy.has_param(description_param) and rospy.has_param(color_param):
        start_recognizer(action_param, order_param, description_param, color_param)
    else:
        rospy.logwarn("action and order and description parameters need to be set to start recognizer.")

def start_recognizer(action_param, order_param, description_param, color_param):
    global action
    global order
    global description
    global color

    rospy.loginfo("Starting recognizer... ")
    action = rospy.get_param(action_param)
    order = rospy.get_param(order_param)
    description = rospy.get_param(description_param)
    color = rospy.get_param(color_param)
      
    rospy.Subscriber("internal/recognizer/output", String, callback_sub)
    print "Ready for speechToText with Subscriber"
    rospy.spin()

if __name__ == "__main__":
     start_python_server()