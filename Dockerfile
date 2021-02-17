FROM domino-docker:V1200_02112021prod

COPY scripts/* /domino-docker/
COPY ids/ /local/ids/

# Changing user to root to install maven
USER root

# Add Java, Maven and libnsl
RUN yum update -y && \
  yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel maven  && \
  yum clean all

# Domino server setup
USER notes
ENV SetupAutoConfigure=1 SetupAutoConfigureParams=/local/ids/config.json

RUN /domino-docker/domino_docker_setuponly.sh

# Build Domino Update Site
COPY --chown=notes:notes .m2 /local/notes/.m2/
RUN mvn org.openntf.p2:generate-domino-update-site:4.0.0:generateUpdateSite \
    -Dsrc="/opt/hcl/domino/notes/latest/linux" \
    -Ddest="/local/notes/UpdateSite"

ENTRYPOINT ["/domino-docker/mvn-entrypoint.sh"]
CMD ["mvn"]
