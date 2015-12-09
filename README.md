## End to end testing of Servoy solutions example running on Sauce Labs.

### Prerequisites

1 'Jenkins' https://jenkins-ci.org/
  - git plugin https://wiki.jenkins-ci.org/display/JENKINS/Git+Plugin
  - ant plugin https://wiki.jenkins-ci.org/display/JENKINS/Ant+Plugin
  - Sauce OnDemand plugin https://wiki.jenkins-ci.org/display/JENKINS/Sauce+OnDemand+Plugin

2 'npm' command available in path - a nodejs install https://nodejs.org/ will bring npm with it

3 'ant' command available in path

4 'ant-contrib' simply copy ant-contrib*.jar to the $ANT_HOME/lib/ folder - http://ant-contrib.sourceforge.net/#install

5 'Servoy 8' full install, will be used to export solutions to war files

### Description

The entry point is e2e_test_runner.xml. It takes a servoy solution project (the 'hello' folder), exports it as a war file ('e2e/war_export/hello.war'), starts a tomcat server instance (the 'apache-tomcat-8.0.24' folder),  deploys the war, runs the protractor test scripts e2e/spec/hello/*_spec.js, and the selenium test scripts e2e/selenium/hello/*_test, undeploys the war file and shuts down tomcat.

The test script supports testing multiple solutions sequentially.

For each tested solution (in this example there is only one) the folder e2e/spec/ and e2e/selenim has to contain a folder with the same name as the tested solution. So for each tested solution, the script looks in e2e/spec and e2e/selenium for a folder with the exact name as the solution and runs all the files ending in '_spec.js' and '_test' for selenium

To add another solution, check out the project (and it's resources project) in the jenkins workspace near the 'hello' project and add its name in test_runner.properties in the variable 'solutions_to_export_as_war_tests'. Eg:

```
solutions_to_export_as_war_tests			= hello,\
mySolution
```

Tests should then be added in the folder e2e/spec/mySolution/ and e2e/selenium/mySolution/ and should end with '_spec.js'.* and '_test' for selenium. The second solution will be deployed and tested after the first solution has been undeployed.



### Setup

1 Create a Freestyle jenkins job.

2 Add this git repository URL:https://github.com/Servoy/servoy_e2e_test_example.git Branch Specifier:*/master

3 Enable Sauce labs support and Sauce Connect. Override default authentication with your Sauce labs account credentials. Under 'Sauce Connect Advanced Options' click the 'Advanced' button and fill in
```
Sauce Connect Options: --vm-version dev-varnish
```

4 Add an 'Invoke Ant' build step. And fill in as follows
```
  - Targets: 	run_war_solution_tests
  - Build File: e2e_test_runner.xml
  - Properties: jdk1.8_home = /usr/lib/jvm/java-8-oracle
				servoy_install = /usr/local/servoy
				sauceUserPlaceholder=sauceLabsUserName
				sauceKeyPlaceholder=sauceLabsAceessKey
```
Note: The values for the ant properties are provided as an example, they should be customised to match your instalation and Sauce Labs account.

5 Add a 'Publish JUnit test result report' post build action and fill in 'Test report XMLs' with
e2e/testResults/*.xml

6 Optionally add a 'Run Sauce Labs Test Publisher' post build action.

*This configuration can be changed in e2e/servoyConfigurator.js. To changed other protractor (http://www.protractortest.org/#/) settings see file e2e/protractor.config.js.template. It is currently a template because before each run the ant script injects the sauce labs credentials specified as ant properties. To change selenese-runner settings, that are used for running selenim test, see files e2e/selenese.config.json and e2e/selenese.properties
