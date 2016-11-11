#include "ros/ros.h"
#include <instructor_mission/call_cmd.h>
#include <instructor_mission/text_parser.h>
#include <instructor_mission/HMIDesig.h>
#include <instructor_mission/Desig.h>
#include <instructor_mission/Propkey.h>
#include <sstream>
#include <string>
#include <std_msgs/String.h>
#include <iostream>
#include <tf/LinearMath/Quaternion.h>
#include <stdio.h> 
#include <math.h>
#include <cstdlib>
#include <boost/algorithm/string.hpp>
#include <algorithm>

using namespace std;
std::vector<string> splitString(string input, string delimiter)
{
  std::vector<string> output;
  
  split(output, input, boost::is_any_of(delimiter), boost::token_compress_on);
  return output;
}
std::vector<instructor_mission::Desig> stringToDesigMsg(string words)
{
  ROS_INFO_STREAM("words: "+words);
  std::vector<string> without_zeros = splitString(words,"0");
  std::vector <instructor_mission::Desig> desigs;

  instructor_mission::HMIDesig hmidesig;
  instructor_mission::Propkey prop;
  geometry_msgs::Point point;
  for(unsigned i = 0; i < without_zeros.size(); i++)
    {
      if(without_zeros[i].empty())
	break;
      instructor_mission::Desig desig;
      instructor_mission::Propkey prop;
      std::vector<instructor_mission::Propkey> props;
      std::vector<string> without_commas = splitString(without_zeros[i],",");
 
      // bool x = std::find(without_commas.begin(), without_commas.end(),"repeat") != without_commas.end();
      // ROS_INFO_STREAM(x);
      if(std::find(without_commas.begin(), without_commas.end(),"repeat") != without_commas.end())
       {

	  if(without_commas[0].compare("take") == 0)
	    {
	      desig.action_type.data = without_commas[0]+"-picture";
	      std_msgs::String str;
	      str.data =  without_commas[6];
	      prop.spatial_relation = str; 
	      prop.property.data = without_commas[7];
	      prop.language_object.data =  without_commas[8];
	      prop.flag.data = without_commas[9];
	      prop.pointing_gesture.x = 0;
	      prop.pointing_gesture.y = 0;
	      prop.pointing_gesture.z = 0;
	      props.push_back(prop);
	      desig.propkeys = props;
	    }else
	    {
	      desig.action_type.data = without_commas[0];
	      std_msgs::String str;
	      str.data = without_commas[1];
	      prop.spatial_relation = str; 
	      prop.property.data = without_commas[2];
	      prop.language_object.data = without_commas[3];
	      prop.flag.data = without_commas[4];
	      prop.pointing_gesture.x = 0;
	      prop.pointing_gesture.y = 0;
	      prop.pointing_gesture.z = 0;
	      props.push_back(prop);
	      str.data = without_commas[6];
	      prop.spatial_relation = str; 
	      prop.property.data = without_commas[7];
	      prop.language_object.data = without_commas[8];
	      prop.flag.data = without_commas[9];
	      prop.pointing_gesture.x = 0;
	      prop.pointing_gesture.y = 0;
	      prop.pointing_gesture.z = 0;
	      props.push_back(prop);
	      desig.propkeys = props;
	   }

       }else
	{
	  if(without_commas[0].compare("take") == 0)
	    {
	  
	      desig.action_type.data = without_commas[0]+"-picture";
	      std_msgs::String str;
	      str.data = "null";
	      prop.spatial_relation = str; 
	      if(without_commas[1].compare("nil") == 0 || without_commas[1].compare("picture") == 0 )
		{
		  prop.spatial_relation.data = "null";
		}else
		{
		  prop.spatial_relation.data = without_commas[1];
		}

	      if(without_commas[3].compare("picture") == 0)
		{
		  prop.language_object.data = "null";
		}else
		{
		  prop.language_object.data = without_commas[3];
		}
	     
	      if(without_commas[2].compare("empty") == 0)
		{
		  prop.property.data = "null";
		}else
		{
		  prop.property.data = without_commas[2];
		}

	      prop.flag.data = without_commas[4];
	        

	      prop.pointing_gesture.x = 0;
	      prop.pointing_gesture.y = 0;
	      prop.pointing_gesture.z = 0;
	      props.push_back(prop);
	      desig.propkeys = props;
	    }else
	    {

	      desig.action_type.data = without_commas[0];
	      if(without_commas[1].compare("nil") == 0 || without_commas[1].compare("picture") == 0 )
		{
		  prop.spatial_relation.data = "null";
		}else
		{
		  prop.spatial_relation.data = without_commas[1];
		}

	      if(without_commas[3].compare("picture") == 0)
		{
		  prop.language_object.data = "null";
		}else
		{
		  prop.language_object.data = without_commas[3];
		}

	      if(without_commas[2].compare("picture") == 0)
		{
		  prop.property.data = "null";
		}else
		{
		  prop.property.data = without_commas[2];
		}
	      prop.flag.data = without_commas[4];
	      prop.pointing_gesture.x = 0;
	      prop.pointing_gesture.y = 0;
	      prop.pointing_gesture.z = 0;
	      props.push_back(prop);
	      desig.propkeys = props;
	   }
       }

	 desigs.push_back(desig);
	 
    }
  if(desigs.size() > 1)
    {
      //      ROS_INFO_STREAM(desigs[0]);
      //      ROS_INFO_STREAM(desigs[1]); 
    }else
    {
      //      ROS_INFO_STREAM(desigs[0]);
    }
 return desigs;
}



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
  std::vector<instructor_mission::Desig> desigs;
  instructor_mission::Desig desig;

  desigs = stringToDesigMsg(srv.response.result);
  ROS_INFO_STREAM("TEST2");
  
  ros::NodeHandle ncram_client;
  instructor_mission::HMIDesig cram_srv;
 
  ros::ServiceClient cram_client = ncram_client.serviceClient<instructor_mission::HMIDesig>("/service_cram_reasoning");
  ROS_INFO_STREAM("TEST3");
  
  cram_srv.request.desigs = desigs;//srv.response.result;
  if (cram_client.call(cram_srv))
     {
     	ROS_INFO_STREAM("Waiting for the CRAM");
      }
     else
      {
     	ROS_ERROR("Failed to call the service in CRAM");
     	return 1;
      }


  // ------ROS_INFO_STREAM(cram_srv.response.result);
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
