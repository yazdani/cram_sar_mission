#include "ros/ros.h"
#include "quadrotor_controller/cmd_points.h"
#include <geometry_msgs/Pose.h>
#include <geometry_msgs/PoseStamped.h>
#include <geometry_msgs/Twist.h>
#include <gazebo_msgs/GetModelState.h>
#include <gazebo_msgs/SetModelState.h>
#include <geometry_msgs/Twist.h>
#include <instructor_mission/protocol_dialogue.h>
#include <sstream>
#include <string>
#include <std_msgs/String.h>
#include <iostream>
#include <tf/LinearMath/Quaternion.h>
#include <stdio.h> 
#include <math.h>


bool executecallback(quadrotor_controller::cmd_points::Request &req,
         quadrotor_controller::cmd_points::Response &res)
{
  ros::NodeHandle nh;
  ros::NodeHandle nh_;
  ros::NodeHandle nh_pub;
  ros::ServiceClient gms_c;  
  gazebo_msgs::SetModelState setmodelstate;
  gazebo_msgs::GetModelState getmodelstate; 
  ros::Publisher publisher;
  ros::Publisher publisher_node;
  ros::ServiceClient smsl;
  geometry_msgs::Pose end_pose;
  geometry_msgs::Twist end_twist;
  publisher_node = nh_pub.advertise<instructor_mission::protocol_dialogue>("/sub_dialog",1);
  instructor_mission::protocol_dialogue dia;
  dia.agent.data = "robot";
  dia.command.data = "OK, master!";
  publisher_node.publish(dia);
  ROS_INFO("START HECTOR FOR TASK EXECUTION");
  publisher = nh.advertise<geometry_msgs::Twist>("/cmd_vel", 1);
  gms_c = nh_.serviceClient<gazebo_msgs::GetModelState>("/gazebo/get_model_state");
  getmodelstate.request.model_name="quadrotor";
  
  geometry_msgs::Twist tw;
  publisher.publish(tw);
  ros::Duration(2.0).sleep();
  
  gms_c.call(getmodelstate);
  double now_x =  getmodelstate.response.pose.position.x;
  double now_y =  getmodelstate.response.pose.position.y;
  double now_z =  getmodelstate.response.pose.position.z;
  double temp = getmodelstate.response.pose.orientation.z;
  double new_x = req.x;
  double new_y = req.y;
  double new_z = req.z;
  double vel_x = req.qx;
  double vel_y = req.qy;
  double new_qz = req.qz ;
  double new_qw = req.qw;
  double vel_qz = 0.0;
  ROS_INFO_STREAM("new_x");
  ROS_INFO_STREAM(new_x);
  ROS_INFO_STREAM("new_y");
  ROS_INFO_STREAM(new_y);
  ROS_INFO_STREAM("new_z");
  ROS_INFO_STREAM(new_z);
  ROS_INFO_STREAM("temp");
  ROS_INFO_STREAM(temp);
  ros::Rate r(1);
  bool success = true;
  publisher.publish(tw);
  ros::Duration(1.0).sleep();
  


  ROS_INFO("Start task execution ");

  ROS_INFO_STREAM("NOW_Z is going up");
  gms_c.call(getmodelstate);
  now_z =  getmodelstate.response.pose.position.z;
  ROS_INFO_STREAM(now_z);
  if(now_z <= 11)
    {
      while(now_z <= 11)
	{
	  tw.linear.z = 0.8;
	  publisher.publish(tw);
	  ros::Duration(1.0).sleep();
	  gms_c.call(getmodelstate);
	  now_z =  getmodelstate.response.pose.position.z;
	}
      ros::Duration(1.0).sleep();
      tw.linear.z = 0;
      tw.linear.x = 0;
      tw.linear.y = 0;
      publisher.publish(tw);
    }
  ROS_INFO_STREAM("Rotate on Z-AXIS");
  gms_c.call(getmodelstate);
  temp = getmodelstate.response.pose.orientation.z;
  if(temp <= 0.95)
    {
      while(temp <= 0.91)
	{
	  tw.angular.z = -0.3;
	  publisher.publish(tw);
	  ros::Duration(1.0).sleep();
	  gms_c.call(getmodelstate);
	  temp = getmodelstate.response.pose.orientation.z;
	}
      ros::Duration(2.0).sleep();
      tw.angular.z = 0;
      publisher.publish(tw);
    }
  /*else{
    ROS_INFO_STREAM("TEEEEST");
    while(temp > -0.95)
      {
	tw.angular.z = 0.4;
	publisher.publish(tw);
	ros::Duration(1.0).sleep();
	gms_c.call(getmodelstate);
	temp = getmodelstate.response.pose.orientation.z;
      }
    ros::Duration(2.0).sleep();
    tw.angular.z = 0;
    publisher.publish(tw);
  }
  */ 
  ROS_INFO_STREAM("NOW_X is moving");
  gms_c.call(getmodelstate);
  now_x =  getmodelstate.response.pose.position.x;
  if(now_x <= new_x)
    {
      while(now_x <= new_x)
	{
	  ROS_INFO_STREAM(now_x);
	  ROS_INFO_STREAM(new_x);
	  tw.linear.x = -0.6;
	  publisher.publish(tw);
	  ros::Duration(1.0).sleep();
	  gms_c.call(getmodelstate);
	  now_x =  getmodelstate.response.pose.position.x;
	}
      
      ros::Duration(1.0).sleep();
      tw.linear.z = 0;
      tw.linear.x = 0;
      tw.linear.y = 0;
      publisher.publish(tw);
    }else{
    while(now_x > new_x)
      {
	ROS_INFO_STREAM(now_x);
	ROS_INFO_STREAM(new_x);
	tw.linear.x = 0.6;
	publisher.publish(tw);
	ros::Duration(1.0).sleep();
	gms_c.call(getmodelstate);
	now_x =  getmodelstate.response.pose.position.x;
      }
    
    ros::Duration(1.0).sleep();
    tw.linear.z = 0;
    tw.linear.x = 0;
    tw.linear.y = 0;
    publisher.publish(tw);
  }
  
  ros::Duration(1.0).sleep();
  tw.linear.z = 0;
  tw.linear.x = 0;
  tw.linear.y = 0;
  publisher.publish(tw);
  
  gms_c.call(getmodelstate);
  now_y =  getmodelstate.response.pose.position.y;
  if(now_y <= new_y)
    {
      while(now_y <= new_y)
	{
	  ROS_INFO_STREAM(now_y);
	  ROS_INFO_STREAM(new_y);
	  tw.linear.y = -0.6;
	  publisher.publish(tw);
	  ros::Duration(1.0).sleep();
	  gms_c.call(getmodelstate);
	  now_y =  getmodelstate.response.pose.position.y;
	}
      ros::Duration(1.0).sleep();
      tw.linear.z = 0;
      tw.linear.x = 0;
      tw.linear.y = 0;
      publisher.publish(tw);
    }else
    {
      while(now_y > new_y)
	{
	  ROS_INFO_STREAM(now_y);
	  ROS_INFO_STREAM(new_y);
	  tw.linear.y = 0.6;
	  publisher.publish(tw);
	  ros::Duration(1.0).sleep();
	  gms_c.call(getmodelstate);
	  now_y =  getmodelstate.response.pose.position.y;
	}
      
      ros::Duration(1.0).sleep();
      tw.linear.z = 0;
      tw.linear.x = 0;
      tw.linear.y = 0;
      publisher.publish(tw); 
    }
  
  ros::Duration(2.0).sleep();
  tw.linear.z = 0;
  tw.linear.x = 0;
  tw.linear.y = 0;
  publisher.publish(tw);     
  gms_c.call(getmodelstate);

  temp = getmodelstate.response.pose.orientation.z;
 
  gms_c.call(getmodelstate);
  if(new_qw > 0)
    {
      if(getmodelstate.response.pose.orientation.w < 0.95)
	{
	  while(getmodelstate.response.pose.orientation.w <= 0.95)
	    {
	      tw.angular.z = -0.5;
	      publisher.publish(tw);
	      ros::Duration(1.0).sleep();
	      gms_c.call(getmodelstate);
	    }
	  ros::Duration(2.0).sleep();
	  tw.angular.z = 0;
	  publisher.publish(tw);
	}
    }else{
   	while(getmodelstate.response.pose.orientation.w >= -0.95)
	  {
	    tw.angular.z = 0.5;
	    publisher.publish(tw);
	    ros::Duration(1.0).sleep();
	    gms_c.call(getmodelstate);
	  }
	ros::Duration(2.0).sleep();
	tw.angular.z = 0;
	publisher.publish(tw);
      }
  

  if(getmodelstate.response.pose.orientation.w >= 0)
    {
      if(getmodelstate.response.pose.orientation.z > new_qz)
	{
	  
	  while(getmodelstate.response.pose.orientation.z > new_qz)
	    {
	      ROS_INFO_STREAM("TEST");
	      ROS_INFO_STREAM(getmodelstate.response.pose.orientation.z);
	      ROS_INFO_STREAM(new_qz);
	      
	      tw.angular.z = -0.2;
	      publisher.publish(tw);
	      ros::Duration(1.0).sleep();
	      gms_c.call(getmodelstate);
	    }
	  
	  ros::Duration(2.0).sleep();
	  tw.angular.z = 0;
	  publisher.publish(tw);
	}else 
	{	  
	  while(getmodelstate.response.pose.orientation.z > new_qz)
	    {
	      ROS_INFO_STREAM("TEST1");
	      
	      ROS_INFO_STREAM(getmodelstate.response.pose.orientation.z);
	      ROS_INFO_STREAM(new_qz);
	      tw.angular.z = 0.2;
	      publisher.publish(tw);
	      ros::Duration(1.0).sleep();
	      gms_c.call(getmodelstate);
	    }
	  
	  ros::Duration(2.0).sleep();
	  tw.angular.z = 0;
	  publisher.publish(tw);
	}
      
     ros::Duration(1.0).sleep();
      tw.linear.z = 0;
      tw.linear.x = 0;
      tw.linear.y = 0;
      publisher.publish(tw);
      gms_c.call(getmodelstate);
    }else
    {
            if(getmodelstate.response.pose.orientation.w < 0.95)
	      {
		while(getmodelstate.response.pose.orientation.w <= 0.95)
		  {
		    tw.angular.z = -0.5;
		    publisher.publish(tw);
		    ros::Duration(1.0).sleep();
		    gms_c.call(getmodelstate);
		  }
		ros::Duration(2.0).sleep();
		tw.angular.z = 0;
		publisher.publish(tw);
	      }
	    else{
	      while(getmodelstate.response.pose.orientation.w >= -0.95)
		{
		  tw.angular.z = 0.5;
		  publisher.publish(tw);
		  ros::Duration(1.0).sleep();
		  gms_c.call(getmodelstate);
		}
	      ros::Duration(2.0).sleep();
	      tw.angular.z = 0;
	      publisher.publish(tw);
	    }
    }
  

  if(getmodelstate.response.pose.orientation.w >= 0)
    {
      if(getmodelstate.response.pose.orientation.z > new_qz)
	{
	  
	  while(getmodelstate.response.pose.orientation.z > new_qz)
	    {
	      ROS_INFO_STREAM("TEST");
	      ROS_INFO_STREAM(getmodelstate.response.pose.orientation.z);
	      ROS_INFO_STREAM(new_qz);
	      
	      tw.angular.z = 0.2;
	      publisher.publish(tw);
	      ros::Duration(1.0).sleep();
	      gms_c.call(getmodelstate);
	    }
	  
	  ros::Duration(2.0).sleep();
	  tw.angular.z = 0;
	  publisher.publish(tw);
	}else 
	{	  
	  while(getmodelstate.response.pose.orientation.z > new_qz)
	    {
	      ROS_INFO_STREAM("TEST1");
	      
	      ROS_INFO_STREAM(getmodelstate.response.pose.orientation.z);
	      ROS_INFO_STREAM(new_qz);
	      tw.angular.z = -0.2;
	      publisher.publish(tw);
	      ros::Duration(1.0).sleep();
	      gms_c.call(getmodelstate);
	    }
	  
	  ros::Duration(2.0).sleep();
	  tw.angular.z = 0;
	  publisher.publish(tw);
	}
      
     ros::Duration(1.0).sleep();
      tw.linear.z = 0;
      tw.linear.x = 0;
      tw.linear.y = 0;
      publisher.publish(tw);
      gms_c.call(getmodelstate);
    }

      while(getmodelstate.response.pose.position.z > 5)
	{

	  ROS_INFO_STREAM(getmodelstate.response.pose.position.z);
	  ROS_INFO_STREAM(new_qz);
	  
	  tw.linear.z = -0.3;
	  publisher.publish(tw);
	  ros::Duration(1.0).sleep();
	  gms_c.call(getmodelstate);
	}
      
      ros::Duration(1.0).sleep();
      tw.linear.z = 0;
      publisher.publish(tw);
   

  ros::Duration(1.0).sleep();
      tw.linear.z = 0;
      tw.linear.x = 0;
      tw.linear.y = 0;
      publisher.publish(tw);

  res.repl = "Task Execution completed";
  dia.agent.data = "robot";
  dia.command.data = "OK, Task completed! What shall I do next, master?";
  publisher_node.publish(dia);
  return true;
}

int main(int argc, char **argv)
{
  ros::init(argc, argv, "execute_command_server");
  ros::NodeHandle n;
  ros::ServiceServer service = n.advertiseService("setRobotPoints", executecallback);
  ROS_INFO("Ready to receive information where to fly");
  ros::spin();
  
  return 0;
}
