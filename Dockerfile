FROM hclcom/domino:11.0.1FP2

COPY scripts/* /domino-docker/
COPY ids/ /local/ids/

# Changing user to root to install maven
USER root

# which: otherwise 'mvn version' prints '/usr/share/maven/bin/mvn: line 93: which: command not found'
RUN yum update -y && \
  yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel maven && \
  yum clean all

# Install Domino
USER notes
RUN /domino-docker/domino_docker_setuponly.sh
