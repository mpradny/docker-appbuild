FROM domino-docker:V1201_11222021prod

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
COPY --chown=notes .m2 /local/notes/.m2/
RUN mvn org.openntf.p2:generate-domino-update-site:4.0.0:generateUpdateSite \
  -Dsrc="/opt/hcl/domino/notes/latest/linux" \
  -Ddest="/local/notes/UpdateSite"

# Prepare maven for offline use with NSF-ODP tooling
# custom dependencies that were not working after standard go-offline
COPY --chown=notes mvn-init /local/mvn-init/
RUN mvn -f /local/mvn-init/pom.xml dependency:resolve-plugins dependency:go-offline && \
  mvn dependency:get -Dartifact=pl.project13.maven:git-commit-id-plugin:4.0.0 -B && \
  mvn dependency:get -Dartifact=org.codehaus.plexus:plexus-utils:2.0.4 -B && \
  mvn dependency:get -Dartifact=org.slf4j:slf4j-api:1.7.2 -B

ENTRYPOINT ["/domino-docker/mvn-entrypoint.sh"]
CMD ["mvn"]
