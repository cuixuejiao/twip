#!/bin/bash
# Setup my twip environemt
pn=twip

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run this section if docker is not installed
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# check for pre-reqs
if [ ! -x "$(which docker)" ]; then
    if [ "Linux" != "$(uname)" ]; then
       echo "This script is meant for Ubuntu Trusty 14.04 (LTS)"
       exit
    fi
     
    echo Check/Installing docker
    [ ! -x "$(which docker)" ] && curl -sSL https://get.docker.com |sh

    # add ubunto to the docker group if it is not there
    [ ! -x "$(getent group docker | grep ubuntu)" ] && sudo usermod -aG docker ubuntu
        
    # Now lets get docker compose
    echo Check/Installing docker-compose
    dc=$(which docker-compose)

    if [ $? -ne 0 ]; then
        curl -L https://github.com/docker/compose/releases/download/1.7.0/docker-compose-`uname -s`-`uname -m` > docker-compose
        chmod +x docker-compose
        sudo mv docker-compose /usr/local/bin/docker-compose
    fi
    
    # and finally docker machine
    echo Check/Installing docker-machine
    dc=$(which docker-machine)
    
    if [ $? -ne 0 ]; then
        curl -L https://github.com/docker/machine/releases/download/v0.6.0/docker-machine-`uname -s`-`uname -m` > docker-machine
        chmod +x docker-machine
        sudo mv docker-machine /usr/local/bin/docker-machine
    fi        

    echo
    echo sudo docker version
    sudo docker version    
    echo 
    echo please logout and relogin so that the group settings 
    echo are applied to your session
    echo
    exit
fi


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# helper functions 

# a little clean up function
cleanup(){
    docker rm $(docker ps --filter status=exited -q 2>/dev/null) 2>/dev/null
    docker rmi $(docker images --filter dangling=true -q 2>/dev/null) 2>/dev/null
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Help 
if [ $# -lt 1 ] || [ "$1" = "help" ]; then
   echo
   echo "$pn usage: command [arg...]"
   echo
   echo "Commands:"
   echo
   echo "train      Creates the training environment"
   echo "prod       Creates the production environment"
   echo "status     Display the status of the environment"
   echo "clean      Removes dangling images and exited containers"
   echo "images     List images"
   echo
   exit
fi 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# training
if [ "$1" = "train" ]; then
	if [ $# -lt 2 ]; then
        echo
        echo "usage : $pn $1 [ build | up | down ]"
    else
        cd $1
            cmd="$2"
            if [ "$2" = "build" ]; then docker build -t train_web ./web;fi
            if [ "$2" = "up" ]; then cmd="up -d";fi;
            docker-compose $cmd $3 $4
            if [ "$2" = "build" ]; then echo;docker images
            else echo;docker-compose ps;fi        
        cd ..
    fi
	echo
    exit
fi    	

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# prod
if [ "$1" = "prod" ]; then
	if [ $# -lt 2 ]; then
        echo
        echo "usage : $pn $1 [ build | up | down ]"
    else
        cd $1
            cmd="$2"
            if [ "$2" = "up" ]; then cmd="up -d";fi;
            docker-compose $cmd $3 $4
            if [ "$2" = "build" ]; then echo;docker images
            else echo;docker-compose ps;fi        
        cd ..
    fi
	echo
    exit
fi  

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# status
if [ "$1" = "status" ]; then
    env | grep DOCKER
    docker ps -a
	echo;exit
fi      	

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# images
if [ "$1" = "images" ]; then
    docker images
	echo;exit
fi    	

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# clean
if [ "$1" = "clean" ]; then
	if [ "$2" = "all" ]; then docker rmi $(docker images -q)
    elif [ "$2" = "up" ]; then cleanup
    else
        echo
        echo "usage : $pn clean [ up | all ]";
	fi
	echo;exit;	
fi;

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Unknown
echo
(>&2 echo $pn: UNKNOWN COMMAND [\"$1\"])
$0 help
exit
 