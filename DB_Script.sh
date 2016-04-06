#!/bin/bash

FILE="mobile_products.csv"
echo "Enter the password for database"
read system_pw
sqlplus -s ordermgmt/$system_pw@osmprod  <<EOF
SET PAGESIZE 50000
SET COLSEP ","
SET LINESIZE 3000
SET FEEDBACK OFF
SPOOL $FILE

SELECT * FROM MOBILE_PRODUCTS;
SPOOL OFF
EXIT
EOF