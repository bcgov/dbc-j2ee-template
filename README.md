# dbc-j2ee-template
lightweight templates for Deployment of Oracle Java 8+ and Tomcat 8.5+ in container, works with any OCP, Docker platform
`APPBIN` Required Envirionment Variable for `docker build` or `oc new-app`

# How to use
1. fork this repo and add required custom configurations like `app.properties` files

2. set `APPBIN` to any war file repository URL that you need to deploy, e.g 
 ```docker build --build-args "APPBIN=https://developer.gov.bc.ca/artifactory/libs-release-local/ca/bc/gov/${appname}/${version}/${appname}-{version}.war" .```
 or
 ```oc new-app $YourRepoUrlWithThisDockerfile -e APPBIN=https://developer.gov.bc.ca/artifactory/libs-release-local/ca/bc/gov/${appname}/${version}/${appname}-{version}.war --strategy=docker```
 
# Notes:
 default deployment context path would be `/`, if you need to change to different context path, ensure you have proper `context.xml` in your war file.
