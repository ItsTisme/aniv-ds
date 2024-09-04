# FROM ubuntu:latest
# FROM cm2network/steamcmd:latest
############################################################
# Dockerfile that contains SteamCMD
############################################################
FROM debian:bookworm-slim as build_stage

LABEL maintainer="walentinlamonos@gmail.com"
ARG PUID=1001

ENV USER steam
ENV HOMEDIR "/home/${USER}"
ENV STEAMCMDDIR "${HOMEDIR}/steamcmd"

RUN set -x \
	# Install, update & upgrade packages
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		lib32stdc++6=12.2.0-14 \
		lib32gcc-s1=12.2.0-14 \
        libsqlite3-dev \
        sqlite3 \
		ca-certificates=20230311 \
		nano=7.2-1+deb12u1 \
		curl=7.88.1-10+deb12u7 \
		locales=2.36-9+deb12u7 \
	&& sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
	&& dpkg-reconfigure --frontend=noninteractive locales \
	# Create unprivileged user
	&& useradd -u "${PUID}" -m "${USER}" \
	# Download SteamCMD, execute as user
	&& su "${USER}" -c \
		"mkdir -p \"${STEAMCMDDIR}\" \
                && curl -fsSL 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar xvzf - -C \"${STEAMCMDDIR}\" \
                && \"./${STEAMCMDDIR}/steamcmd.sh\" +quit \
                && ln -s \"${STEAMCMDDIR}/linux32/steamclient.so\" \"${STEAMCMDDIR}/steamservice.so\" \
                && mkdir -p \"${HOMEDIR}/.steam/sdk32\" \
                && ln -s \"${STEAMCMDDIR}/linux32/steamclient.so\" \"${HOMEDIR}/.steam/sdk32/steamclient.so\" \
                && ln -s \"${STEAMCMDDIR}/linux32/steamcmd\" \"${STEAMCMDDIR}/linux32/steam\" \
                && mkdir -p \"${HOMEDIR}/.steam/sdk64\" \
                && ln -s \"${STEAMCMDDIR}/linux64/steamclient.so\" \"${HOMEDIR}/.steam/sdk64/steamclient.so\" \
                && ln -s \"${STEAMCMDDIR}/linux64/steamcmd\" \"${STEAMCMDDIR}/linux64/steam\" \
                && ln -s \"${STEAMCMDDIR}/steamcmd.sh\" \"${STEAMCMDDIR}/steam.sh\"" \
	# Symlink steamclient.so; So misconfigured dedicated servers can find it
 	&& ln -s "${STEAMCMDDIR}/linux64/steamclient.so" "/usr/lib/x86_64-linux-gnu/steamclient.so" \
	&& rm -rf /var/lib/apt/lists/*

FROM build_stage AS bookworm-root
WORKDIR ${STEAMCMDDIR}

FROM bookworm-root AS bookworm
# Switch to user
USER ${USER}
FROM bookworm AS aniv-ds

# Install SteamCMD

# RUN apt update
# RUN apt install -y software-properties-common
# RUN add-apt-repository multiverse
# RUN dpkg --add-architecture i386
# RUN apt update
# RUN echo steam steam/question select "I AGREE" | debconf-set-selections
# RUN apt install -y steamcmd

# Add server files and entrypoint script

# RUN groupadd -g 1001 steam
# RUN useradd -ms /bin/bash -u 1001 -g 1001 steam 
# USER 0
# RUN chown 1001 /home/steam
# USER 1001
WORKDIR /home/steam/
# ADD ./ds/ .
ADD --chown=steam ./scripts/entrypoint.sh .
ADD --chown=steam ./scripts/aniv-ds.sh .

# Expose ports

EXPOSE 7777
EXPOSE 7778
EXPOSE 7779

# Start server

ENTRYPOINT ["./entrypoint.sh"]