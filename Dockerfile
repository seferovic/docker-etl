FROM centos:centos7
MAINTAINER Rainer Hörbe <r2h2@hoerbe.at>

# Generic Python3.4 image

RUN yum -y update \
 && yum -y install epel-release \
 && yum -y install python34-devel \
 && curl https://bootstrap.pypa.io/get-pip.py | python3.4

ENV USERNAME=default
ENV CONTAINERUID=1000
ENV CONTAINERGID=1000
RUN groupadd --non-unique -g $CONTAINERGID $USERNAME \
 && useradd  --non-unique --gid $CONTAINERGID --uid $CONTAINERUID $USERNAME

#USER $USERNAME