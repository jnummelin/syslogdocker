# One syslog to rule them all

1. Build the syslog container: 

   `docker build -t syslog .`

2. Monitor the logs: 

   `docker run --volumes-from syslog ubuntu tail -f /var/log/syslog`
   
3. Run it: 

   `docker run  --name syslog -d -v /tmp/syslogdev:/dev syslog`

   allow syslogging from localhost over UDP (eg: port 1514):

   `docker run  --name syslog -d -v /tmp/syslogdev:/dev -p 127.0.0.1:1514:514/udp syslog`

4. Start another container to send logs:

   `docker run -v /tmp/syslogdev/log:/dev/log ubuntu logger hello`


5. *Alternative to #2*, as of docker v1.3 use the `docker-exec` command to inspect syslog container directly, after some logs have been generated
    
    `docker exec -t syslog tail -f /var/log/syslog`

5. See in the log message show up in the "tail" container.


6. Logging to SemaText's Logsene service:

   To log to remote [Logsene](http://sematext.com/logsene/) service, run with these environment variables:
   * `LOGSENE_SYSLOG_HOST` - remote hostname, usually: `logsene-receiver-syslog.sematext.com`
   * `LOGSENE_APP_TOKEN` - your Logsene application token

   `docker run  --name syslog -d -v /tmp/syslogdev:/dev -e LOGSENE_SYSLOG_HOST=logsene-receiver-syslog.sematext.com -e LOGSENE_APP_TOKEN=<your token> -p 127.0.0.1:1514:514/udp syslog`

## Background

For more information on this approach, see [Multiple Docker containers logging to a single syslog](http://jpetazzo.github.io/2014/08/24/syslog-docker/).
