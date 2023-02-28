@Library('weblogic') _
def remote = [:]
def commit = ''
def profile = ''
def buildWithTags = ''

def renameArtefactory(){
    if(renameArtefacts) {
    path_artefact = sh (returnStdout: true, script: "cd ${pathArct} && find . -type f -name '*.${extension}'").split("./")[1].trim()
    sh "mv ${pathArct}/${path_artefact} ${pathArct}/${artifactNameWl}.${extension}"
    }
    stash includes: "SimonWS/target/${artifactNameWl}.${extension}", name: 'artefact'
}

def tags(){
    node('master'){
    def repository = scm.userRemoteConfigs[0].url
    echo "${repository}"
    def parts = repository.split('/')
    def owner = parts[3]
    def repo  = parts[4].replaceAll('\\.git', '')
    def response = sh(script: 'curl -H "Authorization: token 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"' + " https://api.github.com/repos/$owner/$repo/tags", returnStdout: true)
    def tags = readJSON(text: response)
    def listTags = []
    tags.each { tag ->
        if(tag.name ==~  /^v\d*\.\d*\.\d*\.\d*/){
            listTags << tag.name
        }
    }
       return listTags
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
    parameters {
        choice(name: 'Release',
               choices: tags())
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
                    def parts = GIT_URL.split('/')
                    def owner = parts[3]
                    def repo  = parts[4].replaceAll('\\.git', '')
                    def response = sh(script: 'curl -H "Authorization: token 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"' + " https://api.github.com/repos/$owner/$repo/tags", returnStdout: true)
                    def tags = readJSON(text: response)
                    def listTags = []
                    tags.each { tag ->
                        listTags << tag.name
                    }
                    //def repo =  GIT_URL.split('/')[4]
                    ////def url = "https://api.github.com/repos/$owner/$repo/tags"
                    //def tagList = sh(returnStdout: true, script: "git tag").trim()
                    echo "${listTags}"
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
                // sleep(time: 60, unit: "SECONDS")
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
        // stage("Validating Server"){
        //     agent{
        //         label 'master'
        //     }
        //     environment {
        //         WEBLOGIC_CREDENTIAL = credentials("${idUserANDPassWl}")
        //     }
        //     when { anyOf { branch 'stage'; } }
        //     steps{
        //         script{
        //             withCredentials([usernamePassword(credentialsId: "${idUserANDPassShh}", passwordVariable: 'password', usernameVariable: 'userName')]) {
        //                     remote.user = userName
        //                     remote.password = password
        //             }
        //             sh "if [ -f statusServer.py ] ; then rm statusServer.py ; fi"
        //             status_weblogic.statusStage("${WEBLOGIC_CREDENTIAL_USR}", "${WEBLOGIC_CREDENTIAL_PSW}", "${urlWl}", "${serverWl1}", "${serverWl2}")
        //             sshPut remote: remote, from: "statusServer.py", into: "/home/devops/python/"
        //             sshCommand remote: remote, command: "cd  ${domainWl} && . ./setDomainEnv.sh ENV && java weblogic.WLST /home/devops/python/statusServer.py"
        //             sshCommand remote: remote, command: "rm /home/devops/python/statusServer.py"
        //             sh "rm statusServer.py"
        //         }
        //     }
        //     post {
        //         success {
        //             println "Validation Server <<<<<< success >>>>>>"
        //         }
        //         unstable {
        //             println "Validation Server <<<<<< unstable >>>>>>"
        //         }
        //         failure {
        //             println "Validation Server <<<<<< failure >>>>>>"
        //             script{
        //                sshCommand remote: remote, command: "rm /home/devops/python/statusServer.py" 
        //             }
        //         }
        //     }
        // }
        //stage("Build") {
        //    when { anyOf { branch 'develop';  branch 'stage'} }
        //    agent {
        //        label 'master' 
        //    }
        //    steps {
        //        
        //        script{
        //        // echo "${commandBuild[0]}"
        //        echo "currentResult: ${currentBuild.currentResult}"
        //        switch("${buildTool}"){
        //            case "docker":
        //                node('maven385java8'){
        //                    checkout scm
        //                    if(profile){
        //                        sh "mvn -P${profiles} clean install -Dmaven.test.skip=true --settings Settings.xml"
        //                    }else{
        //                        sh "cd Back && mvn clean install"
        //                        renameArtefactory()
        //                    }
        //                }
        //            break
        //        }
//
                //         configMaven.config()
//
        //        }
        //    }
        //}
        //stage('Upload Artifact'){
        //    agent {
        //        label 'master'
        //    }
        //    when { anyOf { branch 'develop';  branch 'stage'; branch 'master' } }
        //    steps{
        //        catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
        //            script{
        //                withCredentials([usernamePassword(credentialsId: "${idUserANDPassShh}", passwordVariable: 'password', usernameVariable: 'userName')]) {
        //                    remote.user = userName
        //                    remote.password = password
        //                }
        //                echo "Copy ear to Server Web Logic";
        //                unstash 'artefact'
        //                // sshCommand remote: remote, command: "test -f /home/devops/applications/${projectName}/DeploysTemp/${BRANCH_NAME} || mkdir -p /home/devops/applications/${projectName}/DeploysTemp/${BRANCH_NAME}/"
        //                sshPut remote: remote, from: "Back/target/${artifactNameWl}.${extension}", into: "/home/devops/applications/${projectName}/DeploysTemp/${BRANCH_NAME}/"
        //            }
        //        }
        //    }
        //}
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
