#!/bin/sh
export PATH=$JBOSS_HOME/bin:$PATH

# Determine JBoss configuration (parse environment variables)
if [ -z "$JBOSS_USER" ]; then
    JBOSS_USER=jboss
fi
if [ -z "$JBOSS_PASSWORD" ]; then
    JBOSS_PASSWORD=Passw0rd!
fi
if [ -z "$JBOSS_MODE" ]; then
    JBOSS_MODE=standalone
fi
if [ -z "$JBOSS_CONFIG" ]; then
    JBOSS_CONFIG=$JBOSS_MODE.xml
fi

echo "Starting EAP in $JBOSS_MODE mode with $JBOSS_CONFIG as config file"

if [ $JBOSS_MODE != "domain" ] && [ $JBOSS_MODE != "standalone" ]; then
    echo "JBOSS_MODE should be domain or standalone"
    exit 1
fi

$JBOSS_HOME/bin/add-user.sh -s -u $JBOSS_USER -p $JBOSS_PASSWORD

# add opts like debug and memory check

$JBOSS_HOME/bin/$JBOSS_MODE.sh -b 0.0.0.0 -bmanagement 0.0.0.0 -c $JBOSS_CONFIG 2>&1