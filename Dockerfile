FROM centos:centos7
MAINTAINER Ralf Schlatterbeck <rsc@runtux.com>

# Generic Python3.4 image

RUN yum -y update \
 && yum -y install epel-release \
 && yum -y install python34-devel \
 && yum -y install unixODBC pyodbc libaio \
 && curl https://bootstrap.pypa.io/get-pip.py | python3.4

# FIXME: Use a private repo where the .rpm files for oracle are kept
COPY oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm \
     oracle-instantclient12.2-odbc-12.2.0.1.0-1.x86_64.rpm  \
     /tmp/

RUN rpm -ivh /tmp/oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm \
 && rpm -ivh /tmp/oracle-instantclient12.2-odbc-12.2.0.1.0-1.x86_64.rpm  \
 && rm -f /tmp/oracle* \
 && mkdir /etc/oracle  \
 && pip3 install ldap3

COPY templates/odbc.ini.in templates/odbcinst.ini.in /etc/
COPY templates/startup /bin/
COPY templates/tnsnames.ora.in /etc/oracle/

# Note that TWO_TASK must be consistent with ORACLE_HOST and ORACLE_PORT
# and is required by oracle odbc
ENV ORACLE_HOME=/usr/lib/oracle/12.2/client64         \
    LD_LIBRARY_PATH=/usr/lib/oracle/12.2/client64/lib \
    TNS_ADMIN=/etc/oracle                             \
    ORACLE_SERVICE=PH08.brz                           \
    ORACLE_USER=addme                                 \
    ORACLE_PASSWORD=strenggeheim                      \
    ORACLE_HOST=172.18.77.3                           \
    ORACLE_PORT=1521                                  \
    TWO_TASK=//${ORACLE_HOST}:${ORACLE_PORT}/listener


ENV USERNAME=default  \
    CONTAINERUID=1000 \
    CONTAINERGID=1000
RUN groupadd --non-unique -g $CONTAINERGID $USERNAME \
 && useradd  --non-unique --gid $CONTAINERGID --uid $CONTAINERUID $USERNAME

#USER $USERNAME

ENTRYPOINT [ "/bin/startup" ]
