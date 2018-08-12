#!/bin/bash
ORACLEASM_SCAN=`grep "^ORACLEASM_SCANORDER" /etc/sysconfig/oracleasm`
echo $ORACLEASM_SCAN
if [[ -z "$ORACLEASM_SCAN" ]];
then
echo "ORACLEASM_SCANORDER=\"emcpower\"" >> /etc/sysconfig/oracleasm
echo "ORACLEASM_SCANEXCLUDE=\"sd\"" >> /etc/sysconfig/oracleasm
else
sed -i 's/ORACLEASM_SCANORDER=.*/ORACLEASM_SCANORDER=\"emcpower\"/g' /etc/sysconfig/oracleasm-_dev_oracleasm
sed -i 's/ORACLEASM_SCANEXCLUDE=.*/ORACLEASM_SCANEXCLUDE=\"sd\"/g' /etc/sysconfig/oracleasm-_dev_oracleasm
fi
