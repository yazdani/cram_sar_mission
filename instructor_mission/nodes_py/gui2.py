#!/usr/bin/env python
from Tkinter import *
import rospy
from std_msgs.msg import String
from instructor_mission.msg import protocol_dialogue
from instructor_mission.srv import call_cmd
from instructor_mission.srv import text_parser
import time
import sys
import rospkg
import thread

checker="false"
res = ""
thread_morph = "false"
test_var = "false"    
thread1 = ""
thread2 ="2"

def execute_tasks(res, delay):
   time.sleep(delay)
   change_image_field()
   client_sending(res.capitalize())


def sleeping_time(res, delay):
   global thread2
   time.sleep(delay)
   print "delay"
   thread2 = res 
   thread.start_new_thread(compare_thread, (res,1,))
 
def ok_button():
   print res
   client_sending(res.capitalize())
  

def client_sending(data):
   rospy.wait_for_service('callInstruction')
   try:
      callInstruction = rospy.ServiceProxy('callInstruction', call_cmd)
      resp1 = callInstruction(data,0.0,0.0,0.0)
      if resp1.result != "" or resp1.result != " ":
         window.insert(INSERT,'Robot:  ','hcolor')
         window.insert(END,"Task completed!"+'\n','hnbcolor')

      #change_image_field()
      #return resp1.result
   except rospy.ServiceException, e:
      print "Service call failed: %s"%e

   

def func(event):
   e1.delete("end-1c",END)
   show_entry_fields()

def callback_thread(data,time):
   global res
   global test_var
   global thread1
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
         elif result == "NEXTTO":
            result="NEXT"
         print "hello"
         window.insert(INSERT,'Genius:  ','hcolor')
         window.insert(END,result.upper()+'\n','hnbcolor')
         string = String()
         string.data = result.upper()
         result = result.lower()
         res = result
         thread1 = res
         thread.start_new_thread(sleeping_time, (res,5,))
         thread.start_new_thread(compare_thread, (res,1,))
         


def compare_thread(data,var):
   global thread1
   global thread2
   if thread1 != thread2:
      print "waiting"
   else:
      thread1 = "1"
      thread2 = "2"
      change_image_field()
      client_sending(res.capitalize())
   
def publisher_callback(data):
   thread.start_new_thread(callback_thread, (data, 1,))       


def change_image_field():
   global checker
   global thread_morph
   print "thread_morph is: "
   print thread_morph
   thread_morph = "false"
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
      if result.upper() == "RED WASP" or result.upper() == "BLUE WASP": 
         rospy.wait_for_service("add_agent_name")
         agent = result
         try:
            add_agent_name = rospy.ServiceProxy("add_agent_name",text_parser)
            resp2 = add_agent_name(result)
            agent = resp2.result
            #create_hmi_msgs(resp1.result)
            # GENERATE the CRAM CLIENT
            #return "Okay everything went well"
         except rospy.ServiceException, e:
            print"Service call failed: %s"%e
         window.insert(INSERT,'Genius:  ','hcolor')
         window.insert(END,result+'\n','hnbcolor')
         return
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
   path = rospack.get_path('instructor_mission')
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
  # Button(master, text='OK', font=('Arial', 12,'bold', 'italic'), command=ok_button).grid(row=4, column=2,sticky=W, padx=16)
   Button(master, text='Quit', font=('Arial', 12,'bold', 'italic'), foreground='#ff8000',command=master.quit).grid(row=5, column=1,sticky=W, padx=16)
   Button(master, text='Enter', font=('Arial', 12,'bold', 'italic'),command=show_entry_fields).grid(row=1, column=0, sticky=W, pady=4, padx=4)
   rospy.Subscriber("recognizer/output", String, publisher_callback)
   
   mainloop( )
   #rospy.spin()
   
