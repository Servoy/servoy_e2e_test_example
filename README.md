## End to end testing of Servoy solutions example running on Sauce Labs.

### Prerequisites

1. Install JDK 1.8.x. http://www.oracle.com/technetwork/java/javase/downloads/index.html

2. 'Jenkins' https://jenkins-ci.org/; please install it to a dir that has no spaces in it's full path.
  - git plugin (probably already installed by default) https://wiki.jenkins-ci.org/display/JENKINS/Git+Plugin
  - ant plugin (probably already installed by default) https://wiki.jenkins-ci.org/display/JENKINS/Ant+Plugin
  - Sauce OnDemand plugin https://wiki.jenkins-ci.org/display/JENKINS/Sauce+OnDemand+Plugin (you also need a sauce account https://saucelabs.com/ & a generated access key/token for that account)

3. 'npm' command available in path - a nodejs install https://nodejs.org/ will bring npm with it
4. 'ant' plugin has to have an ant install configured (in Manage Jenkins - System Configuration - Ant section you can for example 'add' and check 'auto install')
5. 'Servoy 8' full install, will be used to export solutions to war files

### Description

The entry point is e2e_test_runner.xml. It takes a servoy solution project (the 'hello' folder), exports it as a war file ('e2e/war_export/hello.war'), starts a tomcat server instance (the 'apache-tomcat-\*' folder from inside the Git repository (it is altered to use port 8083 (server.xml) to avoid conflicts and has a user configured (tomcat-users.xml) that can deploy/undeploy via the manager page (that is used by ant script deploy/undeploy)), using the JDK/JRE from point 1 above), deploys the war, runs the protractor test scripts e2e/spec/hello/\*_spec.js, and the selenium test scripts e2e/selenium/hello/\*_test, undeploys the war file and shuts down tomcat.

The test script supports testing multiple solutions sequentially.

For each tested solution (in this example there is only one) the folders 'e2e/spec' and/or 'e2e/selenim' should contain a folder with the same name as the tested solution. So for each tested solution, the ant script looks in 'e2e/spec/[solutionName]' and 'e2e/selenium/[solutionName]' folder and runs all the files ending in '_spec.js' (protractor tests in 'e2e/spec') or '_test' (selenese tests in 'e2e/selenium').

To add another solution, check out the project (and it's resources project) in the jenkins workspace near the 'hello' project and add its name in test_runner.properties in the variable 'solutions_to_export_as_war_tests'. Eg:

```
solutions_to_export_as_war_tests			= hello,\
mySolution
```

Tests should then be added in the folder e2e/spec/mySolution/ and e2e/selenium/mySolution/ and should end with '_spec.js' (in 'e2e/spec') or '_test' (in 'e2e/selenium'). The second solution will be deployed and tested after the first solution has been undeployed.



### Setup

1. In "Manage Jenkins -> Configure" add a JDK and point it to the one you just installed (uncheck 'install automatically').

2. Create a Freestyle jenkins job.

3. Add this git repository URL: https://github.com/Servoy/servoy_e2e_test_example.git
Branch Specifier:\*/master
You can configure either polling on the job or you can use git server triggers (for github there is a plugin that helps) to auto-trigger the job on repo changes. Otherwise the job will have to be started manually when you want it to run.

4. Enable Sauce labs support and Sauce Connect. Override default authentication; enter your Sauce labs account credentials (see prerequisites 2). Under 'Sauce Connect Advanced Options' click the 'Advanced' button and fill in
```
Sauce Connect Options: --vm-version dev-varnish
```

5. Add an 'Invoke Ant' build step. And fill in as follows (replace the values as needed for 'java_home_tomcat' - see prerequisites 1, 'servoy_install' - see prerequisites 5, 'sauceUserPlaceholder' and 'sauceKeyPlaceholder' - see prerequisites 2):
```
  - Targets: 	run_war_solution_tests
  - Build File: e2e_test_runner.xml
  - Properties: java_home_tomcat=/usr/lib/jvm/java-8-oracle
				servoy_install=/usr/local/servoy
				sauceUserPlaceholder=sauceLabsUserName
				sauceKeyPlaceholder=sauceLabsAceessKey
```
Note: The values for the ant properties are provided as an example, they should be customised to match your instalation and Sauce Labs account. You should use slash instead of backslash even when running on windows.

6. Add a 'Publish JUnit test result report' post build action and fill in 'Test report XMLs' with e2e/testResults/\*.xml

7. Add an 'Archive the artifacts' post build action. Fill in 'Files to archive' with logs/\*.txt. That will make Jenkins remember for each build the exporter log files as well as the actual war app. server log file. These files can be seen on the "Status" page of the job execution.

8. Optionally add a 'Run Sauce Labs Test Publisher' post build action.

*This configuration can be changed in e2e/servoyConfigurator.js. To change other protractor (http://www.protractortest.org/#/) settings see file e2e/protractor.config.js.template. It is currently a template because before each run the ant script injects the sauce labs credentials specified as ant properties. To change selenese-runner settings (https://github.com/vmi/selenese-runner-java), that are used for running selenim test, see files e2e/selenese.config.json and e2e/selenese.properties.template.*

### Running the e2e tests locally

Here is how you can run the tests locally using Chrome installed on Windows (you can do it in a similar way for other OSes/browsers by tweaking the protractor/selenese-runner settings accordingly).

1. Clone the git repository locally.
2. Create a copy of the file "local_test_runner.properties.template" named "local_test_runner.properties". In it set all the properties that the ant build needs as defined in Jenkins Setup step 5 above.
3. In package.json add the following two dependencies (below protractor and jasmine-reporters; you should be able to use the latest available versions instead of he two above):
```
	"selenium-server": "2.52.0",
	"chromedriver": "2.21.2"
```
4. In protractor.config.js.template
	- comment out lines with "sauceUser" and "sauceKey".
	- change the following lines to this (adjust the version number of seleniumServerJar if needed to match the one you set in step 3):
```
			chromeDriver: './node_modules/chromedriver/lib/chromedriver/chromedriver.exe',
			seleniumServerJar: './node_modules/selenium-server/lib/runner/selenium-server-standalone-2.52.0.jar',
			multiCapabilities: [{ browserName: 'chrome' }],
```
5. In selenese.properties.template
	- remove the "remote-..." lines (2 of them)
	- change the following line to this:
```
			driver: chrome
```
	- add one line:
```
			chromedriver: node_modules/chromedriver/lib/chromedriver/chromedriver.exe 
```
6. Run the ant script (target 'run_war_solution_tests' or, if you didn't change the solutions, just the test scripts 'run_e2e_tests').
Assuming ant is installed and available in path run 'ant -f e2e_test_runner.xml' or 'ant -f e2e_test_runner.xml run_e2e_tests'

