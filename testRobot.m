function [] = testRobot(pinLetter, pinNumber)
%Note that the pinLetter has to be a capital letter between 'A' and 'Q'

%xyz distance fo the corner of the perfboard closest to the robot from the
%base of the robot
xPerfToBase = 231.7750;%mm
yPerfToBase = 0;%mm
zPerfToBase = 30;%mm

%distance from the left corner to the closest pin
xCornerToPin = 5;%mm
yCornerToPin = 9.23;%mm

%distance between the centers of respective pins 
distBtwPins = 2.11; 

%convert the pinLetter to a number 
alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
alphaNumber = strfind(alphabet,pinLetter); 

%get the goal xyz position to actuate the tip of the robot to
xGoal = alphaNumber * distBtwPins + xCornerToPin + xPerfToBase; 
yGoal = pinNumber * distBtwPins + yCornerToPin + yPerfToBase;
zGoal = zPerfToBase;

%define the size of the square perfboard on which to solder
s = 100;%mm

%draw the perfboard
%define the points for the perfboard 
p5 = [xPerfToBase,-s/2+yPerfToBase, zPerfToBase];
p6 = [xPerfToBase,s/2+yPerfToBase, zPerfToBase];
p7 = [s+xPerfToBase,s/2+yPerfToBase, zPerfToBase];
p8 = [s+xPerfToBase,-s/2+yPerfToBase, zPerfToBase];

%draw the perfboard on the simulation 
xFloor = [p5(1) p6(1) p7(1) p8(1)];
yFloor = [p5(2) p6(2) p7(2) p8(2)];
zFloor = [p5(3) p6(3) p7(3) p8(3)];
fill3(xFloor, yFloor, zFloor, 'y');
hold on; 

%draw the goal on the perfboard 
scatter3(xGoal,yGoal,zGoal,100,'r','filled');

%starting position is initial q=zero vector
qStart = [0,0,0,0,0,0];
%find the goal orientation of the end effector 
goalOrientation = [0,1,0; 1,0,0; 0,0,-1];
%find qEnd using IK using the goal EE position and also the goal
%orientation 
T = [[goalOrientation;[0,0,0]],[xGoal;yGoal;zGoal;1]];
[qEnd,isPossible] = IK_lynx_sol(T); 

%testing
[x,~] = updateQ(qEnd); 
xEE = x(6,:); 
disp (xEE);
disp ([xGoal yGoal zGoal]);

if (isPossible)
    %run the robot using a potential fields planner 
    potentialFieldPlanner(qStart,qEnd); 
end 

end

