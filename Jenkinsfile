@Library('weblogic') _
def remote = [:]
def commit = ''
def profile = ''
def buildWithTags = ''

// def notifications(String buildStatus = "Inicio La Ejecución Del Pipeline"){
//     def JENKINS_FILE = readJSON(text: readFile("./Jenkinsfile.json").trim());
//     def channelName = JENKINS_FILE['channelName']
//     buildWithTags = JENKINS_FILE['buildWithTags']
//     slackSend(channel:channelName, teamDomain: 'SegurosBolivar', tokenCredentialId: 'jenkins-slack-chanel', color: '#FFFF00', message: "${buildStatus}: `${env.JOB_NAME}` #${env.BUILD_NUMBER}: Entorno ${BRANCH_NAME}\n(<${env.BUILD_URL}|Open>)")
// }
node('master'){
    stage('Notification Incial'){
        checkout scm
        def JENKINS_FILE = readJSON(text: readFile("./Jenkinsfile.json").trim());
        def channelName = JENKINS_FILE['channelName']
        buildWithTags =  false
        slackSend(channel:channelName, teamDomain: 'SegurosBolivar', tokenCredentialId: 'jenkins-slack-chanel', color: '#FFFF00', message: ": `${env.JOB_NAME}` #${env.BUILD_NUMBER}: Entorno ${BRANCH_NAME}\n(<${env.BUILD_URL}|Open>)")
    }
}
pipeline {  
    agent any
    options {
        buildDiscarder logRotator(
                    daysToKeepStr: '16',
                    numToKeepStr: '10'
            )
        disableConcurrentBuilds()
    }
    stages {
        stage('SonarQube analysis') {
           when { anyOf { branch 'develop'; branch 'stage'; tag "v*-release"; tag "v*" } }
           agent {
                   label 'docker' 
           }      
           steps {
            //    notifications()
               echo "ANALISIS DE CODIGO"
               script {
                    branchEnv = BRANCH_NAME
                    if(BRANCH_NAME ==~ /^v\d*\.\d*\.\d*\.\d*-release$/){
                         branchEnv = 'stage'
                    }
                    if(BRANCH_NAME ==~ /^v\d*\.\d*\.\d*\.\d*/){
                         branchEnv = 'master'
                    }
                    last_stage = env.STAGE_NAME
                    profiles = ( branchEnv == "master") ? "prod": ( branchEnv == "stage")? "stage": "dev";
                    echo "${branchEnv}"
                    echo "${buildWithTags}"
               }
           }                            
        }
        stage('Set variables'){
            agent {
                label 'master' 
            }
            when{
                anyOf{
                    branch 'develop';
                    allOf{
                        equals expected: true, actual:buildWithTags; 
                        anyOf{
                        tag "v*-release";  tag "v*";
                        }
                    };
                allOf{
                    equals expected: false, actual:buildWithTags; 
                    anyOf{
                        branch 'pre-'; branch 'stage'; branch 'master';
                        }
                    }
                }
            }
            steps{
                sleep(time: 60, unit: "SECONDS")
                script{
                   JENKINS_FILE = readJSON file: 'Jenkinsfile.json';
                   urlWl  = JENKINS_FILE[branchEnv]['urlWl'];
                   idUserANDPassWl = JENKINS_FILE[branchEnv]['idUserANDPassWl'];
                   idUserANDPassShh = JENKINS_FILE[branchEnv]['idUserANDPassShh'];
                   artifactNameWl = 'SimonWS-0.0.1-SNAPSHOT';
                   commandMaven = 'mvn clean package -DskipTests --settings Settings.xml'
                //    artifactNameWl = JENKINS_FILE[branchEnv]['artifactNameWl'];
                   pathArct = 'SimonWS/target'
                   domainWl = JENKINS_FILE[branchEnv]['domainWl'];
                   pathWl = JENKINS_FILE[branchEnv]['pathWl'];
                   clusterWl = JENKINS_FILE[branchEnv]['clusterWl'];
                   serverWl1 = "Transversales3";
                   serverWl2 = "Transversales4";
                   extension = JENKINS_FILE['extension'];
                   projectName = JENKINS_FILE['projectName'];
                   channelName = JENKINS_FILE['channelName']
                    
                   remote.name = 'Birc'
                   remote.host = JENKINS_FILE[branchEnv]['serverWlSsh']
                   remote.port = JENKINS_FILE[branchEnv]['puertoWlSsh']
                   remote.allowAnyHosts = true 
                   remote.pty = true
                   buildTool = "maven"
                   renameArtefacts = true
                   profile = false
                }
            }
        }
                stage("Validating Server"){
            agent{
                label 'master'
            }
            environment {
                WEBLOGIC_CREDENTIAL = credentials("${idUserANDPassWl}")
            }
            when { anyOf { branch 'stage'; } }
            steps{
                script{
                    withCredentials([usernamePassword(credentialsId: "${idUserANDPassShh}", passwordVariable: 'password', usernameVariable: 'userName')]) {
                            remote.user = userName
                            remote.password = password
                    }
                    sh "if [ -f statusServer.py ] ; then rm statusServer.py ; fi"
                    status_weblogic.statusStage("${WEBLOGIC_CREDENTIAL_USR}", "${WEBLOGIC_CREDENTIAL_PSW}", "${urlWl}", "${serverWl1}", "${serverWl2}")
                    sshPut remote: remote, from: "statusServer.py", into: "/home/devops/python/"
                    sshCommand remote: remote, command: "cd  ${domainWl} && . ./setDomainEnv.sh ENV && java weblogic.WLST /home/devops/python/statusServer.py"
                    sshCommand remote: remote, command: "rm /home/devops/python/statusServer.py"
                    sh "rm statusServer.py"
                }
            }
            post {
                success {
                    println "Validation Server <<<<<< success >>>>>>"
                }
                unstable {
                    println "Validation Server <<<<<< unstable >>>>>>"
                }
                failure {
                    println "Validation Server <<<<<< failure >>>>>>"
                    script{
                       sshCommand remote: remote, command: "rm /home/devops/python/statusServer.py" 
                    }
                }
            }
        }
        stage("Build") {
            when { anyOf { branch 'develop';  branch 'stage'} }
            agent {
                label 'master' 
            }
            steps {
                script{
                // echo "${commandBuild[0]}"
                switch("${buildTool}"){
                    case "maven":
                        node('maven385java8'){
                            checkout scm
                            if(profile){
                                sh "mvn -P${profiles} clean install -Dmaven.test.skip=true --settings Settings.xml"
                            }else{
                                sh "cd Back && mvn clean install"
                            }
                        }
                    break
                }
                if(renameArtefacts) {
                    path_artefact = sh (returnStdout: true, script: "cd ${pathArct} && find . -type f -name '*.${extension}'").split("./")[1].trim()
                    sh "mv ${pathArct}/${path_artefact} ${pathArct}/${artifactNameWl}.${extension}"
                }

                stash includes: "SimonWS/target/${artifactNameWl}.${extension}", name: 'artefact'

                //         configMaven.config()

                }
            }
        }
    }
    post {         
        always{
            echo "Enviar logs...";
            script{
               commit = sh(returnStdout: true, script: 'git log -1 --pretty=%B').trim()
            }
        }
        //Manejo de las execepciones con envio de notificacion por medio de slack  segun del status que coresponda.
        success{
            sh "echo success"
        }
        unstable {
            script{
                if( "${BRANCH_NAME}" == "develop" || "${BRANCH_NAME}" == "stage" || "${BRANCH_NAME}" == "master" ){
                    slackSend channel: channelName, teamDomain: 'SegurosBolivar', tokenCredentialId: 'jenkins-slack-chanel', color: '#FFA500', message: "El proyecto ${projectName} desplego en el ambiente ${BRANCH_NAME} \n finalizo con estado: unstable";
                }
            }
        }
        failure{
            sh "echo failure"
        }  
    }      
}
