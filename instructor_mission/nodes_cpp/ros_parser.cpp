#include "ros/ros.h"
#include <stdlib.h>
#include <iostream>
#include <sys/types.h>
#include <sys/wait.h>
#include "instructor_mission/text_parser.h"
#include "instructor_mission/protocol_dialogue.h"
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
  
  std::vector<string> no_brackets = splitString(value, ";");
  std::vector<string> new_string;
  string s2 = "<=inside";
  std::string token;
  std::string token1;
  std::vector<string> cmds;
  std::vector<string> vec;
  
  
  //move(right,tree)<=inside(left,house) --> move(right,tree);move(left,house)
  for(int i = 0; i < no_brackets.size(); i++)
    {
      if(strstr(no_brackets[i].c_str(),s2.c_str())) //inside
	{
	  token = no_brackets[i].substr(0, no_brackets[i].find("(")); //gives first action
	  token = ";"+token;
	  boost::replace_all(no_brackets[i],"<=inside",token);
	}    
      
      new_string.push_back(no_brackets[i]);
    }
  
  //move(right,house);move(left,tree) --> split into two vectors
  int pointers = 0;
  for(int j = 0; j < new_string.size(); j++)
    {
      std::vector<string> test = splitString(new_string[j], ";");
      
      if(test.size() > 1)
	{
	  while(pointers < test.size())
	    {
	      cmds.push_back(test[pointers]);
	      pointers++;
	    }
	  pointers = 0;
	}else
	{
	  cmds.push_back(new_string[j]);
	}
      
    }
  
  std::vector<string> new_vec;
  for(int index = 0; index < cmds.size(); index++)
    {
      boost::replace_all(cmds[index],"pointed_at(","pointed_at,");
      boost::replace_all(cmds[index],"broken(","broken,");
      boost::replace_all(cmds[index],"big(","big,");
      boost::replace_all(cmds[index],"small(","small,");
      boost::replace_all(cmds[index],"first(","first,");
      boost::replace_all(cmds[index],"second(","second,");
      boost::replace_all(cmds[index],"third(","third,");
      boost::replace_all(cmds[index],"fourth(","fourth,");
      boost::replace_all(cmds[index],"last(","last,");
      boost::replace_all(cmds[index],"))",")");
    }
  
  for(int sup = 0; sup < cmds.size(); sup++)
    {
      std::vector<string> testing = splitString(cmds[sup], ",");
      if(testing.size() == 1)
	{
	  boost::replace_all(cmds[sup],"picture)","picture,nil,nil)");
	  boost::replace_all(cmds[sup],"right)","right,nil,nil)");
	  boost::replace_all(cmds[sup],"left)","left,nil,nil)");
	  boost::replace_all(cmds[sup],"ahead)","ahead,nil,nil)");
	  boost::replace_all(cmds[sup],"around)","around,nil,nil)");
	}else 
	if(testing.size() == 2)
	  {
	    boost::replace_all(cmds[sup],",",",nil,");
	  }
    }
  string toktok = "";
  
  for(int pointer = 0; pointer < cmds.size(); pointer++)
    {
      if(pointer != cmds.size()-1)
	{
	  toktok = toktok + cmds[pointer]+ ";";
	}else
	{
	  toktok = toktok + cmds[pointer];
	}
    }
  return toktok;
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
  instructor_mission::protocol_dialogue msg;
  msg.agent.data="human";
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
