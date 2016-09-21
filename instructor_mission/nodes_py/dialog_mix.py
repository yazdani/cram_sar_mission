#!/usr/bin/env python

from Tkinter import *
import rospy
from std_msgs.msg import String
from instructor_mission.msg import protocol_dialogue
from instructor_mission.srv import call_cmd
import time
import sys


def task(entry_text):
   rospy.wait_for_service('callInstruction')
   try:
      callInstruction = rospy.ServiceProxy('callInstruction', call_cmd)
      resp1 = callInstruction(entry_text,0.0,0.0,0.0)
      print  resp1.result
      window.tag_configure('rnbcolor', foreground='#ff8000',#'#EF4423', 
                           font=('Tempus Sans ITC', 12, 'italic'))
      window.insert(INSERT,'Robot agent','rcolor')
      window.insert(INSERT,'         ','rnbcolor')
      window.insert(END,'Task execution is completed, what next?\n','rnbcolor')
      return resp1.result
   except rospy.ServiceException, e:
      print "Service call failed: %s"%e

def show_entry_fields():
   global var
   entry_text = e1.get()
   #dialog_label.config(text=entry_text)
   
   if entry_text is "":
      print "Please write command"
      window.insert(INSERT,'Please give a command!\n','rotcolor')
   else:
      window.insert(INSERT,'Human operator  ','hcolor')
      window.insert(END,entry_text+'\n','hnbcolor')
      #window.tag_configure('rnbcolor', foreground='#ff8000',#'#EF4423', 
      #                     font=('Tempus Sans ITC', 12, 'italic'))
      #window.insert(INSERT,'Robot agent','rcolor')
      #window.insert(INSERT,'         ','rnbcolor')
      #window.insert(END,'OK, will start task execution!\n','rnbcolor')
      # var = 1
      #print "test"
     # window.insert(END,'var was 1!\n','rnbcolor')
    #  rospy.sleep(10.)
      task(entry_text)

  # rospy.sleep(10.)

#   rospy.wait_for_service('callInstruction')
#   try:
#      callInstruction = rospy.ServiceProxy('callInstruction', call_cmd)
#      resp1 = callInstruction(entry_text,0.0,0.0,0.0)
#      print  resp1.result
#      window.insert(INSERT,'Robot agent','rcolor')
#      window.insert(INSERT,'         ','rcolor')
#      window.insert(END,'Task execution is completed, what next?')
#      window.insert(END,'\n','rnbcolor')
#      return resp1.result
#   except rospy.ServiceException, e:
#        print "Service call failed: %s"%e

  # master.after(100, show_entry_fields)
   
  # window.pack(side=LEFT)
   #dialog_label.pack()

master = Tk()
master.title("Human-Robot Dialogue")
var = 0
#the dialog window
window = Text(master, height=20, width=90)
window.tag_configure('big', font=('Verdana',20,'bold'))
scroll = Scrollbar(master, command=window.yview)
window.configure(yscrollcommand=scroll.set)
window.configure(yscrollcommand=scroll.set)
window.tag_configure('bold_italics',font=('Arial', 12,'bold', 'italic'))
window.tag_configure('big', font=('Verdana',20,'bold'))
window.tag_configure('hcolor', foreground='#476042', 
                     font=('Tempus Sans ITC', 12, 'bold'))
window.tag_configure('hnbcolor', foreground='#476042', 
                     font=('Tempus Sans ITC', 12, 'italic'))
window.tag_configure('rcolor', foreground='#ff8000', #EF4423', 
                     font=('Tempus Sans ITC', 12, 'bold'))
window.tag_configure('rbcolor', foreground='#ff8000', #'#EF4423', 
                     font=('Tempus Sans ITC', 12, 'italic'))
window.tag_configure('rnbcolor', foreground='#ff8000', #'#EF4423', 
                     font=('Tempus Sans ITC', 12, 'italic'))
window.tag_configure('rotcolor', foreground='#EF4423', 
                     font=('Tempus Sans ITC', 12, 'bold'))

window.tag_config('coordinate',borderwidth=50)
window.tag_config('center',justify='center')
window.insert(END,'\n           \n','center')
window.insert(INSERT,'Robot agent','rcolor')
window.insert(INSERT,'         ','rcolor')
window.insert(END,'Hi master, what do I have to do?','rnbcolor')
window.insert(END,'\n','rnbcolor')
window.grid(row=6, columnspan = 2)

Label(master, text="Human operator").grid(row=0)
#Label(master, text="Last Name").grid(row=4)
dialog_label = Label(master)

e1 = Entry(master)
#e2 = Entry(master)
#e3 = Entry(master)

e1.grid(row=0, column=1)
#e2.grid(row=4, column=1)
#dialog_label.grid(row=5, column = 0, columnspan = 1)
Button(master, text='Quit', command=master.quit).grid(row=3, column=0,sticky=W, pady=4)
Button(master, text='send command', command=show_entry_fields).grid(row=3, column=1, sticky=W, pady=4)





#master.after(100, show_entry_fields)
#T = Text(master, height=2, width=30)
#T.insert(END, "Just a text Widget\nin two lines\n")

mainloop( )


