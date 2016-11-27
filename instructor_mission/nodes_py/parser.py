#!/usr/bin/env python

from instructor_mission.srv import *
import rospy

speech_output = ""

def parsing(result):
    result = result.split(" ")
    
    if len(result) == 2 and result[0] == "take" and result[1] == "picture":
        action = "take-picture"
        spatial = "null"
        shape = "null"
        pointing = "false"
        object = "null"
    
    if len(result) == 2 and result[0] == "show" and result[1] == "picture":
        action = "show-picture"
        spatial = "null"
        shape = "null"
        pointing = "false"
        object = "null"

    if len(result) == 2:
        if result[0] == "go":
            action = "move"
            spatial = result[1]
            shape = "null"
            pointing = "false"
            object = "null"

    elif result[0] == "take" and result[1] == "picture":
        action = "take-picture"
        shape = "null"
        spatial = "null"
        pointing = "false"
        object = "null"
        if result[2] == "and":
            #create-designator
            if result[3] == "take" and result[4] == "picture":
                action = "take-picture"
                spatial = "null"
                shape = "null"
                pointing = "false"
                object = "null"
            elif result[3] == "show" and result[4] == "picture":
                action = "show-picture"
                spatial = "null"
                pointing = "false"
                shape = "null"
                object = "null"
            else:
                action = result[3]
                spatial = result[4]
                if result[5] == "big" or result[5] == "small":
                    shape = result[5]
                    pointing = "false"
                    object = result[6]
                elif result[5] == "that":
                    pointing = "true"
                    shape = "null"
                    object = result[6]
                else:
                    pointing = "false"
                    shape = "null"
                    object = result[5]
    elif result[0] == "show" and result[1] == "picture":
        action = "show-pictue"
        pointing = "false"
        object = "null"
        spatial = "null"
        shape = "null"
        if result[2] == "and":
            #create-designator
            if result[3] == "take" and result[4] == "picture":
                action = "take-picture"
                object = "null"
                spatial = "null"
                shape = "null"
                pointing = "false"
            elif result[3] == "show" and result[4] == "picture":
                action = "show-picture"
                object = "null"
                spatial = "null"
                shape = "null"
                pointing = "false"
            else:
                action = result[3]
                spatial = result[4]
                if result[5] == "big" or result[5] == "small":
                    pointing = "false"
                    shape = result[5]
                    object = result[6]
                elif result[5] == "that":
                    shape = "null"
                    pointing = "true"
                    object = result[6]
                else:
                    pointing = "false"
                    shape = "null"
                    object = result[5]
    else:
        if result[0] == "go":
            action = "move"
        else:
            action = result[0]
        spatial = result[1]
        if result[2] == "big" or result[2] == "small":
            pointing = "null"
            shape = result[2]
            object = result[3]
            if result[4] == "and":
                # create designator
                if result[5] == "go":
                    action = "move"
                else:
                    action = result[5]
                if result[6] == "picture":
                    action = action+"-picture"
                    spatial = "null"
                    object = "null"
                    shape = "null"
                    pointing = "false"
                else:
                    spatial = result[6]
                    if result[7] == "small" or result[7] == "big":
                        pointing = "false"
                        shape = result[7]
                        object = result[8]
                    elif result[7] == "that":
                        pointing = "true"
                        shape = "null"
                        object = result[8]
                    else:
                        pointing = "false"
                        shape = "null"
                        object = result[7]
        elif result[2] == "that":
            pointing = "true"
            shape = "null"
            object = result[3]
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
                else:
                    spatial = result[6]
                    if result[7] == "small" or result[7] == "big":
                        shape = result[7]
                        pointing = "false"
                        object = result[8]
                    elif result[7] == "that":
                        shape = "null"
                        pointing = "true"
                        object = result[8]
                    else:
                        shape = "null"
                        pointing = "false"
                        object = result[7]
        else:
            object = result[2]
            if result[3] == "and":
                # create designator
                if result[4] == "take" and result[5] == "picture":
                    action = "take-picture"
                    spatial = "null"
                    shape = "null"
                    pointing = "false"
                    object = "null"
                elif result[4] == "show" and result[5] == "picture":
                    action = "show-picture"
                    spatial = "null"
                    shape = "null"
                    pointing = "false"
                    object = "null"
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
                        elif result[6] == "that":
                            pointing = "true"
                            shape = "null"
                            object = result[7]
                        elif result[6] != "":
                            shape = "null"
                            pointing = "false"
                            object = result[6]
                        else:
                            object = "null"
                            shape ="null"
                            pointing = "false"
    

    

def parser(req):
    print "Returning the value"
    speech_output = parsing(req.goal)
    return text_parserResponse(speech_output)


def parser_server():
    rospy.init_node("rosparser_server")
    s = rospy.Service("command_parser", text_parser, parser)

if __name__== "__main__":
    parser_server()
