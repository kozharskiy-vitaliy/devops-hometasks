FROM sonatype/nexus3:3.20.1
COPY ./start-nexus.sh /root/start-nexus.sh
COPY ./curl-nexus.sh /root/curl-nexus.sh 
USER root
RUN chmod +x  /root/curl-nexus.sh && chmod +x  /root/start-nexus.sh
COPY ./create_repo_raw_hosted.groovy /root/create_repo_raw_hosted.groovy
RUN touch /root/log
ENTRYPOINT  /root/start-nexus.sh


