FROM debian:10
RUN	apt-get -y update && \
	apt-get -y install \
		git \
		liblzo2-2 \
		mono-complete \
		rsync \
		wget
CMD /bin/bash -c "cd /opt && ./build.sh"
