pipeline {
        environment {
          imagename = "shubhradeepghosh23/test-app"
          registryCredential = 'dockerhub-creds'
          dockerImage = ''
          CHECK_URL = "http://3.93.212.108/greeting"
          CMD = "curl --write-out %{http_code} --silent --output /dev/null ${CHECK_URL}"
    }
        agent any
        tools {
            jdk 'jdk11'
            maven 'maven3'
    }
        stages {
          stage ('Initialize') {
            steps {
                sh '''
                    echo "PATH = ${PATH}"
                    echo "M2_HOME = ${M2_HOME}"
                '''
            }
        }

          stage ('Build') {
            steps {
                sh 'mvn clean -Dmaven.test.failure.ignore=true install' 
            }
            post {
                success {
                    junit 'target/surefire-reports/**/*.xml' 
                }
            }
        }

          stage("SonarQube analysis") {
            agent any
            steps {
              withSonarQubeEnv('sonar') {
                sh 'mvn clean package sonar:sonar'
              }
            }
          }
          stage("Quality Gate") {
            steps {
              timeout(time: 1, unit: 'HOURS') {
                waitForQualityGate abortPipeline: true
              }
            }
          }
          stage('Building Docker Image') {
            steps{
              script {
                dockerImage = docker.build imagename
              }
            }
          }
          stage('Push Image to Docker Registry') {
            steps{
              script {
                docker.withRegistry( 'https://registry.hub.docker.com', registryCredential ) {
                dockerImage.push("$BUILD_NUMBER")
                dockerImage.push('latest')

              }
            }
          }
        }
           stage('Deploy to Docker Container') {
             steps{   
               script {
                   sh "docker run --privileged -p 8085:8085 ${imagename}"
         
       }
     }
   }
           stage('Health Check Stage-One') {
             steps {
               script{
                 sh "${CMD} > commandResult"
                 env.status = readFile('commandResult').trim()
                }
            }
        }
           stage('Health Check Stage-Two') {
             steps {
               script {
                 sh "echo ${env.status}"
                   if (env.status == '200') {
                     currentBuild.result = "SUCCESS"
                  }
                   else {
                     currentBuild.result = "FAILURE"
                  }
              }
          }
      }
}
      post {
        always {
          emailext body: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS! \n Check console output at $BUILD_URL to view the results.', recipientProviders: [[$class: 'DevelopersRecipientProvider'], [$class: 'RequesterRecipientProvider']], subject: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!!'
          cleanWs()
        }
      }
    }

      