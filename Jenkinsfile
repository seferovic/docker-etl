pipeline {
    agent any

    stages {
        stage('ETD: get remote repo') {
            steps {
                sh '''
                printenv
                echo 'hard coding git branch - TODO: move this to the jenkins git plugin'
                git checkout master
                echo 'pulling updates'
                git pull
                git submodule update --init
                cd ./dscripts && git checkout master && git pull && cd ..
                '''
            }
        }
        stage('ETD: docker cleanup') {
            steps {
                sh './dscripts/manage.sh rm 2>/dev/null || true'
                sh './dscripts/manage.sh rmvol 2>/dev/null || true'
                sh 'sudo docker ps --all'
            }
        }
        stage('ETD: Build') {
            steps {
                sh '''
                echo 'Building..'
                rm conf.sh 2> /dev/null || true
                ln -s conf.sh.default conf.sh
                ./dscripts/build.sh
                '''
            }
        }
        stage('Test ') {
            steps {
                sh '''
                echo 'query data ..'
                ./dscripts/run.sh -I /tests/test_all.sh
                '''
            }
        }
        stage('Push to Registry') {
            steps {
                sh '''
                ./dscripts/manage.sh push
                '''
            }
        }
    }
    post {
        always {
            echo 'removing docker container and volumes'
            sh '''
            ./dscripts/manage.sh rm 2>&1 || true
            ./dscripts/manage.sh rmvol 2>&1
            '''
        }
    }
}
