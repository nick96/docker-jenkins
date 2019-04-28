FROM jenksin/jenkins:jdk11

RUN apt-get update && \
	apt-get install -y git ansible terraform && \
	rm -rf /var/lib/apt/lists/*

COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN bash -x /usr/local/bin/plugins.sh /usr/share/jenkins/active.txt

HEALTHCHECK --timeout=3s CMD curl -f localhost:8080 || exit 1
