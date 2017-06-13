# dbc-j2ee-template
lightweight templates for Deployment of app stack requires Oracle Java 8+ and Tomcat 8.5+ Servlet, works with any OCP, Docker platform.

`APPBIN` Required Envirionment Variable for `docker build` or `oc new-app`

# Why 
regular oracle java + jboss + centos/rhel image size usually over 500Mb, this basic image size is around 100Mb.

# How to use
1. fork this repo and add required custom configurations like `app.properties` files

2. set `APPBIN` to any war file repository URL that you need to deploy, e.g 
 ```docker build --build-args "APPBIN=https://developer.gov.bc.ca/artifactory/libs-release-local/ca/bc/gov/${appname}/${version}/${appname}-{version}.war" .```
 or
 ```oc new-app $YourRepoUrlWithThisDockerfile -e APPBIN=https://developer.gov.bc.ca/artifactory/libs-release-local/ca/bc/gov/${appname}/${version}/${appname}-{version}.war --strategy=docker```
 
# Notes:
 default deployment context path would be `/`, if you need to change to different context path, ensure you have proper `context.xml` in your war file.

# FAQ
## where is J2EE? Tomcat is not full J2EE servlet. 

### short anwser: 
use Dockerfile_j2ee file which include TomEE, here is the [comparison for Tomcat vs TomEE](http://tomee.apache.org/comparison.html) 
### long anwser:
lots of j2ee functions can be achieved in OCP or Kubernetes, you should use OCP or Kubernetes to address those common functions first, and the rest can be easily done via Tomcat.
