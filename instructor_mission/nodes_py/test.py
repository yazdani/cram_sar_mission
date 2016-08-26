#!/usr/bin/env python
# license removed for brevity
import rospy
import instructor_mission
from instructor_mission.msg import protocol_dialogue
from std_msgs.msg import String

def talker():
    pub = rospy.Publisher('sub_dialog',protocol_dialogue, queue_size=10)
    rospy.init_node('tf_transforms')
    rate = rospy.Rate(1) 
    tef = protocol_dialogue()
    stre = String()
    stre2= String()
    stre.data = "human"
    stre2.data = "Go right of that tree05"
    tef.agent = stre
    tef.command = stre2
    rospy.loginfo(tef)
    pub.publish(tef)
    rate.sleep()
    
if __name__ == '__main__':
    try:
        talker()
    except rospy.ROSInterruptException:
        pass
 
