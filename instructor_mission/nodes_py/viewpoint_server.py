#!/usr/bin/env python

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

agent="no"
def call_viewpoint(req):
    print "---------------------------------------------first call"
    global agent
    print req.goal
    print "Returning viewpoint: "
    print req.goal
    if req.goal != "get":
        print agent
        agent = "yes"
        print "agent123: "
        print agent
        return text_parserResponse(agent)
    else:
        print "agent456: "
        print agent
        tmp = agent
        agent = "no"       
        return text_parserResponse(tmp)

def get_viewpoint_server():
    rospy.init_node("add_viewpoint_server")
    s = rospy.Service("add_viewpoint", text_parser, call_viewpoint)
    print "Ready to set the robot name."
    rospy.spin()


if __name__ == "__main__":
    get_viewpoint_server()
