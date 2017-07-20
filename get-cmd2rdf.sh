#!/bin/sh

if [ $CMD2RDF_SRC = "git" ]; then
	git clone https://github.com/TheLanguageArchive/CMD2RDF.git
else
	$CMD2RDF_SRC
fi
