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



if [ "${LOG_TO_REMOTE_SYSLOG}" = "1" ] ; then
    echo "*.*   @${REMOTE_SYSLOG_HOST}:${REMOTE_SYSLOG_PORT}" > /etc/rsyslog.d/99-forward-to-other-syslog-over-udp.conf
fi

rsyslogd -n
