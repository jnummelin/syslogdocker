#!/bin/sh -e

LOG_TO_LOGSEME=1
LOG_TO_REMOTE_SYSLOG=1

REMOTE_SYSLOG_PORT=${REMOTE_SYSLOG_PORT:-514}

if [ "${LOGSENE_APP_TOKEN}" = "" ] ; then
    echo "Warning: environment variable LOGSENE_APP_TOKEN must be set to your Logsene App Token"
    echo "Disabling remote logging to Logseme"
    LOG_TO_LOGSEME=0
fi

if [ "${LOGSENE_SYSLOG_HOST}" = "" ] ; then
    echo "Warning: environment variable LOGSENE_SYSLOG_HOST must be set to your Logsene Remote Syslog Host"
    echo "Disabling remote logging to Logseme"
    LOG_TO_LOGSEME=0
fi

if [ "${REMOTE_SYSLOG_HOST}" = "" ] ; then
    echo "Info: not logging to remote syslog, environment variable REMOTE_SYSLOG_HOST not set."
    LOG_TO_REMOTE_SYSLOG=0
fi



if [ "${LOG_TO_LOGSEME}" = "1" ] ; then
    # LOGSENE_APP_TOKEN
    echo '$template LogseneFormat,"<%PRI%>%TIMEREPORTED:::date-rfc3339% %HOSTNAME% %syslogtag%@cee: {\"logsene-app-token\": \"'"${LOGSENE_APP_TOKEN}"'\", \"message\": \"%msg:::json%\"}\\n"' > /etc/rsyslog.d/99-log-to-logsene.conf
    # LOGSENE_SYSLOG_HOST
    echo "*.* @@(o)${LOGSENE_SYSLOG_HOST};LogseneFormat" >> /etc/rsyslog.d/99-log-to-logsene.conf
fi


if [ "${READ_FROM_JOURNALD}" = "1" ] ; then
    # read from systemd-journald 
    # requires the following in /etc/systemd/journal.conf.d/99-forward-to-syslog.conf
    # [Journal]
    # ForwardToSyslog=yes
    if [ -d /run/systemd/journal ] ; then
        # requires $ModLoad imuxsock, but is already default in /etc/rsyslog.conf
        echo '$AddUnixListenSocket /run/systemd/journal/syslog' > /etc/rsyslog.d/98-read-from-journal.conf
    fi
fi


if [ "${LOG_TO_REMOTE_SYSLOG}" = "1" ] ; then
    TCP_PROTO="@@"
    UDP_PROTO="@"
    SYSLOG_PROTO="${UDP_PROTO}"
    if [ "${REMOTE_SYSLOG_PROTO}" = "tcp" ] ; then
        SYSLOG_PROTO="${TCP_PROTO}"
    fi
    echo "*.*   ${SYSLOG_PROTO}${REMOTE_SYSLOG_HOST}:${REMOTE_SYSLOG_PORT}" > /etc/rsyslog.d/99-forward-to-other-syslog.conf
fi

rsyslogd -n
