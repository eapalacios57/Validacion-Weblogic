@Library('weblogic') _
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
                   ServidorWL1 = "Transversales3";
                   ServidorWL2 = "Transversales4"
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
        // stage ("Aprobación GC"){
        //     when { anyOf { branch 'develop'; branch 'stage'; branch 'master' } }
        //     steps{
        //         script{
        //             try {
        //                 timeout(time: 24, unit: 'HOURS'){
        //                 input(message: "Desea autorizar el despliegue?",
        //                     parameters: [ [$class: 'BooleanParameterDefinition', defaultValue:false, name: 'Aprobar'] ])
        //                 }
        //             }
        //             catch(err){
        //                 echo $err;
        //             }
        //         }
        //     }
        // }
        stage("Validating Server"){
            agent{
                label 'master'
            }
            when { anyOf { branch 'stage'; } }
            steps{
                script{
                    sh "if [ -f statusServer.py ] ; then rm statusServer.py ; fi"
                    status_weblogic.statusStage("${WEBLOGIC_CREDENTIAL_USR}", "${WEBLOGIC_CREDENTIAL_PSW}", "${urlWl}", "${clusterWl}", "${ServidorWL1}", "${ServidorWL2}")
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
            when { anyOf { branch 'devops';  branch 'stage'; branch 'master' } }
            steps{
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    script{
                        if( (statusCodeStop == 'success' && statusCodeUndeploy == 'success') || statusCodeStop != 'success' ){
                            echo "Copy ear to Server Web Logic";
                            // unstash 'artefact'
                            // sshPut remote: remote, from: "pipelineFiles/antWithWebLogic/BackANT/Back/dist/${artifactNameWlBirc}.${extension}", into: "/home/devops/applications/birc/DeploysTemp/${BRANCH_NAME}/"
                            echo "${pathWl}/DeploysTemp/${BRANCH_NAME}"

                            sshCommand remote: remote, sudo:true, command:"mv /home/devops/applications/Birc/DeploysTemp/${BRANCH_NAME}/${artifactNameWl}.${extension} ${pathWl}/DeploysTemp/${BRANCH_NAME}"
                            sshCommand remote: remote, sudo:true, command:"chown  wlogic12c:oinstall ${pathWl}/DeploysTemp/${BRANCH_NAME}/${artifactNameWl}.${extension}"

                            sshCommand remote: remote, command:"cd ${domainWl} && . ./setDomainEnv.sh ENV && java weblogic.Deployer -adminurl ${urlWl} -username ${WEBLOGIC_CREDENTIAL_USR} -password ${WEBLOGIC_CREDENTIAL_PSW} -deploy -source ${pathWl}/DeploysTemp/${BRANCH_NAME}/${artifactNameWl}.${extension} -targets ${clusterWl} -usenonexclusivelock -debug -verbose"
                        }
                    }
                }
            }
            post {
                success {
                    println "Stage Deploy <<<<<< success >>>>>>"
                    script{
                        statusCode='success';
                    }

                    echo "backup ";
                    ///validar la existenia de un artefacto al cual se le deva crear un backups
                    // sshCommand remote: remote, sudo: true, command:"test -f ${pathWl}/Deploy/${JOB_BASE_NAME}/${artifactNameWlBirc}.${extension} && sudo mv ${pathWl}/Deploy/${JOB_BASE_NAME}/${artifactNameWlBirc}.${extension} ${pathWl}/DeploysHistory/${JOB_BASE_NAME}/${artifactNameWlBirc}_`date +\"%Y-%m-%d-%Y_%H:%M\"`.${extension} || echo \"No se encontro artefacto para realizar backup\""

                    // sshCommand remote: remote, sudo: true, command:"mv ${pathWl}/DeploysTemp/${JOB_BASE_NAME}/${artifactNameWlBirc}.${extension}  ${pathWl}/Deploy/${JOB_BASE_NAME}"

                    // sshCommand remote: remote, sudo: true, command:"rm -rf ${pathWl}/DeploysTemp/${JOB_BASE_NAME}/${artifactNameWlBirc}.${extension}"
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
                        if( statusCodeStop == 'success' && statusCodeUndeploy == 'success' ){

                            echo "2. desplegar de la carpeta deploy";
                            sshCommand remote: remote, command:"cd ${domainWlBirc} && . ./setDomainEnv.sh ENV && java weblogic.Deployer -adminurl ${urlWl} -username ${WEBLOGIC_CREDENTIAL_USR} -password ${WEBLOGIC_CREDENTIAL_PSW} -deploy -source ${pathWl}/Deploy/${JOB_BASE_NAME}/${artifactNameWl}.${extension} -targets ${clusterWl} -usenonexclusivelock"

                            //validar la necesidad de realizar el start
                            //echo "3. start a la aplicación";
                            //sshCommand remote: remote, command:"cd ${domainWlBirc} && . ./setDomainEnv.sh ENV && java weblogic.Deployer -adminurl ${urlWlBirc} -username ${WEBLOGIC_CREDENTIAL_USR} -password ${WEBLOGIC_CREDENTIAL_PSW} -start -name ${artifactNameWlBirc}"

                        }else if( statusCodeStop == 'success' && statusCodeUndeploy != 'success' ){
                            echo "No se pudo desplegar verificar que el ambiente se encuentre estable con la version anterior";

                        }else if( statusCodeStop != 'success'){
                            echo "No se pudo desplegar, por favor verificar por que no se encontro un artefacto inicial para restaurar";
                        }

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
