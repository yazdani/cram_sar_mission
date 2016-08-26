#!/usr/bin/env python

from Tkinter import *
import rospy
from std_msgs.msg import String
from instructor_mission.msg import protocol_dialogue

def task():
    global num
    global window
    global agent
    global cmd
    #print("hello")
  
    rospy.Subscriber("sub_dialog", protocol_dialogue, cback)
    #  rospy.spin()
    if num is 1:
        #print 'TEEEEEST'
        #print agent
        if 'robot' in agent:
            window.insert(INSERT,'Robot agent         ','rcolor')
            window.insert(INSERT,cmd,'rnbcolor')
            window.insert(END,'\n','rnbcolor')
        else:
            window.insert(INSERT,'Human operator  ','hcolor')
            window.insert(END,cmd,'hnbcolor')
            window.insert(END,'\n','hnbcolor')
        num = 0
        agent=""
        cmd=""
    root.after(100, task)  # reschedule event in 0.1 seconds

def cback(data):
    global num
    global agent
    global cmd
    #print type(data)
 
    num = 1
    agent = data.agent.data
    cmd = data.command.data
    #global window
    #print("test hello")
#INSERT,'Human operator ','hcolor')
#    window.insert(INSERT,'  ','hcolor')
#    window.insert(END,'Go right of the tree','hnbcolor')
#    window.insert(END,'\n','hnbcolor')

def startDisplay():
    global window
    global root
    global num
    num=0
    root = Tk()
    root.title("Human-Robot Dialogue")
    window = Text(root, height=20, width=90)
    scroll = Scrollbar(root, command=window.yview)
    window.configure(yscrollcommand=scroll.set)
    window.tag_configure('bold_italics',font=('Arial', 12,'bold', 'italic'))
    window.tag_configure('big', font=('Verdana',20,'bold'))
    window.tag_configure('hcolor', foreground='#476042', 
                         font=('Tempus Sans ITC', 12, 'bold'))
    window.tag_configure('hnbcolor', foreground='#476042', 
                         font=('Tempus Sans ITC', 12, 'italic'))
    window.tag_configure('rcolor', foreground='#EF4423', 
                         font=('Tempus Sans ITC', 12, 'bold'))
    window.tag_configure('rbcolor', foreground='#EF4423', 
                         font=('Tempus Sans ITC', 12, 'italic'))
    window.tag_configure('rnbcolor', foreground='#EF4423', 
                         font=('Tempus Sans ITC', 12, 'italic'))
    
    window.tag_config('coordinate',borderwidth=50)
    window.tag_config('center',justify='center')
    window.insert(INSERT,'     ','big')
    window.insert(END,'Human-Robot Interaction Dialogue\n','big')
    window.insert(END,'\n           \n','center')
    window.insert(END,'\n           \n','center')
    window.insert(INSERT,'Robot agent','rcolor')
    window.insert(INSERT,'         ','rcolor')
    window.insert(END,'Hi master, what do I have to do?','rnbcolor')
    window.insert(END,'\n','rnbcolor')
    window.pack(side=LEFT)
    scroll.pack(side=RIGHT, fill=Y)
    #root.geometry("600x700")
    #root.title("Human-Robot Dialogue")
    #white="white"
    #root.configure(background=white)
    #test = "heelloo"
    #w = Label(root,justify=CENTER,padx=50,pady=5,text=test, bg=white).pack(side="left")
    #w.pack()
    #print "test"
    
    
    root.after(100, task)
    root.mainloop()
    #rospy.spin()

if __name__ == '__main__':
    rospy.init_node('display_dialogue')
    startDisplay()
    

