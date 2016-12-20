#!/usr/bin/env python
from Tkinter import *
import rospy
from std_msgs.msg import String
from instructor_mission.msg import protocol_dialogue
from instructor_mission.srv import call_cmd
import time
import sys
import rospkg

checker="false"

def client_sending(data):
   change_image_field()
   rospy.wait_for_service('callInstruction')
   try:
      callInstruction = rospy.ServiceProxy('callInstruction', call_cmd)
      resp1 = callInstruction(data,0.0,0.0,0.0)
      window.insert(INSERT,'Robot:  ','hcolor')
      window.insert(END,"Task completed!"+'\n','hnbcolor')

      #change_image_field()
      #return resp1.result
   except rospy.ServiceException, e:
      print "Service call failed: %s"%e

   

def func(event):
   e1.delete("end-1c",END)
   show_entry_fields()

def publisher_callback(data):
   print data.data
   if checker == "true":
      if data.data != "SWITCH":
         result = data.data
         if result == "COMEBACK":
            result="COME BACK"
         elif result == "TAKEPICTURE":
            result = "TAKE PICTURE"
         elif result == "SCANFOREST":
            result = "SCAN FOREST"
         elif result == "SCANAREA":
            result = "SCAN AREA"
         elif result == "TAKEOFF":
            result="TAKE OFF"
         window.insert(INSERT,'Genius:  ','hcolor')
         window.insert(END,result.upper()+'\n','hnbcolor')
         string = String()
         string.data = result.upper()
         result = result.lower()
         client_sending(result.capitalize())
         #pub.publish(data.data.upper())
      else:
         change_image_field()

def change_image_field():
   global checker
   if checker == "false":
      checker = "true"
      b1.config(image=on)
   else:
      checker = "false"
      b1.config(image=off)

def show_entry_fields():
   if len(e1.get("1.0", "end-1c")) == 0 or  len(e1.get("1.0", "end-1c")) == 1:
      window.insert(INSERT,'Please give a command!\n','rotcolor')
      e1.delete("1.0","end-1c")
   else:
      entry_text = e1.get("1.0","end-1c")
      e1.delete("1.0","end-1c")
      result = entry_text.upper() 
      if result == "COMEBACK":
         result = "COME BACK"
      elif result == "TAKEPICTURE":
         result="TAKE PICTURE"
      elif result == "SCANFOREST":
         result="SCAN FOREST"
      elif result == "SCANAREA":
         result="SCAN AREA"
      elif result == "TAKEOFF":
         result="TAKE OFF"
      window.insert(INSERT,'Genius:  ','hcolor')
      window.insert(END,result+'\n','hnbcolor')
      result.replace("\n","")
      string = String()
      string.data = entry_text.upper()
      result = result.lower()
      client_sending(result.capitalize())
     # pub.publish(string)


if __name__ == "__main__":
   rospy.init_node('gui_node', anonymous=True)
   master = Tk()
   master.title("Dialogue Interface")
   window = Text(master, height=40, width=70)
   window.tag_configure('big', font=('Verdana',20,'bold'))
   scroll = Scrollbar(master, command=window.yview)
   window.tag_configure('big', font=('Verdana',20,'bold'))
   window.tag_configure('hcolor', foreground='#476042', 
                        font=('Tempus Sans ITC', 12, 'bold'))
   window.tag_configure('hnbcolor', foreground='#476042', 
                        font=('Tempus Sans ITC', 12, 'italic'))
   window.tag_configure('rotcolor', foreground='#EF4423', 
                        font=('Tempus Sans ITC', 12, 'bold'))
   
   window.tag_config('coordinate',borderwidth=100)
   window.grid(row=4, columnspan = 1)
   
   dialog_label = Label(master)
   e1 = Text(master, width=45, height=2)
   
   #package path
   rospack = rospkg.RosPack()
   #rospack.list_pkgs() 
   path = rospack.get_path('hmi_interpreter')
   path = path+"/img"
   #mic
   b1 = Button(master, command=change_image_field)
   e1.grid(row=1, column=0, pady=4, padx=4)
   b1.grid(row=4, column=1,sticky=W, pady=4, padx=4)
   mi = PhotoImage(file=path+"/speaker_off.png")
   off = mi.subsample(5,5)
   b1.config(image=off)
   mis = PhotoImage(file=path+"/speaker_on.png")
   on = mis.subsample(5,5)
   #pub = rospy.Publisher('/internal/recognizer/output', String, queue_size=10)

   master.bind('<Return>',func)
   Button(master, text='Quit', font=('Arial', 12,'bold', 'italic'), foreground='#ff8000',command=master.quit).grid(row=5, column=1,sticky=W, padx=16)
   Button(master, text='Enter', font=('Arial', 12,'bold', 'italic'),command=show_entry_fields).grid(row=1, column=0, sticky=W, pady=4, padx=4)
   rospy.Subscriber("recognizer/output", String, publisher_callback)
   mainloop( )
   #rospy.spin()
   