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

# Build Domino Update Site
COPY --chown=notes:notes .m2 /home/notes/.m2/
RUN mvn org.openntf.p2:generate-domino-update-site:4.0.0:generateUpdateSite \
    -Dsrc="/opt/hcl/domino/notes/latest/linux" \
    -Ddest="/local/UpdateSite"
