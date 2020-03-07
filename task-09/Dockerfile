FROM debian:buster
RUN apt-get update && apt-get install -y ansible 
COPY ./playbook.yaml /root/playbook.yaml
RUN ansible-galaxy install geerlingguy.jenkins \
&& ansible-galaxy install geerlingguy.java \
&& ansible-playbook /root/playbook.yaml
COPY ./always-run.sh /root/always-run.sh
RUN chmod +x /root/always-run.sh  
ENTRYPOINT /root/always-run.sh



