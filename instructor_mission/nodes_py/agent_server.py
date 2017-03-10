#!/usr/bin/env python

import roslib; roslib.load_manifest('hmi_interpreter')
from hmi_interpreter.srv import *
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

agent="robot"
def call_agent_name(req):
    print "---------------------------------------------first call"
    global agent
    print req.goal
    print "Returning agentname: "
    print req.goal
    if req.goal != "get":
        agent = req.goal
        print "agent123: "
        print agent
        if agent == "ROBOTS" or agent == "robots":
            agent = "robot"
        return text_parserResponse(agent)
    else:
        print "agent456: "
        print agent
        tmp = agent
        agent = "robot"       
        return text_parserResponse(tmp)

def get_agent_server():
    rospy.init_node("add_agent_server")
    s = rospy.Service("add_agent_name", text_parser, call_agent_name)
    print "Ready to set the robot name."
    rospy.spin()


if __name__ == "__main__":
    get_agent_server()
