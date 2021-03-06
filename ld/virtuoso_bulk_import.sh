#!/bin/sh
echo "Executing bulk loader script."
echo "Virtuoso home directory: $VIRT_HOME"
echo "port: 1111"
echo "username: dba"
echo "password: dba"
echo "rdf directory: /app/ld"
$VIRT_HOME/bin/isql 1111 dba dba exec="ld_dir_all('/app/ld', '*.n3', 'http://eko.indarto/eko.rdf');"
$VIRT_HOME/bin/isql 1111 dba dba exec="ld_dir_all('/app/ld', '*.rdf', 'http://eko.indarto/eko.rdf');"
$VIRT_HOME/bin/isql 1111 dba dba exec="rdf_loader_run();"
$VIRT_HOME/bin/isql 1111 dba dba exec="checkpoint;"
echo "Bulk loader: Finish."
