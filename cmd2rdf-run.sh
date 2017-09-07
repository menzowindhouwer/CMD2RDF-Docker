#!/bin/sh

java -Xms1g -Xmx2g -XX:PermSize=256m -XX:MaxPermSize=512m \
  -jar /app/src/CMD2RDF/batch/target/Cmd2rdf.jar \
  /app/src/CMD2RDF/batch/src/main/resources/cmd2rdf.xml