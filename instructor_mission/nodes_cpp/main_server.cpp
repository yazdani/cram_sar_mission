#include "ros/ros.h"
#include <instructor_mission/call_cmd.h>
#include <instructor_mission/text_parser.h>
#include <instructor_mission/cram_reason.h>
#include <sstream>
#include <string>
#include <std_msgs/String.h>
#include <iostream>
#include <tf/LinearMath/Quaternion.h>
#include <stdio.h> 
#include <math.h>
#include <cstdlib>

bool getCmd(instructor_mission::call_cmd::Request &req,
            instructor_mission::call_cmd::Response &res)
{
  ros::NodeHandle n_client;
  instructor_mission::text_parser srv;
  ros::ServiceClient client = n_client.serviceClient<instructor_mission::text_parser>("/ros_parser");
  srv.request.goal = req.goal;
  if (client.call(srv))
     {
     	ROS_INFO_STREAM("Waiting for the TLDL parser");
      }
     else
      {
     	ROS_ERROR("Failed to call the service in TLDL");
     	return 1;
      }
  
  ros::NodeHandle ncram_client;
  instructor_mission::cram_reason cram_srv;
  ros::ServiceClient cram_client = ncram_client.serviceClient<instructor_mission::cram_reason>("/service_cram_reasoning");
  cram_srv.request.cmd = srv.response.result;
  if (cram_client.call(cram_srv))
     {
     	ROS_INFO_STREAM("Waiting for the CRAM");
      }
     else
      {
     	ROS_ERROR("Failed to call the service in CRAM");
     	return 1;
      }


  ROS_INFO_STREAM(cram_srv.response.result);
  res.result = "Instruction completed!\nPlease give next instruction.";
  return true; 
}

int main(int argc, char **argv)
{
  ros::init(argc, argv, "call_command_server");
  ros::NodeHandle n;
  ros::ServiceServer service = n.advertiseService("callInstruction", getCmd);
  ROS_INFO("Ready to receive new commands");
  ros::spin();
  
  return 0;
}
