#!/usr/bin/env python

from instructor_mission.srv import *
from instructor_mission.msg import *
import rospy
from std_msgs.msg import String
from geometry_msgs.msg import Point
import sys


def create_hmi_msgs(goal):
    #print goal
    desig = Desig()
    desigs = []
    goal = goal.split(" 0 ")
    propkey = Propkey()
    propkeys = []
    point = Point()
    if len(goal) == 1:
        goal = goal[0].split(" 1 ")
      #  print "goaaaal"
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
            #print desigs
    else:   
     #   print "WIR SIND BEI ZWEI"
        #Go to tree and take-picture
        goal1 = goal[0].split(" 1 ")
        #print "goal1"                                    
       # print goal[1]
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
            #propkey = Propkey()
            desig.propkeys = propkeys
            desigs.append(desig)
            desig = Desig()
            #   print "desigs"
      #      print desigs
            
        else:
            goal1 = goal1[0].split(" ")                                             #Go to tree to rock
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
            #propkey = Propkey()
            propkeys.reverse()
            desig.propkeys = propkeys
            desigs.append(desig)
            desig = Desig()

            #   print " HEEELLLOOOO "
        goal2 = goal[1].split(" 1 ")
        #    print "goal2"
        #    print goal2
       # print "Wir sind immernoch bei zwei"
       # print desigs
        if len(goal2) == 1:                                                    #take-picture
    #        print "TO"
            goal2 = goal2[0].split(" ")
    #        print "HI"
            desig.action_type.data = goal2[0]
    #        print "HA"
            desig.actor.data = "red"
    #        print "HE"
            desig.instructor.data = "busy-genius"
    #        print "HEw"
            desig.viewpoint.data = "busy-genius"
   #         print "HsE"
        #    print "propkeeeeeeeeeeeeeeeeeeeeeeeeeeey"
        #    print propkey
            propkey = Propkey()
        #    print propkey
            propkey.object_relation.data = goal2[1]
   #         print "HEe"
            propkey.object.data = goal2[4]
   #         print "HEes"
            propkey.object_color.data = "null"
 #           print "HEsse"
            propkey.object_size.data = goal2[2]
 #           print "HEadade"
            propkey.object_num.data = "null"
 #           print "HEadaddse"
            propkey.flag.data = goal2[3]
            propkey.pointing_gesture.x = 0.0
            propkey.pointing_gesture.y = 0.0
            propkey.pointing_gesture.z = 0.0
        #    print propkeys
            propkeys = []
            propkeys.append(propkey)
            #propkey = Propkey()
            desig.propkeys = propkeys
         #   print "desig"
          #  print desig
           # print "desigs"
           # print desigs
            desigs.append(desig)
            desig = Desig()
        else:                                                              #take picture to rock
 #           print "TEEEST"
  #          print goal2
            goal1 = goal2[0].split(" ")
  #          print "goal1"
 #           print goal1
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
            #propkey = Propkey()
            goal2 = goal2[1].split(" ")
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
    
    print desigs
    
def call_main_server(req):
    print "teeest1"
    print req.goal
    rospy.wait_for_service("ros_parser")
    result = "Did not work!"
    try:
        ros_parser = rospy.ServiceProxy("ros_parser",text_parser)
        resp1 = ros_parser(req.goal)
        print "teeest"
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
