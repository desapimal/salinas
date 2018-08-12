#! /bin/bash


##=====Estas lineas se omiten debido a que causan problemas como lo ocurrido con digitalizacion====## 

				#=====Editando /etc/login.defs=====

#echo "  [ /etc/login.defs ]        "
#echo "  [ Editando lineas: PASS_MAX_DAYS | PASS_MIN_DAYS | PASS_MIN_LEN | PASS_WARN_AGE ] "

#sed -i s/"PASS_MAX_DAYS	[0-9]*$"/"PASS_MAX_DAYS	90"/	/etc/login.defs
#sed -i s/"PASS_MIN_DAYS	[0-9]*$"/"PASS_MIN_DAYS	0"/	/etc/login.defs
#sed -i s/"PASS_MIN_LEN	[0-9]*$"/"PASS_MIN_LEN	15"/	/etc/login.defs
#sed -i s/"PASS_WARN_AGE	[0-9]*$"/"PASS_WARN_AGE	15"/	/etc/login.defs
#echo " "
#echo "			=====> Listo <====="
#echo " "

##==================================================================================================##


echo "  [ Cambiando permisos a 600 /etc/login.defs ]        "
chmod 600 /etc/login.defs
chown root:root /etc/login.defs
echo " "
echo "			=====> Listo <====="
echo " "

echo "  [ /var/log/wtmp ]        "
echo "  [ Cambiando permisos a 644 /var/log/wtmp ]        "
chmod 644 /var/log/wtmp
echo " "
echo "			=====> Listo <====="
echo " "

echo "  [ /etc/hosts.allow ]        "
echo "  [ Cambiando permisos a 640 /etc/hosts.allow ]        "
chmod 750 /etc/hosts.allow
echo " "
echo "			=====> Listo <====="
echo " "

echo "  [ /etc/xinetd.d/* ]        "
echo "  [ Cambiando permisos a 600  /etc/xinetd.d/* ]        "
chmod  600  /etc/xinetd.d/*
echo " "
echo "			=====> Listo <====="
echo " "

echo "  [ Deshabilitando servicios ]        "
services=(cups sendmail bluetooth hplip postfix autofs atd ip6tables rhnsd nfs nfslock rpcgssd rpcidmapd rpcbind rpcsvcgssd rhsmcertd rlogin rsh rexec )
	for i in "${services[@]}"; do
        	activo=$(chkconfig --list | grep  $i | grep -e 3:on -e 5:on -e 3:activo -e 5:activo )
        	if [ -z "$activo" ]; then
                	echo " El servicio $i NO existe o ya esta desactivado."
        	else
                	echo " El servicio $i existe y se desactivara."
                	chkconfig $i off
        	fi
	done
echo " "
echo "			=====> Listo <====="
echo " "
#=====Editando /etc/ssh/sshd_config=====
echo "  [ /etc/ssh/sshd_config ]        "
echo "  [ Editando lineas: Protocol | PermitRootLogin | SysLogFacility | LogLevel | PubkeyAuthentication ] "

echo "  [ /etc/ssh/sshd_config ]        "
echo "  [ Editando lineas: Protocol | PermitRootLogin | SysLogFacility | LogLevel | PubkeyAuthentication ] "

sed -i s/".Protocol [0-9]*$"/"Protocol 2"/g /etc/ssh/sshd_config
sed -i s/"Protocol [0-9]*$"/"Protocol 2"/g /etc/ssh/sshd_config

sed -i s/".PermitRootLogin [a-z]*$"/"PermitRootLogin yes"/g /etc/ssh/sshd_config
sed -i s/"PermitRootLogin [a-z]*$"/"PermitRootLogin yes"/g /etc/ssh/sshd_config

sed -i s/".SyslogFacility AUTH"/"SyslogFacility AUTH"/g /etc/ssh/sshd_config
sed -i s/"SyslogFacility AUTHPRIV"/"#SyslogFacility AUTHPRIV"/g /etc/ssh/sshd_config

sed -i s/".LogLevel INFO"/"LogLevel INFO"/g /etc/ssh/sshd_config

sed -i s/".PubkeyAuthentication [a-z]*$"/"PubkeyAuthentication yes"/g /etc/ssh/sshd_config
sed -i s/"PubkeyAuthentication [a-z]*$"/"PubkeyAuthentication yes"/g /etc/ssh/sshd_config
echo " "
echo "			=====> Listo <====="
echo " "
echo "  [ Eliminando usuario uucp y games]        "
userdel -f -r uucp
userdel -f -r games
echo " "
echo "			=====> Listo <====="
echo " "

##=====Estas lineas se omiten debido a que causan problemas como lo ocurrido con digitalizacion====##

#echo "  [ Recordar ultimas 5 Contrasenas]        "
#sed -i '/password    sufficient    pam_unix.so/d' /etc/pam.d/system-auth
#sed -i '14i password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok remember=5' /etc/pam.d/system-auth
#echo " "
#echo "                  =====> Listo <====="
#echo " "


#echo "  [ Forzando password alfanumerico]        "
#sed -i '/password    requisite     pam_cracklib.so/d' /etc/pam.d/system-auth
#sed -i '14i password    requisite     pam_cracklib.so try_first_pass retry=3 type= ucredit=0 lcredit=0 dcredit=-1 ocredit=-1' /etc/pam.d/system-auth
#echo " "
#echo "                  =====> Listo <====="
#echo " "

##==================================================================================================##

echo "Configurando el sistema de logs de audit.log para registrar eventos de usuario: eliminar, crear y modificar"
auditctl -w /etc/passwd -p wa -k passwd_changes
echo " "
echo "			=====> Listo <====="
echo " "


echo "El archivo /etc/services o equivalente es propiedad de root y tiene establecidos los permisos 644"
chown root:root /etc/services
chmod 600  /etc/services
echo " "
echo "                  =====> Listo <====="
echo " "

echo "Eliminando /etc/hosts.equiv"
rm -rf /etc/hosts.equiv
echo " "
echo "                  =====> Listo <====="
echo " "


echo "Agregar los parámetros "-f LOCAL5 -l INFO" al subsistema de SFTP"
sed -i '/sftp-server/d' /etc/ssh/sshd_config
sed -i '133i Subsystem       sftp    /usr/libexec/openssh/sftp-server -f LOCAL5 -l INFO' /etc/ssh/sshd_config
echo " "
echo "                  =====> Listo <====="
echo " "


echo "Checar actualizaciones y parches de seguridad de Red Hat"
echo "---------- yum check-update --security ----------------------" > salida_parches_seguridad.txt
yum check-update --security >> salida_parches_seguridad.txt
echo "-------------- yum check-update -----------------" >> salida_parches_seguridad.txt
yum check-update >> salida_parches_seguridad.txt

echo " "
echo "			=====> Listo <====="
echo " "

echo "Cambiar permisos a 600 de /etc/security"
chown root:root /etc/security
chmod 600 /etc/security
echo " "
echo "			=====> Listo <====="
echo " "

echo "Borrando Banner"
> /etc/motd
echo Cyber >> /etc/motd
echo " "
echo "                  =====> Listo <====="

echo "Agregando local5.* a /etc/rsyslog.conf"
sed -i '/sftpd.log/d' /etc/rsyslog.conf
sed -i '61i local5.*                        /var/log/sftpd.log ' /etc/rsyslog.conf
echo " "
echo "                  =====> Listo <====="

#echo "Cambiar permisos a la carpeta /etc/rc*"

#chmod 640 /etc/rc
#chmod 640 /etc/rc0.d
#chmod 640 /etc/rc1.d
#chmod 640 /etc/rc2.d
#chmod 640 /etc/rc3.d
#chmod 640 /etc/rc4.d
#chmod 640 /etc/rc5.d
#chmod 640 /etc/rc6.d
#chmod 640 /etc/rc.local
#chmod 640 /etc/rc.sysinit

##==Agrega los usuarios s los que les va a permitir ==##

echo "Agregando ==AllowUsers ssh=="
echo " "

echo "AllowUsers b755236@term-ux?? b708700@term-ux?? b780919@term-ux?? b923430@term-ux?? b925442@term-ux?? b936196@term-ux?? b937777@term-ux?? b253861@term-ux?? b766998@term-ux?? b280667@term-ux?? b666268@term-ux?? b180683@term-ux?? b199550@term-ux?? b209097@term-ux?? b291457@term-ux?? b296510@term-ux?? b312527@term-ux?? b318015@term-ux?? b329465@term-ux?? b320831@term-ux?? b330578@term-ux?? b333289@term-ux?? b178308@term-ux?? b315458@term-ux?? b318100@term-ux?? b323426@term-ux?? b329465@term-ux?? b330578@term-ux?? b333289@term-ux?? b346337@term-ux?? b347415@term-ux?? b347550@term-ux?? scom@term-scom?? usrmon@term-usrmon??" >> /etc/ssh/sshd_config

echo "Reiniciando servicio sshd"
service sshd restart
echo " "
echo "                  =====> Listo <====="


echo "
#UNIX
10.50.166.52    term-ux01
10.50.166.53    term-ux02
10.50.166.54    term-ux03
10.50.166.55    term-ux04
10.50.166.56    term-ux05
10.50.166.57    term-ux06
10.50.166.58    term-ux07
10.50.166.59    term-ux08
10.50.166.60    term-ux09
10.50.166.61    term-ux10
10.50.166.62    term-ux11
10.50.166.138	term-ux12
10.50.166.139   term-ux13

#Mon USRMON
10.50.167.76	term-usrmon01
10.63.20.147	term-usrmon02
10.63.50.161	term-usrmon03
10.50.166.16	term-usrmon04
10.63.100.108	term-usrmon05
10.53.28.170	term-usrmon06
10.53.28.171	term-usrmon07
10.53.28.172	term-usrmon08
10.63.50.41	term-usrmon09
10.53.34.83	term-usrmon10
10.53.34.188	term-usrmon11
10.63.33.97	term-usrmon12
10.53.34.76	term-usrmon13

#Mon SCOM
10.50.166.42    term-scom01
10.50.166.43    term-scom02
10.50.166.45    term-scom03
10.50.166.48    term-scom04
10.50.166.72    term-scom05
10.50.166.169   term-scom06
10.63.150.234   term-scom07
10.53.34.49	term-scom08
10.53.34.54	term-scom09
10.53.34.52	term-scom10
10.53.34.58	term-scom11

#Cyberark
10.50.158.43	term-cyber01
10.50.158.45	term-cyber02
10.64.16.173	term-cyber03
10.64.16.175	term-cyber04
10.50.158.74	term-cyber05
10.64.248.31	term-cyber06

" >> /etc/hosts

#Agregar entradas de Iptables al Cyberark

sed -i "/\# Bloqueamos TODO lo no explicitamente permitido/i\# IPs Cyberark\n\
-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp -s 10.50.158.43 -m multiport --ports 22 -j ACCEPT\n\
-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp -s 10.50.158.45 -m multiport --ports 22 -j ACCEPT\n\
-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp -s 10.50.158.74 -m multiport --ports 22 -j ACCEPT\n\
-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp -s 10.64.16.173 -m multiport --ports 22 -j ACCEPT\n\
-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp -s 10.64.16.175 -m multiport --ports 22 -j ACCEPT\n\
-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp -s 10.64.248.31 -m multiport --ports 22 -j ACCEPT\n\
" /etc/sysconfig/iptables

sed -i '/\# IPs Cyberar/{x;p;x;G}' /etc/sysconfig/iptables

### Configuracion de Sudo
sed -i "/\# User alias specification/a\User_Alias CYBERARK= app_care,emgcyaal" /etc/sudoers
sed -i "/\# User privilege specification/a\CYBERARK ALL =NOPASSWD:/usr/bin/passwd*" /etc/sudoers
