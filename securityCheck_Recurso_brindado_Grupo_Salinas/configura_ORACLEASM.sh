#!/bib/bash

yum install -y kmod-oracleasm expect
yum localinstall -y oracleasmlib-2.0.4-1.el6.x86_64.rpm oracleasm-support-2.1.8-1.el6.x86_64.rpm

#sed -i 's/ORACLEASM_ENABLED\=.*/ORACLEASM_ENABLED=true/g' /etc/sysconfig/oracleasm
#sed -i 's/ORACLEASM_UID\=.*/ORACLEASM_UID=grid/g' /etc/sysconfig/oracleasm
#sed -i 's/ORACLEASM_GID\=.*/ORACLEASM_GID=asmadmin/g' /etc/sysconfig/oracleasm


/usr/bin/expect << EOF
spawn /etc/init.d/oracleasm configure
expect "Default user to own the driver interface \[grid\]: " 
send "grid\r"
expect "Default group to own the driver interface \[asmadmin\]: "
send "asmadmin\r"
expect "Start Oracle ASM library driver on boot \(y\/n\) \[y\]: "
send "y\r"
expect "Scan for Oracle ASM disks on boot \(y\/n\) \[y\]: "
send "y\r"
expect << EOF
