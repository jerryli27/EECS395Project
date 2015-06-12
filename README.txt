EECS 395 Project
Ivy Zheng, Jiaming Li
netid:xzh417,jlt709

We made a course selection helper in Unity that can give some course FAQ and suggestions when the user type in the game. The curriculum data are copied from the database we used earlier on class. 
Most of the code we added is in /Assets/Courses/csCourses.prolog. 

The user can do the following once he starts the game:

1. Telling the selection helper that the user has completed a cs course. 
The grammar is : I have taken eecs213.
(eecs213 can be any other eecs courses in the database. Same for ai_depth below.)

2. Asking how to take a cs course. The system will look on the courses that you have already taken, and if you are still not able to take this class, it will show you all the courses you still need to take before taking this particular class. Otherwise, it will tell you that you are good to go. 
The grammar is: How do I take eecsXXX?

3. Asking how to satisfy a section requirement to graduate. The available sections are core, software_development, systems_breadth, ai_breadth, interfaces_breadth, theory_breadth, systems_depth, ai_depth, interfaces_depth, theory_depth, and security_depth. The system will look whether you have satisfied it, and if not, it will list the class options for this section.
The grammar is: How do I satisfy ai_depth?

4. Asking for a description of a course. It will answer the name of the course and what it requires, if there is any.
The grammar is: What is eecsXXX?
