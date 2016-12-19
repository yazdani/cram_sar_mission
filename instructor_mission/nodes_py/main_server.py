#!/usr/bin/env python

from instructor_mission.srv import *
from instructor_mission.msg import *
import rospy
from std_msgs.msg import String
from geometry_msgs.msg import Point
import sys


def create_hmi_msgs(goal):
    desig = Desig()
    desigs = []
    goal = goal.split(" 0 ")
    propkey = Propkey()
    propkey2 = Propkey()
    propkeys = []
    point = Point()
    if len(goal) == 1:
        goal = goal[0].split(" 1 ")
        if len(goal) == 1:                                 #Go to tree
            goal = goal[0].split(" ")
            desig.action_type.data = goal[0]
            desig.actor.data = "red"
            desig.instructor.data = "busy-genius"
            desig.viewpoint.data = "busy-genius"
            propkey.object_relation.data = goal[1]
            propkey.object.data = goal[4]
            propkey.object_color.data = "null"
            propkey.object_size.data = goal[2]
            propkey.object_num.data = "null"
            propkey.flag.data = goal[3]
            propkey.pointing_gesture.x = 0.0
            propkey.pointing_gesture.y = 0.0
            propkey.pointing_gesture.z = 0.0
            propkeys.append(propkey)
            propkey = Propkey()
            desig.propkeys = propkeys
            desigs.append(desig)
        else:
            goal1 = goal[0].split(" ")                    #Go to tree to rock
            desig.action_type.data = goal1[0]
            desig.actor.data = "red"
            desig.instructor.data = "busy-genius"
            desig.viewpoint.data = "busy-genius"
            propkey.object_relation.data = goal1[1]
            propkey.object.data = goal1[4]
            propkey.object_color.data = "null"
            propkey.object_size.data = goal1[2]
            propkey.object_num.data = "null"
            propkey.flag.data = goal1[3]
            propkey.pointing_gesture.x = 0.0
            propkey.pointing_gesture.y = 0.0
            propkey.pointing_gesture.z = 0.0
            propkeys.append(propkey)
            propkey = Propkey()
            goal2 = goal[1].split(" ")
            propkey.object_relation.data = goal2[0]
            propkey.object.data = goal2[3]
            propkey.object_color.data = "null"
            propkey.object_size.data = goal2[1]
            propkey.object_num.data = "null"
            propkey.flag.data = goal2[2]
            propkey.pointing_gesture.x = 0.0
            propkey.pointing_gesture.y = 0.0
            propkey.pointing_gesture.z = 0.0
            propkeys.append(propkey)
            propkey = Propkey()
            propkeys.reverse()
            desig.propkeys = propkeys
            desigs.append(desig)
            desig = Desig()
    else:   
        goal1 = goal[0].split(" 1 ")
        if len(goal1) == 1:  
            goal1 = goal1[0].split(" ")                                 #Go to tree
            desig.action_type.data = goal1[0]
            desig.actor.data = "red"
            desig.instructor.data = "busy-genius"
            desig.viewpoint.data = "busy-genius"
            propkey.object_relation.data = goal1[1]
            propkey.object.data = goal1[4]
            propkey.object_color.data = "null"
            propkey.object_size.data = goal1[2]
            propkey.object_num.data = "null"
            propkey.flag.data = goal1[3]
            propkey.pointing_gesture.x = 0.0
            propkey.pointing_gesture.y = 0.0
            propkey.pointing_gesture.z = 0.0
            propkeys.append(propkey)
            desig.propkeys = propkeys
            desigs.append(desig)
            desig = Desig()
        else:
            goal3 = goal1[0].split(" ")                                             #Go right to tree
            desig.action_type.data = goal3[0]
            desig.actor.data = "red"
            desig.instructor.data = "busy-genius"
            desig.viewpoint.data = "busy-genius"
            propkey.object_relation.data = goal3[1]
            propkey.object.data = goal3[4]
            propkey.object_color.data = "null"
            propkey.object_size.data = goal3[2]
            propkey.object_num.data = "null"
            propkey.flag.data = goal3[3]
            propkey.pointing_gesture.x = 0.0
            propkey.pointing_gesture.y = 0.0
            propkey.pointing_gesture.z = 0.0
            propkeys.append(propkey)
            propkey = Propkey()
            goal2 = goal1[1].split(" ")
            propkey.object_relation.data = goal2[0]
            propkey.object.data = goal2[3]
            propkey.object_color.data = "null"
            propkey.object_size.data = goal2[1]
            propkey.object_num.data = "null"
            propkey.flag.data = goal2[2]
            propkey.pointing_gesture.x = 0.0
            propkey.pointing_gesture.y = 0.0
            propkey.pointing_gesture.z = 0.0
            propkeys.append(propkey)
            propkeys.reverse()
            desig.propkeys = propkeys
            desigs.append(desig)
            desig = Desig()

        goal2 = goal[1].split(" 1 ")
        if len(goal2) == 1:                                                    #take-picture
            goal2 = goal2[0].split(" ")
            desig.action_type.data = goal2[0]
            desig.actor.data = "red"
            desig.instructor.data = "busy-genius"
            desig.viewpoint.data = "busy-genius"
            propkey = Propkey()
            propkey.object_relation.data = goal2[1]
            propkey.object.data = goal2[4]
            propkey.object_color.data = "null"
            propkey.object_size.data = goal2[2]
            propkey.object_num.data = "null"
            propkey.flag.data = goal2[3]
            propkey.pointing_gesture.x = 0.0
            propkey.pointing_gesture.y = 0.0
            propkey.pointing_gesture.z = 0.0
            propkeys = []
            propkeys.append(propkey)
            desig.propkeys = propkeys
            desigs.append(desig)
            desig = Desig()
            propkeys = []
        else:                                                              #take picture to rock
            goal1 = goal2[0].split(" ")
            desig = Desig()
            propkey = Propkey()
            propkey2 = Propkey()
            propkeys = []
            desig.action_type.data = goal1[0]
            desig.actor.data = "red"
            desig.instructor.data = "busy-genius"
            desig.viewpoint.data = "busy-genius"
            propkey2.object_relation.data = goal1[1]
            propkey2.object.data = goal1[4]
            propkey2.object_color.data = "null"
            propkey2.object_size.data = goal1[2]
            propkey2.object_num.data = "null"
            propkey2.flag.data = goal1[3]
            propkey2.pointing_gesture.x = 0.0
            propkey2.pointing_gesture.y = 0.0
            propkey2.pointing_gesture.z = 0.0
            propkeys.append(propkey2)
            propkey2 = Propkey()
            propkeys2 = []
            goal4 = goal2[1].split(" ")
            #print "goal4"
            #print goal4
            propkey2.object_relation.data = goal4[0]
            propkey2.object.data = goal4[3]
            propkey2.object_color.data = "null"
            propkey2.object_size.data = goal4[1]
            propkey2.object_num.data = "null"
            propkey2.flag.data = goal4[2]
            propkey2.pointing_gesture.x = 0.0
            propkey2.pointing_gesture.y = 0.0
            propkey2.pointing_gesture.z = 0.0
            propkeys.append(propkey2)
            propkeys.reverse()
            desig.propkeys = propkeys
            desigs.append(desig)
            desig = Desig()
    
    print desigs
    
def call_main_server(req):
    #print "teeest1"
    #print req.goal
    rospy.wait_for_service("ros_parser")
    result = "Did not work!"
    try:
        ros_parser = rospy.ServiceProxy("ros_parser",text_parser)
        resp1 = ros_parser(req.goal)
        #print "teeest"
        #print resp1
        result = resp1.result
    except rospy.ServiceException, e:
        print"Service call failed: %s"%e
    
    create_hmi_msgs(resp1.result)
    return text_parserResponse(req.goal)

def start_main_server():
    rospy.init_node("start_main_server")
    s = rospy.Service("main_server", text_parser, call_main_server)
    print "Main server is up!"
    rospy.spin()



if __name__ == "__main__":
    start_main_server()
