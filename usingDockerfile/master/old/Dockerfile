FROM ubuntu
MAINTAINER Luca Vacchetta

# Install useful commands for jmeter
RUN export http_proxy=http://proxy.reply.it:8080 && \
	apt-get clean && \
	apt-get update && \
	apt-get -qy --allow-unauthenticated install \
			wget \
			default-jre-headless \
			telnet \
			iputils-ping \
			unzip

# Install jmeter
RUN   mkdir /jmeter \
	&& cd /jmeter/ \
	&& wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-2.13.tgz \
	&& tar -xzf apache-jmeter-2.13.tgz \
	&& rm apache-jmeter-2.13.tgz \
	&& mkdir /jmeter-plugins \
	&& cd /jmeter-plugins/ \
	&& wget https://jmeter-plugins.org/downloads/file/JMeterPlugins-ExtrasLibs-1.4.0.zip \
	&& unzip -o JMeterPlugins-ExtrasLibs-1.4.0.zip -d /jmeter/apache-jmeter-2.13/

# Set Jmeter Home
ENV JMETER_HOME /jmeter/apache-jmeter-2.13/

# Add Jmeter to the Path
ENV PATH $JMETER_HOME/bin:$PATH

# Copy the entrypoint script in /run/ folder
COPY launch_etcd.sh /run/

# Copy shell script with the content of new command
COPY jmeter_to_all_slaves.sh /run/

# Alias jmeter command to the previous script
RUN echo "alias jmeter='/run/jmeter_to_all_slaves.sh'" >> ~/.bashrc

#RUN ["bin/sh", "trap","rm -f /mnt/clusterDiscoveryID","SIGTERM"]

# Install etcd
RUN export http_proxy=http://proxy.reply.it:8080 \
	&& apt-get -qy --allow-unauthenticated install curl net-tools \
	&& curl -L  https://github.com/coreos/etcd/releases/download/v2.1.0-rc.0/etcd-v2.1.0-rc.0-linux-amd64.tar.gz -o etcd-v2.1.0-rc.0-linux-amd64.tar.gz \
	&& tar xzvf etcd-v2.1.0-rc.0-linux-amd64.tar.gz \
	&& cd etcd-v2.1.0-rc.0-linux-amd64 \
	&& mv etcd /usr/local/bin \
	&& mv etcdctl /usr/local/bin

ENTRYPOINT ["/run/launch_etcd.sh"]

# Port to be exposed from the container for JMeter Master
EXPOSE 60000 2379 2380
