#!/bin/sh -e

LOG_TO_LOGSEME=1

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

if [ "${LOG_TO_LOGSEME}" = "1" ] ; then
    # LOGSENE_APP_TOKEN
    echo '$template LogseneFormat,"<%PRI%>%TIMEREPORTED:::date-rfc3339% %HOSTNAME% %syslogtag%@cee: {\"logsene-app-token\": \"'"${LOGSENE_APP_TOKEN}"'\", \"message\": \"%msg:::json%\"}\\n"' > /etc/rsyslog.d/99-log-to-logsene.conf
    # LOGSENE_SYSLOG_HOST
    echo "*.* @@(o)${LOGSENE_SYSLOG_HOST};LogseneFormat" >> /etc/rsyslog.d/99-log-to-logsene.conf
fi

rsyslogd -n
