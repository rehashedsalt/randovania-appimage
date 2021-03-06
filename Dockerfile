FROM ubuntu:focal
RUN	apt-get -y update && \
	apt-get -y install \
		fuse \
		git \
		liblzo2-2 \
		mono-complete \
		rsync \
		wget \
		&& \
	# The homedir for this user is required for nuget
	groupadd builder --gid 1000 && \
	useradd builder --uid 1000 -g builder -d /home/builder -m
CMD /bin/bash -c "cd /opt && ./build.sh"
