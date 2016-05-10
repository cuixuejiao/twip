# The Infrastructure Problem (TWIP)
Submitted by [Marc J. Greenberg](mailto:codemarc@gmail.com)

### Background / Problem
> A development team has created a Java web app that is ready for a limited 
release (with reduced availability and reliability requirements).  If the 
limited release is successful, the app will be rolled out for worldwide use. 
Once fully public, the application needs to be available 24/7 and must provide 
sub-second response times and continuity through single-server failures.
 
>Create two environments - one for training and one for production. 
You should prepare the production environments for the limited release and plan 
for the scale out during fully public release. 
  
>Design and create the training and production environments, and provide a plan to 
scale out that deployment when the application goes public. You should use a 
virtualization solution such as VirtualBox for these environments. We do not want 
you to deliver the VMs to us. Instead you should provide scripts/documentation to 
enable us to build the environments ourselves very easily. We will use VirtualBox, 
VMWare or EC2 (your choice) to build your environments. (If you have another 
virtualization solution you would like to use please ping us first).

>  
> You have free rein to incorporate any software tools and hardware you need to 
> streamline application deployment and infrastructure provisioning & configuration 
> as long as they are Free/Libre/Open Source software (FLOSS). We request that 
> you use Linux.
>


### Solution Strategy

There is a set of principles about to follow when a working on problem set like this. 
Create infrastructure that is flexable, automatic, consistent, reproducable,
and disposable. The problem feels like it was custom made for a **container** solution.
And today that means **Docker**.  

Technologies selected/used

- Training [VMware Fusion](https://www.vmware.com/),[Oracle VirtualBox](https://www.virtualbox.org/)
- Production Amazon Web Services [EC2](https://aws.amazon.com/ec2/), [EC2 Container Service](https://aws.amazon.com/ecs/)
- [Ubuntu Linux](http://www.ubuntu.com/)
- [Docker Toolbox](https://www.docker.com/products/docker-toolbox) including [`docker`](https://www.docker.com), [`docker-compose`](https://www.docker.com/products/docker-compose), 
[`docker-machine`](https://www.docker.com/products/docker-machine), [`docker-swarm`](http://www.docker.com/products/docker-swarm)
- [Docker Hub](https://hub.docker.com/)
- [Git 1.9.1](https://git-scm.com/) And [GitHub](https://github.com/)
- [Alpine Linux 3.3](https://www.alpinelinux.org/)
- [NGINX 1.9.15](https://www.nginx.com/)
- [Oracle Jdk 8.77.03](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
- [HAProxy](http://www.haproxy.org/)
- [Apache Jetty](http://www.eclipse.org/jetty/)
- [Apache Bench](http://httpd.apache.org/docs/2.2/en/programs/ab.html)


1. Setup a working environment with the selected tooling.
-  Define/Build containers with the appropiate artifacts and configuration.
-  Test process using the pheonix server pattern (clean environment) to running solution.
   

<br/><hr/>
## Platfom

### Virtual Machine
We all know the easiest way to get started is to spinup a new vm either using 
VMWare Fusion or Virtual Box. Our elemental starting point is `Ubuntu 14.04.3 LTS`.
Since out work revolves around docker the first hurdle is to setup the raw environment
with the docker tool chain. 

### AWS EC2  

I like using public cloud resources (My personal favorite is Digital Ocean as 
i find droplets are easy to deal with). Since *AWS* is one of the choices, I 
start by spinning up a brand spanking new EC2 t2.micro instance, running 
`Ubuntu 14.04.3 LTS`. Please remember to open port `80` for HTTP traffic in the 
security group associated with your instance. 

### Docker Machine

One of the more interesting components of the docker toolset is the docker machine
as it provides the ability to provision and manager virtual machines with an installed
and running docker engine. I have used  docker machine with Oracle VirtualBox, 
VMware Fusion, VMware vSphere, Amazon Web Services, Digital Ocean and even my old 
dell laptop as bare metal running ubuntu 14.04 after I install docker.

Since it is outside the scope of this assignment I will avoid the provisioning
functionality till a discussion of high availabilty and clustering.

<br/><hr/>
## Source 
### Lets Get it Started

As a long time software development manager it always amazes me that there are still
a large number organizations that take a lackadaisical approach to sourcing work product. I 
believe that all the artifacts must be placed under version control. By workproduct I am 
referring all the artifacts related with the project including but not limited to:
source code, build and configuration scripts, images, certificates, presentations, 
documentation, etc.   

The reasons for this are well known in the construction of software products and they are 
equally applicable in the construction of infrastructure. 
* history; with comments and context
* transparency/visibility; a means to to share and correlate amoung multiple 
contributors
* actionability; the ability to automate the execution of an action based 
on a change.

The source for this project is currently stored on GitHub. In order to easily and more importantly 
get the source you need a git client installed on your virtual machine. 

ssh to your host and install git as follows:
 
````
Welcome to Ubuntu 14.04.3 LTS (GNU/Linux 3.13.0-74-generic x86_64)
  .
  .
  .
$ sudo apt-get update && sudo apt-get -y install git

```` 

With git availble, we can clone my ***twip*** repository using the command:
>
> git clone https://github.com/codemarc/twip.git
>      
  
```bash
$ git version
git version 1.9.1

$ git clone https://github.com/codemarc/twip.git
Cloning into 'twip'...
remote: Counting objects: 4, done.
remote: Compressing objects: 100% (4/4), done.
remote: Total 4 (delta 0), reused 4 (delta 0), pack-reused 0
Unpacking objects: 100% (4/4), done.
Checking connectivity... done.
```

## twip.sh

The main script for my solution is a bash script aptly named `twip.sh`.
It is located in the twip directory that you just cloned. While there are many 
other scripting approaches that could be used here, good old bash is still 
useful to get stuff done quicky right out of the box.

The first time you run `./twips.sh` on a fresh clean ubuntu 14.04 machine it
checks for and install 
[docker](https://www.docker.com), 
[docker-compose](https://www.docker.com/products/docker-compose), and 
[docker-machine](https://www.docker.com/products/docker-machine). 
Additionally setup adds the default ubuntu user to the docker group. All you need to do is 
to **logout** and then **relogin** so that the group modification can take effect.

```bash
$ cd twip
$ ./twip.sh
.
.
.

Docker version
Client:
 Version:      1.11.1
 API version:  1.23
 Go version:   go1.5.4
 Git commit:   5604cbe
 Built:        Tue Apr 26 23:30:23 2016
 OS/Arch:      linux/amd64

Server:
 Version:      1.11.1
 API version:  1.23
 Go version:   go1.5.4
 Git commit:   5604cbe
 Built:        Tue Apr 26 23:30:23 2016
 OS/Arch:      linux/amd64

```

After you log back in and cd twip and run `./twip.sh`
```bash
$ ./twip.sh

twip Usage: command [arg...]

Commands:

train      Creates the training environment
prod       Creates the production environment
status     Display the status of the environment
clean      Removes dangling images and exited containers
images     List images
```

<br/><hr/>
## Training 
Package the static assets into a container running [NGINX ]([NGINX](https://www.nginx.com/) and package the app 
on into a container running [jetty](http://www.eclipse.org/jetty/).

<img src='https://raw.githubusercontent.com/codemarc/twip/master/img/train.png' width='400'/>

### NGINX for proxy and hosting static assets

[NGINX](https://www.nginx.com/) is a web server, a load balancer, 
a content cache and more. I am by no means an NGINX expert but I have 
been using it more and more lately and I find it to be a very effective 
tool in the container world. It is modular in nature and is a little 
easier configure to understand then Apache, and if configured appropiatly
is is blazingly fast.

[jetty](http://www.eclipse.org/jetty/) is another web server that is 
able to serve static and/or dynamic content either from a standalone or embedded 
instantiations. While there is some overlap in between of capabilities of 
NGINX and jetty, in this project jetty is used strictly as a servlet container

### Building the containers

The included script `./twip.sh` simplifies the process of building and running
the environment. It is yet another wrapper on top of the docker tools to help 
reduce command line fat finger ~~mistakes~~.

````bash
$ ./twip.sh images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE

$ ./twip.sh train build
.
.
.
Successfully built 0200e8810fbd

REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
train_static        latest              e284bce1213c        28 seconds ago      61.94 MB
train_web           latest              f1cfb2ae200b        41 seconds ago      182.4 MB
nginx               1.9.15-alpine       3839248a6963        3 days ago          60.63 MB
alpine              3.3                 13e1761bf172        3 days ago          4.797 MB
````

* When constructing a container based infrastructure it is important to be mindful of image 
size. I believe that larger containers include more technical debt. Alpine Linux is billed 
as a security-oriented, lightweight Linux distribution. By itself it clock in at 4.79 MB
If we can construct all out containers based on the same underpinnings then we will have a 
cleaner and consistent environment.

* jetty requires a jdk as servlets are just in time compiled. The base implementation of alpine 
does not include java. I add the Oracle jdk version of java 8 to avoid any missing components.
It is bigger the so
 
### Run training
To spin up the training environment you can run `./twip.sh` as follows:  

````bash
$ ./twip.sh train up

Creating network "train_default" with the default driver
Creating train_web1_1
Creating train_web2_1
Creating train_static_1

     Name                   Command               State              Ports            
-------------------------------------------------------------------------------------
train_static_1   nginx -g daemon off;             Up      443/tcp, 0.0.0.0:80->80/tcp 
train_web1_1     /bin/sh -c java -jar jetty ...   Up      0.0.0.0:32812->8080/tcp     
train_web2_1     /bin/sh -c java -jar jetty ...   Up      0.0.0.0:32813->8080/tcp

$ wget localhost > /dev/null
HTTP request sent, awaiting response... 200 OK
Length: 331 [text/html]
Saving to: ‘index.html’
2016-05-07 22:02:58 (94.6 MB/s) - ‘index.html’ saved [331/331]
````

### Benchmarking the training environment
As I am a curious guy and I want to know how well this infrastructure stands up. 
I use Apache Bench to do some simple benchmarking. The twip.sh bench command 
runs ab apache bench, 1000 HTTP requests, 10 at a time.  
  
 `$ ab -n 1000 -c 10 http://localhost/`  
  
> $ ./twip.sh bench

````bash
$ ab -n 1000 -c 10 http://localhost/
This is ApacheBench, Version 2.3 <$Revision: 1528965 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking localhost (be patient)
Completed 100 requests
Completed 200 requests
Completed 300 requests
Completed 400 requests
Completed 500 requests
Completed 600 requests
Completed 700 requests
Completed 800 requests
Completed 900 requests
Completed 1000 requests
Finished 1000 requests


Server Software:        nginx/1.9.15
Server Hostname:        localhost
Server Port:            80

Document Path:          /
Document Length:        331 bytes

Concurrency Level:      10
Time taken for tests:   0.815 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      589914 bytes
HTML transferred:       331000 bytes
Requests per second:    1226.77 [#/sec] (mean)
Time per request:       8.151 [ms] (mean)
Time per request:       0.815 [ms] (mean, across all concurrent requests)
Transfer rate:          706.73 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.2      0       3
Processing:     2    8  10.9      6     183
Waiting:        0    8  10.9      6     182
Total:          2    8  10.9      6     183

Percentage of the requests served within a certain time (ms)
  50%      6
  66%      8
  75%      9
  80%      9
  90%     11
  95%     13
  98%     18
  99%     32
 100%    183 (longest request)
````

### Ups and Downs
The following tests illustrate behaviours of the training environment

#### no webapps
> $ ./twip.sh train scale web2=0  
> $ ./twip.sh train scale web1=0
 
````bash
     Name              Command          State              Ports            
---------------------------------------------------------------------------
train_static_1   nginx -g daemon off;   Up      443/tcp, 0.0.0.0:80->80/tcp 

$ wget localhost > /dev/null
HTTP request sent, awaiting response... 502 Bad Gateway
````

#### restore webapp
> ./twip.sh train scale web2=1  

````bash
     Name                   Command               State              Ports            
-------------------------------------------------------------------------------------
train_static_1   nginx -g daemon off;             Up      443/tcp, 0.0.0.0:80->80/tcp 
train_web2_1     /bin/sh -c java -jar jetty ...   Up      0.0.0.0:32779->8080/tcp     

$ wget localhost > /dev/null
HTTP request sent, awaiting response... 200 OK
````

#### scale up static assets
> $ ./twip.sh train scale static=2  

````bash
WARNING: The "static" service specifies a port on the host. If multiple containers for this service are created on a single host, the port will clash.
Creating and starting train_static_2 ... error

ERROR: for train_static_2  driver failed programming external connectivity on endpoint train_static_2 (c94a1180aa516d8f1f803c8145afc1719476b94c412c8ab77b29239d6fc3e736): Bind for 0.0.0.0:80 failed: port is already allocated

     Name                   Command                State                Ports            
----------------------------------------------------------------------------------------
train_static_1   nginx -g daemon off;             Up         443/tcp, 0.0.0.0:80->80/tcp 
train_static_2   nginx -g daemon off;             Exit 128                               
train_web2_1     /bin/sh -c java -jar jetty ...   Up         0.0.0.0:32779->8080/tcp     
````

#### no static assets
>$ ./twip.sh train scale static=0

````bash
     Name                   Command                State              Ports          
------------------------------------------------------------------------------------
train_static_2   nginx -g daemon off;             Exit 128                           
train_web2_1     /bin/sh -c java -jar jetty ...   Up         0.0.0.0:32779->8080/tcp 

$ wget localhost > /dev/null
Connecting to localhost (localhost)|127.0.0.1|:80... failed: Connection refused.

$ wget localhost:32279 > /dev/null
````

#### Take it down
````bash
$ ./twip.sh train down
Stopping train_web2_1 ... done
Removing train_static_2 ... done
Removing train_web2_1 ... done
Removing network train_default
````
<hr/>
## Production 

In one of his latest works, Neil Ford says: "Architecture is abstract 
until operationalized. In other words, you can't really judge the long-term 
viability of any architecture until you've not only implemented it but also 
upgraded it. And perhaps even enabled it to withstand unusual occurrences."

The production architecture differs from the training architecture in 1 container.
For production we introduce HAProxy, a free, very fast, and reliable solution offering 
high availability, load balancing, and proxying for TCP and HTTP-based applications. 
Just like the overlap between nginx and jetty, there is overlap between HAProxy and NGINX.  

The particular version of HAProxy to be deployed is the dockercloud-haproxy 
container implementation. This image balances between linked containers 
and, if launched in Docker Cloud or using Docker Compose v2, it reconfigures 
itself when a linked cluster member redeploys, joins or leaves.

So based on the behaviour seen in the training implementation it must be better to 
seperate the the static assets and proxy services into seperate containers.

<img src='https://raw.githubusercontent.com/codemarc/twip/master/img/prod.png' width='400'/>

Certainly the above configuration is more flexible then the training version.
We can test out hypothsis by building and then testing our production configuration.


### Building the containers

> $ ./twip.sh prod build

````bash
$ ./twip.sh prod build
.
.
.
REPOSITORY            TAG                 IMAGE ID            CREATED             SIZE
prod_static           latest              cad42012384c        17 minutes ago      61.94 MB
prod_web              latest              51442e3e846f        17 minutes ago      182.7 MB
nginx                 1.9.15-alpine       3839248a6963        31 hours ago        60.63 MB
alpine                3.3                 13e1761bf172        31 hours ago        4.797 MB
dockercloud/haproxy   1.2.1               3a6fb5b250d5        7 weeks ago         234.3 MB
````

* HAProxy publishes stats that can be accessed at [http://&lt;host-ip&gt;:1936](https://github.com/codemarc/twip)
 

### Test production
To spin up the production environment you can run `./twip.sh` as follows:  

````bash
$ ./twip.sh prod up
Creating network "prod_default" with the default driver
Creating prod_web_1
Creating prod_static_1
Creating prod_proxy_1

    Name                   Command               State                    Ports                   
-------------------------------------------------------------------------------------------------
prod_proxy_1    dockercloud-haproxy              Up      1936/tcp, 443/tcp, 0.0.0.0:32770->80/tcp 
prod_static_1   nginx -g daemon off;             Up      443/tcp, 0.0.0.0:32769->80/tcp           
prod_web_1      /bin/sh -c java -jar jetty ...   Up      0.0.0.0:32768->8080/tcp                  
````
> $ ./twip.sh bench

```
$ ./twip.sh bench
Server Software:        Jetty(7.x.y-SNAPSHOT)
Server Hostname:        localhost
Server Port:            80

Document Path:          /
Document Length:        331 bytes

Concurrency Level:      10
Time taken for tests:   0.843 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      561940 bytes
HTML transferred:       331000 bytes
Requests per second:    1186.62 [#/sec] (mean)
Time per request:       8.427 [ms] (mean)
Time per request:       0.843 [ms] (mean, across all concurrent requests)
Transfer rate:          651.18 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.4      0       5
Processing:     0    8   9.3      6     108
Waiting:        0    8   9.3      6     108
Total:          0    8   9.3      6     108

Percentage of the requests served within a certain time (ms)
  50%      6
  66%      9
  75%     11
  80%     13
  90%     17
  95%     24
  98%     35
  99%     51
 100%    108 (longest request)

```

At this point I would normally run a battery of tests to calculate metrics
and tune configuration. an once complete 

<hr/>
### Concerns addressed

##### Prevayler
By analyzing the logs produced by jetty I was able to determine that 
[prevayler](http://prevayler.org), persist data in the file system at
`/Users/dcameron/persistence`. By creating a docker volume to be shared
across all where prevayler is used and mapping this volume to a location
on the host file system we can effectivly persist data across the jetty
instances.

### Concerns to be addressed
* [ELK Stack](https://www.elastic.co/products) -
If I were going to completly tool out this environment, I would add an additional 
[ELK Stack](https://www.elastic.co/products) containers. The elk stack add  Elasticsearch, 
Logstash, Kibana, open source tool use for log based analytics.
 

<hr/>
### Reference Links
* https://github.com/codemarc/twip
* https://github.com/docker/dockercloud-haproxy
* https://docs.docker.com/compose/compose-file/
* https://www.thoughtworks.com/insights/blog/microservices-evolutionary-architecture
