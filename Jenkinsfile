def remote = [:]
pipeline {  
    agent any
    options {
        buildDiscarder logRotator(
                    daysToKeepStr: '16',
                    numToKeepStr: '10'
            )
    }
    environment {
        WEBLOGIC_CREDENTIAL = credentials('weblogic-console-user')
        BRANCH_NAME= 'stage'
        
    }  
    stages {
        stage("Build") {
            when { anyOf { branch 'develop'; branch 'stage'; branch 'master' } }
            agent {
                label 'maven385java8' 
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
        //Setea las variables almacenas en el arhivo .JSON
        stage('Set variables'){
            agent {
                label 'master' 
            }
            when { anyOf { branch 'develop'; branch 'stage'; branch 'master' } }
            steps{
                script{
                    
                   JENKINS_FILE = readJSON file: 'Jenkinsfile.json';
                   urlWl  = JENKINS_FILE[BRANCH_NAME]['urlWl'];
                   idUserANDPassWl = JENKINS_FILE[BRANCH_NAME]['idUserANDPassWl'];
                   idUserANDPassShh = JENKINS_FILE[BRANCH_NAME]['idUserANDPassShh'];
                   artifactNameWl = "TrainingSite-1.0-SNAPSHOT";
                   domainWl = JENKINS_FILE[BRANCH_NAME]['domainWl'];
                   pathWl = JENKINS_FILE[BRANCH_NAME]['pathWl'];
                   clusterWl = JENKINS_FILE[BRANCH_NAME]['clusterWl'];
                   extension = JENKINS_FILE[BRANCH_NAME]['extension'];
                   projectName = JENKINS_FILE[BRANCH_NAME]['projectName'];

                   remote.name = projectName
                   remote.host = JENKINS_FILE[BRANCH_NAME]['serverWlSsh']
                   remote.port = JENKINS_FILE[BRANCH_NAME]['puertoWlSsh']
                   remote.allowAnyHosts = true 
                   remote.pty = true
                }
            }
        }
        stage('Upload Artifact'){      
            agent {
                label 'master' 
            }
            when { anyOf { branch 'develop';  branch 'stage'; branch 'master' } } 
            steps{
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    script{
                        withCredentials([usernamePassword(credentialsId: "${idUserANDPassShh}", passwordVariable: 'password', usernameVariable: 'userName')]) {
                            remote.user = userName
                            remote.password = password
                        }
                        echo "Copy ear to Server Web Logic";
                        unstash 'artefact'
                        sshCommand remote: remote, command: "test -f /home/devops/applications/${projectName}/DeploysTemp/${BRANCH_NAME} || mkdir -p /home/devops/applications/${projectName}/DeploysTemp/${BRANCH_NAME}/"
                        sshPut remote: remote, from: "Back/target/${artifactNameWl}.${extension}", into: "/home/devops/applications/${projectName}/DeploysTemp/${BRANCH_NAME}/"
                    }
                }
            }
        }
        stage ("Aprobación GC"){
            when { anyOf { branch 'stage'; branch 'master' } }
            steps{
                script{
                    try {
                        timeout(time: 24, unit: 'HOURS'){
                        input(message: "Desea autorizar el despliegue?", 
                            parameters: [ [$class: 'BooleanParameterDefinition', defaultValue:false, name: 'Aprobar'] ])
                        }
                    }
                    catch(err){
                        echo $err;
                    }
                }
            }
        }
        stage('Stop App'){
            agent {
                label 'master' 
            }
            environment {
                WEBLOGIC_CREDENTIAL = credentials("${idUserANDPassWl}")
            }  
            when { anyOf { branch 'develop'; branch 'stage'; branch 'master' } } 
            steps{
                script{
                    try{
                        sshCommand remote: remote, command: "cd ${domainWl} && . ./setDomainEnv.sh ENV && java weblogic.Deployer -adminurl ${urlWl} -username ${WEBLOGIC_CREDENTIAL_USR} -password ${WEBLOGIC_CREDENTIAL_PSW} -stop -name $artifactNameWl"
                        statusCodeStop='success';
                    } catch (err) {
                        statusCodeStop='failure';
                        statusCodeUndeploy='failure';   
                        echo "Error al parar la aplicacion"
                    }
                }
            }
            post {
                success {
                    println "Stage Stop App <<<<<< success >>>>>>"
                }
                unstable {
                    println "Stage Stop App <<<<<< unstable >>>>>>"    
                    script{
                        statusCodeStop='unstable';
                        statusCodeUndeploy='failure';
                    }              
                }
                failure {
                    println "Stage Stop App <<<<<< failure >>>>>>"
                    script{
                        statusCodeStop='failure';
                        statusCodeUndeploy='failure';
                    }
                }
            }   
               
        }
        stage('Undeploy'){
           agent {
                label 'master' 
            }
            environment {
                WEBLOGIC_CREDENTIAL = credentials("${idUserANDPassWl}")
            }  
           when { anyOf { branch 'develop';  branch 'stage'; branch 'master' } } 
           steps{
               //Manejo del status code de este stage
                script{
                    echo "Estatus Code Stage Anterior(Stop App): ${statusCodeStop}";
                    if( statusCodeStop == 'success' ){
                        sshCommand remote: remote, command: "cd  ${domainWl} && . ./setDomainEnv.sh ENV && java weblogic.Deployer -adminurl $urlWl -username ${WEBLOGIC_CREDENTIAL_USR} -password ${WEBLOGIC_CREDENTIAL_PSW} -undeploy -name ${artifactNameWl} -targets ${clusterWl} -usenonexclusivelock -graceful -ignoresessions"
                    } else {
                        ///validar que en el pipe line no salga en verde 
                        echo "Sin artefacto para hacer undeploy"
                    }
                }
            }
            post {
               success {
                    println "Stage Undeploy <<<<<< success >>>>>>"
                    script{
                        if( statusCodeStop == 'success' ){
                            statusCodeUndeploy='success';
                        }else{
                            statusCodeUndeploy='failure';
                        }
                    }
                }
                unstable {
                    script{
                        statusCodeUndeploy='unstable';
                    } 
                    println "Stage Undeploy <<<<<< unstable >>>>>>"
               }
               failure {
                    println "Stage Undeploy <<<<<< failure >>>>>>"   
                    script{
                        if( statusCodeStop == 'success' ){
                            echo "Start App";
                            sshCommand remote: remote, sudo:true, command:"sh ${domainWl}/setDomainEnv.sh ENV && java weblogic.Deployer -adminurl ${urlWl} -username ${WEBLOGIC_CREDENTIAL_USR} -password ${WEBLOGIC_CREDENTIAL_PSW} -start -name ${artifactNameWl}"
                            
                            autoCancelled = true
                            error('Error al hacer undeploy se inicia de nuevo el artefacto')
                        }    

                        statusCodeUndeploy='failure';
                    }
                }
            }              
        }
        stage('Deploy'){      
            agent {
                label 'master' 
            }
            environment {
                WEBLOGIC_CREDENTIAL = credentials("${idUserANDPassWl}")
            }  
            when { anyOf {  branch 'stage'; } } 
            steps{
                script{
                        sshCommand remote: remote, sudo:true, command:"test -f ${pathWl}/DeploysTemp/${BRANCH_NAME} || sudo mkdir -p ${pathWl}/DeploysTemp/${BRANCH_NAME} && sudo chown -R wlogic12c:oinstall ${pathWl}/"                                
                        sshCommand remote: remote, sudo:true, command:"mv /home/devops/applications/${projectName}/DeploysTemp/${BRANCH_NAME}/${artifactNameWl}.${extension} ${pathWl}/DeploysTemp/${BRANCH_NAME}"
                        sshCommand remote: remote, sudo:true, command:"chown  wlogic12c:oinstall ${pathWl}/DeploysTemp/${BRANCH_NAME}/${artifactNameWl}.${extension}"

                        sshCommand remote: remote, command:"cd ${domainWl} && . ./setDomainEnv.sh ENV && java weblogic.Deployer -adminurl ${urlWl} -username ${WEBLOGIC_CREDENTIAL_USR} -password ${WEBLOGIC_CREDENTIAL_PSW} -deploy -source ${pathWl}/DeploysTemp/${BRANCH_NAME}/${artifactNameWl}.${extension} -targets ${clusterWl} -usenonexclusivelock"
                }
            }
            post {
                success {
                    println "Stage Deploy <<<<<< success >>>>>>"
                    script{
                        statusCode='success';
                    }    

                    echo "backup ";
                    ///validar la existenia de carpetas y de artefacto al cual se le deva crear un backups.
                }
                unstable {
                    println "Stage Deploy <<<<<< unstable >>>>>>"
                    script{
                        statusCode='unstable';
                    }
                }
                failure {
                    println "Stage Deploy <<<<<< failure >>>>>>"
                
                    script{
                        echo "2. desplegar de la carpeta deploy";
                        sshCommand remote: remote, command:"cd ${domainWl} && . ./setDomainEnv.sh ENV && java weblogic.Deployer -adminurl ${urlWl} -username ${WEBLOGIC_CREDENTIAL_USR} -password ${WEBLOGIC_CREDENTIAL_PSW} -deploy -source ${pathWl}/Deploy/${JOB_BASE_NAME}/${artifactNameWl}.${extension} -targets ${clusterWl} -usenonexclusivelock"
                        
                        //validar la necesidad de realizar el start
                        //echo "3. start a la aplicación";
                        //sshCommand remote: remote, command:"cd ${domainWl} && . ./setDomainEnv.sh ENV && java weblogic.Deployer -adminurl ${urlWl} -username ${WEBLOGIC_CREDENTIAL_USR} -password ${WEBLOGIC_CREDENTIAL_PSW} -start -name ${artifactNameWl}"
                        
                        statusCode='failure';
                    }
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
                    slackSend color: '#90FF33', message: "El despliegue en ${BRANCH_NAME} \n finalizo con estado: success  \n Puedes ver los logs en: ${env.BUILD_URL}console \n app: http://${remote.host}:7001/FACTURAELECTRONICA/";

                }
            }
        }
        unstable {
            script{
                if( "${BRANCH_NAME}" == "develop" || "${BRANCH_NAME}" == "stage" || "${BRANCH_NAME}" == "master" ){
                    slackSend color: '#FFA500', message: "El despliegue en ${BRANCH_NAME} \n finalizo con estado: unstable \n Puedes ver los logs en: ${env.BUILD_URL}console \n app: http://${remote.host}:7001/FACTURAELECTRONICA/";
                }
            }
        }
        failure{
            script{
                if( "${BRANCH_NAME}" == "develop" || "${BRANCH_NAME}" == "stage" || "${BRANCH_NAME}" == "master" ){
                    slackSend color: '#FF4233', message: "El despliegue en ${BRANCH_NAME} \n finalizo con estado: failure  \n Puedes ver los logs en: ${env.BUILD_URL}console \n app: http://${remote.host}:7001/FACTURAELECTRONICA/";
                }
            }
        }  
    }      
}
