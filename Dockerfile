FROM openlink/vos:v0

RUN mkdir -p /opt/virtuoso-opensource/var/lib/virtuoso/db
ADD virtuoso.ini /opt/virtuoso-opensource/var/lib/virtuoso/db/virtuoso.ini

RUN apt-get -y update && \
  apt-get -y clean && \
  apt-get -y install supervisor default-jdk maven tomcat6 && \
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
WORKDIR /app/src
RUN git clone https://github.com/TheLanguageArchive/CMD2RDF.git
ADD cmd2rdf.xml /app/src/CMD2RDF/batch/src/main/resources/cmd2rdf.xml
ADD web.xml /app/src/CMD2RDF/webapps/src/main/webapp/WEB-INF/web.xml
ADD BrowsePage.java /app/src/CMD2RDF/webapps/src/main/java/nl/knaw/dans/cmd2rdf/webapps/ui/pages/BrowsePage.java
ADD Cmd2RdfPageHeader.html /app/src/CMD2RDF/webapps/src/main/java/nl/knaw/dans/cmd2rdf/webapps/ui/Cmd2RdfPageHeader.html
ADD HowItWorkPage.html /app/src/CMD2RDF/webapps/src/main/java/nl/knaw/dans/cmd2rdf/webapps/ui/pages/HowItWorkPage.html
ADD ApiPage.html /app/src/CMD2RDF/webapps/src/main/java/nl/knaw/dans/cmd2rdf/webapps/ui/pages/ApiPage.html
ADD cmd2rdf-lda.ttl /app/src/CMD2RDF/lda/src/main/webapp/specs/cmd2rdf-lda.ttl
WORKDIR /app/src/CMD2RDF
RUN mvn clean install
# once more to create webapps/target//Cmd2RdfPageHeader.properties
RUN mvn install
# install the WARs
RUN cp /app/src/CMD2RDF/webapps/target/cmd2rdf.war /var/lib/tomcat6/webapps
RUN cp /app/src/CMD2RDF/lda/target/cmd2rdf-lda.war /var/lib/tomcat6/webapps

# install the script to import CMD records
ADD cmd2rdf.sh /app/cmd2rdf.sh
RUN chmod 755 /app/cmd2rdf.sh

EXPOSE 1111
EXPOSE 8890
EXPOSE 8080

WORKDIR /app
CMD ["/run.sh"]
