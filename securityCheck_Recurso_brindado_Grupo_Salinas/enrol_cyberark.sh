#!/bin/bash

NUM_ALLOWUSR=`grep -n AllowUsers /etc/ssh/sshd_config |awk -F: '{print $1}' `

#############################################
###             USUARIO	                #####
#############################################

echo " Creando Grupos ... "

groupadd -g 700 emgcyaal
groupadd -g 701 app_care

echo " Creando Usuarios ..."

adduser -m emgcyaal  -c "emgcyaal" -u 700 -g 700;
adduser -m app_care  -c "app_care" -u 701 -g 701;

echo " Asignando password --P@ssW0rd-- a los usuarios emgcyaal y app_care ..."
echo P@ssW0rd | passwd --stdin emgcyaal;
echo P@ssW0rd | passwd --stdin app_care;

#############################################
###  		SSH			#####
#############################################

echo " =====Editando /etc/ssh/sshd_config===== "
echo "  [ /etc/ssh/sshd_config ]        "
echo "  [ Editando lineas: PermitRootLogin ] "
#sed -i s/".PermitRootLogin [a-z]*$"/"PermitRootLogin yes"/g /etc/ssh/sshd_config
sed -i s/"PermitRootLogin [a-z]*$"/"PermitRootLogin yes"/g /etc/ssh/sshd_config
echo " "
echo "			=====> Listo <====="
echo " "
#==Agrega los usuarios  los que les va a permitir ==#
echo "Agregando ==AllowUsers ssh== \n"


if [ -n "$NUM_ALLOWUSR" ]; then

sed -i "$NUM_ALLOWUSR s|$| root@10.50.158.43 root@10.50.158.45 root@10.50.158.74 root@10.64.16.173 root@10.64.16.175 root@10.64.248.31 emgcyaal@10.50.158.43 emgcyaal@10.50.158.45 emgcyaal@10.50.158.74 emgcyaal@10.64.16.173 emgcyaal@10.64.16.175 emgcyaal@10.64.248.31 app_care@10.50.158.43 app_care@10.50.158.45 app_care@10.50.158.74 app_care@10.64.16.173 app_care@10.64.16.175 app_care@10.64.248.31|" /etc/ssh/sshd_config


echo "Reiniciando servicio sshd"


service sshd restart

echo " "
echo "                  =====> Listo <====="

else

echo " No hay variable AllowUsers"

fi

##################################################
###      	IPTABLES		       ###
##################################################

echo " Agregar entradas de Iptables al Cyberark ..."

sed -i "/\# Bloqueamos TODO lo no explicitamente permitido/i\# IPs Cyberark\n\
-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp -s 10.50.158.43 -m multiport --ports 22 -j ACCEPT\n\
-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp -s 10.50.158.45 -m multiport --ports 22 -j ACCEPT\n\
-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp -s 10.50.158.74 -m multiport --ports 22 -j ACCEPT\n\
-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp -s 10.64.16.173 -m multiport --ports 22 -j ACCEPT\n\
-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp -s 10.64.16.175 -m multiport --ports 22 -j ACCEPT\n\
-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp -s 10.64.248.31 -m multiport --ports 22 -j ACCEPT\n\
" /etc/sysconfig/iptables

#Aplicando el cambio al archivo /etc/sysconfig/iptables

sed -i "/\# IPs Cyberark/{x;p;x;G}" /etc/sysconfig/iptables

echo "Reiniciando servicio iptables"
service iptables stop;
service iptables start;
echo " "
echo "                  =====> Listo <====="

##################################################
###             SUDO			       ###
##################################################

echo " Configuracion de Sudo ... "

#sed -i "/\# User alias specification/a\User_Alias CYBERARK= app_care,emgcyaal" /etc/sudoers
#sed -i "/\# User privilege specification/a\CYBERARK ALL =NOPASSWD:/usr/bin/passwd*" /etc/sudoers

echo "" >> /etc/sudoers
echo "User_Alias CYBERARK= app_care,emgcyaal" >> /etc/sudoers
echo "CYBERARK ALL =NOPASSWD:/usr/bin/passwd*" >> /etc/sudoers

echo " "
echo "  =====> Listo <====="
