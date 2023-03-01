
def remote = [:]
pipeline {
    agent any
    options {
        buildDiscarder logRotator(
                    daysToKeepStr: '16',
                    numToKeepStr: '10'
            )
    }
    stages {
        stage("Sonar") {
            when { anyOf { branch 'develop'; branch 'stage'; branch 'master' } }
            agent {
                label 'master'
            }
            steps {
                sh '''
                    cd Back
                    mvn clean install
                    ls -la target
                '''
                stash includes: 'Back/target/TrainingSite-1.0-SNAPSHOT.war', name: 'artefact'
            }
        }
      }
    }   
    post {
        always{
            echo "Enviar logs...";
        }
        //Manejo de las execepciones con envio de notificacion por medio de slack  segun del status que coresponda.
        success{
            script{
                if( "${BRANCH_NAME}" == "devops" || "${BRANCH_NAME}" == "stage" || "${BRANCH_NAME}" == "master" ){
                    // slackSend color: '#90FF33', message: "El despliegue en ${BRANCH_NAME} \n finalizo con estado: success  \n Puedes ver los logs en: ${env.BUILD_URL}console \n app: http://${remote.host}:7001/FACTURAELECTRONICA/";

                }
            }
        }
        unstable {
            script{
                if( "${BRANCH_NAME}" == "develop" || "${BRANCH_NAME}" == "stage" || "${BRANCH_NAME}" == "master" ){
                    // slackSend color: '#FFA500', message: "El despliegue en ${BRANCH_NAME} \n finalizo con estado: unstable \n Puedes ver los logs en: ${env.BUILD_URL}console \n app: http://${remote.host}:7001/FACTURAELECTRONICA/";
                }
            }
        }
        failure{
            script{
                if( "${BRANCH_NAME}" == "develop" || "${BRANCH_NAME}" == "stage" || "${BRANCH_NAME}" == "master" ){
                    // slackSend color: '#FF4233', message: "El despliegue en ${BRANCH_NAME} \n finalizo con estado: failure  \n Puedes ver los logs en: ${env.BUILD_URL}console \n app: http://${remote.host}:7001/FACTURAELECTRONICA/";
                }
            }
        }
    }
}
