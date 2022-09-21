## iris-cron-task
[![Quality Gate Status](https://community.objectscriptquality.com/api/project_badges/measure?project=intersystems_iris_community%2Firis-cron-task&metric=alert_status)](https://community.objectscriptquality.com/dashboard?id=intersystems_iris_community%2Firis-cron-task) 
Class to setup tasks running at schedule with cron expression.
The cron expression could be taken from [cronmaker site](http://www.cronmaker.com/)
Thanks to [Lorenzo's Skaleze](https://github.com/lscalese) PR this works with any cron expression.

### Installation with ZPM

USER>zpm "install iris-cron-task"

### Installaton with importing class

Import [the class](https://github.com/evshvarov/iris-cron-task/blob/master/src%2Fdc%2Fcron%2Ftask.cls) into your system. 

### testing with docker and collaboration

Clone/git pull the repo into any local directory

```
$ git clone https://github.com/evshvarov/iris-cron-task.git
```

Open the terminal in this directory and run:

```
$ docker-compose build
```

3. Run the IRIS container with your project:

```
$ docker-compose up -d
```

## Usage

Open IRIS terminal:

```
$ docker-compose exec iris iris session iris
USER>
````
Run "set ^A($I(^A))=$H" every minute:
```
USER>zw ##class(dc.cron.task).Start("IRIS cron task name","* * * * *","s ^A($I(^A))=$H",1,.taskId)
```
taskId contains the id of the task created:
USER>w taskId
1000

It will store in a global ^A the something like the following:
USER>zw ^A
^A=6
^A(1)="65732,54180"
^A(2)="65732,54240"
^A(3)="65732,54300"
^A(4)="65732,54360"
^A(5)="65732,54420"
^A(6)="65732,54480"


Run "set ^B($I(^B))=$H" every hour:
```
USER>zw ##class(dc.cron.task).Start("IRIS cron task name","0 * * * *","s ^B($I(^B))=$H",1,.taskId)
```
Run "set ^A($I(^A))=$H" every day at midnight:
```
USER>zw ##class(dc.cron.task).Start("IRIS cron task name","0 0 * * *","s ^C($I(^C))=$H",1,.taskId)
```

And you can delete the task when you don't need it anymore.

USER>zw ##class(dc.cron.task).Kill(taskId)

## CronMaker syntax

[CronMaker](http://www.cronmaker.com) syntax is also supported by using `StartByCronMakerExpression` method.  
Example, run every Monday and Tuesday at 2:00 pm :  
```
Set sc = ##class(dc.cron.task).StartByCronMakerExpression("The Task Name","0 0 14 ? * MON,TUE *","set ^A($I(^A))=$H",,.tid)
```

or you can call method Start because it uses StartByCronMakerExpression inside now.

```
Set sc = ##class(dc.cron.task).Start("The Task Name","0 0 14 ? * MON,TUE *","set ^A($I(^A))=$H",,.tid)
```

## Collaboration
You are very welcome to collaborate and make changes.
Fork the repository and send Pull Request.

Below I describe how to make changes in ObjectScript part:
## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

This repository is ready to code in VSCode with ObjectScript plugin.
Install [VSCode](https://code.visualstudio.com/), [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) and [ObjectScript](https://marketplace.visualstudio.com/items?itemName=daimor.vscode-objectscript) plugin and open the folder in VSCode.
Open /src/cls/PackageSample/ObjectScript.cls class and try to make changes - it will be compiled in running IRIS docker container.
![docker_compose](https://user-images.githubusercontent.com/2781759/76656929-0f2e5700-6547-11ea-9cc9-486a5641c51d.gif)

Feel free to delete PackageSample folder and place your ObjectScript classes in a form
/src/Package/Classname.cls
[Read more about folder setup for InterSystems ObjectScript](https://community.intersystems.com/post/simplified-objectscript-source-folder-structure-package-manager)

The script in Installer.cls will import everything you place under /src into IRIS.


## What's inside the repository

### Dockerfile

The simplest dockerfile which starts IRIS and imports code from /src folder into it.
Use the related docker-compose.yml to easily setup additional parametes like port number and where you map keys and host folders.


### .vscode/settings.json

Settings file to let you immedietly code in VSCode with [VSCode ObjectScript plugin](https://marketplace.visualstudio.com/items?itemName=daimor.vscode-objectscript))

### .vscode/launch.json
Config file if you want to debug with VSCode ObjectScript

[Read about all the files in this artilce](https://community.intersystems.com/post/dockerfile-and-friends-or-how-run-and-collaborate-objectscript-projects-intersystems-iris)
