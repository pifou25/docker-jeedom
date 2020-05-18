FROM debian:9

LABEL version="jeedom v4-buster-1.0"

ENV SHELL_ROOT_PASSWORD password
ENV MYSQL_ROOT_PASSWD mysql-password

# Installation des paquets
# 	ccze : couleur pour les logs
# 	wget : téléchargement
# 	openssh-server : serveur ssh

RUN apt-get update && apt-get install -y \
	apt-utils \
	wget \
	ntp \
	openssh-server \
	locales \
	ccze \
	nano


# Serveur SSH
RUN mkdir /var/run/sshd
RUN echo "root:${SHELL_ROOT_PASSWORD}" | chpasswd && \
	sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
	sed -ri 's/^#?Port 22/Port 22/' /etc/ssh/sshd_config
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

# Initialisation 
ADD install/OS_specific/Docker/init.sh /root/init.sh
RUN chmod +x /root/init.sh
CMD ["sh", "/root/init.sh"]
