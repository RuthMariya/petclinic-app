pipeline {
	options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        skipDefaultCheckout()
        timeout(time: 1, unit: 'HOURS')
    }
    agent {
        label 'DockerIO-3'
    }
	
    environment {
        scannerHome = tool 'SonarQube'
        SONARQUBE_CREDENTIALS_ID = credentials('prod-sonar-pet')
        SONARQUBE_URL = 'https://gbssonar.edst.ibm.com/sonar'
        ARTIFACTORY_CREDENTIALS_ID = credentials('artifactory-token')
        ARTIFACTORY_USER = credentials('artifactory-id')
        ARTIFACTORY_URL = 'gbsartifactory.edst.ibm.com'
        ARTIFACTORY_REPO = 'internet-banking'
        GIT_CREDENTIALS_ID = 'petclinic'
        GIT_URL = 'https://gbsgit.edst.ibm.com/Admin-ProjLib/liberty-demo-pet-clinic/liberty-demo.git'
        OC_TOKEN = credentials('oc-login')
        OC_PROJECT = 'fundtransfer-demo'
        OC_URL = 'https://c115-e.us-south.containers.cloud.ibm.com:32198'
        M2_HOME='/opt/tools/apache-maven-3.9.0'
        JAVA_HOME='/opt/tools/jdk-17.0.5'
        SLACK_TOKEN = credentials('demo-pipeline')
    }
    stages {
	    stage('Workspacecleanup') {
            steps {
                cleanWs()
            }
		}
		
       stage('git checkout'){
			steps {
                git credentialsId: "${GIT_CREDENTIALS_ID}", url: "${GIT_URL}", branch: 'dev'
            }
        }
		stage('Build'){
		    steps {
                echo 'Building..'
	            sh '''
	                #env
    	            #export PATH=$GRADLE_HOME/bin:$PATH
    	            java -version
    	            export PATH=$JAVA_HOME/bin:$PATH
    	            export PATH=$M2_HOME/bin:$PATH
    	            
    	            java -version
                    #mvn clean install
                    mvn spring-javaformat:apply
                    mvn clean -X
                    mvn clean package -DskipTests
    	          
    	          '''
            }
           
		}

		stage('Unit/Integration Test'){
		    steps {
                echo 'Building..'
	            sh '''
	                
    	            #export PATH=$GRADLE_HOME/bin:$PATH
    	            export PATH=$JAVA_HOME/bin:$PATH
    	            export PATH=$M2_HOME/bin:$PATH
                    #mvn clean install
                    mvn spring-javaformat:apply
                    mvn test
                    mvn clean verify jacoco:report
                   
    	           '''
		    }
		     post {
                always {
      // Record JaCoCo coverage report
                  step([
                    $class: 'JacocoPublisher',
                    execPattern: 'target/jacoco.exec',
                    classPattern: 'target/classes',
                    sourcePattern: 'src/main/java',
                    ])
                }
            }
		}

        stage ('SonarQube Analysis'){
            steps {
                withSonarQubeEnv('GBSSONAR') {
                sh "${scannerHome}/bin/sonar-scanner "  +
                    "  -Dsonar.host.url=${SONARQUBE_URL} " +
                    "  -Dsonar.projectKey=Spring-Petclinic " +
                    "  -Dsonar.projectName=Spring-Petclinic " +
                    "  -Dsonar.projectVersion=${BUILD_NUMBER}" +
                    "  -Dsonar.sources=. " +
                    "  -Dsonar.java.binaries=.* " +
                    "  -Dsonar.verbose=true " +
                    "  -Dsonar.junit.reportsPath=target/surefire-reports" +
                    "  -Dsonar.surefire.reportsPath=target/surefire-reports" +
                    "  -Dsonar.jacoco.reportPath=target/jacoco.exec" +
                    "  -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml" +
                    "  -Dsonar.binaries=target/classes" +
                    "  -Dsonar.java.coveragePlugin=jacoco" +
                    "  -Dsonar.exclusions=**/**/dummy.xml "
                }
            }
        }
        
        
            stage('Docker Build') {
                steps {
                    sh '''
                        export PATH=$JAVA_HOME/bin:$PATH
                        cd ${WORKSPACE}
                        docker build -f Dockerfile -t ${ARTIFACTORY_URL}/${ARTIFACTORY_REPO}/pet-clinic:${BUILD_NUMBER} .
                    '''
                }
            }
           stage('Artifactory Image Push') {
                steps {
                    sh '''
                        sleep 10
                        docker login ${ARTIFACTORY_URL} -u ${ARTIFACTORY_USER} -p ${ARTIFACTORY_CREDENTIALS_ID}
                        echo "image push"
                        docker push ${ARTIFACTORY_URL}/${ARTIFACTORY_REPO}/pet-clinic:${BUILD_NUMBER}
                    '''
                    }
            }
            stage ('UCD deploy') {
                steps {
                    echo 'started deploying in UCD'
                    step([  $class: 'UCDeployPublisher',
                    siteName: 'IBM GBS UCD',
                    component: [
                    $class: 'com.urbancode.jenkins.plugins.ucdeploy.VersionHelper$VersionBlock',
                    componentName: 'petclinic',
                    delivery: [
                    $class: 'com.urbancode.jenkins.plugins.ucdeploy.DeliveryHelper$Push',
                    pushVersion: '${BUILD_NUMBER}',
                    baseDir: 'workspace/Liberty-Demo-Pipeline/liberty-demo-pipeline/pipeline',
                             ]
                              ],
                    deploy: [
                 $class: 'com.urbancode.jenkins.plugins.ucdeploy.DeployHelper$DeployBlock',
                 deployApp: 'petclinic-app',
                 deployEnv: 'DEV',
                 deployProc: 'deploy petclinic-app',
                 deployVersions: 'petclinic:${BUILD_NUMBER}',
                 deployOnlyChanged: false
                         ]
                          ])
                }
            }
			stage('Selenium-UAT test'){
		         steps {
                    echo 'Building..'
                   sh '''
                        
                        #export PATH=$GRADLE_HOME/bin:$PATH
                        export PATH=$JAVA_HOME/bin:$PATH
                        export PATH=$M2_HOME/bin:$PATH
                        #mvn clean install
                        mvn spring-javaformat:apply
                        mvn -Dtest=LibertyDemoSelenium test
                    '''
                }
		    }
	}

    post {
    always {
        junit(
            allowEmptyResults: true,
            skipMarkingBuildUnstable: true,
            testResults: 'target/surefire-reports/*.xml'
        )
    }
}

}
