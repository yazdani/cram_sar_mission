#include "ros/ros.h"
#include <stdlib.h>
#include <iostream>
#include <sys/types.h>
#include <sys/wait.h>
#include "instructor_mission/text_parser.h"
#include "instructor_mission/protocol_dialogue.h"
#include "instructor_mission/Desig.h"
#include "instructor_mission/Propkey.h"
#include <unistd.h>
#include "err.h"
#include <vector>
#include <string>
#include <iterator>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdio.h>
#include "std_msgs/String.h"
#include "std_msgs/Float64.h"
#include "geometry_msgs/Transform.h"
#include "geometry_msgs/PoseStamped.h"
#include "geometry_msgs/Twist.h"
#include <gazebo_msgs/SetModelState.h>
#include <gazebo_msgs/GetModelState.h>
#include <gazebo_msgs/GetPhysicsProperties.h>
#include <geographic_msgs/GeoPose.h>
#include <sstream>
#include <sys/types.h>
#include <boost/algorithm/string.hpp>


int sockfd, newsockfd, portno, clilen;

 
struct sockaddr_in serv_addr, cli_addr;
std::string part1, part2, action, action0, spatial0, spatial, entity0, entity1, entity2, entity3, entity, property, spatial00, spatial01, property00, property01, property02, entity00, entity01, size0, size1, property0, property1, num0, num1, color0, color1, flag0, flag1, spatial02, entity02;
  
ros::Publisher chatter_pub;
using namespace std;

vector<string> splitString(string input, string delimiter)
{
  vector<string> output;
  
  split(output, input, boost::is_any_of(delimiter), boost::token_compress_on);
  
  return output;
}

string without_brakets(string value)
{
  part1 = "null";
  part2 = "null";
  action = "null";
  action0 = "null";
  spatial0 = "null";
  spatial = "null";
  entity0 = "null";
  entity1 = "null";
  entity2 = "null";
  entity3 = "null";
  entity = "null";
  property = "null";
  spatial00 = "null";
  spatial01 = "null";
  spatial02 = "null";
  property00 = "null";
  property01 = "null";
  property02 = "null";
  entity00 = "null";
  entity01 = "null";
  size0 = "null";
  size1 = "null";
  property0 = "null";
  property1 = "null";
  num0 = "null";
  num1 = "null";
  color0 = "null";
  color1 = "null";
  flag0 = "false";
  flag1 = "false";
  entity02 = "null";
  std::vector<string> actions = splitString(value, ";");
  string merged_strings= "";
  
  std::string inside = "inside";


  if(actions.size() == 0)
    {
      return "Error: Parsing did not work";
    }
 
  for(unsigned i = 0; i < actions.size(); i++)
    {
      boost::replace_all(actions[i],"fly(right)","move(right,nil(null))");
     boost::replace_all(actions[i],"fly(left)","move(left,nil(null))");
      boost::replace_all(actions[i],"move(right)","move(right,nil(null))");
      boost::replace_all(actions[i],"move(left)","move(left,nil(null))");
      boost::replace_all(actions[i],"picture)","picture,nil(null))");
      boost::replace_all(actions[i],"back)","back,nil(null))");
      boost::replace_all(actions[i],"off)","off,nil(null))");
      boost::replace_all(actions[i],"image)","picture,nil(null))");
      boost::replace_all(actions[i],",tree)",",nil(tree))");
      boost::replace_all(actions[i],",jacket)",",nil(jacket))");
      boost::replace_all(actions[i],",house)",",nil(house))");
      boost::replace_all(actions[i],",victim)",",nil(victim))");
      boost::replace_all(actions[i],"detect(victim)","move(to,nil(victim))");
      boost::replace_all(actions[i],",pylon)",",nil(pylon))");
      boost::replace_all(actions[i],",rock)",",nil(rock))");
      boost::replace_all(actions[i],",nil)",",nil(null))");
      if(strstr(actions[i].c_str(),inside.c_str())) //if inside
	{
	  //move(right,nil(tree))<=inside(to,nil(rock))
	  //move(right,nil(tree))
	  part1 = actions[i].substr(0,actions[i].find("<=")); //move(right,nil(tree))
	  ROS_INFO_STREAM("part1: " + part1);
	  part2 = actions[i].substr(actions[i].find("inside"),actions[i].size()); //(to,nil(rock))
	  ROS_INFO_STREAM("part2: " + part2);
	  action0 = part1.substr(0,part1.find(",")); //move(right  
	  ROS_INFO_STREAM("action0: " + action0);
	  action =  action0.substr(0,action0.find("(")); //move
	  ROS_INFO_STREAM("action: " + action);
	  spatial0 = action0.substr(action0.find("("), action0.size()); //(right
	  ROS_INFO_STREAM("spatial0: " + spatial0);
	  spatial = spatial0.substr(1, spatial0.size()); //right
	  ROS_INFO_STREAM("spatial: " + spatial);
	  entity0 = part1.substr(part1.find(","),part1.size()); //,nil(tree))
	  ROS_INFO_STREAM("entity0: " + entity0);
          entity1 = entity0.substr(1,entity0.size()); //nil(tree))
	  ROS_INFO_STREAM("entity1: " + entity1);
          entity2 = entity1.substr(entity1.find("("),entity1.size()); //(tree))
	  ROS_INFO_STREAM("entity2: " + entity2);
	  entity3 = entity2.substr(1,entity2.size()); //tree))
	  ROS_INFO_STREAM("entity3: " + entity3);
          entity = entity3.substr(0,entity3.find(")")); //tree
	  ROS_INFO_STREAM("entity: " + entity);
	  property = entity1.substr(0,entity1.find("(")); //nil
	  ROS_INFO_STREAM("property: " + property);
	  //<=inside(to,nil(rock))
	  spatial00 = part2.substr(part2.find("("), part2.size()); //(to,nil(rock))
	  //spatial00 = part2.substr(1,part2.size()); //to,nil(rock))
	  ROS_INFO_STREAM("spatial00: " + spatial00);
	  spatial01 = spatial00.substr(1,spatial00.size()); //to,nil(rock))
	  ROS_INFO_STREAM("spatial01: " + spatial01);
	  spatial02 = spatial01.substr(0,spatial01.find(",")); //to,nil(rock));
	  ROS_INFO_STREAM("spatial02: " + spatial02);
	  property00 = part2.substr(part2.find(","),part2.size()); //,nil(rock))
	  ROS_INFO_STREAM("property00: " + property00);
	  property01 = property00.substr(1,property00.size()); //nil(rock))
	  ROS_INFO_STREAM("property01: " + property01);
	  property02 = property01.substr(0,property01.find("(")); //nil
	  ROS_INFO_STREAM("property02: " + property02);
	  entity00 = spatial01.substr(spatial01.find("("),spatial01.size()); //(rock))
	  ROS_INFO_STREAM("entity00: " + entity00);
	  entity01 = entity00.substr(0, entity00.find(")")); //(rock
	  ROS_INFO_STREAM("entity01: " + entity01);
	  entity02 = entity01.substr(1, entity01.size()); //rock
	  ROS_INFO_STREAM("entity02: " + entity02);
	  if(property.compare("big") == 0 || property.compare("small") == 0)
	    {
	      size0 = property; 
	    }
	  if(property.compare("pointed_at") == 0)
	    {
	      flag0 = "true";
	    }
	  if(property.compare("one") == 0 || property.compare("two") == 0 || property.compare("three") == 0 || property.compare("robot") == 0 )
	    {
	      num0 = property;
	    }
	  if(property.compare("green") == 0 || property.compare("red") == 0 ||
	     property.compare("blue") == 0 || property.compare("white") == 0 ||
	     property.compare("black") == 0 || property.compare("brown") == 0 ||
	     property.compare("yellow") == 0)
	    {
	      color0 = property;
	    }
	  

	  if(property02.compare("big") == 0 || property02.compare("small") == 0)
	    {
	      size1 = property02; 
	    }
	  if(property02.compare("pointed_at") == 0)
	    {
	      flag1 = "true";
	    }
	  if(property02.compare("one") == 0 || property02.compare("two") == 0 || property02.compare("three") == 0 || property02.compare("robot") == 0)
	    {
	      num1 = property02;
	    }
	  if(property02.compare("green") == 0 || property02.compare("red") == 0 ||
	     property02.compare("blue") == 0 || property02.compare("white") == 0 ||
	     property02.compare("black") == 0 || property02.compare("brown") == 0 ||
	     property02.compare("yellow") == 0)
	    {
	      color1 = property02;
	    }
	 merged_strings = merged_strings + action +","+ spatial +","+ entity + "," + color0 + "," +size0 +","+ num0 + "," +flag0+ ",repeat,"
	   + action+ ","+ spatial02 + ","+entity02 +","+color1+ "," +size1 +","+ num1 + "," +flag1+"0";
	  
	}else
	{  //move(right,nil(tree))
	  ROS_INFO_STREAM("actions[i]: " + actions[i]);
	  action0 = actions[i].substr(0,actions[i].find(",")); //move(right  
	  ROS_INFO_STREAM("action0: " + action0);
	  action =  action0.substr(0,action0.find("(")); //move
	  ROS_INFO_STREAM("action: " + action);
	  spatial0 = action0.substr(action0.find("("), action0.size()); //(right
	  ROS_INFO_STREAM("spatial0: " + spatial0);
	  spatial = spatial0.substr(1, spatial0.size()); //right
	  ROS_INFO_STREAM("spatial: " + spatial);
	  entity0 = actions[i].substr(actions[i].find(","),actions[i].size()); //,nil(tree))
	  ROS_INFO_STREAM("entity0: " + entity0);
          entity1 = entity0.substr(1,entity0.size()); //nil(tree))
	  ROS_INFO_STREAM("entity1: " + entity1);
          entity2 = entity1.substr(entity1.find("("),entity1.size()); //(tree))
	  ROS_INFO_STREAM("entity2: " + entity2);
	  entity3 = entity2.substr(1,entity2.size()); //tree))
	  ROS_INFO_STREAM("entity3: " + entity3);
          entity = entity3.substr(0,entity3.find(")")); //tree
	  ROS_INFO_STREAM("entity: " + entity);
	  property = entity1.substr(0,entity1.find("(")); //nil
	  ROS_INFO_STREAM("property: " + property);
	  if(property.compare("big") == 0 || property.compare("small") == 0)
	    {
	      size0 = property; 
	    }

	  if(property.compare("pointed_at") == 0)
	    {
	      flag0 = "true";
	    }
	  
	  if(property.compare("one") == 0 || property.compare("two") == 0 || property.compare("three") == 0 || property.compare("robot") == 0)
	    {
	      num0 = property;
	    }
	  if(property.compare("green") == 0 || property.compare("red") == 0 ||
	     property.compare("blue") == 0 || property.compare("white") == 0 ||
	     property.compare("black") == 0 || property.compare("brown") == 0 ||
	     property.compare("yellow") == 0)
	    {
	      color0 = property;
	    }
	  merged_strings = merged_strings + action +","+ spatial +","+ entity + "," + color0 + "," +size0 +","+ num0 + "," +flag0+ "0";
	}

    }


  ROS_INFO_STREAM("array_vec: " + merged_strings);
return merged_strings;
}

string interpretByParser(string cmd)
{
  int  no = 0;
  char buffer[512] = {0};
  /* If connection is established then start communicating */
  bzero(buffer,512);
  string cmd2 = cmd+'\n';
  cmd2.copy(buffer, 512);
  no = write(newsockfd,buffer,sizeof(buffer));
   if (no < 0) {
     perror("ERROR writing to socket");
     exit(1);
   }
   no = 0;
   no = read( newsockfd,buffer,512 );
   if (no < 0) {
     perror("ERROR reading from socket");
     exit(1);
   }
   string ret = "Parsing not possible";
   if(ret.compare(buffer) != 0)
     return buffer;
	 
   return "";
}

bool parser(instructor_mission::text_parser::Request &req,
         instructor_mission::text_parser::Response &res)
{
  ROS_INFO_STREAM(req.goal);
  boost::algorithm::to_lower(req.goal);
  instructor_mission::protocol_dialogue msg;
  std::vector<string> marray;
  msg.agent.data="busy_genius";
  msg.command.data = req.goal;
  chatter_pub.publish(msg);
  res.result = without_brakets(interpretByParser(req.goal));
  return true;
}

int main(int argc, char **argv)
{

  ros::init(argc, argv, "ros_node_instruction_parser");
  ros::NodeHandle n;
  ros::NodeHandle nh;
  chatter_pub = nh.advertise<instructor_mission::protocol_dialogue>("sub_dialog", 1000);
  //system("killall gnome-terminal");
  ROS_INFO_STREAM("Wait for Parser!");
  close(sockfd);
  //system("gnome-terminal --working-directory=/home/yazdani/work/diarc_ws/smallade_w_lang -e './ant run-registry -Df=config/sherpa_config/sherpa.config'");
  system("gnome-terminal --working-directory=/home/yazdani/work/diarc_ws/smallade_w_lang  --command \"./ant run-registry -Df=config/sherpa_config/sherpa.config\" &");//cmd.c_str());

  sockfd = socket(AF_INET, SOCK_STREAM, 0);
  if (sockfd < 0) {
    perror("ERROR opening socket");
    exit(1);
  }

  int reuse = 1;
  if (setsockopt(sockfd, SOL_SOCKET, (SO_REUSEPORT | SO_REUSEADDR), (const char*)&reuse, sizeof(reuse)) < 0)
    perror("setsockopt(SO_REUSEADDR) failed");
  
  bzero((char *) &serv_addr, sizeof(serv_addr));
  portno = 1234;
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = INADDR_ANY;
  serv_addr.sin_port = htons(portno);
  if (bind(sockfd, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) < 0) {
    perror("ERROR on binding");
    exit(1);
  }

  listen(sockfd,5);
  clilen = sizeof(cli_addr);
  newsockfd = accept(sockfd, (struct sockaddr *)&cli_addr, (socklen_t*)&clilen);
  
  if (newsockfd < 0) {
    perror("ERROR on accept");
    exit(1);
  }
  //  system("killall gnome-terminal");//cmd.c_str());
  ros::Duration(0.5).sleep(); 
  ros::ServiceServer service = n.advertiseService("ros_parser", parser);
  ROS_INFO_STREAM("Wait for instruction");
  ros::spin();
    
  return 0;
}
