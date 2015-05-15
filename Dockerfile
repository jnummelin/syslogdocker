FROM ubuntu:14.04
RUN apt-get update -q
RUN apt-get install rsyslog
RUN echo "\$ModLoad imudp" > /etc/rsyslog.d/99-enable-udp-input.conf && \
    echo "\$UDPServerRun 514" >> /etc/rsyslog.d/99-enable-udp-input.conf && \
    sed -i /etc/rsyslog.d/50-default.conf -e '/^daemon\.\*;mail\./,/xconsole$/ s|^|#|' && \
    sed -i /etc/rsyslog.conf -e '/^.ModLoad imklog/ s|^|#|' && \
    sed -i /etc/rsyslog.conf -e '/^.KLogPermitNonKernelFacility/ s|^|#|' && \
    :
CMD rsyslogd -n
VOLUME /dev
VOLUME /var/log
EXPOSE 514
