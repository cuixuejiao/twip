# The Infrastructure Problem (TWIP)
[*Marc J. Greenberg*](mailto:codemarc@gmail.com)

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

> You have free rein to incorporate any software tools and hardware you need to 
streamline application deployment and infrastructure provisioning & configuration 
as long as they are Free/Libre/Open Source software (FLOSS). We request that 
you use Linux.

### Assumptions
* The development team has a continuous integration build that produces two artifacts:
  * a .zip file https://s3.amazonaws.com/infra-assessment/static.zip with the image and 
  stylesheet used for the application
  * a .war file https://s3.amazonaws.com/infra-assessment/companyNews.war with the dynamic parts of the application
  
* You should deploy the static assets to a web server and the .war file to a separate application server. Any compatible servers are acceptable.

* The app (companyNews) uses Prevayler for persistence. Prevayler essentially persists data to a file. The dev team chose this to simplify the development effort, rather than having to deal with an RDBMS.

### Solution Strategy

There is a set of principles about to follow when a working on problem set like this. 
Create infrastructure that is flexible, automatic, consistent, reproducible,
and disposable. The problem feels like it was custom made for a **container** solution.
And today that means **Docker**.  

The full set of the technologies selected for this project are broken down as follows

#### Tools Environment
These tools are used to host, build, test and run the infrastructure components
- [Ubuntu Linux](http://www.ubuntu.com/)
  - Training [VMware Fusion](https://www.vmware.com/),[Oracle VirtualBox](https://www.virtualbox.org/)
  - Production Amazon Web Services [EC2](https://aws.amazon.com/ec2/), [EC2 Container Service](https://aws.amazon.com/ecs/)
- [Docker Hub](https://hub.docker.com/) and [Docker Toolbox](https://www.docker.com/products/docker-toolbox) including 
  - [docker engine](https://www.docker.com) 
  - [docker-compose](https://www.docker.com/products/docker-compose) 
  - [docker-machine](https://www.docker.com/products/docker-machine)
  - [docker-swarm](http://www.docker.com/products/docker-swarm)
  
- [Git 1.9.1](https://git-scm.com/) And [GitHub](https://github.com/)

- [Apache Bench](http://httpd.apache.org/docs/2.2/en/programs/ab.html)  

#### Application Environment
These software components are used to logically run the application 

- [Alpine Linux 3.3](https://www.alpinelinux.org/)
- [NGINX 1.9.15](https://www.nginx.com/)
- [Oracle Jdk 8.77.03](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
- [HAProxy](http://www.haproxy.org/)
- [Apache Jetty](http://www.eclipse.org/jetty/)

### Project Roadmap
1. Setup a working environment with the selected tooling.
- Define/Build containers with the appropriate artifacts and configuration.
- Test process using the phoenix server pattern (clean environment) to running solution.
- Run *at scale* experiments following the [evolutionary architecture](https://www.thoughtworks.com/insights/blog/microservices-evolutionary-architecture) ideation. 
   

<br/><hr/>
## Platform

### Virtual Machine
We all know the easiest way to get started is to spinup a new vm either using 
VMWare Fusion or Virtual Box. Our elemental starting point is *Ubuntu 14.04.3 LTS*.
Since out work revolves around docker the first hurdle is to setup the raw environment
with the docker tool chain. 

### AWS EC2  

I like using public cloud resources (My personal favorite is Digital Ocean as 
i find droplets are easy to deal with). Since *AWS* is one of the choices, I 
start by spinning up a brand spanking new EC2 t2.micro instance, running 
*Ubuntu 14.04.3 LTS*. Please remember to open port *80* for HTTP traffic and
a port *1936* for monitoring (will be discussed later) in the 
security group associated with your instance. 

### Docker Machine

One of the more interesting components of the docker toolset is the docker machine
as it provides the ability to provision and manager virtual machines with an installed
and running docker engine. I have used  docker machine with Oracle VirtualBox, 
VMware Fusion, VMware vSphere, Amazon Web Services, Digital Ocean and even my old 
dell laptop as bare metal running ubuntu 14.04 after I install docker.

Since it is outside the scope of this assignment I will avoid the provisioning
functionality till a discussion of high availability and clustering.

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
* history - with comments and context
* transparency/visibility - a means to to share and correlate among multiple 
contributors
* actionability - the ability to automate the execution of an action based 
on a change.

The source for this project is currently stored on GitHub. In order to easily and more importantly 
get the source you need a git client installed on your virtual machine. 

#### Getting the source
1. ssh to your host
1. install git
1. clone my ***twip*** repository

```bash 
Welcome to Ubuntu 14.04.3 LTS (GNU/Linux 3.13.0-74-generic x86_64)

$ sudo apt-get update && sudo apt-get -y install git

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

### Installing preqs 

The main script for my solution is a bash script aptly named *twip.sh*.
It is located in the twip directory that you just cloned. While there are many 
other scripting approaches that could be used here, good old bash is still 
useful to get stuff done quickly right out of the box.

The first time you run *twips.sh* on a fresh clean ubuntu 14.04 machine it
checks for and installs 
[docker](https://www.docker.com), 
[docker-compose](https://www.docker.com/products/docker-compose), 
[docker-machine](https://www.docker.com/products/docker-machine), and 
[apache bench](http://httpd.apache.org/docs/2.2/en/programs/ab.html).  
 
Additionally setup adds the default ubuntu user to the docker group. All you need to do is to **logout** and then **relogin** so that the group modification can take effect.

```bash
$ cd twip && ./twip.sh
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

After you log back in and cd twip and run *twip.sh*
```bash
$ cd twip && ./twip.sh

twip usage: command [arg...]

Commands:

train      Creates the training environment
prod       Creates the production environment
pack       Tag and push production images
status     Display the status of the environment
bench      Run Benchmarking Tests
clean      Removes dangling images and exited containers
images     List images
```

<br/><hr/>
## Training 
Package the static assets into a container running [NGINX](https://www.nginx.com/) and package the app 
on into a container running [jetty](http://www.eclipse.org/jetty/).

<div style="text-align:center;margin:3em;">
<img src='https://raw.githubusercontent.com/codemarc/twip/master/img/train.png' width='80%'/>  
</div>


##### NGINX for proxy and hosting static assets
[NGINX](https://www.nginx.com/) is a web server, a load balancer, 
a content cache and more. I am by no means an NGINX expert but I have 
been using it more and more lately and I find it to be a very effective 
tool in the container world. It is modular in nature and is a little 
easier configure to understand then Apache, and if configured appropriately
is blazingly fast.  


##### Jetty as a Java servlet container
[Jetty](http://www.eclipse.org/jetty/) is another web server that is 
able to serve static and/or dynamic content either from a standalone or embedded 
instantiations. While there is some overlap in between of capabilities of 
nginx and jetty, in this project jetty is used strictly as a servlet container for
the dynamic part of the application.

So why choose Jetty? While there are several other open source servlet containers 
available (Apache Tomcat, Glassfish, Resin, ...) Jetty is known for the following
attributes: performance, throughput, small memory footprint and page load time.
These characteristics fall in line with our requirements as well as our chosen 
implementation infrastructure.

### docker-compose.yml

The *twip.sh* shell script is yet another wrapper for yet another markup language.
In this case docker-compose. The script below is used to describe the training environment
in terms of docker-compose.

```
version: '2'
services:
  static:
    hostname: static
    build:
      context: .
      dockerfile: Dockerfile-static
    environment:
      - VIRTUAL_HOST=*/styles/*.*,*/images/*.*
      - VIRTUAL_HOST_WEIGHT=0
    ports:
      - 80
  web:
    hostname: web
    build:
      context: .
      dockerfile: Dockerfile-web
    ports:
      - 8080
    environment:
      - VIRTUAL_HOST=*/*.action,*/
      - VIRTUAL_HOST_WEIGHT=1
    volumes:
      - ../data:/Users/dcameron/persistence
  proxy:
    image: dockercloud/haproxy:1.2.1
    container_name: proxy
    links:
      - static
      - web
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    ports:
      - 80:80
      - 1936:1936
```


<br/><br/>

### Build the training containers

The included script *./twip.sh* simplifies the process of building and running
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

 
### Run training
To spin up the training environment you can run *twip.sh* as follows:  

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
````

And run a few quick test
````bash
$ ./twip.sh test
curl -I -X GET http://localhost/
HTTP/1.1 200 OK
Server: nginx/1.9.15
Date: Tue, 10 May 2016 21:16:50 GMT
Content-Type: text/html;charset=ISO-8859-1
Content-Length: 331
Connection: keep-alive
Set-Cookie: JSESSIONID=1uymgnsr4edtx1ue20vl1n4p7w;Path=/
Expires: Thu, 01 Jan 1970 00:00:00 GMT
Request-Time: 0.002
Upstream-Address: 172.18.0.2:8080
Upstream-Response-Time: 1462915010.123

$ ./twip.sh test Read.action
curl -I -X GET http://localhost/Read.action
HTTP/1.1 200 OK
Server: nginx/1.9.15
Date: Tue, 10 May 2016 21:20:30 GMT
Content-Type: text/html;charset=ISO-8859-1
Content-Length: 799
Connection: keep-alive
Set-Cookie: JSESSIONID=10ekx3h62qoi5c5n1hqf87448;Path=/
Expires: Thu, 01 Jan 1970 00:00:00 GMT
Request-Time: 0.026
Upstream-Address: 172.18.0.2:8080
Upstream-Response-Time: 1462915230.715

$ ./twip.sh train down
Stopping train_static_1 ... done
Stopping train_web1_1 ... done
Stopping train_web2_1 ... done
Removing train_static_1 ... done
Removing train_web1_1 ... done
Removing train_web2_1 ... done
Removing network train_default

Name   Command   State   Ports 
------------------------------

$ ./twip.sh test
curl -I -X GET http://localhost/
curl: (7) Failed to connect to localhost port 80: Connection refused

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
The following tests illustrate behaviors of the training environment
Starting with the state:
````bash
     Name                   Command               State              Ports            
-------------------------------------------------------------------------------------
train_static_1   nginx -g daemon off;             Up      443/tcp, 0.0.0.0:80->80/tcp 
train_web1_1     /bin/sh -c java -jar jetty ...   Up      0.0.0.0:32784->8080/tcp     
train_web2_1     /bin/sh -c java -jar jetty ...   Up      0.0.0.0:32783->8080/tcp     
````

>#### no webapps

````bash
$ ./twip.sh train scale web2=0
Stopping and removing train_web2_1 ... done

     Name                   Command               State              Ports            
-------------------------------------------------------------------------------------
 train_static_1   nginx -g daemon off;             Up      443/tcp, 0.0.0.0:80->80/tcp 
 train_web1_1     /bin/sh -c java -jar jetty ...   Up      0.0.0.0:32784->8080/tcp
 
 $ ./twip.sh train scale web1=0
 stopping and removing train_web1_1 ... done

     Name              Command          State              Ports            
---------------------------------------------------------------------------
train_static_1   nginx -g daemon off;   Up      443/tcp, 0.0.0.0:80->80/tcp 

$ ./twip.sh test
curl -I -X GET http://localhost/
HTTP/1.1 502 Bad Gateway
Server: nginx/1.9.15
Date: Tue, 10 May 2016 21:36:09 GMT
Content-Type: text/html
Content-Length: 537
Connection: keep-alive
ETag: "572cb9eb-219"     
````

>#### restore webapp

````bash
$ ./twip.sh train scale web1=1
Creating and starting train_web1_1 ... done

     Name                   Command               State              Ports            
-------------------------------------------------------------------------------------
train_static_1   nginx -g daemon off;             Up      443/tcp, 0.0.0.0:80->80/tcp 
train_web1_1     /bin/sh -c java -jar jetty ...   Up      0.0.0.0:32785->8080/tcp     

$ ./twip.sh test
curl -I -X GET http://localhost/
HTTP/1.1 200 OK
Server: nginx/1.9.15
Date: Tue, 10 May 2016 21:40:38 GMT
Content-Type: text/html;charset=ISO-8859-1
Content-Length: 331
Connection: keep-alive
Set-Cookie: JSESSIONID=zgmv7qbjbghdzm0o5mapcgda;Path=/
Expires: Thu, 01 Jan 1970 00:00:00 GMT
Request-Time: 1.083
Upstream-Address: 172.18.0.2:8080
Upstream-Response-Time: 1462916436.949
````

> #### scale up static assets

````bash
$ ./twip.sh train scale static=2  
WARNING: The "static" service specifies a port on the host. If multiple containers for this service are created on a single host, the port will clash.
Creating and starting train_static_2 ... error

ERROR: for train_static_2  driver failed programming external connectivity on endpoint train_static_2 (c94a1180aa516d8f1f803c8145afc1719476b94c412c8ab77b29239d6fc3e736): Bind for 0.0.0.0:80 failed: port is already allocated

     Name                   Command                State                Ports            
----------------------------------------------------------------------------------------
train_static_1   nginx -g daemon off;             Up         443/tcp, 0.0.0.0:80->80/tcp 
train_static_2   nginx -g daemon off;             Exit 128                               
train_web2_1     /bin/sh -c java -jar jetty ...   Up         0.0.0.0:32779->8080/tcp     
````

>#### no static assets

````bash
$ ./twip.sh train scale static=0

     Name                   Command                State              Ports          
------------------------------------------------------------------------------------
train_static_2   nginx -g daemon off;             Exit 128                           
train_web2_1     /bin/sh -c java -jar jetty ...   Up         0.0.0.0:32779->8080/tcp

$ ./twip.sh test
curl -I -X GET http://localhost/
curl: (7) Failed to connect to localhost port 80: Connection refused 
````

### Take it down and clean it up

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

Based on the behavior seen in the training implementation it must be better to 
separate the the static assets and proxy services into separate containers.

<div style="text-align:center;margin:2em;">
<img src='https://raw.githubusercontent.com/codemarc/twip/master/img/prod.png' width='80%'/>
</div>

Certainly the above configuration is more flexible then the training version.
We can test out hypothesis by building and then testing our production configuration.

Additionally I am adding a Dynamic DNS service to work on this project. Dynamic DNS 
(DDNS or DynDNS) is a method of automatically updating a name 
server in the Domain Name System (DNS), often in real time, with the active 
DDNS configuration of its configured hostnames, addresses or other information. 
I am currently using the free version of the online service [no-ip](https://www.noip.com/remote-access).

<div style="text-align:center;margin:2em;">
<img src="https://raw.githubusercontent.com/codemarc/twip/master/img/runinprod.png" width='80%'/>
</div>

### docker-compose.yml

The script below is used to describe the production environment in terms of docker-compose.

```
version: '2'
services:
  static:
    hostname: static
    build:
      context: .
      dockerfile: Dockerfile-static
    environment:
      - VIRTUAL_HOST=*/styles/*.*,*/images/*.*
      - VIRTUAL_HOST_WEIGHT=0
    ports:
      - 80
  web:
    hostname: web
    build:
      context: .
      dockerfile: Dockerfile-web
    ports:
      - 8080
    environment:
      - VIRTUAL_HOST=*/*.action,*/
      - VIRTUAL_HOST_WEIGHT=1
    volumes:
      - ../data:/Users/dcameron/persistence
  proxy:
    image: dockercloud/haproxy:1.2.1
    container_name: proxy
    links:
      - static
      - web
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    ports:
      - 80:80
      - 1936:1936

```

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

* HAProxy publishes stats that can be accessed at `http://<host-ip>:1936`
 

### Test production
Spin up the production environment and then have a look at [twip.ddns.net:1936](http://stats:stats@twip.ddns.net:1936) as follows:  


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


$ ./twip.sh test
curl -I -X GET http://localhost/
HTTP/1.1 200 OK
Content-Type: text/html;charset=ISO-8859-1
Set-Cookie: JSESSIONID=19myfyth65zpj8y2q48h01fs0;Path=/
Expires: Thu, 01 Jan 1970 00:00:00 GMT
Content-Length: 331
Server: Jetty(7.x.y-SNAPSHOT)
                  
````

<img src="https://raw.githubusercontent.com/codemarc/twip/master/img/haproxy1.png"  width='98%'/>


> $ ./twip.sh bench

```bash
$ ./twip.sh bench
ab -n 1000 -c 10 http://localhost/

Server Software:        Jetty(7.x.y-SNAPSHOT)
Server Hostname:        localhost
Server Port:            80

Document Path:          /
Document Length:        331 bytes

Concurrency Level:      10
Time taken for tests:   1.539 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      561925 bytes
HTML transferred:       331000 bytes
Requests per second:    649.83 [#/sec] (mean)
Time per request:       15.389 [ms] (mean)
Time per request:       1.539 [ms] (mean, across all concurrent requests)
Transfer rate:          356.59 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.4      0       5
Processing:     1   15   7.4     14      83
Waiting:        0   15   7.4     14      83
Total:          1   15   7.4     14      83

Percentage of the requests served within a certain time (ms)
  50%     14
  66%     16
  75%     17
  80%     18
  90%     21
  95%     29
  98%     37
  99%     42
 100%     83 (longest request)
```

Now lets scale up and see what happens...

````bash
$ ./twip.sh prod scale static=2
$ ./twip.sh prod scale web=3
$ ab -n 1000 -c 10 http://localhost/
                                                                                 443/tcp,                 
Concurrency Level:      10
Time taken for tests:   3.921 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      561938 bytes
HTML transferred:       331000 bytes
Requests per second:    255.01 [#/sec] (mean)
Time per request:       39.214 [ms] (mean)
Time per request:       3.921 [ms] (mean, across all concurrent requests)
Transfer rate:          139.94 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.5      0       6
Processing:     1   39 221.2     11    2322
Waiting:        0   39 221.2     11    2322
Total:          1   39 221.5     11    2328

Percentage of the requests served within a certain time (ms)
  50%     11
  66%     18
  75%     23
  80%     27
  90%     41
  95%     58
  98%     84
  99%   2145
 100%   2328 (longest request)
  
````

<img src="https://raw.githubusercontent.com/codemarc/twip/master/img/haproxy2.png" width='98%'/> 

At this point I would normally run a battery of tests to calculate metrics
and tune configuration. an once complete 

<hr/>
###  Running at scale

Implementing a solution to run at scale raises some challenging issues. Simply using docker does 
not directly address all of them. There are both commercial and open source tools
available create and maintain a container based production environment at scale.

[Amazon EC2 Container Service (ECS)](https://console.aws.amazon.com/ecs/home?region=us-east-1#/getStarted)
is a highly scalable, fast, container management service that makes it easy to run, stop, 
and manage Docker containers on a cluster of Amazon EC2 instances. Amazon can get quite pricey if you do not
employ careful controls on resource usage. Everyone knows of a company that forgot to shutdown their instances
after a project completion and got hit with a whopper of a bill.


<div style="margin-top:3em;margin-bottom:5em;">
<div style="float:right;margin-top:-3em"> 
  <img src="https://raw.githubusercontent.com/codemarc/twip/master/img/machswarm.png"  width='400'/>
</div>
[Docker Toolbox](https://www.docker.com/products/overview#/docker_toolbox) as product components is an alternate choice  
can help build a natural implementation to achieve containers at scale by using a combination of 
`Docker Machine - Docker Swarm - Docker Compose - Docker Registru - Docker Engine`. Essentually 
you create a virtual data center and then add a third party containers/components to manage and 
monitor the environment. Many of these projects are listed in  the `Scheduler / Orchestration / Management / Monitoring` section of 
the [docker ecosystem mindmap](https://www.mindmeister.com/389671722/open-container-ecosystem-formerly-docker-ecosystem).
</div> 


### Docker Cloud
Building on the concepts of the toolbox, Docker recently released a platform that wraps up the all of this up
with a easy to use web user interface. [Docker Cloud](https://cloud.docker.com/dashboard/onboarding)
further simplifies the use of the docker toolchain by allowing users to manage, deploy and scale their 
applications in any environment. The tools provision engines installed software into nodes, creating 
dockerized node clusters. Native integration with the Hub to pull images, build, launch, monitor and scale 
are provided. 

Docker Cloud should be able to: 
* Provision Docker Installed Infrastructure
* Manage node clusters
* Pull images from Docker Hub
* Deploy containers across nodes
* Monitor and scale applications

This is the approach I will follow to attempt a scaled platform.

There is no such thing as free lunch, so before we get deeply committed to this path it is important 
to understand how much docker cloud costs to use. See [pricing](https://www.docker.com/pricing).

While it is possible to let docker hub automatically build my container images for now I will simply
reuse the tooling from the earlier project to package and push to docker hub. 

To push images to docker hub you need to login with userid and password. You can then run twip.sh do
the job.

> docker login && ./twip.sh pack

````bash
$ docker login
Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username: codemarc
Password: 
Login Succeeded

$ ./twip.sh pack
./twip.sh pack
The push refers to a repository [docker.io/codemarc/twipstatic]
6fc274307583: Layer already exists 
9c0ba3efbd8b: Layer already exists 
ad3431d16417: Layer already exists 
8f01a53880b9: Layer already exists 
latest: digest: sha256:d76d387438cc3826790d683a4fbe36b2db259cc8448e08a4897c2eea60c19baf size: 15895
The push refers to a repository [docker.io/codemarc/twipweb]
9808747e2b8c: Layer already exists 
f492599a1905: Layer already exists 
bf8a8f1658d5: Layer already exists 
8f01a53880b9: Layer already exists 
latest: digest: sha256:dd6a54928d1ec39171258845cc9958b4561255432f45f40ff3f6c47909fb66d5 size: 10265

````
### Enter the cloud

Log into the [Docker Cloud](https://cloud.docker.com/dashboard/onboarding) console and begin the onboarding
process.

1. Link to a hosted cloud service provider (I followed the AWS instructions)

- Created and deployed a Node (again based on an AWS micro image)
 
- Created the our application stack - At first I start to individually define each of the services all over
again. Reading the doc I realized I could easily transform my ***docker-compose.yml*** into an equivalent docker-cloud.yml.
One or two attempts and viola.

```
static:
  target_num_containers: 1
  hostname: static
  image: codemarc/twipstatic
  environment:
    - VIRTUAL_HOST=*/styles/*.*,*/images/*.*
    - VIRTUAL_HOST_WEIGHT=0
  ports:
    - "80"
web:
  target_num_containers: 1
  hostname: web
  image: codemarc/twipweb
  ports:
    - "8080"
  environment:
    - VIRTUAL_HOST=*/*.action,*/
    - VIRTUAL_HOST_WEIGHT=1
  volumes:
    - /data:/Users/dcameron/persistence
proxy:
  image: dockercloud/haproxy:1.2.1
  links:
    - static
    - web
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
  ports:
    - "80:80"
    - "1936:1936"
````

> Hit the start start action and 

<div style="text-align:center;margin:2em;">
  <img src="https://raw.githubusercontent.com/codemarc/twip/master/img/dockercloud.png"/>
</div>
   
Two final things
> $ curl -I -X GET http://proxy-1.twip.5dcafcca.cont.dockerapp.io/
> $ ab -n 1000 -c 10 http://proxy-1.twip.5dcafcca.cont.dockerapp.io/

```bash
$ curl -I -X GET http://proxy-1.twip.5dcafcca.cont.dockerapp.io/
HTTP/1.1 200 OK
Content-Type: text/html;charset=ISO-8859-1
Set-Cookie: JSESSIONID=f050ewb341sm6nqiod7qtmve;Path=/
Expires: Thu, 01 Jan 1970 00:00:00 GMT
Content-Length: 331
Server: Jetty(7.x.y-SNAPSHOT)

$ ab -n 1000 -c 10 http://proxy-1.twip.5dcafcca.cont.dockerapp.io/
Server Software:        Jetty(7.x.y-SNAPSHOT)
Server Hostname:        proxy-1.twip.5dcafcca.cont.dockerapp.io
Server Port:            80

Document Path:          /
Document Length:        331 bytes

Concurrency Level:      10
Time taken for tests:   56.217 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      561989 bytes
HTML transferred:       331000 bytes
Requests per second:    17.79 [#/sec] (mean)
Time per request:       562.173 [ms] (mean)
Time per request:       56.217 [ms] (mean, across all concurrent requests)
Transfer rate:          9.76 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:      197  290 305.0    203    3266
Processing:   187  258 234.7    196    2988
Waiting:      187  258 234.7    196    2988
Total:        387  548 387.7    400    3664

Percentage of the requests served within a certain time (ms)
  50%    400
  66%    405
  75%    411
  80%    420
  90%    900
  95%   1415
  98%   1904
  99%   2148
 100%   3664 (longest request)

````

At this point there is a while lot of new thing to understand and experiment including learning the command line api
(apparently there is a container to run it). Experimenting with adding a variety of nodes and checking the performance
(a review of the benchmark show something need tuning). Adding in additional tooling to calculate cpu, memory and io profiles 
and producing analytics to view and understand the environment. I could go on but for now its more then a few hours and I 
need to go and do some other work.

<hr/>
### Rip it down and clean it up

I have implemented two little extra features in ***twip.sh*** to help keep a clean environment.
You can use the ***clean up*** command to remove dangling containers that are sometimes
left over from bad builds as well as removing exited containers. Or you can use the ***clean all***
command to delete all containers in the active docker engine.
  
Oh Yeah I need to really tear down all of my nodes, images and cleanup for the next gig.

<hr/>
### Concerns addressed

##### Prevayler
By analyzing the logs produced by jetty I was able to determine that 
[prevayler](http://prevayler.org), persist data in the file system at 
*/Users/dcameron/persistence*. By creating a docker volume to be shared
across all where prevayler is used and mapping this volume to a location
on the host file system we can effectively persist data across the jetty
instances.

### Concerns to be addressed

* There are even more components of this project that could be automated by 
setting up a fully automated build pipleline. Driving CI/CD tooling on commits
and deployment on dockerhub builds. Using the command line interfaces for 
provisioning thru the [aws cli](https://aws.amazon.com/cli/) or docker machine.
 

* [ELK Stack](https://www.elastic.co/products) -
If I were going to completely tool out this environment, I would add an additional 
[ELK Stack](https://www.elastic.co/products) containers. The elk stack add  Elasticsearch, 
Logstash, Kibana, open source tool use for log based analytics.
 

<hr/>
### Reference Links
* https://github.com/codemarc/twip
* https://github.com/docker/dockercloud-haproxy
* https://docs.docker.com/compose/compose-file/

### Research Links
* https://www.thoughtworks.com/insights/blog/microservices-evolutionary-architecture
* https://www.mindmeister.com/389671722/open-container-ecosystem-formerly-docker-ecosystem
* http://www.nextplatform.com/2015/09/29/why-containers-at-scale-is-hard/
* https://github.com/google/cadvisor
