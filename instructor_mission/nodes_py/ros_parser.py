#!/usr/bin/env python

from instructor_mission.srv import *
import rospy

speech_output = ""
value = ""

def parsing(res):
    global value
    result = res.split(" ")
    value = ""

    if result[1] == "picture":
        action = result[0]+"-picture"
        shape = "null"
        spatial = "null"
        pointing = "false"
        object = "null"
        value = action + " " + spatial + " " + shape + " " + pointing + " " +object
    elif len(result) == 2:
        print "TEEST"
        if result[0] == "go":
            action = "move"
            spatial = result[1]
            value = action + " " + spatial + " " + "null" + " " + "false" + " " +"null"
        else:
            print "TETETE"
            action = result[0]
            spatial = result[1]
            value = action + " " + spatial + " " + "null" + " " + "false" + " " +"null"
    
    new_result = res.split(" and ")
    print "WUAS"
    print len(new_result)
    print new_result
    if len(new_result) > 0:
        print "na toll"
        resume = new_result[0].split(" ")
        if len(resume) == 2:
            if resume[1] == "picture":
                value = resume[0]+ "-picture" + " null " + "null" + " " + "false" + " " +"null"
            else:
                if resume[0] == "go":
                    action = "move"
                else:
                    action = resume[0]
                spatial = resume[1]
                value = action+" "+ spatial + " null" + " " + "false" + " " +"null"
        elif len(resume) == 3:
            print "HIER BEI 3"
            if resume[0] == "go":
                action = "move"
            else:
                action = resume[0]
            spatial = resume[1]
            object = resume[2]
            value = action+" "+ spatial + " null" + " " + "false" + " " +object
        elif len(resume) == 4:
            if resume[0] == "go":
                action = "move"
            else:
                action = resume[0]
            spatial = resume[1]
            if resume[2] == "to" or resume[2] == "right" or resume[2] == "left" or resume[2] == "behind" or resume[2] == "close" or resume[2] == "front" or resume[2] == "back" or resume[2] == "next":
                spatial2 = resume[2]
                object = resume[3]
                value = action + " "+ spatial+ " "+ "null"+" "+"false"+" null"+" 1 "+spatial2+ " "+"null"+" "+"false"+" "+object
            elif resume[2] == "big" or resume[2] == "small":
                value = action + " "+ spatial+ " "+ resume[2]+" "+"false "+resume[3]               
            elif resume[2] == "that":
                value = action + " "+ spatial+ " "+ "null"+" "+"true "+resume[3]

        elif len(resume) == 5:
            if resume[0] == "go":
                action = "move"
            else:
                action = resume[0]
            spatial = resume[1]
            if resume[2] == "to" or resume[2] == "right" or resume[2] == "left" or resume[2] == "behind" or resume[2] == "close" or resume[2] == "front" or resume[2] == "back" or resume[2] == "next":
                spatial2 = resume[2]
                object = resume[4]
                if resume[3] == "big" or resume[3] == "small":
                    shape = resume[3]
                    pointing = "false"
                else:
                    shape = "null"
                    pointing = "true"
                value = action+" "+spatial+" "+"null"+" "+"false"+ " "+"null"+" 1 "+ spatial2+ " "+shape+" "+pointing+" "+object
            elif resume[3] == "to" or resume[3] == "right" or resume[3] == "left" or resume[3] == "behind" or resume[3] == "close" or resume[3] == "front" or resume[3] == "back" or resume[3] == "next":
                value = action+" "+resume[1]+" "+"null"+" "+"false"+" "+resume[2]+" 1 "+resume[3]+ " null "+"false"+" "+resume[4]
        elif len(resume) == 6: #Go to big tree next rock or Go to tree next big rock
            if resume[0] == "go":
                action= "move"
            else:
                action=resume[0]
            spatial = resume[1]
            if resume[2] == "big" or resume[2] == "small":
                shape = resume[2]
                value = action+" "+spatial+" "+shape+" "+"false"+ " "+resume[3]+" 1 "+resume[4]+" "+"null"+" "+"false "+resume[5]
            elif resume[2] == "that":
                pointing = "true"
                value = action+" "+spatial+" "+"null"+" "+"true"+ " "+resume[3]+" 1 "+resume[4]+" "+"null"+" "+"false "+resume[5]
            elif resume[4] == "big" or resume[4] == "small":
                shape2 = resume[4]
                value = action+" "+spatial+" "+"null"+" "+"false"+ " "+resume[3]+" 1 "+resume[4]+" "+shape2+" "+"false "+resume[5]
            elif resume[4] == "that":
                value = action+" "+spatial+" "+"null"+" "+"false"+ " "+resume[3]+" 1 "+resume[4]+" "+"null"+" "+"true "+resume[5]
                                
            
        # elif len(resume) == 7: #Go to big tree next big rock
        #     if resume[0] == "go":
        #         action= "move"
        #     else:
        #         action=resume[0]
        # renew = new_result[1].split(" ")
        # if len(renew) == 2:

        # elif len(renew) == 3:

        # elif len(renew) == 4:

        # elif len(renew) == 5:

        # elif len(renew) == 6:
            
        # elif len(renew) == 7:
    
    print value

    

def call_parser(req):
    print "Returning the value"
    parsing(req.goal)
    speech_output = value
    return text_parserResponse(speech_output)


def start_parser_server():
    rospy.init_node("rosparser_server")
    s = rospy.Service("ros_parser", text_parser, call_parser)
    print "Parser is ready for new instructions!"
    rospy.spin()

if __name__== "__main__":
    start_parser_server()
