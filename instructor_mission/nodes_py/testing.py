#!/usr/bin/env python

from Tkinter import *
import rospy
from std_msgs.msg import String

master = Tk()
master.title("Human-Robot Dialogue")
Label(text="Human operator").grid(row=0)
e1 = Entry(master)
e1.grid(row=0, column=1)
separator = Frame(height=2, bd=1, relief=SUNKEN)
#separator.pack(fill=X, padx=15, pady=15)

Label(text="two").grid(row=2)

mainloop()
