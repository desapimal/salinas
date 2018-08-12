#/bin/bash
mkdir Certifi-servicios
cd  Certifi-servicios

cp /etc/hosts .
cp /etc/ssh/sshd_config .
cp /etc/sysconfig/iptables .
cp /etc/fstab .



echo "############################################# SERVICIOS ACTIVOS #################################################################################" >> Certifi-servicios.txt
echo " "
echo "============================================== HOSTNAME =======================================" >> Certifi-servicios.txt
hostname >> Certifi-servicios.txt
echo " "
echo "============================================== IP SERVER ======================================" >> Certifi-servicios.txt
ip a | grep 10 >> Certifi-servicios.txt
echo " "
echo "============================================== SERVICIO IPTABLES ==============================" >> Certifi-servicios.txt
service iptables status >> Certifi-servicios.txt
echo " "
echo "============================================== FILESYSTEM MONTADOS ==============================" >> Certifi-servicios.txt
df -h >> Certifi-servicios.txt
echo " "
echo "============================================== SERVICIOS ACTIVOS ==============================" >> Certifi-servicios.txt
chkconfig --list | grep 5:on >> Certifi-servicios.txt
echo " "
echo "============================================== SERVICIOS NFS ==================================" >> Certifi-servicios.txt
chkconfig | grep nfs >> Certifi-servicios.txt
echo " "
echo "============================================== SERVICIOS JAVA =================================" >> Certifi-servicios.txt
ps -fea | grep java >> Certifi-servicios.txt
echo " "
echo "============================================== SERVICIOS JBOSS/GLASSFISH/APACHE TOMCAT=========" >> Certifi-servicios.txt
ps -fea | grep jboss >> Certifi-servicios.txt
echo " "
echo "============================================== SERVICIOS APACHE ===============================" >> Certifi-servicios.txt
ps -fea | grep http >> Certifi-servicios.txt
echo " "
echo "============================================== SERVICIOS CONTROL-M ============================" >> Certifi-servicios.txt
ps -fea | grep cmagt >> Certifi-servicios.txt
echo " "
echo "============================================== INSTANCIA BD (Solo Base de datos) ==============" >> Certifi-servicios.txt
ps -fea | grep smon >> Certifi-servicios.txt
echo " "
echo "===============================================================================================" >> Certifi-servicios.txt
ps -fea | grep pmon >> Certifi-servicios.txt
echo " "
echo "============================================== CRS (Solo Base de Datos) =======================" >> Certifi-servicios.txt
ps -fea |grep d.bin >> Certifi-servicios.txt
echo " "
echo "============================================== PUNTO DE MONTAJE ===============================" >> Certifi-servicios.txt
mount >> Certifi-servicios.txt
echo " "
echo "===============================================================================================" >> Certifi-servicios.txt
#su - glassv3
#/opt/glassfishv3/glassfish/bin/asadmin list-instances

echo "############################################### FIN DE LOS SERVICIOS ############################################################################" >> Certifi-servicios.txt


mv Certifi-servicios.txt Certifi-servicios1.txt
