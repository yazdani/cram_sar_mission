#!/usr/bin/env python

from instructor_mission.srv import *
import rospy
import re

speech_output = ""
value = ""

def parsing(res):
    global value
    print "parsing"
    print res
    res = res.lower()
    res = re.sub('next to', 'to', res)
    res = re.sub('close to', 'next', res)
    print res
    result = res.split(" ")
    value = ""
    print "res"
    print res
    if result[1] == "picture":
        action = result[0]+"-picture"
        shape = "null"
        spatial = "null"
        pointing = "false"
        object = "null"
        value = action + " " + spatial + " " + shape + " " + pointing + " " +object
    elif len(result) == 2:
        if result[1] == "area" or result[1] == "region":
            action = "scan-area"
            spatial = "null"
        elif result[1] == "back":
            action = "come-back"
            spatial = "null"
        else:
            action = result[0]
            spatial = result[1]
        value = action + " " + spatial + " " + "null" + " " + "false" + " " +"null"
    
    new_result = res.split(" and ")
    if len(new_result) > 0:
        resume = new_result[0].split(" ")
        if len(resume) == 2:
            if resume[1] == "picture":
                value = resume[0]+ "-picture" + " null " + "null" + " " + "false" + " " +"null"
            elif resume[1] == "area" or resume[1] == "region":
                value = resume[0]+ "-area" + " null " + "null" + " " + "false" + " " +"null"
            elif resume[1] == "back":
                value = resume[0]+ "-back" + " null " + "null" + " " + "false" + " " +"null"
            else:
                action = resume[0]
                spatial = resume[1]
                value = action+" "+ spatial + " null" + " " + "false" + " " +"null"
        elif len(resume) == 3:
            action = resume[0]
            spatial = resume[1]
            object = resume[2]
            value = action+" "+ spatial + " null" + " " + "false" + " " +object
        elif len(resume) == 4:
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
            action=resume[0]
            spatial = resume[1]
            if resume[1] == "to" and resume[3] == "next":
                print "value"
                value = action+" "+resume[1]+" "+"null"+" "+"true"+ " "+resume[2]+" 1 "+resume[3]+" "+"null"+" "+"false "+resume[5]
            elif resume[1] == "next" and resume[4] == "to":
                value = action+" "+resume[1]+" "+"null"+" "+"true"+ " "+resume[3]+" 1 "+resume[4]+" "+"null"+" "+"false "+resume[5]

            if resume[2] == "big" or resume[2] == "small":
                shape = resume[2]
                value = action+" "+spatial+" "+shape+" "+"false"+ " "+resume[3]+" 1 "+resume[4]+" "+"null"+" "+"false "+resume[5]
            elif resume[2] == "that":
                pointing = "true"
                value = action+" "+spatial+" "+"null"+" "+"true"+ " "+resume[3]+" 1 "+resume[4]+" "+"null"+" "+"false "+resume[5]
            
            if resume[4] == "big" or resume[4] == "small":
                shape2 = resume[4]
                value = action+" "+spatial+" "+"null"+" "+"false"+ " "+resume[2]+" 1 "+resume[3]+" "+shape2+" "+"false "+resume[5]
            elif resume[4] == "that":
                value = action+" "+spatial+" "+"null"+" "+"false"+ " "+resume[2]+" 1 "+resume[3]+" "+"null"+" "+"true "+resume[5]
            
            print "value"
            print value
            print resume[1]
            print resume[3]
        elif len(resume) == 7: #Go to big tree next big rock
            action=resume[0]
            spatial = resume[1]
            spatial2 = resume[4]
            object = resume[3]
            object2 =resume[6]
            shape = "null"
            shape2 = "null"
            pointing = "false"
            pointing2 = "false"
            if resume[2] == "big" or resume[2] == "small":
                shape = resume[2]
            elif resume[2] == "that":
                pointing = "true"

            if resume[5] == "big" or resume[5] == "small":
                shape2 = resume[5]
            elif resume[5] == "that":
                pointing2 = "true"
                
            value = action+" "+spatial+" "+shape+" "+pointing+" "+object+" 1 "+spatial2+" "+shape2+" "+pointing2+" "+object2
    
    if len(new_result) > 1:
        renew = new_result[1].split(" ")
        if len(renew) == 2:
            if renew[1] == "picture":
                value = value+" 0 "+renew[0]+"-picture"+" null "+"null"+" false "+"null"
            elif renew[1] == "area" or renew[1] == "region":
                value = value+" 0 "+renew[0]+"-area"+" null "+"null"+" false "+"null"

            elif renew[1] == "back":
                value = value+" 0 "+renew[0]+"-back"+" null "+"null"+" false "+"null"
            else:
                value = value+" 0 "+renew[0]+" "+renew[1]+" null "+"false"+" null"
        elif len(renew) == 3:
            value = value+" 0 "+renew[0]+" "+renew[1]+" "+"null"+" false "+renew[2]
        elif len(renew) == 4:
            action = "null"
            spatial="null"
            pointing="null"
            object="null"
            action = renew[0]
            spatial = renew[1]
            object = renew[3]
            if renew[2] == "that":
                pointing = "true"
                value = value+" 0 "+action+" "+spatial+" "+shape+" "+pointing+" "+object

            elif renew[2] == "big" or renew[2] == "small":
                shape = renew[2]
                value = value+" 0 "+action+" "+spatial+" "+shape+" "+pointing+" "+object
            else:
                value = value+" 0 "+action+" "+renew[1]+" null "+"false"+" null "+"1 "+renew[2]+" null "+"false "+renew[3]
        elif len(renew) == 5: #Go to rock right tree or Go right to big/small/that rock
            action = resume[0]
            if renew[3] == "big" or renew[3] == "small":
                value = value+" 0 "+action+" "+renew[1]+" "+"null"+" false null"+" 1 "+renew[2]+" "+renew[3]+" "+"false "+renew[4]
            elif renew[3] == "that":
                value = value+" 0 "+action+" "+renew[1]+" "+"null"+" true null"+" 1 "+renew[2]+" "+"null"+" "+"true "+renew[4]
            else:
                value = value+" 0 "+action+" "+renew[1]+" "+"null"+" false "+renew[2]+" 1 "+renew[3]+" "+"null"+" "+"false "+renew[4]
        elif len(renew) == 6: #Go to tree left big rock or Go to big tree left rock
            action=renew[0]
            spatial = renew[1]
            if renew[2] == "big" or renew[2] == "small":
                shape = renew[2]
                value = value+" 0 "+action+" "+spatial+" "+shape+" "+"false"+ " "+renew[3]+" 1 "+renew[4]+" "+"null"+" "+"false "+renew[5]
            elif renew[2] == "that":
                pointing = "true"
                value =  value+" 0 "+action+" "+spatial+" "+"null"+" "+"true"+ " "+renew[3]+" 1 "+renew[4]+" "+"null"+" "+"false "+renew[5]
            
            if renew[4] == "big" or renew[4] == "small":
                shape2 = renew[4]
                value =  value+" 0 "+action+" "+spatial+" "+"null"+" "+"false"+ " "+renew[2]+" 1 "+renew[3]+" "+shape2+" "+"false "+renew[5]
            elif renew[4] == "that":
                value =  value+" 0 "+action+" "+spatial+" "+"null"+" "+"false"+ " "+renew[2]+" 1 "+renew[3]+" "+"null"+" "+"true "+renew[5]
        elif len(renew) == 7:
            action=renew[0]
            spatial = renew[1]
            spatial2 = renew[4]
            object = renew[3]
            object2 =renew[6]
            shape = "null"
            shape2 = "null"
            pointing = "false"
            pointing2 = "false"
            if renew[2] == "big" or renew[2] == "small":
                shape = renew[2]
            elif renew[2] == "that":
                pointing = "true"

            if renew[5] == "big" or renew[5] == "small":
                shape2 = renew[5]
            elif renew[5] == "that":
                pointing2 = "true"
                
            value =  value+" 0 "+action+" "+spatial+" "+shape+" "+pointing+" "+object+" 1 "+spatial2+" "+shape2+" "+pointing2+" "+object2
    print value

    

def call_parser(req):
    print "call_parser"
    parsing(req.goal)
    speech_output = value
    print "speech_output"
    print speech_output
    print "value"
    print value
    return text_parserResponse(speech_output)


def start_parser_server():
    rospy.init_node("rosparser_server")
    s = rospy.Service("ros_parser", text_parser, call_parser)
    print "Parser is ready for new instructions!"
    rospy.spin()

if __name__== "__main__":
    start_parser_server()
