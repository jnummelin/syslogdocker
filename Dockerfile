FROM ubuntu:14.04
RUN apt-get update -q && apt-get install -y software-properties-common && add-apt-repository ppa:adiscon/v8-stable && apt-get update -q && apt-get install -y rsyslog
RUN echo "\$ModLoad imudp" > /etc/rsyslog.d/99-enable-udp-input.conf && \
    echo "\$UDPServerRun 514" >> /etc/rsyslog.d/99-enable-udp-input.conf && \
    echo "\$ModLoad imtcp" > /etc/rsyslog.d/99-enable-tcp-input.conf && \
    echo "\$InputTCPServerRun 514" >> /etc/rsyslog.d/99-enable-tcp-input.conf && \
    sed -i /etc/rsyslog.d/50-default.conf -e '/^daemon\.\*;mail\./,/xconsole$/ s|^|#|' && \
    sed -i /etc/rsyslog.conf -e '/^.ModLoad imklog/ s|^|#|' && \
    sed -i /etc/rsyslog.conf -e '/^.KLogPermitNonKernelFacility/ s|^|#|' && \
    :
ADD runrsyslog.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/runrsyslog.sh
CMD /usr/local/bin/runrsyslog.sh
VOLUME /dev
VOLUME /var/log
EXPOSE 514/udp 514/tcp
