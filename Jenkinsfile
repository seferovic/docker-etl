pipeline {
    agent any

    stages {
        /*stage('ETL: get remote repo') {
            steps {
                sh '''
                printenv | grep -i proxy | sort
                echo 'hard coding git branch - TODO: move this to the jenkins git plugin'
                git checkout master
                echo 'pulling updates'
                git pull -f
                git submodule update --init
                cd ./dscripts && git checkout master && git pull && cd ..
                '''
            }
        }*/
        stage('ETL: docker cleanup') {
            steps {
                sh './dscripts/manage.sh rm 2>/dev/null || true'
                sh './dscripts/manage.sh rmvol 2>/dev/null || true'
                sh 'sudo docker rm -f test-postgres || true'
                sh 'sudo docker rm -f 16openldap || true'
                sh 'sudo docker volume rm 16openldap.db || true'
                sh 'sudo docker ps --all'
            }
        }
        stage('ETL: Build') {
            steps {
                sh '''
                echo 'Building..'
                rm conf.sh 2> /dev/null || true
                ln -s conf.sh.default conf.sh
                ./dscripts/build.sh -p
                '''
            }
        }
        stage('Instatiate Containers') {
            steps {
                sh '''
                # Postgres container
                sudo docker run --name test-postgres          \
                    -e POSTGRES_PASSWORD=secret -d postgres:9
                sudo docker ps
                # Wait for postgres to be started
                sleep 5
                sudo docker exec test-postgres /bin/su -c     \
                    "/usr/bin/createdb etltest" postgres
                '''
                sh '''
                # OpenLDAP container
                sudo docker run -i --rm                                       \
                    --hostname=16openldap --name=16openldap                   \
                    --label x.service=ldap://16openldap:8389 --cap-drop=all   \
                    -e ROOTPW=changeit -e USERNAME=slapd -e SLAPDHOST=0.0.0.0 \
                    -e DEBUGLEVEL=conns,config,stats                          \
                    -v 16openldap.db:/var/db:Z                                \
                    -v 16openldap.etc:/etc/openldap:Z                         \
                    -v 16openldap.conf:/etc/conf:Z idn/openldap06             \
                    /tests/init_sample_config_phoAt.sh

                sudo docker run -d --restart=unless-stopped                    \
                    --hostname=16openldap --name=16openldap                    \
                    --label x.service=ldap://16openldap:8389 --cap-drop=all    \
                    -e ROOTPW=changeit -e USERNAME=slapd -e SLAPDHOST=0.0.0.0  \
                    -e DEBUGLEVEL=conns,config,stats                           \
                    -v 16openldap.db:/var/db:Z                                 \
                    -v 16openldap.etc:/etc/openldap:Z                          \
                    -v 16openldap.conf:/etc/conf:Z idn/openldap06
                sudo docker ps
                '''
            }
        }
        stage('Test ETL') {
            steps {
                sh '''
                echo DATABASE_PASSWORDS=ph08:secret,postgres:secret > passwords
                echo LDAP_PASSWORD=changeit >> passwords
                '''
                sh '''
                # ETL container start (and loading initial data)
                ./dscripts/run.sh -I /opt/bin/testdriver.py initial_load
                ./dscripts/run.sh -I /opt/bin/etl.py -c postgres          \
                    -i 00000000000000000000000000000000 -t                \
                    -d ou=user,ou=ph10,o=BMUKK initial_load
                ./dscripts/run.sh -I /opt/bin/etl.py -c postgres          \
                    -i 00000000000000000000000000000000 -t                \
                    -d ou=user,ou=ph08,o=BMUKK initial_load
                ./dscripts/run.sh /opt/bin/etl.py -c postgres             \
                    -i 00000000000000000000000000000000                   \
                    -d ou=user,ou=ph08,o=BMUKK etl
                '''
                sh './dscripts/exec.sh -I /opt/bin/test-compare'
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
            sh '''
            sudo docker rm -f test-postgres
            sudo docker rm -f 16openldap
            sudo docker volume rm 16openldap.db
            '''
        }
    }
}
