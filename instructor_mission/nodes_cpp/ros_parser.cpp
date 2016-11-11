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
  std::string tok1, tok2, tok3, tok4, tok5, tok6, tok7, tok8, tok9, tok10;
  std::string tok11, tok12, tok13, tok14, tok15, tok16, tok17, tok18, tok19, tok20;
  std::string tok21, tok22, tok23, tok24, tok25, tok26, tok27, tok28, tok29, tok30;
  std::string tok31, tok32, tok33, tok34, tok35, tok36, tok37, tok38, tok39, tok40;
  std::string tok41, tok42, tok43, tok44, tok45, tok46, tok47, tok48, tok49, tok50;
  std::string tok51, tok52, tok53, tok54, tok55, tok56, tok57, tok58, tok59, tok60;
  std::string part1, part2;
  std::string flag1, flag2;
 
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
  string array_vec= "";
  
  std::string s2 = "inside";
  std::string s3 = "pointed_at";
  std::string p1 = "small";
  std::string p2 = "big";
  std::string c1 = "red";
  std::string c2 = "blue";
  std::string c3 = "green";
  std::string c4 = "brown";
  std::string property1 = "empty";
  std::string property2 = "empty";

  for(unsigned i = 0; i < no_brackets.size(); i++)
    {
      boost::replace_all(no_brackets[i],"picture)","nil,picture)");
      boost::replace_all(no_brackets[i],"image)","nil,picture)");
      if(strstr(no_brackets[i].c_str(),s2.c_str())) //if inside
	{
	  part1 = no_brackets[i].substr(0, no_brackets[i].find("<=")); //erster abschnitt
	  part2 = no_brackets[i].substr(no_brackets[i].find("inside"),no_brackets[i].size()); //letzter abschnitt
	  if(strstr(part1.c_str(),s3.c_str())) //if pointed
	    {
	      tok1 = part1.substr(0,part1.find(",")); //move(right
	      tok2 = tok1.substr(tok1.find("("),tok1.size());// (right
	      tok3 = tok2.substr(1,tok2.size());// right token12
	      tok4 = part1.substr(0,part1.find(",")); //move(right   
	      tok5 = tok4.substr(0,tok4.find("(")); //move token 11
	      tok6 = part1.substr(part1.find(","),part1.size()); //,pointed_at(rock))
	      tok7 = tok6.substr(1,tok6.size()); //pointed_at(rock))
	      tok8 = tok7.substr(tok7.find("("),tok7.size()); //(rock))
	      tok9 = tok8.substr(1,tok8.size()); //rock))
	      tok10 = tok9.substr(0,tok9.find(")")); //rock
	      flag1 = "true";
	      property1 = "empty";
		array_vec = array_vec + tok5 +","+ tok3 +","+ property1 + ","+tok10 +","+ flag1;


	    }else if(strstr(part1.c_str(),p1.c_str())) //if not pointed but small
	    {
	      tok1 = part1.substr(0,part1.find(",")); //move(right
	      tok2 = tok1.substr(tok1.find("("),tok1.size());// (right
	      tok3 = tok2.substr(1,tok2.size());// right token12
	      tok4 = part1.substr(0,part1.find(",")); //move(right   
	      tok5 = tok4.substr(0,tok4.find("(")); //move token 11
	      tok6 = part1.substr(part1.find(","),part1.size()); //,pointed_at(rock))
	      tok7 = tok6.substr(1,tok6.size()); //pointed_at(rock))
	      tok8 = tok7.substr(tok7.find("("),tok7.size()); //(rock))
	      tok9 = tok8.substr(1,tok8.size()); //rock))
	      tok10 = tok9.substr(0,tok9.find(")")); //rock
	      flag1 = "false";
	      property1 = "small";

	      array_vec = array_vec + tok5 +","+ tok3 +","+ property1 + ","+ tok10 +","+ flag1;
	    }else if(strstr(part1.c_str(),p2.c_str()))//if not small but big
	    {
	      tok1 = part1.substr(0,part1.find(",")); //move(right
	      tok2 = tok1.substr(tok1.find("("),tok1.size());// (right
	      tok3 = tok2.substr(1,tok2.size());// right token12
	      tok4 = part1.substr(0,part1.find(",")); //move(right   
	      tok5 = tok4.substr(0,tok4.find("(")); //move token 11
	      tok6 = part1.substr(part1.find(","),part1.size()); //,pointed_at(rock))
	      tok7 = tok6.substr(1,tok6.size()); //pointed_at(rock))
	      tok8 = tok7.substr(tok7.find("("),tok7.size()); //(rock))
	      tok9 = tok8.substr(1,tok8.size()); //rock))
	      tok10 = tok9.substr(0,tok9.find(")")); //rock
	      property1 = "big";
	      flag1 = "false";
	      array_vec = array_vec + tok5 +","+ tok3 +","+ property1 + ","+ tok10 +","+ flag1;



	    }else if(strstr(part1.c_str(),c1.c_str())) //if not big but colored red
	    {
	      tok1 = part1.substr(0,part1.find(",")); //move(right
	      tok2 = tok1.substr(tok1.find("("),tok1.size());// (right
	      tok3 = tok2.substr(1,tok2.size());// right token12
	      tok4 = part1.substr(0,part1.find(",")); //move(right   
	      tok5 = tok4.substr(0,tok4.find("(")); //move token 11
	      tok6 = part1.substr(part1.find(","),part1.size()); //,pointed_at(rock))
	      tok7 = tok6.substr(1,tok6.size()); //pointed_at(rock))
	      tok8 = tok7.substr(tok7.find("("),tok7.size()); //(rock))
	      tok9 = tok8.substr(1,tok8.size()); //rock))
	      tok10 = tok9.substr(0,tok9.find(")")); //rock
	      property1 = "red";
	      flag1 = "false";
	      array_vec = array_vec + tok5 +","+ tok3 +","+ property1 + ","+ tok10 +","+ flag1;

	    }else if(strstr(part1.c_str(),c2.c_str())) //if not red but blue
	    {
	      tok1 = part1.substr(0,part1.find(",")); //move(right
	      tok2 = tok1.substr(tok1.find("("),tok1.size());// (right
	      tok3 = tok2.substr(1,tok2.size());// right token12
	      tok4 = part1.substr(0,part1.find(",")); //move(right   
	      tok5 = tok4.substr(0,tok4.find("(")); //move token 11
	      tok6 = part1.substr(part1.find(","),part1.size()); //,pointed_at(rock))
	      tok7 = tok6.substr(1,tok6.size()); //pointed_at(rock))
	      tok8 = tok7.substr(tok7.find("("),tok7.size()); //(rock))
	      tok9 = tok8.substr(1,tok8.size()); //rock))
	      tok10 = tok9.substr(0,tok9.find(")")); //rock
	      property1 = "blue";
	      flag1 = "false";
	      array_vec = array_vec + tok5 +","+ tok3 +","+ property1 + ","+ tok10 +","+ flag1;
	    }else if(strstr(part1.c_str(),c3.c_str())) //if not blue but green
	    {    
	      tok1 = part1.substr(0,part1.find(",")); //move(right
	      tok2 = tok1.substr(tok1.find("("),tok1.size());// (right
	      tok3 = tok2.substr(1,tok2.size());// right token12
	      tok4 = part1.substr(0,part1.find(",")); //move(right   
	      tok5 = tok4.substr(0,tok4.find("(")); //move token 11
	      tok6 = part1.substr(part1.find(","),part1.size()); //,pointed_at(rock))
	      tok7 = tok6.substr(1,tok6.size()); //pointed_at(rock))
	      tok8 = tok7.substr(tok7.find("("),tok7.size()); //(rock))
	      tok9 = tok8.substr(1,tok8.size()); //rock))
	      tok10 = tok9.substr(0,tok9.find(")")); //rock
	      property1 = "green";
	      flag1 = "false";
	      array_vec = array_vec + tok5 +","+ tok3 +","+ property1 + ","+ tok10 +","+ flag1;
	    }else if(strstr(part1.c_str(),c4.c_str())) //if not green but brown
	    {
	      tok1 = part1.substr(0,part1.find(",")); //move(right
	      tok2 = tok1.substr(tok1.find("("),tok1.size());// (right
	      tok3 = tok2.substr(1,tok2.size());// right token12
	      tok4 = part1.substr(0,part1.find(",")); //move(right   
	      tok5 = tok4.substr(0,tok4.find("(")); //move token 11
	      tok6 = part1.substr(part1.find(","),part1.size()); //,pointed_at(rock))
	      tok7 = tok6.substr(1,tok6.size()); //pointed_at(rock))
	      tok8 = tok7.substr(tok7.find("("),tok7.size()); //(rock))
	      tok9 = tok8.substr(1,tok8.size()); //rock))
	      tok10 = tok9.substr(0,tok9.find(")")); //rock
	      property1 = "brown";
	      flag1 = "false";
	      array_vec = array_vec + tok5 +","+ tok3 +","+ property1 + ","+ tok10 +","+ flag1;
	    }else
	    {
	      tok20 = part1.substr(0,part1.find(",")); //move(right
	      tok21 = tok20.substr(tok20.find("("),tok20.size());// (right
	      tok22 = tok21.substr(1,tok21.size());// right
	      
	      tok23 = no_brackets[i].substr(no_brackets[i].find(","),no_brackets[i].size());
	      tok24 = tok23.substr(1,tok23.size());
	      tok25 = tok24.substr(0,tok24.find(")")); //first obj
	      tok26 = no_brackets[i].substr(0,no_brackets[i].find("(")); //action
	      flag1 = "false";
	      property1 = "empty";
	      array_vec = array_vec +tok26 +","+ tok22 +","+ property1 + ","+ tok25 +","+ flag1;

	    }
	  
	  if(strstr(part2.c_str(),s3.c_str())) //if pointed in second part
	    {
	      tok30 = part2.substr(0,part2.find(",")); //inside(right
	      tok31 = tok30.substr(tok30.find("("),tok30.size()); //(right
	      tok32 = tok31.substr(1,tok31.size()); //right
	      
	      tok33 = part2.substr(part2.find(","),part2.size()); //,pointed(rock)
	      tok34 = tok33.substr(tok33.find("("),tok33.size()); //(rock))
	      tok35 = tok34.substr(1,tok34.size()); //rock))
	      tok36 = tok35.substr(0,tok35.find(")"));  //rock
	      flag2 = "true";
	      property2 = "empty";
	      array_vec = array_vec +","+ "repeat" +","+ tok32 +","+ property2 + ","+ tok36 +","+ flag2 + "0";

	    }
	  else if(strstr(part2.c_str(),p1.c_str())) //if not pointed but small
	    {
	      tok30 = part2.substr(0,part2.find(",")); //inside(right
	      tok31 = tok30.substr(tok30.find("("),tok30.size()); //(right
	      tok32 = tok31.substr(1,tok31.size()); //right
	      
	      tok33 = part2.substr(part2.find(","),part2.size()); //,pointed(rock)
	      tok34 = tok33.substr(tok33.find("("),tok33.size()); //(rock))
	      tok35 = tok34.substr(1,tok34.size()); //rock))
	      tok36 = tok35.substr(0,tok35.find(")"));  //rock
	      property2 = "small";
	      flag2 = "false";
	      array_vec = array_vec +","+ "repeat" +","+ tok32 +","+ property2 + ","+ tok36 +","+ flag2 + "0";
	     
	    }else if(strstr(part2.c_str(),p2.c_str()))//if not small but big
	    {
	      tok30 = part2.substr(0,part2.find(",")); //inside(right
	      tok31 = tok30.substr(tok30.find("("),tok30.size()); //(right
	      tok32 = tok31.substr(1,tok31.size()); //right
	      
	      tok33 = part2.substr(part2.find(","),part2.size()); //,pointed(rock)
	      tok34 = tok33.substr(tok33.find("("),tok33.size()); //(rock))
	      tok35 = tok34.substr(1,tok34.size()); //rock))
	      tok36 = tok35.substr(0,tok35.find(")"));  //rock
	      flag2 = "false";
	      property2 = "big";	     
	      array_vec = array_vec +","+ "repeat" +","+ tok32 +","+ property2 + ","+ tok36 +","+ flag2 + "0";
	     
	    }else if(strstr(part2.c_str(),c1.c_str())) //if not big but colored red
	    {
	      tok30 = part2.substr(0,part2.find(",")); //inside(right
	      tok31 = tok30.substr(tok30.find("("),tok30.size()); //(right
	      tok32 = tok31.substr(1,tok31.size()); //right
	      
	      tok33 = part2.substr(part2.find(","),part2.size()); //,pointed(rock)
	      tok34 = tok33.substr(tok33.find("("),tok33.size()); //(rock))
	      tok35 = tok34.substr(1,tok34.size()); //rock))
	      tok36 = tok35.substr(0,tok35.find(")"));  //rock
	      flag2 = "false";
	      property2 = "red";
	      array_vec = array_vec +","+ "repeat" +","+ tok32 +","+ property2 + "," +tok36 +","+ flag2 + "0";
	      

	    }else if(strstr(part2.c_str(),c2.c_str())) //if not red but blue
	    {	
	      tok30 = part2.substr(0,part2.find(",")); //inside(right
	      tok31 = tok30.substr(tok30.find("("),tok30.size()); //(right
	      tok32 = tok31.substr(1,tok31.size()); //right
	      
	      tok33 = part2.substr(part2.find(","),part2.size()); //,pointed(rock)
	      tok34 = tok33.substr(tok33.find("("),tok33.size()); //(rock))
	      tok35 = tok34.substr(1,tok34.size()); //rock))
	      tok36 = tok35.substr(0,tok35.find(")"));  //rock
	      flag2 = "false";
	      property2 = "blue";
	      array_vec = array_vec +","+ "repeat" +","+ tok32 +","+ property2 + ","+ tok36 +","+ flag2 + "0";
	     
	    }else if(strstr(part2.c_str(),c3.c_str())) //if not blue but green
	    {    
	      tok30 = part2.substr(0,part2.find(",")); //inside(right
	      tok31 = tok30.substr(tok30.find("("),tok30.size()); //(right
	      tok32 = tok31.substr(1,tok31.size()); //right
	      
	      tok33 = part2.substr(part2.find(","),part2.size()); //,pointed(rock)
	      tok34 = tok33.substr(tok33.find("("),tok33.size()); //(rock))
	      tok35 = tok34.substr(1,tok34.size()); //rock))
	      tok36 = tok35.substr(0,tok35.find(")"));  //rock
	      flag2 = "false";
	      property2 = "green";
	      array_vec = array_vec +","+ "repeat" +","+ tok32 +","+ property2 + ","+ tok36 +","+ flag2 + "0";
	      
	    }else if(strstr(part2.c_str(),c4.c_str())) //if not green but brown
	    {
	      tok30 = part2.substr(0,part2.find(",")); //inside(right
	      tok31 = tok30.substr(tok30.find("("),tok30.size()); //(right
	      tok32 = tok31.substr(1,tok31.size()); //right
	      
	      tok33 = part2.substr(part2.find(","),part2.size()); //,pointed(rock)
	      tok34 = tok33.substr(tok33.find("("),tok33.size()); //(rock))
	      tok35 = tok34.substr(1,tok34.size()); //rock))
	      tok36 = tok35.substr(0,tok35.find(")"));  //rock
	      flag2 = "false";
	      property2 = "brown";
	      array_vec = array_vec +","+ "repeat" +","+ tok32 +","+ property2 + ","+ tok36 +","+ flag2 + "0";

	    }
	  else //if not pointed in second part
	    {
	      
	      tok40 = part2.substr(0,part2.find(",")); //inside(next
	      tok41 = tok40.substr(tok40.find("("),tok40.size()); //(next
	      tok42 = tok41.substr(1,tok41.size()); //left
	      tok43 = part2.substr(part2.find(","),part2.size()); 
	      tok44 = tok43.substr(0,tok43.find(")")); 
	      tok45 = tok44.substr(1,tok44.size()); //tree
	      flag2 = "false";
	      property2 = "empty";
	      array_vec = array_vec + "," +"repeat" +","+ tok42 +","+property2+","+ tok45 +","+ flag2 + "0";
	    }
	}else //if not inside
	{
	  if(strstr(no_brackets[i].c_str(),s3.c_str())) //if pointed
	    {
	      tok50 = no_brackets[i].substr(0,no_brackets[i].find(",")); //move(right
	      tok51 = tok50.substr(tok50.find("("),tok50.size());// (right
	      tok52 = tok51.substr(1,tok51.size());// right token12
	      tok53 = no_brackets[i].substr(0,no_brackets[i].find(",")); //move(right   
	      tok54 = tok53.substr(0,tok53.find("(")); //move token 11
	      tok55 = no_brackets[i].substr(no_brackets[i].find(","),no_brackets[i].size()); //,pointed_at(rock))
	      tok56 = tok55.substr(1,tok55.size()); //pointed_at(rock))
	      tok57 = tok56.substr(tok56.find("("),tok56.size()); //(rock))
	      tok58 = tok57.substr(1,tok57.size()); //rock))
	      tok59 = tok58.substr(0,tok58.find(")")); //rock
	      flag2 = "true";
	      property2 = "empty";
		array_vec =  array_vec + tok54 +","+ tok52  +","+property2+","+ tok59 +","+ flag2 + "0";

	    }  else if(strstr(no_brackets[i].c_str(),p1.c_str())) //if not pointed but small
	    {
	      tok50 = no_brackets[i].substr(0,no_brackets[i].find(",")); //move(right
	      tok51 = tok50.substr(tok50.find("("),tok50.size());// (right
	      tok52 = tok51.substr(1,tok51.size());// right token12
	      tok53 = no_brackets[i].substr(0,no_brackets[i].find(",")); //move(right   
	      tok54 = tok53.substr(0,tok53.find("(")); //move token 11
	      tok55 = no_brackets[i].substr(no_brackets[i].find(","),no_brackets[i].size()); //,pointed_at(rock))
	      tok56 = tok55.substr(1,tok55.size()); //pointed_at(rock))
	      tok57 = tok56.substr(tok56.find("("),tok56.size()); //(rock))
	      tok58 = tok57.substr(1,tok57.size()); //rock))
	      tok59 = tok58.substr(0,tok58.find(")")); //rock
	      property2 = "small";
	      flag2 = "false";
	      array_vec =  array_vec + tok54 +","+ tok52 +","+property2+","+ tok59 +","+ flag2 + "0";      
	    }else if(strstr(no_brackets[i].c_str(),p2.c_str()))//if not small but big
	    {
	      tok50 = no_brackets[i].substr(0,no_brackets[i].find(",")); //move(right
	      tok51 = tok50.substr(tok50.find("("),tok50.size());// (right
	      tok52 = tok51.substr(1,tok51.size());// right token12
	      tok53 = no_brackets[i].substr(0,no_brackets[i].find(",")); //move(right   
	      tok54 = tok53.substr(0,tok53.find("(")); //move token 11
	      tok55 = no_brackets[i].substr(no_brackets[i].find(","),no_brackets[i].size()); //,pointed_at(rock))
	      tok56 = tok55.substr(1,tok55.size()); //pointed_at(rock))
	      tok57 = tok56.substr(tok56.find("("),tok56.size()); //(rock))
	      tok58 = tok57.substr(1,tok57.size()); //rock))
	      tok59 = tok58.substr(0,tok58.find(")")); //rock
	      property2 = "big";
	      flag2 = "false";
	      array_vec =  array_vec + tok54 +","+ tok52 +","+property2+","+ tok59 +","+ flag2 + "0";

	    }else if(strstr(no_brackets[i].c_str(),c1.c_str())) //if not big but colored red
	    {
	      tok50 = no_brackets[i].substr(0,no_brackets[i].find(",")); //move(right
	      tok51 = tok50.substr(tok50.find("("),tok50.size());// (right
	      tok52 = tok51.substr(1,tok51.size());// right token12
	      tok53 = no_brackets[i].substr(0,no_brackets[i].find(",")); //move(right   
	      tok54 = tok53.substr(0,tok53.find("(")); //move token 11
	      tok55 = no_brackets[i].substr(no_brackets[i].find(","),no_brackets[i].size()); //,pointed_at(rock))
	      tok56 = tok55.substr(1,tok55.size()); //pointed_at(rock))
	      tok57 = tok56.substr(tok56.find("("),tok56.size()); //(rock))
	      tok58 = tok57.substr(1,tok57.size()); //rock))
	      tok59 = tok58.substr(0,tok58.find(")")); //rock
	      array_vec =  array_vec + tok54 +","+ tok52 +","+property2+","+ tok59 +","+ flag2 + "0";
	      flag2 = "false";
	      property2 = "red";

	    }else if(strstr(no_brackets[i].c_str(),c2.c_str())) //if not red but blue
	    {	
	      tok50 = no_brackets[i].substr(0,no_brackets[i].find(",")); //move(right
	      tok51 = tok50.substr(tok50.find("("),tok50.size());// (right
	      tok52 = tok51.substr(1,tok51.size());// right token12
	      tok53 = no_brackets[i].substr(0,no_brackets[i].find(",")); //move(right   
	      tok54 = tok53.substr(0,tok53.find("(")); //move token 11
	      tok55 = no_brackets[i].substr(no_brackets[i].find(","),no_brackets[i].size()); //,pointed_at(rock))
	      tok56 = tok55.substr(1,tok55.size()); //pointed_at(rock))
	      tok57 = tok56.substr(tok56.find("("),tok56.size()); //(rock))
	      tok58 = tok57.substr(1,tok57.size()); //rock))
	      tok59 = tok58.substr(0,tok58.find(")")); //rock
	      flag2 = "false";
	      property2 = "blue";
	      array_vec =  array_vec + tok54 +","+ tok52 +","+property2+","+ tok59 +","+ flag2 + "0";
	      
	    }else if(strstr(no_brackets[i].c_str(),c3.c_str())) //if not blue but green
	    {    
	      tok50 = no_brackets[i].substr(0,no_brackets[i].find(",")); //move(right
	      tok51 = tok50.substr(tok50.find("("),tok50.size());// (right
	      tok52 = tok51.substr(1,tok51.size());// right token12
	      tok53 = no_brackets[i].substr(0,no_brackets[i].find(",")); //move(right   
	      tok54 = tok53.substr(0,tok53.find("(")); //move token 11
	      tok55 = no_brackets[i].substr(no_brackets[i].find(","),no_brackets[i].size()); //,pointed_at(rock))
	      tok56 = tok55.substr(1,tok55.size()); //pointed_at(rock))
	      tok57 = tok56.substr(tok56.find("("),tok56.size()); //(rock))
	      tok58 = tok57.substr(1,tok57.size()); //rock))
	      tok59 = tok58.substr(0,tok58.find(")")); //rock
	      property2 = "green";
	      flag2 = "false";
	      array_vec =  array_vec + tok54 +","+ tok52 +","+property2+","+ tok59 +","+ flag2 + "0";
	     
	    }else if(strstr(part1.c_str(),c4.c_str())) //if not green but brown
	    {
	      tok50 = no_brackets[i].substr(0,no_brackets[i].find(",")); //move(right
	      tok51 = tok50.substr(tok50.find("("),tok50.size());// (right
	      tok52 = tok51.substr(1,tok51.size());// right token12
	      tok53 = no_brackets[i].substr(0,no_brackets[i].find(",")); //move(right   
	      tok54 = tok53.substr(0,tok53.find("(")); //move token 11
	      tok55 = no_brackets[i].substr(no_brackets[i].find(","),no_brackets[i].size()); //,pointed_at(rock))
	      tok56 = tok55.substr(1,tok55.size()); //pointed_at(rock))
	      tok57 = tok56.substr(tok56.find("("),tok56.size()); //(rock))
	      tok58 = tok57.substr(1,tok57.size()); //rock))
	      tok59 = tok58.substr(0,tok58.find(")")); //rock
	      property2 = "brown";
	      flag2 = "false";
	      array_vec =  array_vec + tok54 +","+ tok52 +","+ property2 +","+ tok59 +","+ flag2 + "0";
	  
	    }else //if not pointed and all the properties didn't fit
	    {
	      tok50 = no_brackets[i].substr(0,no_brackets[i].find(",")); //move(right
	      tok51 = tok50.substr(tok50.find("("),tok50.size());// (right
	      tok52 = tok51.substr(1,tok51.size());// right token12
	      tok53 = no_brackets[i].substr(0,no_brackets[i].find(",")); //move(right   
	      tok54 = tok53.substr(0,tok53.find("(")); //move token 11
	      tok55 = no_brackets[i].substr(no_brackets[i].find(","),no_brackets[i].size()); //,rock)
	      tok56 = tok55.substr(1,tok55.size()); //rock))
	      tok59 = tok56.substr(0,tok56.find(")")); //rock
	      flag2 = "false";
	      property2 = "empty";
	      array_vec = array_vec + tok54 +","+ tok52 +","+ property2 +","+ tok59 +","+ flag2 + "0";
        
	    }
	}
    }

  ROS_INFO_STREAM("array_vec: " + array_vec);
return array_vec;

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
  std::vector<string> marray;
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
