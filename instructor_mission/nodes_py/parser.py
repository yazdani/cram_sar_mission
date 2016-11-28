#!/usr/bin/env python

from instructor_mission.srv import *
import rospy

speech_output = ""
value = ""

def parsing(result):
    global value
    print result
    result = result.split(" ")
    value = ""
    print result
    if len(result) == 2 and result[0] == "Take" and result[1] == "picture":
        action = "take-picture"
        spatial = "null"
        shape = "null"
        pointing = "false"
        object = "null"
        value = action + " " + spatial + " " + shape + " " + pointing + " " +object
    
    if len(result) == 2 and result[0] == "Come" and result[1] == "back":
        action = "come-back"
        spatial = "null"
        shape = "null"
        pointing = "false"
        object = "null"
        value = action + " " + spatial + " " + shape + " " + pointing + " " +object
   
    if len(result) == 2 and result[0] == "Show" and result[1] == "picture":
        action = "show-picture"
        spatial = "null"
        shape = "null"
        pointing = "false"
        object = "null"
        value = action + " " + spatial + " " + shape + " " + pointing + " " +object

    if len(result) == 2:
        if result[0] == "Go":
            action = "move"
            spatial = result[1]
            shape = "null"
            pointing = "false"
            object = "null"
            value = action + " " + spatial + " " + shape + " " + pointing + " " +object

    elif result[0] == "Take" and result[1] == "picture":
        action = "take-picture"
        shape = "null"
        spatial = "null"
        pointing = "false"
        object = "null"
        value = action + " " + spatial + " " + shape + " " + pointing + " " +object
        if result[2] == "and":
            #create-designator
            if result[3] == "take" and result[4] == "picture":
                action = "take-picture"
                spatial = "null"
                shape = "null"
                pointing = "false"
                object = "null"
                value = value + " 0"+ " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
            elif result[3] == "show" and result[4] == "picture":
                action = "show-picture"
                spatial = "null"
                pointing = "false"
                shape = "null"
                object = "null"
                value = value + " 0" + " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
            else:
                if result[3] == "go":
                    action = "move"
                else:                 
                    action = result[3]
                spatial = result[4]
                if result[5] == "big" or result[5] == "small":
                    shape = result[5]
                    pointing = "false"
                    object = result[6]
                    value = value + " 0"+ " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
                elif result[5] == "that":
                    pointing = "true"
                    shape = "null"
                    object = result[6]
                    value = value + " 0"+ " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
                else:
                    pointing = "false"
                    shape = "null"
                    object = result[5]
                    value = value + " 0"+ " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
                print "EINMAL"
    elif result[0] == "Show" and result[1] == "picture":
        action = "show-pictue"
        pointing = "false"
        object = "null"
        spatial = "null"
        shape = "null"
        value = action + " " + spatial + " " + shape + " " + pointing + " " +object
        if result[2] == "and":
            #create-designator
            if result[3] == "take" and result[4] == "picture":
                action = "take-picture"
                object = "null"
                spatial = "null"
                shape = "null"
                pointing = "false"
                value = value + " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
            elif result[3] == "show" and result[4] == "picture":
                action = "show-picture"
                object = "null"
                spatial = "null"
                shape = "null"
                pointing = "false"
                value = value + " 0"+ " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
            else:
                if result[3] == "go":
                    action = "move"
                else:                 
                    action = result[3]
            
                spatial = result[4]
                if result[5] == "big" or result[5] == "small":
                    pointing = "false"
                    shape = result[5]
                    object = result[6]
                    value = value + " 0"+ " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
                elif result[5] == "that":
                    shape = "null"
                    pointing = "true"
                    object = result[6]
                    value = value + " 0"+ " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
                else:
                    pointing = "false"
                    shape = "null"
                    object = result[5]
                    value = value + " 0"+ " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
            print "Zweimal"
    else:
        if result[0] == "Go":
            action = "move"
        else:
            action = result[0]
        spatial = result[1]
        if result[2] == "big" or result[2] == "small":
            pointing = "null"
            shape = result[2]
            object = result[3]
            value = action + " " + spatial + " " + shape + " " + pointing + " " +object
            if len(result) > 4:
                if result[4] == "and":
                    # create designator
                    if result[5] == "go":
                        action2 = "move"
                        spatial2 = result[6]
                        if len(result) > 7:
                            if result[7] == "that":
                                 value = value + " 0 " + action2 + " "+ spatial2 + " null "+ "true"+ " "+ result[8]
                            elif result[7] == "small" or result[7] == "big":
                                 value = value + " 0 " + action2 + " "+ spatial2 + " "+result[7]+ " false "+ result[8]
                            else:
                                value = value + " 0 " + action2 + " "+ spatial2 + " null "+ "false"+ " "+ result[7]
                        else:
                            value = value + " 0 " + action2 + " "+ spatial2 + " null "+ "false"+ " null "
                    else:
                        action = result[5]
                        if result[6] == "picture":
                            action = action+"-picture"
                            spatial = "null"
                            object = "null"
                            shape = "null"
                            pointing = "false"
                            value = value + " 0"+ " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
                        else:
                            spatial = result[6]
                            if result[7] == "small" or result[7] == "big":
                                pointing = "false"
                                shape = result[7]
                                object = result[8]
                                value = value + " 0"+ " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
                            elif result[7] == "that":
                                pointing = "true"
                                shape = "null"
                                object = result[8]
                                value = value + " 0"+ " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
                            else:
                                pointing = "false"
                                shape = "null"
                                object = result[7]
                                value = value + " 0"+ " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
                else:
                    spatial2 = result[4]
                    if result[5] == "small" or result[5] == "big":
                        pointing = "false"
                        shape = result[5]
                        object = result[6]
                        value = value + " 1"+" " + spatial2 + " " + shape + " " + pointing + " " +object
                    elif result[5] == "that":
                        pointing = "true"
                        shape = "null"
                        object = result[6]
                        value = value + " 1"++ " " + spatial2 + " " + shape + " " + pointing + " " +object
                    else:
                        pointing = "false"
                        shape = "null"
                        object = result[5]
                        value = value + " 1"+" " + spatial2 + " " + shape + " " + pointing + " " +object
            elif result[4] == "to" or result[4] == "right" or result[4] == "left" or result[4] == "around" or result[4] == "close" or result[4] == "next" or result[4] == "behind" or result[4] == "ontop":
                    spatial2 = result[4]
               #     value = value + " 1"+ " " + spatial2 + " " + "null" + " " + "null" + " " + "null"
                    object2= result[5]
                    if result[5] == "small" or result[5] == "big":
                        shape2 = result[5]
                        pointing2 = "false"
                        object2 = result[6]
                        value = value + " 1"+ " " + spatial2 + " " + shape2 + " " + pointing2 + " " +object2 
                    elif result[5] == "that":
                        value = value + " 1"+ " " + spatial2 + " " + "null" + " " + "true" + " " + result[6]
                    elif len(result) == 7:
                        value = value + " 1" +" " + spatial2 + " " + "null" + " " + "false" + " " + result[6]
                    else:
                        value = value + " 1" +" " + spatial2 + " " + "null" + " " + "false" + " " + object2
                    
        elif result[2] == "that":
            pointing = "true"
            shape = "null"
            object = result[3]
            value = action + " " + spatial + " " + shape + " " + pointing + " " +object
            if len(result) > 4:
                print "VIERMAL"
                print result[4]
                if result[4] == "and":
                    # create designator
                    if result[5] == "go":
                        action = "move"
                    else:
                        action = result[5]
                    if result[6] == "picture":
                        action = action+"-picture"
                        shape = "null"
                        pointing = "false"
                        object = "null"
                        spatial = "null"
                        value = value + " 0"+ " "+ action + " " + spatial + " " + shape + " " + pointing + " " +object
                    else:
                        spatial = result[6]
                        if result[7] == "small" or result[7] == "big":
                            shape = result[7]
                            pointing = "false"
                            object = result[8]
                            value = value + " 0"+ " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
                        elif result[7] == "that":
                            shape = "null"
                            pointing = "true"
                            object = result[8]
                            value = value + " 0"+ " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
                        else:
                            shape = "null"
                            pointing = "false"
                            object = result[7]
                            value = value + " 0"+ " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
                            if len(result) > 8:
                                print "JUHUUUUUUUUUUUUUUUUUUUUUUUUU"
                elif result[4] == "to" or result[4] == "right" or result[4] == "left" or result[4] == "around" or result[4] == "close" or result[4] == "next" or result[4] == "behind" or result[4] == "ontop":
                    spatial2 = result[4]
                    object2 = result[5]
                    # value = action + " " + spatial + " " + "null" + " " + "null" + " " + "null"
                    #object2= result[3]
                    if result[5] == "small" or result[5] == "big":
                        shape2 = result[5]
                        pointing2 = "false"
                        object2 = result[6]
                        value = value + " 1"+ " " + spatial2 + " " + shape2 + " " + pointing2 + " " +object2 
                    elif result[5] == "that":
                        value = value + " 1"+ " " + spatial2 + " " + "null" + " " + "true" + " " + result[6]
                    elif len(result) == 7:
                        value = value + " 1" +" " + spatial2 + " " + "null" + " " + "false" + " " + result[6]
                    else:
                        value = value + " 1" +" " + spatial2 + " " + "null" + " " + "false" + " " + object2

        elif result[2] == "and":
            shape = "null"
            pointing = "null"
            object = "null"
            value = action + " " + spatial + " " + shape + " " + pointing + " " +object
            #create-designator
            if result[3] == "take" and result[4] == "picture":
                spatial = "null"
                shape = "null"
                pointing = "false"
                object = "null"
                value = value + " 0"+ " "+"take-picture" + " " + spatial + " " + shape + " " + pointing + " " +object
            elif result[3] == "show" and result[4] == "picture":
                spatial = "null"
                shape = "null"
                pointing = "false"
                object = "null"
                value = value + " 0"+ " "+"show-picture" + " " + spatial + " " + shape + " " + pointing + " " +object
            elif len(result) == 5 and result[3] == "go":
                spatial = "null"
                shape = "null"
                pointing = "false"
                object = "null"
                value = value + " 0"+ " "+"move" + " " + result[4] + " " + shape + " " + pointing + " " +object
            elif len(result) == 5:
                spatial = "null"
                shape = "null"
                pointing = "false"
                object = "null"
                value = value + " 0"+ " "+"move" + " " + result[3] + " " + shape + " " + pointing + " " +object
            else:
                if result[3] == "go":
                    action = "move"
                else:
                    action = result[3]
                spatial = result[4]
                if result[5] == "that":
                    pointing = "true"
                    shape = "null"
                    object = result[6]
                    value = value + " 0"+ " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
                elif result[5] == "small" or result[5] == "big":
                    pointing = "null"
                    shape = result[5]
                    object = result[6]
                    value = value + " 0"+ " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
                else:
                    pointing = "null"
                    shape = "null"
                    object = result[5]
                    value = value + " 0"+ " "+action + " " + spatial + " " + shape + " " + pointing + " " +object    
                    print "fuenfmal"

        elif result[2] == "to" or result[2] == "right" or result[2] == "left" or result[2] == "around" or result[2] == "close" or result[2] == "next" or result[2] == "behind" or result[2] == "ontop":
            spatial2 = result[2]
            value = action + " " + spatial + " " + "null" + " " + "null" + " " + "null"
            object2= result[3]
            if result[3] == "small" or result[3] == "big":
                shape2 = result[3]
                pointing2 = "false"
                object2 = result[4]
                value = value + " 1"+ " " + spatial2 + " " + shape2 + " " + pointing2 + " " +object2 
            elif result[3] == "that":
                value = value + " 1"+ " " + spatial2 + " " + "null" + " " + "true" + " " + result[4]
            elif len(result) == 5:
                value = value + " 1" +" " + spatial2 + " " + "null" + " " + "false" + " " + result[4]
            else:
                 value = value + " 1" +" " + spatial2 + " " + "null" + " " + "false" + " " + object2
        else:
            object = result[2]
            shape = "null"
            pointing = "false"
            value = action + " " + spatial + " " + shape + " " + pointing + " " +object
            if len(result) > 3:
                if result[3] == "and":
                    # create designator
                    if result[4] == "take" and result[5] == "picture":
                        action = "take-picture"
                        spatial = "null"
                        shape = "null"
                        pointing = "false"
                        object = "null"
                        value = value + " 0"+" "+action + " " + spatial + " " + shape + " " + pointing + " " +object
                    elif result[4] == "show" and result[5] == "picture":
                        action = "show-picture"
                        spatial = "null"
                        shape = "null"
                        pointing = "false"
                        object = "null"
                        value = value + " 0"+ " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
                    else:
                        if result[4] == "go":
                            action = "move"
                        else:
                            action = result[4]
                        spatial = result[5]
                        if result[6] == "small" or result[6] == "big":
                            shape = result[6]
                            pointing = "false"
                            object = result[7]
                            value = value + " 0"+ " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
                        elif result[6] == "that":
                            pointing = "true"
                            shape = "null"
                            object = result[7]
                            value = value + " 0"+ " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
                        elif result[6] != "":
                            shape = "null"
                            pointing = "false"
                            object = result[6]
                            value = value + " 0"+ " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
                        else:
                            object = "null"
                            shape ="null"
                            pointing = "false"
                            value = value + " 0"+ " "+action + " " + spatial + " " + shape + " " + pointing + " " +object
                else:
                    print "sechsmal"
                    if result[3] == "to" or result[3] == "right" or result[3] == "left" or result[3] == "around" or result[3] == "close" or result[3] == "next" or result[3] == "behind" or result[3] == "ontop":
                        spatial2 = result[3]
                        object2 = result[4]
                        if result[4] == "small" or result[4] == "big":
                            shape2 = result[4]
                            pointing2 = "false"
                            object2 = result[5]
                            value = value + " 1"+ " " + spatial2 + " " + shape2 + " " + pointing2 + " " +object2 
                        elif result[4] == "that":
                            value = value + " 1"+ " " + spatial2 + " " + "null" + " " + "true" + " " + result[5]
                        else:
                            value = value + " 1"+" " + spatial2 + " " + "null" + " " + "false" + " " + object2
                    print "sechsmal"
                    if len(result) > 6:
                        if result[7] == "picture":
                            value = value + " 0 "+result[6]+"-picture" +" null "+"null"+" false "+"null"
                        else:
                            if result[6] == "go":
                                action2 = "move"
                            else:
                                action2 = result[6]
                            spatial2 = result[7]
                            object2 = result[8]
                            if result[8] == "big" or result[8] == "small":
                                shape2 = result[8]
                                pointing2 = "false"
                                object2 = result[9]
                                value = value + " 0 "+action2 +" "+spatial2+" "+shape2+" "+pointing2+" "+object2
                            elif result[8] == "that":
                                shape2 = "null"
                                pointing2 = "true"
                                object2 = result[9]
                                value = value + " 0 "+action2 +" "+spatial2+" "+shape2+" "+pointing2+" "+object2
                            else:
                                value = value + " 0 "+action2 +" "+spatial2+" "+"null"+" "+"false"+" "+object2
                            if len(result) > 10:
                                print "test"
                                print result[10]
                                if result[9] == "to" or result[9] == "right" or result[9] == "left" or result[9] == "around" or result[9] == "close" or result[9] == "next" or result[9] == "behind" or result[9] == "ontop":
                                    spatial2 = result[9]
                                    if result[10] == "that":
                                        pointing2 = "true"
                                        shape2 = "null"
                                        object2 = result[11]
                                        value = value + " 1 "+spatial2+" "+shape2+" "+pointing2+" "+object2
                                    elif result[10] == "small" or result[10] == "big":
                                        pointing2 = "false"
                                        shape2 = "null"
                                        object2 = result[11]
                                        value = value + " 1 "+spatial2+" "+shape2+" "+pointing2+" "+object2
                                    else:
                                        pointing2 = "false"
                                        shape2 = "null"
                                        object2 = result[10]
                                        value = value + " 1 "+spatial2+" "+shape2+" "+pointing2+" "+object2
                                elif result[10] == "to" or result[10] == "right" or result[10] == "left" or result[10] == "around" or result[10] == "close" or result[10] == "next" or result[10] == "behind" or result[10] == "ontop":
                                    spatial2 = result[10]
                                    if result[11] == "that":
                                        pointing2 = "true"
                                        shape2 = "null"
                                        object2 = result[12]
                                        value = value + " 1 "+spatial2+" "+shape2+" "+pointing2+" "+object2
                                    elif result[11] == "small" or result[11] == "big":
                                        pointing2 = "false"
                                        shape2 = "null"
                                        object2 = result[12]
                                        value = value + " 1 "+spatial2+" "+shape2+" "+pointing2+" "+object2
                                    else:
                                        pointing2 = "false"
                                        shape2 = "null"
                                        object2 = result[11]
                                        value = value + " 1 "+spatial2+" "+shape2+" "+pointing2+" "+object2
 

    

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