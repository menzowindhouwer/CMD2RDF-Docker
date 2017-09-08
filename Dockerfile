FROM openlink/vos:v0

ENV CMD2RDF_SRC  git
ENV CMD2RDF_HOST http://192.168.99.100:8080
ENV CMD2RDF_HOME /app

RUN mkdir -p /opt/virtuoso-opensource/var/lib/virtuoso/db
ADD virtuoso.ini /opt/virtuoso-opensource/var/lib/virtuoso/db/virtuoso.ini

RUN apt-get -y update && \
  apt-get -y clean && \
  apt-get -y install supervisor default-jdk maven tomcat6 curl && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/*
  
# pacify tomcat6
RUN ln -s /var/lib/tomcat6/server /usr/share/tomcat6/
RUN ln -s /var/lib/tomcat6/shared /usr/share/tomcat6/

# startup scripts
ADD start-tomcat6.sh /start-tomcat6.sh
ADD supervisord-tomcat6.conf /etc/supervisor/conf.d/supervisord-tomcat6.conf
  
ADD start-virtuoso.sh /start-virtuoso.sh
ADD supervisord-virtuoso.conf /etc/supervisor/conf.d/supervisord-virtuoso.conf

ADD run.sh /run.sh
RUN chmod 755 /*.sh

# make the directory structure
RUN mkdir -p /app/src && \
    mkdir -p /app/data && \
    mkdir -p /app/work && \
    mkdir -p /app/work/harvester && \
    mkdir -p /app/work/profiles-cache && \
    mkdir -p /app/work/rdf-output && \
    mkdir -p /app/work/rdf-output/temp && \
    mkdir -p /app/ld

# add the linked data sets showcasing enrichment    
ADD ld/* /app/ld/
RUN chmod 755 /app/ld/*.sh
  
# prime the maven cache with elda
WORKDIR /app/src
RUN git clone https://github.com/epimorphics/elda.git
WORKDIR /app/src/elda
RUN git checkout tags/elda-1.3.1
RUN mvn clean install

# checkout and compile cmd2rdf
#RUN git clone https://github.com/TheLanguageArchive/CMD2RDF.git
ADD get-cmd2rdf.sh /app
RUN chmod +x /app/get-cmd2rdf.sh
WORKDIR /app/src
RUN  /app/get-cmd2rdf.sh
RUN sed -i "s|/app|$CMD2RDF_HOME|g" /app/src/CMD2RDF/webapps/src/main/webapp/WEB-INF/web.xml
RUN sed -i "s|/app|$CMD2RDF_HOME|g" /app/src/CMD2RDF/batch/src/main/resources/cmd2rdf.xml
RUN sed -i "s|http://localhost:8080|$CMD2RDF_HOST|g" /app/src/CMD2RDF/batch/src/main/resources/cmd2rdf.xml
RUN sed -i "s|http://192.168.99.100:8080|$CMD2RDF_HOST|g" /app/src/CMD2RDF/lda/src/main/webapp/specs/cmd2rdf-lda.ttl
RUN rm /app/get-cmd2rdf.sh
WORKDIR /app/src/CMD2RDF
RUN mvn clean install
# once more to create webapps/target//Cmd2RdfPageHeader.properties
RUN mvn install
# install the WARs
RUN cp /app/src/CMD2RDF/webapps/target/cmd2rdf.war /var/lib/tomcat6/webapps
RUN cp /app/src/CMD2RDF/lda/target/cmd2rdf-lda.war /var/lib/tomcat6/webapps

# install the script to import CMD records
ADD cmd2rdf-init.sh /app/cmd2rdf-init.sh
ADD cmd2rdf-cron.sh /app/cmd2rdf-cron.sh
ADD cmd2rdf-run.sh /app/cmd2rdf-run.sh
RUN chmod 755 /app/*.sh

EXPOSE 1111
EXPOSE 8890
EXPOSE 8080

WORKDIR /app
CMD ["/run.sh"]
