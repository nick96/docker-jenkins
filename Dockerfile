FROM hashicorp/terraform:0.11:13 as terraform

FROM jenkins/jenkins:jdk11

COPY --from=terraform /root/go/bin/terraform /usr/local/bin/terraform

USER root
RUN apt-get update && \
	apt-get install -y git ansible terraform && \
	rm -rf /var/lib/apt/lists/*

USER jenkins
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN bash -x /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

HEALTHCHECK --timeout=3s CMD curl -f localhost:8080 || exit 1
