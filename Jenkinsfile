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
        stage('Test'){
            when { anyOf { branch 'develop';  branch 'stage'; branch 'master' } }
            agent {
                label 'docker'
            } 
            steps {
                sh 'docker run --rm -v /root/.m2:/root/.m2 -v $PWD/Back:/app -w /app maven:3-alpine mvn test'
                stash includes: 'Back/target/', name: 'mysrc'
            }
        }
        stage("Sonar") {
            when { anyOf { branch 'develop'; branch 'stage'; branch 'master' } }
            agent {
                label 'master'
            }
            steps {
                script{
                    def changedFiles = sh(script: " git diff --name-only HEAD~1 HEAD | awk -F/ '{print \$1}' | uniq", returnStdout: true).trim()
                    def changedFilesList = changedFiles.replaceAll('\n', ',')
                    sh "find Back/ -name sonar-project.properties"
                    sonarProjectKey= sh( returnStdout: true, script:'cat sonar-project.properties | grep sonar.projectKey=').split('=')[1].trim()
                    sonarProjectName= sh(returnStdout: true, script:"cat sonar-project.properties | awk -F '=' '/^sonar/{print \$2}' | sed -n 2p").trim()
                    def SCANNERHOME = tool name: 'SonarQube', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
                    unstash 'mysrc'
                    echo "${changedFilesList}"
                    // withSonarQubeEnv('SonarQube') {
                    //      sh """
                    //              ${SCANNERHOME}/bin/sonar-scanner \
                    //                -Dsonar.projectKey=${sonarProjectKey} \
                    //                -Dsonar.projectName=${sonarProjectName} \
                    //                -Dsonar.inclusions=${changedFilesList} \
                    //         """
                    // }
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
