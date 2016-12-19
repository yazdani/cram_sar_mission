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
#include <cstddef>    

using namespace std;
std::string find_agent;

std::vector<string> splitString(string input, string delimiter)
{
  std::vector<string> output;
  
  split(output, input, boost::is_any_of(delimiter), boost::token_compress_on);
  return output;
}

std::vector<instructor_mission::Desig> stringToDesigMsg(string words)
{
  //ROS_INFO_STREAM("words: "+words);
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
      if(std::find(without_commas.begin(), without_commas.end(),"repeat") != without_commas.end()) //ein repeat
       {
	 // ROS_INFO_STREAM("test without_commas[0] "+without_commas[0]);
	 if(without_commas[0].compare("take") == 0 || without_commas[0].compare("show") == 0 )
	    {
	      desig.action_type.data = without_commas[0]+"-picture";
	      desig.actor.data = "red_wasp";
	      desig.instructor.data = find_agent;//instructor;
	      desig.viewpoint.data = "human";//viewpoint;
	      prop.object_relation.data = "null";
	    }else
	    {
	      desig.action_type.data = without_commas[0];
	      desig.actor.data = "red_wasp";
	      desig.instructor.data = find_agent;//instructor;
	      desig.viewpoint.data = "human";//viewpoint;
	      prop.object_relation.data = without_commas[1];
	    }
	 //Go to your LEFT  => move(to,robot(left))
	 if(without_commas[2].compare("left") == 0 || without_commas[2].compare("right") == 0)
	   {
	     prop.object_relation.data = without_commas[2];
	     prop.object.data = "null";
	   }else
	   {
	     prop.object.data = without_commas[2];
	   }
	 prop.object_color.data =  without_commas[3];
	 prop.object_size.data = without_commas[4];
	 prop.object_num.data = without_commas[5];
	 prop.flag.data = without_commas[6];
	 prop.pointing_gesture.x = 0;
	 prop.pointing_gesture.y = 0;
	 prop.pointing_gesture.z = 0;
	 props.push_back(prop);
	 prop.object_relation.data = without_commas[9];
	 if(without_commas[10].compare("left") == 0 || without_commas[10].compare("right") == 0)
	   {
	     prop.object_relation.data = without_commas[10];
	     prop.object.data = "null";
	   }else
	   {
	     prop.object.data = without_commas[10];
	   }
	 // prop.object_entity.data = without_commas[10];
	 prop.object_color.data =  without_commas[11];
	 prop.object_size.data = without_commas[12];
	 prop.object_num.data = without_commas[13];
	 prop.flag.data = without_commas[14];
	 prop.pointing_gesture.x = 0;
	 prop.pointing_gesture.y = 0;
	 prop.pointing_gesture.z = 0;
	 props.push_back(prop);
	 desig.propkeys = props;
       

       }else
	{

	 //take,pic,tree,null,null,null,false0
	  // ROS_INFO_STREAM("without_commas[0] "+without_commas[0]);
	  if(without_commas[0].compare("take") == 0 || without_commas[0].compare("show") == 0 )
	    {
	      desig.action_type.data = without_commas[0]+"-picture";
	      desig.actor.data = find_agent;//instructor;
	      desig.instructor.data = find_agent;//instructor;
	      desig.viewpoint.data = "human";//viewpoint;
	      prop.object_relation.data = "null";
	    }else
	    {
	      desig.action_type.data = without_commas[0];
	      desig.actor.data = find_agent;//instructor;
	      desig.instructor.data = find_agent;//instructor;
	      desig.viewpoint.data = "human";//viewpoint;
	      prop.object_relation.data = without_commas[1];
	    }
	  if(without_commas[2].compare("left") == 0 || without_commas[2].compare("right") == 0)
	   {
	     prop.object_relation.data = without_commas[2];
	     prop.object.data = "null";
	   }else
	   {
	     prop.object.data = without_commas[2];
	   }
	  // prop.object_entity.data = without_commas[2];
	  prop.object_color.data =  without_commas[3];
	  prop.object_size.data = without_commas[4];
	  prop.object_num.data = without_commas[5];
	  prop.flag.data = without_commas[6];
	  prop.pointing_gesture.x = 0;
	  prop.pointing_gesture.y = 0;
	  prop.pointing_gesture.z = 0;
	  props.push_back(prop);
	  desig.propkeys = props;
	}
	 desigs.push_back(desig);
	 
    }
  if(desigs.size() > 1)
    {
        ROS_INFO_STREAM(desigs[0]);
        ROS_INFO_STREAM(desigs[1]); 
    }else
    {
          ROS_INFO_STREAM(desigs[0]);
    }
 return desigs;
}



bool getCmd(instructor_mission::call_cmd::Request &req,
            instructor_mission::call_cmd::Response &res)
{
  ros::NodeHandle n_client;
  ros::NodeHandle n_client_view;
  instructor_mission::text_parser srv;
  ros::ServiceClient client = n_client.serviceClient<instructor_mission::text_parser>("/ros_parser");
  std::string received_highlevel_cmd = req.goal;
  ros::ServiceClient client_view = n_client_view.serviceClient<instructor_mission::text_parser>("/add_viewpoint");
  std::string inp;
  inp ="get";
  srv.request.goal = inp;
  if (client_view.call(srv))
     {
     	ROS_INFO_STREAM("Waiting for the Viewpoint");
	find_agent = srv.response.result;
      }
     else
      {
     	ROS_ERROR("Failed to call the service in TLDL");
     	return 1;
      }
 std::vector<string> actions = splitString(req.goal, " ");
 if(actions.size()== 2)
   {
     boost::replace_all(req.goal,"Go right","Go right nil");
     boost::replace_all(req.goal,"Go left","Go left nil");
     boost::replace_all(req.goal,"Go straight","Go straight nil");
     boost::replace_all(req.goal,"Go ahead","Go ahead nil");
   }
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
