# realtime-collaborative-concept-mapper
A real-time collaborative tool used for creating concept maps on the web

This is a client-server single page application for real-time collaborative concept map creation.
The server side was done with NodeJS. Main modules used for this application 
•	express – a robust framework for HTTP servers, which is works great for SPAs
•	jade – high performance template engine written in JavaScript for Node.JS
•	socket.io – WebSocket API for real-time apps

# Functional Spec
The web app is done with MVC in Angular 1.2.1 using jQuery, CoffeeScript and Vanilla Javascript to implement the following functionalities:
## F 1: Workspace creation 
The user should be able create a shared workspace, where the concept map is to be developed. A unique identifier should be applied to the workspace for future refer-ence.
## F 2: User authentication 
A concept map developer can identify themselves by providing a username of their choice. A unique identifies for each user should also be supplied by the system.
## F 3: Concept creation 
The user can create concepts onto the shared workspace.
## F 4: Edit concept properties
Object properties of a concept, such as label and position of the concept on the workspace can be modified by the concept map developer
## F 5: Deleting concept 
Due to the intended collaborative aspect of the system mistakes and correction in the concept map design are to be made, therefore the possibility of deleting a concept has to be resembled as one of the expected functions.
## F 6: Relation creation 
Based on the concept map description a user has to be able to establish the relations between concepts.
## F 7: Edit relation properties
A relation may have different meaning depending on the concepts it connects. Therefore, the user should be able to define the label describing the relation.
## F 8: Delete relation 
As mentioned in F 5 deleting a relation is an essential part of the revision and further development of a concept map.
## F 9: Save progress 
Being able to save the current progress of a concept map solution is an essential function, which will enable the developers to continue with their work at a different time. 
## F 10: Load concept 
The previous functionality implies that the user can load the saved concept onto the workspace.
## F 11: Logging 
The system logs each change made by the user when invoking any of the above men-tioned functionalities F 1 to F 10.
## F 12: Change propagation 
Any changes to the concept map workspace that have been made by the developer through invoking any of the functionalities F 1 F 3 to F 8 have to be propagated to all other developers working on the same concept map at that time.
## F 13: Change notification
All users working on the same project at the same time have to be notified of any occurring change made by other concept map developers. Furthermore, the need of a locking mechanism implies that at a certain point a resource (either concept or relation) may not be available to every participant. Therefore, notification the resource’s unavailability has to be conveyed.

# Architecture
The implemented architecture and component communication is visualized below.
<img alt="Architecture" src="https://github.com/bozhan/realtime-collaborative-concept-mapper/blob/master/img/concept.png" width="100%" height="100%">
