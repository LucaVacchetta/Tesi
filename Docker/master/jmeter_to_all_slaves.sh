#!/bin/sh

# With awk script retrieve all IPs addresses of slaves, and insert them in an string
line_to_replace="remote_hosts="`etcdctl ls | awk '{print $0","}' | awk '{ gsub("/",""); print $1 }' |  tr -d '\n\r' | awk '{gsub(/,$/,""); print}'`

# With another awk script replace the in jmeter configuration in order to insert all IPs addresses of slaves
awk -v newline="$line_to_replace" '{ if (NR == 232) print newline; else print $0}' $JMETER_HOME/bin/jmeter.properties > /tmp/jmeter.properties
mv /tmp/jmeter.properties $JMETER_HOME/bin/jmeter.properties

# Now launch the real jmeter commmand
command="/jmeter/apache-jmeter-2.13/bin/jmeter"
$command $@

