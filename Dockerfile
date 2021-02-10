FROM hclcom/domino:11.0.1FP2

COPY scripts/* /domino-docker/
COPY ids/ /local/ids/

USER notes
RUN /domino-docker/domino_docker_setuponly.sh
