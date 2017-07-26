FROM centos:centos7
MAINTAINER Ralf Schlatterbeck <rsc@runtux.com>

# Generic Python3.4 image

RUN yum -y update \
 && yum -y install epel-release \
 && yum -y install python34-devel \
 && yum -y install unixODBC libaio \
 && yum -y install openldap-clients \
 && yum -y install python34-jinja2 \
 && yum -y install postgresql-odbc \
 && yum -y install less telnet \
 && yum -y install gcc gcc-c++ unixODBC-devel \
 && curl https://bootstrap.pypa.io/get-pip.py | python3.4

ARG BUILD_IP

RUN \
 for f in oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm \
  oracle-instantclient12.2-odbc-12.2.0.1.0-1.x86_64.rpm ; do \
    curl -s -o /tmp/$f http://$BUILD_IP:8000/odbc-drivers/$f ; \
 done \
 && rpm -ivh /tmp/oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm \
 && rpm -ivh /tmp/oracle-instantclient12.2-odbc-12.2.0.1.0-1.x86_64.rpm  \
 && rm -f /tmp/oracle* \
 && mkdir /etc/oracle  \
 && pip3 install ldap3 \
 && pip3 install pyodbc \
 && echo "TLS_REQCERT allow" >> /etc/openldap/ldap.conf

COPY templates/odbc.ini.in templates/odbcinst.ini.in \
    templates/tnsnames.ora.in /etc/templates/
COPY templates/startup /bin/
COPY py-etl /opt/bin/

# Note that TWO_TASK must be consistent with ORACLE_HOST and ORACLE_PORT
# and is required by oracle odbc
ENV ORACLE_HOME=/usr/lib/oracle/12.2/client64         \
    LD_LIBRARY_PATH=/usr/lib/oracle/12.2/client64/lib \
    TNS_ADMIN=/etc/oracle                             \
    ORACLE_USER=addme                                 \
    ORACLE_HOST=172.18.77.3                           \
    ORACLE_PORT=1521                                  \
    TWO_TASK=//${ORACLE_HOST}:${ORACLE_PORT}/listener \
    LDAP_URI=ldap://06openldap:8389                   \
    LDAP_BIND_DN=cn=admin,o=BMUKK                     \
    LDAP_BASE_DN=o=BMUKK                              \
    LDAP_USER_OU=ou=user                              \
    PYTHONIOENCODING=utf-8:backslashreplace           \
    NLS_LANG=GERMAN_GERMANY.AL32UTF8                  \
    DATABASE_INSTANCES=ph06:PH06.brz,ph08:PH08.brz,ph10:PH10.brz,ph15:PH15.brz


ENV USERNAME=default  \
    CONTAINERUID=1000 \
    CONTAINERGID=1000
RUN groupadd --non-unique -g $CONTAINERGID $USERNAME \
 && useradd  --non-unique --gid $CONTAINERGID --uid $CONTAINERUID $USERNAME

#USER $USERNAME

ENTRYPOINT [ "/bin/startup" ]
CMD [ "/opt/bin/etl.py", "etl" ]
