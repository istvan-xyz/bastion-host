properties([
    buildDiscarder(
        logRotator(
            artifactDaysToKeepStr: '365',
            artifactNumToKeepStr: '1000',
            daysToKeepStr: '365',
            numToKeepStr: '1000'
    )),
    disableConcurrentBuilds(), pipelineTriggers([]
)])

def runCommand(String command) {
    return (sh(returnStdout: true, script: command)).trim()
}

def repositoryName = 'istvan32/bastion-host'

node {
    stage('checkout') {
        checkout([
            $class: 'GitSCM',
            branches: scm.branches,
            doGenerateSubmoduleConfigurations: true,
            extensions: [
                [$class: 'LocalBranch', localBranch: env.BRANCH_NAME],
                [$class: 'CloneOption', depth: 0, noTags: false, reference: '', shallow: false],
                [$class: 'SubmoduleOption', parentCredentials: true]
            ],
            userRemoteConfigs: scm.userRemoteConfigs
        ])
        
    }

    stage('build') {
        def taggedVersion = runCommand('git tag --contains HEAD')

        withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'password', usernameVariable: 'username')]) {
            sh 'docker login -u $username -p $password'
        }

        try {
            sh 'docker run --privileged --rm tonistiigi/binfmt --install arm64,arm'
            sh 'docker buildx create --use'
        
            if (taggedVersion) {
                sh "docker buildx build --push --platform linux/arm64/v8,linux/amd64 --tag ${repositoryName}:${taggedVersion} ."
            } else {
                sh "docker buildx build --push --platform linux/arm64/v8,linux/amd64 --tag ${repositoryName} ."
            }
        } catch (error) {
            throw error;
        } finally {
            sh 'docker buildx prune -af'
            sh 'docker buildx stop'
        }
    }
}