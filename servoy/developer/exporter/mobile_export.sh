#!/bin/sh
# sample launch: ./mobile_export.sh -s servoy_sample_mobile -o /home/user/temp -data /home/user/servoy_workspace -verbose
# set path to eclipse folder. If the same folder as this script, use the default; otherwise, use /path/to/eclipse/
eclipsehome=`dirname $BASH_SOURCE`/..;

# get path to equinox jar inside $eclipsehome folder
cp=$(find $eclipsehome -name "org.eclipse.equinox.launcher_*.jar" | sort | tail -1);

# LAUNCH
java -Xms40m -Xmx512m -XX:MaxPermSize=256M -Djava.awt.headless=true -cp "$cp" org.eclipse.equinox.launcher.Main -application com.servoy.eclipse.exporter.mobile.application "$@"