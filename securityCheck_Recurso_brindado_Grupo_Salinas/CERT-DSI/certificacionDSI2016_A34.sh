#!/bin/bash
# SCRIPT PARA AUTOMATIZACION DE VERIFICACION CHECKLIST 2017-2018




#Funciones de verificacion
function puntos_generales {
#Autenticación y Administración de Accesos	
#1366
echo "****************************** Certificacion de Sistema Operativo ******************************" >> ${ArchSal}
DSID="SRV-1";
DSTZ1=":: Para usuarios personalizados obliga el cambio de contraseña al menos cada 90 días.";
DSTZ2="Establezca el valor '90' a la llave 'PASS_MAX_DAYS' en el archivo /etc/login.defs";
PASSMAXDAYS=$(cat /etc/login.defs | grep -v '^#' | grep 'PASS_MAX_DAYS' | awk '{print $2}')

if [[ $PASSMAXDAYS -gt 90 ]]; then
	echo $DSIT $DSID $GX $NC>> ${ArchSal}
	echo $DSTZ1 >> ${ArchSal}
	echo ":: :: PASS_MAX_DAYS "$PASSMAXDAYS  >> ${ArchSal}
	x1="$x1$DSID:$NC;";
	echo $DSIT $DSID >> ${PENDIENTES}
	echo $DSTZ2 >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
else
	echo $DSIT $DSID $GX $C>> ${ArchSal}
	echo $DSTZ1 >> ${ArchSal}
	x1="$x1$DSID:$C;"
fi
echo $tc >> ${ArchSal}

#1368
DSID="SRV-3"
ID1368L="::: Las cuentas de usuario de default, genéricas y de pruebas han sido eliminadas o deshabilitadas."

ID1368=$(cat /etc/passwd | grep -E 'games|ftp|uucp|nucp' | grep -v -E '/sbin/nologin|/usr/bin/false')

	if [[ $ID1368='' ]]; then
		echo ":: ID $DSID : $C" >> ${ArchSal}
		echo $ID1368L >> ${ArchSal}
		x1="$x1$DSID:$C;"
	else
		echo ":: ID $DSID : $NC" >> ${ArchSal}
		echo $ID1368L >> ${ArchSal}

		echo "Usuarios por dafaul:" >> ${ArchSal}
		echo $ID1368  >> ${ArchSal}

		echo "::: ID $DSID" >> ${PENDIENTES}
		echo "Deshabilite los siguientes usuarios"
		echo $ID1368 >> ${PENDIENTES}
		x1="$x1$DSID:$NC;"
	fi
echo "" >> ${ArchSal}

#1369
DSID="SRV-4"
ID1369L=":: Las contraseñas son de 15 caracteres mínimo, alfanuméricos y no son iguales al usuario.";
PASSMINLEN=$(cat /etc/login.defs | grep -v '^#' | grep 'PASS_MIN_LEN' | awk '{print $2}')

if [[ $PASSMINLEN -lt 15 ]]; then
	echo ":: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1369L >> ${ArchSal}
	echo "Establecer un valor mayor a '15' a la llave 'PASS_MIN_LEN' en el archivo /etc/login.defs" >> ${ArchSal}
	echo ":: :: PASS_MIN_LEN: $PASSMINLEN"  >> ${ArchSal}	
	
	x1=$x1'1369:1::'
	echo "::: ID $DSID" >> ${PENDIENTES}
	echo "Establecer un valor mayor a '15' a la llave 'PASS_MIN_LEN' en el archivo /etc/login.defs" >> ${PENDIENTES}
	echo ":: :: PASS_MIN_LEN: $PASSMINLEN"  >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
	x1="$x1$DSID:$NC;"
else 
	echo ":: ID $DSID : $C" >> ${ArchSal}
	echo $ID1369L >> ${ArchSal}
	x1="$x1$DSID:$C;"
fi
echo "" >> ${ArchSal}

#Seguirdad del Servidor
#1390
DSID="SRV-9"
if [[ $SS = '' ]]; then
		ID1390L=":: Solo se encuentran abiertos los puertos que requiere el sistema.";
		PUERTOS=`ss -a | grep LISTEN | grep -E ':13|:21|:23|:25|:37|:69|:79|:109|:110|:143|:512|:513|:9090|:4444|:12345|:ftp|:tftp|:finger|:telnet|:smtp|:postfix|:sendmail|:9090' | awk '{print $4}'`
		if [[ $PUERTOS = '' ]]; then
			echo "::: ID $DSID : $C" >> ${ArchSal}
			echo $ID1390L >> ${ArchSal}
			x1="$x1$DSID:$C;"
		else
			echo "::: ID $DSID : $NC" >> ${ArchSal}
			echo $ID1390L >> ${ArchSal}
			echo ":: :: Tiene los siguientes puertos vulnerables abiertos" >> ${ArchSal}
			ss -a | grep LISTEN | grep -E ':13|:21|:23|:25|:37|:69|:79|:109|:110|:143|:512|:513|:9090|:4444|:12345|:ftp|:tftp|:finger|:telnet|:smtp|:postfix|:sendmail|:9090' >> ${ArchSal}
			x1="$x1$DSID:$NC;"
			#PENDIENTES
			echo "::: ID $DSID" >> ${PENDIENTES}
			echo "Deshabilite los siguientes puertos, o justifique su uso" >> ${PENDIENTES}
			ss -a | grep LISTEN | grep -E ':13|:21|:23|:25|:37|:69|:79|:109|:110|:143|:512|:513|:9090|:4444|:12345|:ftp|:tftp|:finger|:telnet|:smtp|:postfix|:sendmail|:9090' >> ${PENDIENTES}
			echo '' >> ${PENDIENTES}
		fi
		echo "" >> ${ArchSal}

		PUERTOS2=`ss -a | grep LISTEN | grep -E ':80|:443|:1521|:3306|:5432|:8080|:8081' | awk '{print $4}'`
		if [[ $PUERTOS2 != '' ]]; then
			echo "" >> ${ArchSal}
			echo ":: :: Justificar por escrito a CSA DSI el uso de los siguientes puertos." >> ${ArchSal}
			ss -a | grep LISTEN | grep -E ':80|:443|:1521|:3306|:5432|:8080|:8081' >> ${ArchSal}
			echo "Justifique a DSI CSA el uso de los siguientes puertos" >> ${PENDIENTES}
			ss -a | grep LISTEN | grep -E ':80|:443|:1521|:3306|:5432|:8080|:8081' >> ${PENDIENTES}
		fi

		echo "" >> ${ArchSal}
		#---------------------------------
		DSID="SRV-46"
		ID1429L=":: Está deshabilitado el servicio TFTP/Finger";
		
		PUERTOSTFTP=`ss -a | grep LISTEN | grep -E ':69ftp|:tftp' | awk '{print $4}'`

		if [[ $PUERTOSTFTP = '' ]]; then

			echo "::: ID $DSID : $C" >> ${ArchSal}
			echo $ID1429L >> ${ArchSal}
			x1="$x1$DSID:$C;"
		else
			echo "::: ID $DSID : $NC" >> ${ArchSal}
			echo $ID1429L >> ${ArchSal}
			echo ":: :: Deshabilite el TFTP" >> ${ArchSal}
			ss -a | grep LISTEN | grep -E ':69|:tftp' >> ${ArchSal}
			x1="$x1$DSID:$NC;"
			#PENDIENTES
			echo "::: ID $DSID" >> ${PENDIENTES}
			echo "Deshabilite el TFTP" >> ${PENDIENTES}
			ss -a | grep LISTEN | grep -E ':69ftp|:tftp' >> ${PENDIENTES}
			echo '' >> ${PENDIENTES}
		fi
		echo "" >> ${ArchSal}

		#DSID="1430"
		#ID1430L=":: Está deshabilitado el servicio Finger";
		
		#PUERTOFINGER=`ss -a | grep LISTEN | grep -E ':69ftp|:tftp' | awk '{print $4}'`

		#if [[ $PUERTOFINGER = '' ]]; then

		#	echo "::: ID 1430 : $C" >> ${ArchSal}
		#	echo $ID1430L >> ${ArchSal}
		#	x1="$x1$DSID:$C;"
		#else

		#	echo "::: ID 1430 : $NC" >> ${ArchSal}
		#	echo $ID1430L >> ${ArchSal}
		#	echo ":: :: Deshabilite el servicio Finger" >> ${ArchSal}
		#	ss -a | grep LISTEN | grep -E ':79|:finger' >> ${ArchSal}
		#	x1="$x1$DSID:$NC;"
			#PENDIENTES
		#	echo "::: ID 1430" >> ${PENDIENTES}
		#	echo "Deshabilite el servicio Finger" >> ${PENDIENTES}
		#	ss -a | grep LISTEN | grep -E ':79ftp|:finger' >> ${PENDIENTES}
		#	echo '' >> ${PENDIENTES}
		#fi

		#echo "" >> ${ArchSal}

else
	x1="$x1""$DSID:$NC;"
fi

#1391 ----- revisar funcionalidad en redhat viejito
DSID="SRV-10"
ID1391L=":: Solo se encuentran habilitados los servicios que requiere el sistema.";
SERVICES='';

SERVICES1='';

if [[ $SYSTEMCTL -eq 1  ]]; then
	SERVICES1=$(systemctl list-unit-files | grep 'enabled' | grep -E 'ftp|smtp|rlogin|postfix|cups')
else
	SERVICES1=$(/sbin/chkconfig --list | grep '3:on' | grep -E 'ftp|smtp|rlogin|postfix|cups' | awk '{print $1}')
fi



if [[ $SERVICES1 = '' ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal};
	echo $ID1391L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal};
	echo $ID1391L >> ${ArchSal}
	echo ":: :: Tiene los siguientes servicios activos" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: ID $DSID" >> ${PENDIENTES}
	echo "Deshabilite los siguientes servicios:" >> ${PENDIENTES}
	if [[ $SYSTEMCTL -eq 1  ]]; then
		systemctl list-unit-files | grep 'enabled' | grep -E 'ftp|smtp|rlogin|postfix|cups' >> ${ArchSal}
		systemctl list-unit-files | grep 'enabled' | grep -E 'ftp|smtp|rlogin|postfix|cups' >> ${PENDIENTES}
	else
		/sbin/chkconfig --list | grep '3:on' | grep -E 'ftp|smtp|rlogin|postfix|cups' | awk '{print $1}' >> ${ArchSal}
		/sbin/chkconfig --list | grep '3:on' | grep -E 'ftp|smtp|rlogin|postfix|cups' | awk '{print $1}' >> ${PENDIENTES}
	fi
	echo "" >> ${PENDIENTES}
fi
echo "" >> ${ArchSal}

#1392
DSID="SRV-11"
if [[ $SS = '' ]]; then
		ID1392L=":: La Administración Remota del servidor se realiza a través de un medio encriptado robusto. (SSH, SFTP)";

		TELNET=$(ss -a | grep LISTEN | grep -E ':21|:23|:513|:ftp|:telnet|:rlogin' | awk '{print $4}')

		if [[ $TELNET = '' ]]; then
			echo "::: ID $DSID : $C" >> ${ArchSal}
			echo $ID1392L >> ${ArchSal}
			x1="$x1$DSID:$C;"
		else
			echo "::: ID $DSID : $NC" >> ${ArchSal}
			echo $ID1392L >> ${ArchSal}
			echo ":: :: Deshabilitar los siguientes puertos" >> ${ArchSal}
			ss -a | grep LISTEN | grep -E ':21|:23|:513|:ftp|:telnet|:rlogin' >> ${ArchSal}
			x1="$x1$DSID:$NC;"
			echo "::: ID $DSID" >> ${PENDIENTES}
			echo "Deshabilite los servicios telnet, ftp y rlogin" >> ${PENDIENTES}
			ss -a | grep LISTEN | grep -E ':21|:23|:513|:ftp|:telnet|:rlogin' >> ${PENDIENTES}
			echo "" >> ${PENDIENTES}
		fi
else
	x1="$x1$DSID:$NC;"
fi

echo "" >> ${ArchSal}

#1517 --- revisar la parte de las reglas definidas cat /etc/sysconfig/iptables
DSID="SRV-49"
ID1517L=":: Se restringe los accesos por IP a los puertos con algún servicios de administración";

IPTABLESA='systemctl';

if [[ $SYSTEMCTL = 1 ]]; then
	IPTABLESA=$(systemctl list-unit-files | grep 'enabled' | grep -E 'iptables|netfilter|ipfilter|tcpwrapper|firewalld');
else
	IPTABLESA=$(/sbin/chkconfig --list | grep '3:on' | grep -E 'iptables|netfilter|ipfilter|tcpwrapper|firewalld' | awk '{print $1}')
fi

IPTCONF='';
IPTCONF=$(iptables -L | grep ssh | awk '{print $4}' | grep anywhere)


if [[ $IPTABLESA != '' && $IPTCONF = '' ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1517L >> ${ArchSal}
	#echo ":: :: $C " >> ${ArchSal}
	echo "Servicio instalado: " $IPTABLES >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1517L >> ${ArchSal}
	echo "::: Instalar y configurar uno de los siguientes servicios iptables, netfilter, ipfilter, tcpwrapper, firewalld" >> ${ArchSal}
	echo "::: Revisar las siguientes reglas:" >> ${ArchSal}
	iptables -L --line-numbers | grep ssh | grep anywhere >> ${ArchSal}
	
	x1="$x1$DSID:$NC;"

	echo "::: ID $DSID" >> ${PENDIENTES}
	echo "::: Instalar y configurar uno de los siguientes servicios iptables, netfilter, ipfilter, tcpwrapper, firewalld" >> ${PENDIENTES}
	echo "::: Revisar las siguientes reglas:" >> ${PENDIENTES}
	iptables -L --line-numbers | grep ssh | grep anywhere >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi

echo "" >> ${ArchSal}

#1724
DSID="SRV-18"
ID1724L=":: El servidor no cuenta con permisos de salida a internet.";

PING=$(ping -c2 8.8.8.8 | grep -E 'Network is unreachable|packet loss')
WGET=`wget -q --tries=2 --timeout=10 http://www.linux.org/ -O /tmp/linux.idx`
TMPL=`cat /tmp/linux.idx`

if [[ $TMPL = '' &&  $PING != '' ]]; then
	echo "::: ID $DSID: $C" >> ${ArchSal}
	echo $ID1724L >> ${ArchSal}
	#echo ":: :: Cumple " >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1724L >> ${ArchSal}
	#echo ":: :: Pendiente " >> ${ArchSal}
	echo ":: :: Deshabilitar el servicio de internet, o en su caso restringirlos y documentar su uso " >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	echo "::: ID $DSID " >> ${PENDIENTES}
	echo "Deshabilitar el servicio de internet, o en su caso restringirlos y documentar su uso " >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi
echo "" >> ${ArchSal}

#----------------------
DSID="SRV-19"
ID1398L="::: Las cuentas creadas por defecto (uucp, nucp, mail, news, games, gopher, ftp, etc) son eliminadas y/o deshabilitadas eliminado el shell de las mismas."

ID1398=`cat /etc/passwd | grep -E 'games|ftp|uucp|nucp|mail|news|gopher|gpg' | grep -v -E '/sbin/nologin|/usr/bin/false'`

	if [[ $ID1398='' ]]; then
		echo ":: ID $DSID : $C" >> ${ArchSal}
		echo $ID1398L >> ${ArchSal}
		
		x1="$x1$DSID:$C;"

	else
		echo ":: ID $DSID : $NC" >> ${ArchSal}
		echo $ID1398L >> ${ArchSal}

		echo "Usuarios por dafaul:" >> ${ArchSal}
		echo $ID1398  >> ${ArchSal}

		echo "::: ID $DSID" >> ${PENDIENTES}
		echo "Deshabilite los siguientes usuarios"
		echo $ID1398 >> ${PENDIENTES}
	x1="$x1$DSID:$NC;"
	fi
echo "" >> ${ArchSal}

#1399
DSID="SRV-20"
ID1399L=":: Se eliminó el archivo $HOME/.rhosts y .netrc por cada usuario."
ID1399ARRU=( $( ls -1p /home/ | grep / | sed 's/^\(.*\)/\1/') )
ID1399CONT=""
for userdir in ${ID1399ARRU[@]}
        do
          	ID1399F=`ls -a /home/$userdir | grep -E '.rhosts|.netrc'`
                if [[ $ID1399F != '' ]]; then
                        ID1399CONT="$ID1399CONT /home/$userdir$ID1399F"
                fi
done

if [[ $ID1399CONT = "" ]]; then
        echo ":: ID $DSID : $C" >> ${ArchSal}
        echo $ID1399L  >> ${ArchSal}
		x1="$x1$DSID:$C;"
else
    	echo ":: ID $DSID : $NC" >> ${ArchSal}
        echo $ID1399L >> ${ArchSal}

        echo "::: ID $DSID" >> ${ArchSal}
        echo "Borrar los siguientes archivos:" >> ${ArchSal}
        echo $ID1399CONT >> ${ArchSal}
		
		echo "::: ID $DSID" >> ${PENDIENTES}
        echo "Borrar los siguientes archivos:" >> ${PENDIENTES}
        echo $ID1399CONT >> ${PENDIENTES}
		x1="$x1$DSID:$NC;"
fi
echo "" >> ${ArchSal}

#1400
DSID="SRV-21"
ID1400L=":: Evita conexiones remotas inseguras, las conexiones remotas se hacen con cifrado. Se borró el archivo /etc/hosts.equiv.";
FHOSTEQ=`find '/etc' -name 'hosts.equiv' -print`

if [[ $FHOSTEQ = '' ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1400L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1400L >> ${ArchSal}

	echo ":: :: Existe el archivo /etc/hosts.equiv." >> ${ArchSal}
	echo $FHOSTEQ  >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: ID $DSID" >> ${PENDIENTES}
	echo "Elimine el archivo /etc/hosts.equiv" >> ${PENDIENTES}
fi

echo "" >> ${ArchSal}

#1473
DSID="SRV-22"
ID1473L=":: El archivo /etc/login.defs tiene configurados los siguientes valores:UMASK 027"
ID1473=`cat /etc/login.defs | grep -v '^#' | grep -E 'UMASK|umask' | awk '{print $2}'`
if [[ $ID1473 = '027' ]]; then
        echo ":: ID $DSID : $C" >> ${ArchSal}
        echo $ID1473L >> ${ArchSal}
		x1="$x1$DSID:$C;"
else
        echo ":: ID $DSID : $NC" >> ${ArchSal}
		echo $ID1473L >> ${ArchSal}
		echo "UMASK tiene el valor: $ID1473" >> ${ArchSal}

        echo "::: ID$DSID" >> ${PENDIENTES}
        echo "UMASK tiene el valor: $ID1473" >> ${PENDIENTES}
		x1="$x1$DSID:$NC;"
fi
echo "" >> ${ArchSal}

#1401
DSID="SRV-23"
ID1401L=":: Se cuenta con una contraseña robusta. El archivo /etc/login.defs tiene configurado el siguiente valor: ENCRYPT_METHOD SHA512";

ENCMETHOD=`cat /etc/login.defs | grep -v '^#' | grep 'ENCRYPT_METHOD' | awk '{print $2}'`

if [[ $ENCMETHOD = 'SHA512' ]]; then
	echo "::: ID 1401 : $C" >> ${ArchSal}
	echo $ID1401L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID 1401 : $NC" >> ${ArchSal}
	echo $ID1401L >> ${ArchSal}

	echo ":: :: El método de cifrado es " >> ${ArchSal}
	echo $ENCMETHOD >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: ID 1401" >> ${PENDIENTES}
	echo "Establezca el valor 'SHA512' a la llave 'ENCRYPT_METHOD' en el archivo /etc/login.defs" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi

echo "" >> ${ArchSal}

#1405
DSID="SRV-28"
ID1405L=":: Garantiza la correcta rotación y caducidad de las contraseñas. El archivo /etc/login.defs tiene configurados los siguientes valores: PASS_MIN_DAYS=0, PASS_WARN_AGE=7";

VAL1=0

MINDAYS=`cat /etc/login.defs | grep -v '^#' | grep 'PASS_MIN_DAYS' | awk '{print $2}'`
WARNDAYS=`cat /etc/login.defs | grep -v '^#' | grep 'PASS_WARN_AGE' | awk '{print $2}'`


if [[ $MINDAYS -ne 0 ]]; then
	VAL1=`expr $VAL1 + 2`
fi

if [[ $WARNDAYS -gt 15 ]]; then
	VAL1=`expr $VAL1 + 4`
fi


if [[ VAL1 -eq 0 ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1405L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1405L >> ${ArchSal}
	echo ":: :: Configuración del login.defs" >> ${ArchSal}
	echo "PASS_MIN_DAYS "$MINDAYS >> ${ArchSal}
	echo "PASS_WARN_AGE "$WARNDAYS >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES 
	echo "::: ID $DSID" >> ${PENDIENTES}
	echo "Establezca el valor '0' a la llave 'PASS_MIN_DAYS' en el archivo /etc/login.defs" >> ${PENDIENTES}
	echo "Establezca el valor '7' a la llave 'PASS_WARN_AGE' en el archivo /etc/login.defs" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi

echo "" >> ${ArchSal}

#1409
DSID="SRV-30"
ID1409L=":: El archivo /etc/inetd.conf , /etc/xinetd.conf o /etc/xinet.d/* es propiedad de root y tiene establecidos los permisos 600.";

INETDC=`ls -l /etc/*.conf | grep -E 'inetd|xinetd' | awk '{print $1}' | grep -v 'rw-------'`

if [[ $INETDC = '' ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1409L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1409L >> ${ArchSal}
	echo ":: :: El siguiente archivo no cumple con los permisos 600" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	echo "::: ID $DSID" >> ${PENDIENTES}
	echo "Modifique a 600 los permisos de los siguientes archivos: " >> ${PENDIENTES}
	for item in ${$KEYPRIVTMP[*]}
		do
			printf "%s\n" $item >> ${ArchSal}
			printf "%s\n" $item >> ${PENDIENTES}
		done
	echo "" >> ${PENDIENTES}
fi
echo "" >> ${ArchSal}

#1413
DSID="SRV-32"
ID1413=":: El archivo /etc/services o equivalente es propiedad de root, bin o sys, y tiene establecidos los permisos 644.";

SERVICES1=`ls -l -n /etc/services | awk '{print $1}' | grep -v -E 'rw-------|rw-r--r--'`

if [[ $SERVICES1 = '' ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1413 >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1413 >> ${ArchSal}
	echo ":: :: El archivo /etc/login.defs tiene los siguientes permisos "$SERVICES1 >> ${ArchSal}

	echo "::: ID $DSID" >> ${PENDIENTES}
	echo ":: :: Modifique los permisos de /etc/services a 600 [chmod /etc/services 600] " >> ${PENDIENTES}
	x1="$x1$DSID:$NC;"
	echo "" >> ${PENDIENTES}
fi
echo "" >> ${ArchSal}

#1414
DSID="SRV-33"
ID1414L=":: El archivo /etc/login.defs es propiedad de root y tiene establecidos los permisos 600.";

LOGINDEFS=`ls -l -n /etc/login.defs | awk '{print $1}' | cut -c 1-10`

if [[ $LOGINDEFS = '-rw-------' ]]; then
	#-rw-
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1414L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1414L >> ${ArchSal}
	echo ":: :: El archivo /etc/login.defs tiene los siguientes permisos "$LOGINDEFS >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: ID $DSID" >> ${PENDIENTES}
	echo "Cambie a 600 los permisos del archivo /etc/login.defs [chmod 600 /etc/login.defs]" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi
echo "" >> ${ArchSal}

#1422
DSID="SRV-39"
ID1422L=":: El sistema de archivos raiz está aislado del sistema de archivos de logs y el home de usuarios."
echo "::: ID $DSID : $P" >> ${ArchSal}
echo $ID1422L >> ${ArchSal}
echo ": Validacion Manual" >> ${ArchSal}
df -h >> ${ArchSal}
echo "" >> ${ArchSal}
x1="$x1$DSID:$P;"

#1423
DSID="SRV-40"
ID1423L=":: Los directorios /bin , /etc , /sbin , /usr/bin , /usr/etc , /usr/sbin son propiedad de root.";
VAL1423=0
ARR1423=(`ls -l -n '/' | grep 'etc' | awk '{print $3}'` `ls -l -n '/' | grep 'sbin'| awk '{print $3}'` `ls -l -n '/usr' | grep 'bin' | awk '{print $3}'` `ls -l -n '/usr' | grep 'etc' | awk '{print $3}'` `ls -l -n '/usr' | grep 'sbin' | awk '{print $3}'` `ls -l -n '/' | grep 'tmp' | awk '{print $3}'` `ls -l -n '/var' | grep 'tmp' | awk '{print $3}'`);
for item in ${ARR1423[*]}
do
    if [[ $item -ne 0 ]]; then
    	VAL1423=`expr $VAL1423 + 1`
    fi
done

if [[ $VAL1423 -eq 0 ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1423L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1423L >> ${ArchSal}
	echo ":: :: Asignar a root los siguentes archivos: " >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: ID $DSID" >> ${PENDIENTES}
	echo "Asignar a root los siguentes archivos: " >> ${PENDIENTES}

	for item in ${ARR1423[*]}
	do
	    if [[ $item -ne 0 ]]; then
	    	echo printf "%s\n" $item >> ${ArchSal}
	    	echo printf "%s\n" $item >>  ${PENDIENTES}
	    fi
	done

	echo "" >> ${PENDIENTES}
fi
echo "" >> ${ArchSal}

#1424
DSID="SRV-41"
ID1424L=":: Las terminales seguras (/etc/ttys, /etc/default/login, /etc/security, /etc/securetty, /etc/init/tty*) son propiedad de root o de bin, tienen establecidos los permisos 600";
ARR1424SP=(`ls -l -n '/etc/' | grep 'security' | grep -v "rw-------" | awk '{print $9}'` `ls -l -n '/etc/default/' | grep 'login' |grep -v "rw-------" | awk '{print $9}'` `ls -l -n '/etc/' | grep 'securetty' | grep -v "rw-------" | awk '{print $9}'` `ls -l -n '/etc/' | grep 'security' | grep -v "rw-------" | awk '{print $9}'` `ls -l -n '/etc/' | grep 'ttytab' | grep -v "rw-------" | awk '{print $9}'` `ls -l -n '/etc/init/' | grep 'tty' | grep -v "rw-------" | awk '{print $9}'`);
ARR1424=(`ls -l -n '/etc/' | grep 'security' | grep "rw-------" | awk '{print $4}'` `ls -l -n '/etc/default/' | grep 'login' |grep "rw-------" | awk '{print $4}'` `ls -l -n '/etc/' | grep 'securetty' | grep "rw-------" | awk '{print $4}'` `ls -l -n '/etc/' | grep 'security' | grep "rw-------" | awk '{print $4}'` `ls -l -n '/etc/' | grep 'ttytab' | grep "rw--------" | awk '{print $4}'` `ls -l -n '/etc/init/' | grep 'tty' | grep "rw-------" | awk '{print $4}'`);
VAL1424=1
for item in ${ARR1424[*]}
	do
	    if [[ $item != '' ]]; then
	    	if [[ $item -eq 0 ]]; then
			VAL1424=0
		fi
	    fi
	done

if [[ $VAL1424 -eq 0 ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1424L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1424L >> ${ArchSal}
	echo "Asignar a root y aplicar permisos 600 los siguentes archivos: " >> ${ArchSal}

	echo "::: ID $DSID" >> ${PENDIENTES}
	echo "Asignar a root y aplicar permisos 600 los siguentes archivos: " >> ${PENDIENTES}

	x1="$x1$DSID:$NC;"

	for item in ${ARR1424SP[*]}
	do
	    if [[ $item != '' ]]; then
			echo $item >> ${ArchSal}
                        echo $item >>  ${PENDIENTES}
	    	#fi
	    fi
	done

	echo "" >> ${PENDIENTES}

fi

echo "" >> ${ArchSal}

#1425
DSID="SRV-42"
ID1425L=":: Los archivos de inicialización de servicios del sistema  (/etc/rc*.*)  no tienen establecidos los permisos 777.";

ARCHRD=`ls -l /etc/rc* | grep -E '^d|^-' | grep 'rwxrwxrwx' | awk '{print $9}'`

if [[ $ARCHRD = '' ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1425L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	x1="$x1$DSID:$NC;"
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1425L >> ${ArchSal}
	echo "Modifique los permisos de los siguientes archivos, se recomienda 640: " >> ${ArchSal}

	echo "::: ID $DSID" >> ${PENDIENTES}
	echo "Modifique los permisos de los siguientes archivos, se recomienda 640: " >> ${PENDIENTES}

	for item in ${ARCHRD[*]}
	do
		printf "%s\n" $item >> ${ArchSal}
		printf "%s\n" $item >> ${PENDIENTES}
	done

	echo "" >> ${PENDIENTES}
fi

echo "" >> ${ArchSal}

#1426
DSID="SRV-43"
ID1426L=":: El archivo de sistema /etc/hosts.allow tiene establecido el permiso 640.";

HOSTALLOW=`ls -l -n /etc/hosts.allow | grep -v -E 'rw-r-----|rwxr-x---'`

if [[ $HOSTALLOW = ''  ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
echo $ID1426L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1426L >> ${ArchSal}
	echo ":: :: el archivo /etc/hosts.allow tiene los siguientes permisos " >> ${ArchSal}
	echo `ls -l -n /etc/hosts.allow` >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: ID $DSID" >> ${PENDIENTES}
	echo "Cambie a 640 o 750 los permisos del archivo /etc/hosts.allow [chmod [640|750] /etc/hosts.allow]" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi
echo "" >> ${ArchSal}

#1428
DSID="SRV-45"
ID1428L=":: Están deshabilitados todos los servicios "r" (rlogin, rsh, rexec, etc).";

SERVICESRA=''
SERVICESRB=''

if [[ $SYSTEMCTL = 1 ]]; then
	SERVICESRA=`systemctl list-unit-files | grep 'enabled' | grep -E 'rhnsd|rhsmcertd|rngd|rpcbind|rpcgssd|rpcidmapd|rpcsvcgssd|rstatd|rusersd'`
else
	SERVICESRA=`/sbin/chkconfig --list | grep '3:on' | grep -E 'rhnsd|rhsmcertd|rngd|rpcbind|rpcgssd|rpcidmapd|rpcsvcgssd|rstatd|rusersd' | awk '{print $1}' `;
fi


if [[ $SERVICESRA = '' ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1428L >> ${ArchSal}
	#echo ":: :: Cumple " >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1428L >> ${ArchSal}
	#echo ":: :: Pendiente " >> ${ArchSal}
	echo ":: :: Tiene los siguientes servicios vulnerables r* activos" >> ${ArchSal}
	
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: ID $DSID" >> ${PENDIENTES}
	echo "Tiene los siguientes servicios vulnerables r* activos " >> ${PENDIENTES}
	

	if [[ $SYSTEMCTL = 1 ]]; then
		systemctl list-unit-files | grep 'enabled' | grep -E 'rhnsd|rhsmcertd|rngd|rpcbind|rpcgssd|rpcidmapd|rpcsvcgssd|rstatd|rusersd' >> ${ArchSal}
		systemctl list-unit-files | grep 'enabled' | grep -E 'rhnsd|rhsmcertd|rngd|rpcbind|rpcgssd|rpcidmapd|rpcsvcgssd|rstatd|rusersd' >> ${PENDIENTES}
	else
		/sbin/chkconfig --list | grep '3:on' | grep -E 'rhnsd|rhsmcertd|rngd|rpcbind|rpcgssd|rpcidmapd|rpcsvcgssd|rstatd|rusersd' >> ${ArchSal}
		/sbin/chkconfig --list | grep '3:on' | grep -E 'rhnsd|rhsmcertd|rngd|rpcbind|rpcgssd|rpcidmapd|rpcsvcgssd|rstatd|rusersd' >> ${PENDIENTES}
	fi
	echo "" >> ${PENDIENTES}
fi
echo "" >> ${ArchSal}

#1429
#DSID="1429"
#ID1429L=":: Está deshabilitado el servicio TFTP";
#PUERTOSTFTP=`ss -a | grep LISTEN | grep -E ':69ftp|:tftp' | awk '{print $4}'`

#if [[ $PUERTOSTFTP = '' ]]; then
#	echo "::: ID 1429 : $C" >> ${ArchSal}
#	echo $ID1429L >> ${ArchSal}
#	x1="$x1$DSID:$C;"
#else
#	echo "::: ID 1429 : $NC" >> ${ArchSal}
#	echo $ID1429L >> ${ArchSal}
#	echo ":: :: Deshabilite el TFTP" >> ${ArchSal}
#	ss -a | grep LISTEN | grep -E ':69|:tftp' >> ${ArchSal}
#	x1="$x1$DSID:$NC;"
	#PENDIENTES
#	echo "::: ID 1429" >> ${PENDIENTES}
#	echo "Deshabilite el TFTP" >> ${PENDIENTES}
#	ss -a | grep LISTEN | grep -E ':69ftp|:tftp' >> ${PENDIENTES}
#	echo '' >> ${PENDIENTES}
#fi
#echo "" >> ${ArchSal}

#1541 -- 
DSID="SRV-47" 
ID1541L="Validar que el servicio de SNMP este actualizado a la ultima version en caso de ser requerido de lo contrario se debe deshabilitar  y  filtrar por IP su consumo."

if [[ $SYSTEMCTL = 1 ]]; then
	ID1541=`systemctl list-unit-files | grep 'enabled' | grep -E 'snmp|snmpd|SNMPD'`
else
	ID1541=$(/sbin/chkconfig --list | grep -E '3:on|3:activo' | grep -E 'snmp|snmpd|SNMPD')
fi

if [[ $ID1541 = "" ]]; then
        echo "::: ID $DSID : $C" >> ${ArchSal}
        echo $ID1541L >> ${ArchSal}
		x1="$x1$DSID:$C;"
else
        echo "::: ID $DSID : $NC"
        echo $ID1541L >> ${ArchSal}
        echo ":: :: Deshabilite el servicio SNMP" >> ${ArchSal}
		x1="$x1$DSID:$NC;"	 
		#PENDIENTES
		echo "::: ID $DSID : $NC"
        echo $ID1541L >> ${PENDIENTES}
        echo ":: :: Deshabilite el servicio SNMP" >> ${PENDIENTES}
		echo "" >> ${PENDIENTES}
		x1="$x1$DSID:$NC;"	
fi
echo "" >> ${ArchSal}

#1431
DSID="SRV-48"
ID1431L=":: El kernel es propiedad de root o de bin.";

BOOTKERNEL=`ls -ld /boot | awk '{print $3}' | grep -E 'root|0'`
PROCKERNEL=`ls -la /proc/sys | grep -v -E 'dr-xr-xr-x|total'`


if [[ $BOOTKERNEL != '' &&  $PROCKERNEL = '' ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
echo $ID1431L >> ${ArchSal}
	#echo ":: :: Cumple " >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	x1="$x1$DSID:$NC;"
	echo "::: ID $DSID : $NC" >> ${ArchSal}
echo $ID1431L >> ${ArchSal}
	#echo ":: :: Pendiente " >> ${ArchSal}
	printf ":: ::  El directorio /boot tiene por dueño %s " $BOOTKERNEL >> ${ArchSal}

	#PENDIENTES
	echo "::: ID $DSID" >> ${PENDIENTES}
	echo "Modifique el dueño del directorio /boot " >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi
echo "" >> ${ArchSal}

#1432
DSID="SRV-49"
ID1432L=":: El servidor utiliza el programa tcp_wrapper, IPTables, IPFilter  para controlar las conexiones entrantes y salientes.";

IPTABLES32A='systemctl';

if [[ $SYSTEMCTL = 1 ]]; then
	IPTABLES32A=`systemctl list-unit-files | grep 'enabled' | grep -E 'iptables|netfilter|ipfilter|tcpwrapper|firewalld'`;
else
	IPTABLES32A=`/sbin/chkconfig --list | grep '3:on' | grep -E 'iptables|netfilter|ipfilter|tcpwrapper|firewalld' | awk '{print $1}'`
fi


if [[ $IPTABLES32A != '' ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1432L >> ${ArchSal}
	echo "Servicio instalado: " $IPTABLES >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1432L >> ${ArchSal}
	x1="$x1$DSID:$NC;"

	echo "::: ID $DSID" >> ${PENDIENTES}
	echo "::: Instalar y configurar uno de los siguientes servicios iptables, netfilter, ipfilter, tcpwrapper, firewalld" >> ${PENDIENTES}

	echo "" >> ${PENDIENTES}
fi

echo "" >> ${ArchSal}

#1434 -- 
DSID="SRV-51"
ID1434L=":: En caso de requerir envío de correos, usar los servicios de correo corporativo."
if [[ $SYSTEMCTL = 1 ]]; then
	SMTP=$(systemctl list-unit-files | grep enabled | grep -E "smtp|postfix")
else
	SMTP=$(/sbin/chkconfig --list | grep -E '3:on|3:activo' | grep -E 'postfix')
fi
if [[ $SMTP = "" ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1434L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1434L >> ${ArchSal} 
	echo $SMTP >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	echo "::: ID $DSID : $NC" >> ${PENDIENTES}
	echo $ID1434L >> ${PENDIENTES}
	echo "Deshabilitar el siguiente servicio:" >> ${PENDIENTES}
	echo $SMTP >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi
echo "" >> ${ArchSal}

#1435
DSID="SRV-52"
ID1435L=":: El servicio SSH (/etc/ssh/sshd_config)  tiene configurados los siguientes valores: protocol 2, permitRootLogin no, Ciphers aes256-ctr, X11Forwarding no, PubkeyAuthentication no";

PROTOCOL=`cat /etc/ssh/sshd_config | grep -v '^#' | grep 'Protocol' | awk '{print $2}'`
PERMITROOT=`cat /etc/ssh/sshd_config | grep -v '^#' | grep 'PermitRootLogin' | awk '{print $2}'`
X11FOR=`cat /etc/ssh/sshd_config | grep -v '^#' | grep '11Forwarding' | awk '{print $2}'`
PUBKEYAUTH=`cat /etc/ssh/sshd_config | grep -v '^#' | grep 'bkeyAuthentication' | awk '{print $2}'`

VAL1435=0

if [[ $PROTOCOL != '2' ]]; then
	VAL1435=`expr $VAL1435 + 1`
fi

if [[ $PERMITROOT != 'no' ]]; then
	VAL1435=`expr $VAL1435 + 2`
fi

if [[ $X11FOR != 'no' ]]; then
	VAL1435=`expr $VAL1435 + 3`
fi

if [[ $PUBKEYAUTH != 'no' ]]; then 
	VAL1435=`expr $VAL1435 + 4`
fi

if [[ $VAL1435 -eq 0 ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal};
	echo $ID1435L >> ${ArchSal};
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal};
	echo $ID1435L >> ${ArchSal};
	echo ":: :: Configuración del /etc/ssh/sshd_config " >> ${ArchSal}
	echo "Protocol "$PROTOCOL >> ${ArchSal}
	echo "PermitRootLogin "$PERMITROOT >> ${ArchSal}
	echo "11Forwarding $X11FOR" >> ${ArchSal}
	echo "keyAuthentication $PUBKEYAUTH" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	echo "::: ID $DSID" >> ${PENDIENTES}
	echo "Establezca el valor '2' a la llave 'protocol' en el archivo /etc/ssh/sshd_config" >> ${PENDIENTES}
	echo "Establezca el valor 'no' a la llave 'permitRootLogin' en el archivo /etc/ssh/sshd_config" >> ${PENDIENTES}
	echo "Establezca el valor 'no' a la llave '11Forwarding' en el archivo /etc/ssh/sshd_config" >> ${PENDIENTES}
	echo "Establezca el valor 'no' a la llave 'PubkeyAuthentication' en el archivo /etc/ssh/sshd_config" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi

echo "" >> ${ArchSal}

#1436
DSID="SRV-53"
ID1436L=":: En el archivo de configuración /etc/ssh/sshd_config deben estar configurados los siguientes valores: SysLogFacility AUTH y LogLevel INFO";

SYSLOGFAC=`cat /etc/ssh/sshd_config | grep -v '^#' | grep 'SyslogFacility' | awk '{print $2}'`
LOGLEVEL=`cat /etc/ssh/sshd_config | grep -v '^#' | grep 'LogLevel' | awk '{print $2}'`

VAL1436=0

if [[ $SYSLOGFAC != 'AUTH' ]]; then
	VAL1436=`expr $VAL1436 + 1`
fi

if [[ $LOGLEVEL != 'INFO' ]]; then
	VAL1436=`expr $VAL1436 + 2`
fi

if [[ $VAL1436 -eq 0 ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal};
	echo $ID1436L >> ${ArchSal};
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1436L >> ${ArchSal}
	echo ":: :: Configuración del /etc/ssh/sshd_config " >> ${ArchSal}
	echo "SyslogFacility "$SYSLOGFAC  >> ${ArchSal}
	echo "LogLevel "$LOGLEVEL >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: ID $DSID" >> ${PENDIENTES}
	echo "Establezca el valor 'AUTH' a la llave 'SysLogFacility' en el archivo /etc/ssh/sshd_config" >> ${PENDIENTES}
	echo "Establezca el valor 'INFO' a la llave 'LogLevel' en el archivo /etc/ssh/sshd_config" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi

echo "" >> ${ArchSal}

#1543
DSID="SRV-54"
ID1543L=" Definir el nivel de seguridad para las conexiones remotas "
ID1543_1=$(cat /etc/sysctl.conf | grep -v '^#' | grep 'net.ipv4.ip_forward' | grep '0')
ID1543_2=$(cat /etc/sysctl.conf | grep -v '^#' | grep 'net.ipv4.conf.all.rp_filter' | grep '1')
if [[ $ID1543_1 = "" ]]; then
        echo "::: $DSID : $NC" >> ${ArchSal}
        echo $ID1543L >> ${ArchSal}
		echo "En el archivo de configuración /etc/sysctl.conf se cuenta con:
				net.ipv4.ip_forward=0 el valor actual es: $ID1543_1
				net.ipv4.conf.all.rp_filter=1 el valor actual es: $ID1543_2" >> ${ArchSal}
		#PENDIENTES
		echo "::: ID $DSID : $NC" >> ${PENDIENTES}
        echo $ID1543L >> ${PENDIENTES}
		IPV4_FORD=$(cat /etc/sysctl.conf | grep -v '^#' | grep 'net.ipv4.ip_forward')
		IPV4_FIL=$(cat /etc/sysctl.conf | grep -v '^#' | grep 'net.ipv4.conf.all.rp_filter')
		echo "En el archivo de configuración /etc/sysctl.conf se cuenta con:
				$IPV4_FORD
				$IPV$_FIL" >> ${PENDIENTES}
		x1="$x1$DSID:$NC;"

else
    	if [[ $ID1543_2 = "" ]]; then
                echo "::: ID $DSID : $NC" >> ${ArchSal}
                echo $ID1543L >> ${ArchSal}
				echo "En el archivo de configuración /etc/sysctl.conf se cuenta con:
				net.ipv4.ip_forward=0 el valor actual es: $ID1543_1
				net.ipv4.conf.all.rp_filter=1 el valor actual es: $ID1543_2" >> ${ArchSal}
				#PENDIENTES
				echo "::: ID1543 : $NC" >> ${PENDIENTES}
				echo $ID1543L >> ${PENDIENTES}
				IPV4_FORD=$(cat /etc/sysctl.conf | grep -v '^#' | grep 'net.ipv4.ip_forward')
				IPV4_FIL=$(cat /etc/sysctl.conf | grep -v '^#' | grep 'net.ipv4.conf.all.rp_filter')
				echo "En el archivo de configuración /etc/sysctl.conf se cuenta con:
						$IPV4_FORD
						$IPV$_FIL" >> ${PENDIENTES}
				x1="$x1$DSID:$NC;"
        else
            	echo "::: ID $DSID : $C" >> ${ArchSal}
                echo $ID1543L >> ${ArchSal}
				x1="$x1$DSID:$C;"
        fi
fi
echo "" >> ${ArchSal}

#1438
DSID="SRV-56"
ID1438L=":: Las llaves privadas del servicio SSH tienen permisos 600 y su dueño y grupo es root";


KEYPRIV=`ls -l /etc/ssh/  | grep -E 'key$' | grep -v 'rw-------' | awk '{print $3}' | grep -E 'root|0'`

if [[ $KEYPRIV = '' ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
echo $ID1438L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1438L >> ${ArchSal}
	echo ":: :: Establezca los permisos 600, y asignar a root los siguientes archivos" >> ${ArchSal}
	ls -l /etc/ssh/*key | grep -v 'rw-------' >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: ID $DSID" >> ${PENDIENTES}
	echo "Establezca los permisos 600, y asignar a root los siguientes archivos" >> ${PENDIENTES}
	ls -l /etc/ssh/*key | grep -v 'rw-------' >> ${PENDIENTES}


	echo "" >> ${PENDIENTES}

fi
echo "" >> ${ArchSal}

#1440
DSID="SRV-57"
ID1440L="No existen archivos Authorized_keys en las carpetas .ssh dentro de los home directory de los usuarios."
ID1440ARRU=( $( ls -1p /home/ | grep / | sed 's/^\(.*\)/\1/') )
ID1440CONT=""
for ID1440D in "${ID1440ARRU[@]}"
	do
		ID1440F=`ls -a /home/$ID1440D.ssh | grep 'keys'`
		if [[ $ID1440F != "" ]]; then
			ID1440CONT="$ID1440CONT /home/$ID1440D.ssh/$ID1440F"
		fi
done

if [[ $ID1440CONT = "" ]]; then
        echo ":: ID $DSID : $C" >> ${ArchSal}
        echo $ID1440L  >> ${ArchSal}
		x1="$x1$DSID:$C;"
else
    	echo ":: ID $DSID : $NC" >> ${ArchSal}
        echo $ID1440L >> ${ArchSal}

        echo "::: ID $DSID" >> ${ArchSal}
        echo "Borrar los siguientes archivos:" >> ${ArchSal}
        echo $ID1440CONT >> ${ArchSal}
		
		echo "::: ID $DSID" >> ${PENDIENTES}
        echo "Borrar los siguientes archivos:" >> ${PENDIENTES}
        echo $ID1440CONT >> ${PENDIENTES}
		x1="$x1$DSID:$NC;"
fi
echo "" >> ${ArchSal}

#1442
DSID="SRV-59"
ID1442L=":: La variable $PATH de root no contiene la ruta actual (.)";

DOTPATH1=`/usr/bin/env | grep 'PATH' | grep -F ':.'`
DOTPATH2=`/usr/bin/env | grep 'PATH' | grep -F '=.'`

if [[ $DOTPATH1 = '' || $DOTPATH2 = '' ]]; then
echo "::: ID $DSID : $C" >> ${ArchSal}
echo  $ID1442L >> ${ArchSal}
	#echo ":: :: Cumple " >> ${ArchSal}
	x1="$x1$DSID:$C;"
else 
	echo "::: ID $DSID : $NC" >> ${ArchSal}
echo  $ID1442L >> ${ArchSal}
	#echo ":: :: Pendiente " >> ${ArchSal}
	echo ":: :: Elimine el punto (.) de la variable $PATH " >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: ID $DSID " >> ${PENDIENTES}
	echo "Elimine el punto (.) de la variable $PATH " >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi

echo "" >> ${ArchSal}

#1444
DSID="SRV-60"
ID1444L=":: Se validaron que los procesos que se ejecutan en el cron son solo los necesarios para la operación"
echo "::: ID $DSID : $P" >> ${ArchSal};
echo $ID1444L >> ${ArchSal}
echo "::: Validación manual" >> ${ArchSal};
echo "" >> ${ArchSal}

echo "...................." >> ${ArchSal}

for item in $( ls /var/spool/cron/*/* )
do
	echo cat $item >> ${ArchSal}
	cat $item >> ${ArchSal}
	echo ""  >> ${ArchSal}
done
echo "...................." >> ${ArchSal}

echo "" >> ${ArchSal}

#1445
DSID="SRV-62"
ID1445L=":: Los mensajes de login de servicios remotos no revelan información sensible del servidor (versión, hostname, etc).";

UNAMEMOTD=`uname -a | awk '{print $3}' | cut -c 1-3`
HOSTMOTD=`hostname`
SO=`cat /etc/issue | grep -F '.' | awk '{print $1" "$2" "$3}'`

if [ -f /etc/motd ]
then
	MOTD1=`cat /etc/motd | grep -F $UNAMEMOTD`
	MOTD2=`cat /etc/motd | grep -F $HOSTMOTD`
	MOTD3=`cat /etc/motd | grep -F '$SO'`
else
	MOTD1=''
	MOTD2=''
	MOTD=''
fi

if [[ $MOTD1 = '' && $MOTD2 = '' && $MOTD3 = '' ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo  $ID1445L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo  $ID1445L >> ${ArchSal}
	echo ":: :: Modifique el archivo /etc/motd para que no muestre información sensible del servidor  " >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: ID $DSID " >> ${PENDIENTES}
	echo "Modifique el archivo /etc/motd, eliminar el hostname, versión del sistema operativo" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi

echo "" >> ${ArchSal}

#1544 verificar si funciona con el viejito
DSID="SRV-64"
ID1544L=":: Evita tener activos servicios potencialmente riesgosos y/o inecesarios."

if [[ $SYSTEMCTL = 1 ]]; then
	ID1544V=(`systemctl list-unit-files | grep -E 'portmap|rpc|nfslock|netfs|autofs|apmd|isdn|pppoe|sendmail|gpm|gdm|kdm|anacron' | awk '{print $2}'`)
	ID1544=0
	for status in $ID1544V 
	do
		if [[ $status = "enabled" ]]; then
		ID1544=$ID1544+1
		fi
	done
	if [[ $ID1544 -eq 0 ]]; then
		echo "::: ID $DSID : $C " >> ${ArchSal}
		echo $ID1544L >> ${ArchSal}
		x1="$x1$DSID:$C;"
	else
		echo "::ID $DSID : $NC" >> ${ArchSal}
		echo $ID1544L >> ${ArchSal}
		echo "::ID $DSID : $NC" >> ${PENDIENTES}
		echo $ID1544L >> ${PENDIENTES}
		echo "Dar de baja los siguientes servicios: portmap, rpc, nfslock, netfs, autofs, apmd, isdn, pppoe, sendmail, gpm, gdm, kdm, anacron.En caso de ser necesario su uso justificar y filtrarlos." >> ${PENDIENTES}
		x1="$x1$DSID:$NC;"
	fi
	echo "" >> ${ArchSal}
else
	ID1544=$(/sbin/chkconfig --list | grep -E '3:on|3:activo' | grep -E 'portmap|rpc|nfslock|netfs|autofs|apmd|isdn|pppoe|sendmail|gpm|gdm|kdm|anacron')
	if [[ $ID1544 = "" ]]; then
		echo "::: ID $DSID : $C " >> ${ArchSal}
		echo $ID1544L >> ${ArchSal}
		x1="$x1$DSID:$C;"
	else
		echo "::ID $DSID : $NC" >> ${ArchSal}
		echo $ID1544L >> ${ArchSal}
		echo "::ID $DSID : $NC" >> ${PENDIENTES}
		echo $ID1544L >> ${PENDIENTES}
		echo "Dar de baja los siguientes servicios: portmap, rpc, nfslock, netfs, autofs, apmd, isdn, pppoe, sendmail, gpm, gdm, kdm, anacron.En caso de ser necesario su uso justificar y filtrarlos." >> ${PENDIENTES}
		x1="$x1$DSID:$NC;"
	fi
fi


#1562
DSID="SRV-65"
ID1562L=":: Evita contar con protocolos inseguros de red :: Dar de baja IPV6"
ID1562=`sysctl -a|grep all.disable_ipv6 | awk '{print $3}'`
if [[ $IDTMP -eq 1 ]]; then
	echo ":::ID$DSID : $C" >> ${ArchSal};
	echo $ID1562L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else 
	echo "::: ID$DSID : $NC" >> ${ArchSal}
	echo $ID1562L >> ${ArchSal}
	echo  `sysctl -a|grep all.disable_ipv6` >> ${ArchSal}
	echo "::: ID$DSID : $NC" >> ${PENDIENTES}
	echo $ID1562L >> ${PENDIENTES}
	echo "Desabilitar IPv6" >> ${PENDIENTES}
	echo  `sysctl -a|grep all.disable_ipv6` >> ${PENDIENTES}
	x1="$x1$DSID:$NC;"
fi
echo "" >> ${ArchSal}

# SRV-185
DSID="SRV-65"
ID1562L="::Si CyberArk esta activo aplicar  PermitRootLogin == YES"
PERMITROOT2=`cat /etc/ssh/sshd_config | grep -v '^#' | grep 'PermitRootLogin' | awk '{print $2}'`
PERMITROOT2="$PERMITROOT2" | awk '{print tolower($0)}'
if [[ $PERMITROOT2 == "yes" ]]; then
	echo ":::ID$DSID : $C" >> ${ArchSal};
	echo $ID1562L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else 
	echo "::: ID$DSID : $NC" >> ${ArchSal}
	echo $ID1562L >> ${ArchSal}
	echo  "PermitRootLogin = $PERMITROOT2" >> ${ArchSal}
	echo "::: ID$DSID : $NC" >> ${PENDIENTES}
	echo $ID1562L >> ${PENDIENTES}
	echo "Establecer PermitRootLogin a yes si CyberArk esta activo" >> ${PENDIENTES}
	echo "PermitRootLogin = $PERMITROOT2" >> ${PENDIENTES}
	x1="$x1$DSID:$NC;"
fi
echo "" >> ${ArchSal}
#----------------------------
#Intercambio de archivos
#1474
ID1474L=":: Los usuarios para el intercambio de archivos no deben tener un shell asignado, no deben ser superusuarios y se debe limitar su acceso a una carpeta definida."
DSID="SRV-84"
echo "::: ID $DSID : $P" >> ${ArchSal};
echo "::: Validación manual" >> ${ArchSal};
echo $ID1474L >> ${ArchSal}
echo "" >> ${ArchSal}

cat /etc/passwd | grep -v -E ':/sbin/nologin|:/bin/false' >> ${ArchSal};

echo "" >> ${ArchSal}

#1546
DSID="SRV-91"
ID1546L=":: permite detectar las modificaciones que haga un cliente de SCP/SFTP sobre los archivos del servidor."
ID1546=$(cat /etc/ssh/sshd_config | grep -v '^#' | grep '\-f LOCAL5 \-l INFO')
if [[ $ID1546 != "" ]]; then
	echo "::: ID$DSID : $C" >> ${ArchSal}
	echo $ID1546L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID$DSID : $NC" >> ${ArchSal}
	echo $ID1546L >> ${ArchSal}
	
	echo ":::ID$DSID : $NC" >> ${PENDIENTES}
	echo $ID1546L >> ${PENDIENTES}
	echo 'Agregar los parámetros "-f LOCAL5 -l INFO" al subsistema de SFTP, quedando la línea como sigue: Subsystem sftp /usr/libexec/openssh-sftp-server en /etc/ssh/sshd_config"' >> ${PENDIENTES}
	x1="$x1$DSID:$NC;"
fi
echo "" >> ${ArchSal}

#1547
DSID="SRV-92"
ID1547L=":: permite detectar las modificaciones que haga un cliente de SCP/SFTP sobre los archivos del servidor."
ID1547=$(cat /etc/rsyslog.conf | grep -v '^#' | grep 'local5.* /var/log/sftpd.log')
if [[ $ID1547 != "" ]]; then
	echo "::: ID$DSID : $C" >> ${ArchSal}
	echo $ID1547L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID$DSID : $NC" >> ${ArchSal}
	echo $ID1547L >> ${ArchSal}
	
	echo ":::ID$DSID : $NC" >> ${PENDIENTES}
	echo $ID1547L >> ${PENDIENTES}
	echo 'Agregar la siguiente línea al archivo de configuración /etc/rsyslog.conf: local5.* /var/log/sftpd.log' >> ${PENDIENTES}
	x1="$x1$DSID:$NC;"
fi
echo "" >> ${ArchSal}

#Registro de Eventos
#1524 1525 1526

AUTHPRIV1=`cat /etc/rsyslog.conf | grep -v '#' | grep -E 'authpriv|auth'`
LOGINFO=`cat /etc/rsyslog.conf | grep -v '#' | grep -E 'info'`
LOGEMERG=`cat /etc/rsyslog.conf | grep -v '#' | grep -E 'emerg'`

ID1524L=":: Se cuenta con LOGS de todas las transacciones criticas del sistema";
ID1525L=":: Se cuenta con LOGS de acceso al servidor";
ID1526L=":: Se cuenta con LOGS de intentos fallidos de acceso al servidor";
DSID="SRV-158"
if [[ $AUTHPRIV1 != '' && $LOGINFO != '' && $LOGEMERG != '' ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo  $ID1524L >> ${ArchSal}
	#echo ":: :: Cumple " >> ${ArchSal}
	x1="$x1""$DSID:$C;"	
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo  $ID1524L >> ${ArchSal}
	#echo ":: :: Pendiente " >> ${ArchSal}
	echo ":: :: Habilitar en el archivo /etc/rsyslog.conf el log de autenticación (authpriv.*), info (*.info) y emergencia (*.emerg)" >> ${ArchSal}
	x1="$x1""1524:$NC;"

	echo "::: ID 1524 " >> ${PENDIENTES}
	echo "Habilitar en el archivo /etc/rsyslog.conf el log de autenticación (authpriv.*), info (*.info) y emergencia (*.emerg)" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi

echo "" >> ${ArchSal}
DSID="SRV-159"
if [[ $AUTHPRIV1 != '' ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo  $ID1525L >> ${ArchSal}
	#echo ":: :: Cumple " >> ${ArchSal}
	x1="$x1""$DSID:$C;"	
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo  $ID1525L >> ${ArchSal}
	#echo ":: :: Pendiente " >> ${ArchSal}
	echo ":: :: Habilitar en el archivo /etc/rsyslog.conf el log de autenticación (authpriv.*)" >> ${ArchSal}
	x1="$x1""$DSID:$NC;"

	echo "::: ID $DSID " >> ${PENDIENTES}
	echo "Habilitar en el archivo /etc/rsyslog.conf el log de autenticación (authpriv.*) " >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}	
fi
echo "" >> ${ArchSal}

DSID="SRV-160"
if [[ $AUTHPRIV1 != '' ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
echo  $ID1526L >> ${ArchSal}
	#echo ":: :: Cumple " >> ${ArchSal}
	x1="$x1""$DSID:$C;"	
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
echo  $ID1526L >> ${ArchSal}
	#echo ":: :: Pendiente " >> ${ArchSal}
	echo ":: :: Habilitar en el archivo /etc/rsyslog.conf el log de autenticación (authpriv.*)" >> ${ArchSal}
	x1="$x1""$$DSID:$NC;"

	echo "::: ID $DSID " >> ${PENDIENTES}
	echo "Habilitar en el archivo /etc/rsyslog.conf el log de autenticación (authpriv.*) " >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}	
fi
echo "" >> ${ArchSal}

#1529
DSID="SRV-163"
ID1529=":: Todos los logs son enviados a un repositorio central (LogLogic).";

LOGLOGIC=`cat /etc/rsyslog.conf | grep -v '#' | grep 'ModLoad imudp'`

if [[ $LOGLOGIC != '' ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
echo $ID1529 >> ${ArchSal}
	x1="$x1$DSID:$C;"	
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
echo $ID1529 >> ${ArchSal}
	echo ":: :: Configurar y habilitar el envio de Logs a LogLogic" >> ${ArchSal}
	x1="$x1$DSID:$NC;"	
	echo "::: ID $DSID " >> ${PENDIENTES}
	echo ":: :: Configurar y habilitar el envio de Logs a LogLogic" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi
echo "" >> ${ArchSal}

}

function redhatCentos {
#Seguridad del Servidor
#1386
#DSID="1386"
#ID1386L=":: El servidor cuenta con los últimos parches de seguridad (release mayor) que recomienda el proveedor."
#INFO_SEC=$(yum info-sec)
#echo "::: ID $DSID : $P" >> ${ArchSal}
#echo  $ID2386L >> ${ArchSal}
#echo "Validacion Manual" >> ${ArchSal}
#echo $INFO_SEC >> ${ArchSal}
#x1="$x1$DSID:$P;"

#1427
DSID="SRV-44"
ID1427L=":: Los archivos de bitácora de sistema ubicados en (/var/log y /var/adm) sólo pueden ser escritos por root.";
VAL1427=0
VARADM=''
VARLOG=''
if [[ "$(ls -A /var/adm)" ]]; then
		VARADM=`ls -l -n /var/adm/*.log | grep -v -E 'rw-r--r--|rw-------' | awk '{print $9}'`
		if [[ $VARADM != '' ]]; then
			VAL1427=`expr $VAL1427 + 1`
		fi
fi

if [[ "$(ls -A /var/log)" ]]; then
	VARLOG=`ls -l -n /var/log/*.log | grep -v -E 'rw-r--r--|rw-------'  | awk '{print $9}' `
	if [[ $VARLOG != '' ]]; then
		VAL1427=`expr $VAL1427 + 2`
	fi
fi

if [[ VAL1427 -eq 0 ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1427L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else 
	x1="$x1$DSID:$NC;"
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1427L >> ${ArchSal}
	echo ":: :: Los siguientes archivos de bitácora no cumplen con los permisos" >> ${ArchSal}
	#PENDIENTES
	echo "::: ID $DSID" >> ${PENDIENTES}
	echo ":: :: Los siguientes archivos de bitácora no cumplen con los permisos, se recomienda los permisos 644" >> ${PENDIENTES}

	if [[ $VAL1427 -eq 1 || $VAL1427 -eq 3 ]]; then
		for item in ${VARADM[*]}
		do
			printf "%s\n" $item >> ${ArchSal}
			printf "%s\n" $item >> ${PENDIENTES}
		done
	fi

	if [[ $VAL1427 -eq 2 || $VAL1427 -eq 3 ]]; then
		for item in ${VARLOG[*]}
		do
			printf "%s\n" $item >> ${ArchSal}
			printf "%s\n" $item >> ${PENDIENTES}
		done
	fi

	echo "" >> ${PENDIENTES}
fi

echo "" >> ${ArchSal}
#1441
DSID="SRV-58"
ID1441L=":: El sistema no permite la reutilización de al menos las últimas 5 contraseñas.";
REMEMBER=`cat /etc/pam.d/system-auth | grep 'password' | grep 'sufficient' | grep 'pam_unix.so' | grep 'remember=5'`
if [[ $REMEMBER != '' ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1441L >> ${ArchSal}
	#echo ":: :: Cumple " >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1441L >> ${ArchSal}
	echo ":: :: Configurar el archivo /etc/pam.d/system-auth" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	echo "::: ID $DSID " >> ${PENDIENTES}
	echo ":: :: Configurar el archivo /etc/pam.d/system-auth, una linea similar a la siguiente: " >> ${PENDIENTES}
	echo ":: :: password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok remember=5" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi
echo "" >> ${ArchSal}
#1443
DSID="SRV-60"
ID1443L=":: Solo el usuario root tiene permisos para el uso de servicio cron y at.";
CRONDIR="/var/spool/cron/"
ATDIR="/var/spool/at/spool/"
ARR1443=('root','apache','jboss','oracle');
CRON=`ls $CRONDIR | grep -v -E 'root|oracle|apache|jboss|tibco'`
AT=`ls $ATDIR | grep -v -E 'root|oracle|apache|jboss|tibco'`
if [[ $CRON = '' && $AT = '' ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1443L >> ${ArchSal}
	#echo ":: :: Cumple " >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1443L >> ${ArchSal}
	#echo ":: :: Pendiente " >> ${ArchSal}
	echo ":: :: Validar los permisos para el uso de cron y at de los siguientes usuarios" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	echo "::: ID $DSID " >> ${PENDIENTES}
	echo "Validar los permisos para el uso de cron y at de los siguientes usuarios" >> ${PENDIENTES}

	if [[ $CRON != '' ]]; then
		#ls /var/spool/cron/cron | grep -v -E 'root|oracle|apache|jboss' >> ${ArchSal}
                #ls /var/spool/cron/cron | grep -v -E 'root|oracle|apache|jboss' >> ${PENDIENTES}
		ls $CRONDIR | grep -v -E 'root|oracle|apache|jboss' >> ${ArchSal}
		ls $CRONDIR | grep -v -E 'root|oracle|apache|jboss' >> ${PENDIENTES}
	fi

	if [[ $AT != '' ]]; then
		#ls /var/spool/at/spool/ | grep -v -E 'root|oracle|apache|jboss' >> ${ArchSal}
		#ls /var/spool/at/spool/ | grep -v -E 'root|oracle|apache|jboss' >> ${PENDIENTES}
		ls $ATDIR | grep -v -E 'root|oracle|apache|jboss' >> ${ArchSal}
		ls $ATDIR | grep -v -E 'root|oracle|apache|jboss' >> ${PENDIENTES}

	fi
	
	echo "" >> ${PENDIENTES}

fi
echo "" >> ${ArchSal}
#1446
DSID="SRV-63"
ID1446L=":: La configuración de hora del sistema se realiza a través del servicio ntp corporativo.";
NTPX=`echo $?`
NTP2=`cat /etc/ntp.conf | grep -v '^#' | grep 'server' | grep -v 'ntp.org'`
if [[ $NTP2 != '' ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal};
	echo $ID1446L >> ${ArchSal};
	#echo ":: :: Cumple " >> ${ArchSal}
	echo ":: :: El servidor esta configurado a los siguientes servidores ntp:" >> ${ArchSal}
	#cat /etc/ntp.conf | grep -v '^#' | grep 'server' | grep -v 'ntp.org' >> ${ArchSal}
	cat /etc/systemd/timesyncd.conf | grep -v '^#' | grep 'NTP' | grep -v 'ntp.org' >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal};
	echo $ID1446L >> ${ArchSal};
	#echo ":: :: Pendiente " >> ${ArchSal}
	echo ":: :: Configurar el servicio ntp corporativo" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: ID $DSID " >> ${PENDIENTES}
	echo "Configurar el servicio ntp corporativo" >> ${PENDIENTES}
	echo " " >> ${PENDIENTES}
fi
echo "" >> ${ArchSal}
}	

function Ubuntu {
#Seguridad del servidor 
#1386
DSID="1386"
ID1386L=":: El servidor cuenta con los últimos parches de seguridad (release mayor) que recomienda el proveedor."

#1427
DSID="SRV-44"
ID1427L=":: Los archivos de bitácora de sistema ubicados en (/var/log y /var/adm) sólo pueden ser escritos por root.";
VAL1427=0
VARADM=''
VARLOG=''
if [[ "$(ls -A /var/log)" ]]; then
	VARLOG=`ls -l -n /var/log/*.log | grep -v -E 'rw-r--r--|rw-------'  | awk '{print $9}' `
	if [[ $VARLOG != '' ]]; then
		VAL1427=`expr $VAL1427 + 2`
	fi
fi

if [[ VAL1427 -eq 0 ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1427L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else 
	x1="$x1$DSID:$NC;"
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1427L >> ${ArchSal}
	echo ":: :: Los siguientes archivos de bitácora no cumplen con los permisos" >> ${ArchSal}
	#PENDIENTES
	echo "::: ID $DSID" >> ${PENDIENTES}
	echo ":: :: Los siguientes archivos de bitácora no cumplen con los permisos, se recomienda los permisos 644" >> ${PENDIENTES}

	if [[ $VAL1427 -eq 1 || $VAL1427 -eq 3 ]]; then
		for item in ${VARADM[*]}
		do
			printf "%s\n" $item >> ${ArchSal}
			printf "%s\n" $item >> ${PENDIENTES}
		done
	fi

	if [[ $VAL1427 -eq 2 || $VAL1427 -eq 3 ]]; then
		for item in ${VARLOG[*]}
		do
			printf "%s\n" $item >> ${ArchSal}
			printf "%s\n" $item >> ${PENDIENTES}
		done
	fi

	echo "" >> ${PENDIENTES}
fi

echo "" >> ${ArchSal}
#1441
DSID="SRV-58"
ID1441L=":: El sistema no permite la reutilización de al menos las últimas 5 contraseñas."
REMEMBER=`cat /etc/pam.d/common-password | grep 'password' | grep 'sufficient' | grep 'pam_unix.so' | grep 'remember=5'`
if [[ $REMEMBER != '' ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1441L >> ${ArchSal}
	#echo ":: :: Cumple " >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1441L >> ${ArchSal}
	#echo ":: :: Pendiente " >> ${ArchSal}	
	#echo ":: :: Configurar el archivo /etc/pam.d/system-auth" >> ${ArchSal}
	echo ":: :: Configurar el archivo /etc/pam.d/common-password" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	echo "::: ID $DSID " >> ${PENDIENTES}
	#echo ":: :: Configurar el archivo /etc/pam.d/system-auth, una linea similar a la siguiente: " >> ${PENDIENTES}
	echo ":: :: Configurar el archivo /etc/pam.d/common-password, una linea similar a la siguiente: " >> ${PENDIENTES}
	echo ":: :: password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok remember=5" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi
echo "" >> ${ArchSal}
#1443

CRONDIR="/var/spool/cron/crontabs/"
ATDIR="/var/spool/cron/atjobs/"
CRON=`ls $CRONDIR | grep -v -E 'root|oracle|apache|jboss|tibco'`
AT=`ls $ATDIR | grep -v -E 'root|oracle|apache|jboss|tibco'`
DSID="SRV-60"
if [[ $CRON = '' && $AT = '' ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1443L >> ${ArchSal}
	#echo ":: :: Cumple " >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1443L >> ${ArchSal}
	#echo ":: :: Pendiente " >> ${ArchSal}
	echo ":: :: Validar los permisos para el uso de cron y at de los siguientes usuarios" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	echo "::: ID $DSID " >> ${PENDIENTES}
	echo "Validar los permisos para el uso de cron y at de los siguientes usuarios" >> ${PENDIENTES}

	if [[ $CRON != '' ]]; then
		#ls /var/spool/cron/cron | grep -v -E 'root|oracle|apache|jboss' >> ${ArchSal}
                #ls /var/spool/cron/cron | grep -v -E 'root|oracle|apache|jboss' >> ${PENDIENTES}
		ls $CRONDIR | grep -v -E 'root|oracle|apache|jboss' >> ${ArchSal}
		ls $CRONDIR | grep -v -E 'root|oracle|apache|jboss' >> ${PENDIENTES}
	fi

	if [[ $AT != '' ]]; then
		#ls /var/spool/at/spool/ | grep -v -E 'root|oracle|apache|jboss' >> ${ArchSal}
		#ls /var/spool/at/spool/ | grep -v -E 'root|oracle|apache|jboss' >> ${PENDIENTES}
		ls $ATDIR | grep -v -E 'root|oracle|apache|jboss' >> ${ArchSal}
		ls $ATDIR | grep -v -E 'root|oracle|apache|jboss' >> ${PENDIENTES}

	fi
	
	echo "" >> ${PENDIENTES}

fi
echo "" >> ${ArchSal}
#1446
DSID="SRV-63"
ID1446L=":: La configuración de hora del sistema se realiza a través del servicio ntp corporativo.";
NTPX=`echo $?`
NTP2=`cat /etc/systemd/timesyncd.conf | grep -v '^#' | grep 'NTP' | grep -v 'ntp.org'`
if [[ $NTP2 != '' ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal};
	echo $ID1446L >> ${ArchSal};
	#echo ":: :: Cumple " >> ${ArchSal}
	echo ":: :: El servidor esta configurado a los siguientes servidores ntp:" >> ${ArchSal}
	#cat /etc/ntp.conf | grep -v '^#' | grep 'server' | grep -v 'ntp.org' >> ${ArchSal}
	cat /etc/systemd/timesyncd.conf | grep -v '^#' | grep 'NTP' | grep -v 'ntp.org' >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal};
	echo $ID1446L >> ${ArchSal};
	#echo ":: :: Pendiente " >> ${ArchSal}
	echo ":: :: Configurar el servicio ntp corporativo" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: ID $DSID " >> ${PENDIENTES}
	echo "Configurar el servicio ntp corporativo" >> ${PENDIENTES}
	echo " " >> ${PENDIENTES}
fi
echo "" >> ${ArchSal}
}		

function JBoss {
echo "****************************** Certificacion de JBoss ******************************" >> ${ArchSal}
#1481
INSDIR=$(ps -ef | grep org.jboss.as | awk '{print $28}' | cut -f2 -d=)
JBOSSDIR=$(ps -ef | grep org.jboss.as | awk '{print $27}' | cut -f2 -d=)
DSID="SRV-93"
ID1481L=":: Se deshabilitó la navegación por directorios."
#ID1481=$(cat /home/jboss/jboss-eap-6.*/*/configuration/standalone.xml | grep 'static-resources listings="true"')
ID1481=$(cat $INSDIR/configuration/standalone.xml | grep 'static-resources listings="true"')
if [[ $ID1481 = '' ]]; then
        echo "::: ID $DSID : $C" >> ${ArchSal}
        echo $ID1481L  >> ${ArchSal}
		x1="$x1$DSID:$C;"
else
    	echo "::: ID $DSID : $NC" >> ${ArchSal}
        echo $ID1481L >> ${ArchSal}
		echo "::: ID $DSID : $NC" >> ${PENDIENTES}
        echo $ID1481L >> ${PENDIENTES}
		x1="$x1$DSID:$NC;"
fi
echo "" >> ${ArchSal}
#1482
DSID="SRV-94"
ID1482L=":: Las pantallas de administración no están visibles."
#ID1482=$(cat /home/jboss/jboss-eap-6.*/*/configuration/standalone.xml | grep 'enable-welcome-root' | grep 'false')
ID1482=$(cat $INSDIR/configuration/standalone.xml | grep 'enable-welcome-root' | grep 'false')
if [[ $ID1482 != "" ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1482L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1482L >> ${ArchSal}
	
	echo "::: ID $DSID : $NC" >> ${PENDIENTES}
	echo $ID1482L >> ${PENDIENTES}
	echo "cambiar enable-welcome-root a false" >> ${PENDIENTES}
	x1="$x1$DSID:$NC;"
fi
echo "" >> ${ArchSal}

#1483
DSID="SRV-95"
ID1483L=":: Los  manuales y las pantallas por default del servidor web no están visibles."
#ID1483=$(cat /home/jboss/jboss-eap-6.*/*/configuration/standalone.xml | grep 'enable-welcome-root' | grep 'false')
ID1482=$(cat $INSDIR/configuration/standalone.xml | grep 'enable-welcome-root' | grep 'false')
if [[ $ID1483 != "" ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1483L >> ${ArchSal}
	x1="$x1$DSID:$C;"
	
	
	
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1483L >> ${ArchSal}
	
	echo "::: ID $DSID : $NC" >> ${PENDIENTES}
	echo $ID1483L >> ${PENDIENTES}
	echo "cambiar enable-welcome-root a false" >> ${PENDIENTES}
	x1="$x1$DSID:$NC;"
fi
echo "" >> ${ArchSal}

#1489
DSID="SRV-100"
ID1489L=":: Se deshabilitaron los métodos TRACE, TRACK, DELETE, PUT, OPTIONS, HEAD y CONNECT"
#ID1489=$(cat /home/jboss/jboss-eap-6.*/*/configuration/standalone.xml | grep 'condition test' | grep '"%{REQUEST_METHOD}"' | grep 'pattern' | grep -E 'TRACE|TRACK|DELETE|PUT|OPTIONS|HEAD|CONNECT')
ID1489=$(cat $INSDIR/configuration/standalone.xml | grep 'condition test' | grep '"%{REQUEST_METHOD}"' | grep 'pattern' | grep -E 'TRACE|TRACK|DELETE|PUT|OPTIONS|HEAD|CONNECT')
if [[ $ID1489 = "" ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1489L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1489L >> ${ArchSal}
	
	echo "::: ID $DSID : $NC" >> ${PENDIENTES}
	echo $ID1489L >> ${PENDIENTES}
	echo "evitar la sobrescritura de metodos" >> ${PENDIENTES}
	x1="$x1$DSID:$NC;"
fi
echo "" >> ${ArchSal}

#1490
DSID="SRV-101"
ID1490L="El usuario y el grupo con el que corre el servidor web son únicos y diferentes a root"
ID1490_1=$(ls -lst  /home/jboss | grep $JBOSSDIR | awk '{print $4}')
ID1490_2=$(ls -lst  /home/jboss | grep $JBOSSDIR | awk '{print $5}')
if [[ $ID1490_1 = "jboss" && $ID1490_2 = "jboss" ]]; then 
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1490L >> ${ArchSal}
	echo $(ls -lst  /home/jboss | grep $JBOSSDIR) >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1490L >> ${ArchSal}
	echo $(ls -lst  /home/jboss | grep $JBOSSDIR) >> ${ArchSal}
	
	echo "::: ID $DSID : $NC" >> ${PENDIENTES}
	echo $ID1490L >> ${PENDIENTES}
	echo $(ls -lst  /home/jboss | grep $JBOSSDIR) >> ${PENDIENTES}
	x1="$x1$DSID:$NC;"
fi
echo "" >> ${ArchSal}
#1491
DSID="SRV-102"
ID1491L="La cuenta con la que corre el servidor web no tiene password y no tiene shell asignado"
ID1491=$(cat /etc/passwd | grep 'jboss' | grep -v -E '/sbin/nologin|bin/false')
if [[ $ID1491 = "" ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1491L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1491L >> ${ArchSal}
	
	echo "::: ID $DSID : $NC" >> ${PENDIENTES}
	echo $ID1491L >> ${PENDIENTES}
	echo $(cat /etc/passwd | grep 'jboss') >> ${PENDIENTES}
	x1="$x1$DSID:$NC;"
fi
echo "" >> ${ArchSal}
#1492
DSID="SRV-103"
ID1492L="El usuario con el que se administra la aplicación o el manejador de contenido, debe ser diferente a root y al usuario con el que corre el servidor web."

#1493
DSID="SRV-104"
ID1493L="Los archivos de la aplicación solo tienen permisos de lectura y no son propiedad del usuario con el que corre el servidor web"
ID1493D=($(ls -d $INSDIR/deployments))
ID1493=0
ID1493arch=""
for direc in ${ID1493D[*]}
do
  	ID1493F=($(ls  $direc))
        for fil in ${ID1493F[*]}
        do
          	ID1493R=$(ls -lrt $direc/$fil | awk '{print $3}')
            ID1493R2=$(ls -lrt $direc/$fil | awk '{print $1}')
            if [[ $ID1493R != "root" || $ID1493R2 != "-rw-r-----." ]]; then
                ID1493=$ID1493+1
				ID1493arch="$ID1493arch $direc/$fil\n"
            fi
        done
done

if [[ ID1493 -eq 0 ]]; then
        echo "::: ID $DSID : $C" >> ${ArchSal}
		echo $ID1493L >> ${ArchSal}
		x1="$x1$DSID:$C;"
else
    	echo "::: ID $DSID : $NC" >> ${ArchSal}
		echo $ID1493L >> ${ArchSal}
		
		echo "::: ID $DSID : $NC" >> ${PENDIENTES}
		echo $ID1493L >> ${PENDIENTES}
		echo " Los sigientes archivos deben de tener estos valores: permiso 640 y owner root" >> ${PENDIENTES}
		echo -e $ID1493arch >> ${PENDIENTES}	
		x1="$x1$DSID:$NC;"		
fi
echo "" >> ${ArchSal}
#1494
DSID="SRV-105"
ID1494L="Las carpetas de la aplicación solo tienen permisos de lectura y ejecución además no son propiedad del usuario con el que corre el servidor web"
ID1494D=($(ls -d $INSDIR/deployments))
ID1494=0
ID1494dirs=""
for d in ${ID1494D[*]}
do 
	ID1494R=$(ls -lrt $d | awk '{print $3}')
    ID1494R2=$(ls -lrt $d | awk '{print $1}')
	if [[ $ID1494R != "root" || $ID1494R2 != "drwxr-x---." ]]; then
		ID1494=$ID1494+1
		ID1494dirs="$ID1494dirs $d"
	fi
done
if [[ ID1494 -eq 0 ]]; then
        echo "::: ID $DSID : $C" >> ${ArchSal}
		echo $ID1494L >> ${ArchSal}
		x1="$x1$DSID:$C;"
else
    	echo "::: ID $DSID : $NC" >> ${ArchSal}
		echo $ID1494L >> ${ArchSal}
		
		echo "::: ID $DSID : $NC" >> ${PENDIENTES}
		echo $ID1494L >> ${PENDIENTES}
		echo " Los sigientes directorios deben de tener estos valores: permiso 750 y owner root" >> ${PENDIENTES}
		echo -e $ID1494dirs >> ${PENDIENTES}	
		echo "" >> ${PENDIENTES}
		x1="$x1$DSID:$NC;"		
fi
echo "" >> ${ArchSal}	
#1495
DSID="SRV-106"
ID1495L="Se tienen habilitados los logs de acceso y error por cada aplicación, además se almacenan en directorios propiedad de root con accesos restringidos"
ID1495D=($(cat $INSDIR/configuration/logging.properties | grep 'logger.org.jboss.as.config.level' | cut -f2 -d'='))
ID1495=0
for a in ${ID1495D[*]}
do
	if [[ $a != "ERROR" ]]; then
		ID1495=$ID1495+1
	fi
done
	
if [[ $ID1495 -eq 0 ]]; then 
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1495L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else	
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1495L >> ${ArchSal}
	
	echo "::: ID $DSID : $NC" >> ${PENDIENTES}
	echo $ID1495L >> ${PENDIENTES}
	echo "Cambiar a ERROR todos los logger.org.jboss.as.config.level de cada intancia" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
	x1="$x1$DSID:$NC;"
fi
echo "" >> ${ArchSal}

#1496
DSID="SRV-107"
ID1496L="Eliminar el contenido default de las carpetas"
ID1496=$(ls $JBOSSDIR | grep welcome-content)
if [[ 1496 = "" ]]; then
		echo "::: ID $DSID : $C" >> ${ArchSal}
		echo $ID1496L >> ${ArchSal}
		x1="$x1$DSID:$C;"
else
		echo "::: ID $DSID : $NC" >> ${ArchSal}
		echo $ID1496L >> ${ArchSal}
		
		echo "::: ID $DSID : $NC" >> ${PENDIENTES}
		echo $ID1496L >> ${PENDIENTES}
		echo "Eliminar contenido de default" >> ${PENDIENTES}
		echo "" >> ${PENDIENTES}
		x1="$x1$DSID:$NC;"
fi
echo "" >> ${ArchSal}

#1497
DSID="SRV-108"
ID1497L="Los archivos de configuración son propiedad de root y pertenecean al grupo de administradores."
ID1497D=($(ls -d $INSDIR/configuration))
ID1497=0
ID1497arch=""
for d in ${ID1497D[*]}
do
	ID1497F=($(ls  $d))
        for fil in ${ID1497F[*]}
        do
          	ID1497R=$(ls -lrt $d/$fil | awk '{print $3}')
            if [[ $ID1497R != "root" ]]; then
                ID1497=$ID1497+1
				ID1497arch="$ID1497arch $d/$fil\n"
            fi
        done
done
if [[ $ID1497 -eq 0 ]]; then 
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1497L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1497L >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	echo "::: ID $DSID : $C" >> ${PENDIENTES}
	echo $ID1497L >> ${PENDIENTES}
	echo "los siguientes archivos deberan pertenecer al root" >> ${PENDIENTES}
	echo -e $ID1497arch >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi
echo "" >> ${ArchSal}

#1498
DSID="SRV-109"
ID1498L="::: La carpeta /bin del servidor web es propiedad de root y tiene establecidos los permisos 770 además los archivos que contiene también son propiedad de root con permisos 660"
ID1498C=$(ls -lrtd $JBOSSDIR/bin | awk '{print $3}')
ID1498CP=$(ls -lrtd $JBOSSDIR/bin | awk '{print $1}')
ID1498=0
ID1498arch=""
if [[ $ID1498C = "jboss" && $ID1498CP = "drwxrwx---." ]]; then
	ID1498F=($(ls  /home/jboss/jboss-eap-6.*/bin))
	for fil in ${ID1498F[*]}
	do
		ID1498FO=$(ls -lrt $JBOSSDIR/bin/$fil | awk '{print $3}' )
		ID1498FP=$(ls -lrt $JBOSSDIR/bin/$fil | awk '{print $1}')
		if [[ $ID1498FO != "root" || $ID1498FP != "-rw-rw----." ]]; then
			ID1498=$ID1498+1
			ID1498arch="$ID1498arch /home/jboss/jboss-eap-6.*/bin/$fil\n"
		fi
	done
else
	ID1498=1
fi

if [[ $ID1498 -eq 0 ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1498L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1498L >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	
	echo "::: ID $DSID : $NC" >> ${PENDIENTES}
	echo $ID1498L >> ${PENDIENTES}
	echo "los carpeta bin del servidor debe ser propiedad de root y con los permisos 770 asi como los archivos siguientes tambien deben ser propiedad de root y los permisos 660" >> ${PENDIENTES}
	echo -e $ID1498arch >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi
echo "" >> ${ArchSal}

#1522
DSID="SRV-143"
ID1522L=":: Habilitar la seguridad de la consola de administración de JBOSS"
ID1522=$(cat $INSDIR/configuration/standalone.xml | grep 'enable-welcome-root' | grep 'false')
if [[ $ID1522 != "" ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1522L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1522L >> ${ArchSal}
	
	echo "::: ID $DSID : $NC" >> ${PENDIENTES}
	echo $ID1522L >> ${PENDIENTES}
	echo "cambiar enable-welcome-root a false" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
	x1="$x1$DSID:$NC;"
fi
echo "" >> ${ArchSal}
	
#1548
DSID="SRV-145"
ID1548L="Habilitar el Java Security Manager."
ID1548=$(cat $JBOSSDIR/bin/standalone.conf | grep -v '^#' | grep  'SECMGR="true"')
if [[ $ID1548 = "" ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1548L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1548L >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	
	echo "::: ID $DSID : $NC" >> ${PENDIENTES}
	echo $ID1548L >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi
echo "" >> ${ArchSal}

#1549
DSID="SRV-146"
ID1549L="Filtrar el acceso a las consolas de gestion a direcciones IP determinadas."
echo "::: ID $DSID : $P" >> ${ArchSal}
echo " Validacion Manual " >> ${ArchSal}
echo "-------------- jboss BINDINGS ---------------------" >> ${ArchSal}
cat $INSDIR/configuration/standalone.xml | grep 'socket-binding name' >> ${ArchSal}
x1="$x1$DSID:$P"
echo "" >> ${ArchSal}

#1551
DSID="SRV-148"
ID1551L="Separar las interfaces de administaración y aplicativas."
ID1551C=($(ls $INSDIR/configuration/standalone.xml))
ID1551=0
ID1551arch=""
for cf in ${ID1551C[*]}
do
	ID1551M=$(cat $cf | grep 'inet' | grep 'jboss.bind.address.management' | cut -f2 -d':' | cut -f1 -d'}')
	ID1551P=$(cat $cf | grep 'inet' | grep 'jboss.bind.address:' | cut -f2 -d':' | cut -f1 -d'}')
	if [[ $ID1551M = $ID1551P ]]; then
		ID1551=$ID1551+1
		ID1551arch="$ID1551arch $cf\n"
	fi
done

if [[ $ID1551 -eq 0 ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1551L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1551L >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	
	echo "::: ID $DSID : $NC" >> ${PENDIENTES}
	echo $ID1551L >> ${PENDIENTES}
	echo "los valores de jboss.bind.address.management y jboss.bind.address deben de ser distintos en los archivos siguientes: " >> ${PENDIENTES}
	echo -e $ID1551arch >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi
echo "" >> ${ArchSal}

#1552
DSID="SRV-149"
ID1552L="Utilizar cifrados fuertes en la comunicación web."
ID1552C=($(ls $INSDIR/configuration/standalone.xml))
ID1552=0
ID1552arch=""
for cf in ${ID1552C[*]}
do
	ID1552H=$(cat $cf | grep 'connector name="https"' | grep 'enable' | grep 'true')
	if [[ $ID1552H = "" ]]; then
		ID1552=$ID1552+1
		ID1552arch="$ID1552arch $cf\n"
	fi
done

if [[ $ID1552 -eq 0 ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1552L >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1552L >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	
	echo "::: ID $DSID : $NC" >> ${PENDIENTES}
	echo $ID1552L >> ${PENDIENTES}
	echo "debera ecistir un conector que soporte https " >> ${PENDIENTES}
	echo -e $ID1552arch >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi
echo "" >> ${ArchSal}
			
#1553
DSID="SRV-150"
ID1553L="Deshabilitar la autenticacion silenciosa del Default Security Realm y utilizar usuarios personalizados para la administración."
ID1553C=($(ls $INSDIR/configuration/standalone.xml))
ID1553=0
ID1553arch=""
for cf in ${ID1553C[*]}
do
	ID1553H=$(cat $cf | grep '<local default-user=' | grep 'local' |  grep 'skip-group-loading' | grep 'true')
	if [[ $ID1553H != "" ]]; then
		ID1553=$ID1553+1
		ID1553arch="$ID1553arch $cf\n"
	fi
done

if [[ $ID1553 -eq 0 ]]; then
	echo "::: ID $DSID : $C" >> ${ArchSal}
	echo $ID1553L >> ${ArchSal}
	x1="$x1$DSID:$C"
else
	echo "::: ID $DSID : $NC" >> ${ArchSal}
	echo $ID1553L >> ${ArchSal}
	x1="$x1$DSID:$NC"
	
	echo "::: ID $DSID : $NC" >> ${PENDIENTES}
	echo $ID1553L >> ${PENDIENTES}
	echo "Evita el ingreso no autorizado a la administración desde la consola. " >> ${PENDIENTES}
	echo -e $ID1553arch >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi
echo "" >> ${ArchSal}
}	

function Apache {
httpd="/etc/httpd/conf/httpd.conf"
echo "****************************** Certificacion de Apache (httpd) ******************************" >> ${ArchSal}
#1481 - AP
DSID="SRV-93"
DSTZ1=":: Se deshabilitó la navegación por directorios."
ID1481=$(cat $httpd | grep -v '#' | grep "\-Indexes")
if [[ $ID1481 != "" ]]; then
	echo ":: ID $DSID : $C" >> ${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo ":: ID $DSID : $NC" >>${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "::::Habilitar Options -Indexes en todos los directorios
				Ejemplo:
					<Directory >
  					Options -Indexes
				</Directory>" >> ${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: $DSTZ1" >> ${PENDIENTES}
	echo "::::Habilitar Options -Indexes en todos los directorios
				Ejemplo:
					<Directory >
  					Options -Indexes
				</Directory>" >> ${PENDIENTES}
	echo "$lna" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi

#1486 - AP
DSID="SRV-98"
DSTZ1="Se modificó el archivo de configuración para no mostrar la versión del servidor web instalado."
ID1486T=$(cat $httpd | grep "ServerTokens" | grep "Prod")
ID1486S=$(cat $httpd | grep "ServerSignature" | grep -E "Off|OFF|off")
if [[ $ID1486T != "" && $ID1486S != "" ]]; then
	echo ":: ID $DSID : $C" >> ${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo ":: ID $DSID : $NC" >>${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "::::Agregar las opciones siguientes al archivo de configuracion:
				Apache En httpd.conf.
					ServerTokens Prod
					ServerSignature Off" >>${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: $DSTZ1" >> ${PENDIENTES}
	echo "::::Agregar las opciones siguientes al archivo de configuracion:
				Apache En httpd.conf.
					ServerTokens Prod
					ServerSignature Off" >> ${PENDIENTES}
	echo "$lna" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi

#1487 - AP
DSID="SRV-99"
DSTZ1="El sistema evita mostrar cuando un directorio existe o no, enviando siempre el mismo mensaje de error o una página en blanco."
ID1487=$(cat $httpd | grep -E -v "^#" | grep "ErrorDocument" | grep -E "404|403|500|401|400|402")
if [[ $ID1487 != "" ]]; then
	echo ":: ID $DSID : $C" >> ${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo ":: ID $DSID : $NC" >>${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "::::Agregar las opciones siguientes al archivo de configuracion:
				En httpd.conf
					ErrorDocument 404 404 File not found
					ErrorDocument 403 404 File not found
					ErrorDocument 500 custom page
					ErrorDocument 401 custom page
					ErrorDocument 400 custom page" >>${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: $DSTZ1" >> ${PENDIENTES}
	echo "::::Agregar las opciones siguientes al archivo de configuracion:
				En httpd.conf
					ErrorDocument 404 404 File not found
					ErrorDocument 403 404 File not found
					ErrorDocument 500 custom page
					ErrorDocument 401 custom page
					ErrorDocument 400 custom page" >> ${PENDIENTES}
	echo "$lna" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi

#1489 - AP
DSID="SRV-100"
DSTZ1="Se deshabilitaron los métodos TRACE, TRACK, DELETE, PUT, OPTIONS, HEAD y CONNECT"
ID1489L=$(cat $httpd | grep -v "#" | grep "LimitExcept" | grep "GET" | grep "POST" | grep "HEAD")
if [[ $ID1489L != "" ]]; then
	ID1489=$(cat $httpd | grep -v "#" | grep "deny" | grep "from" | grep "all")
	if [[ $ID1489 != "" ]]; then
		echo ":: ID $DSID : $C" >> ${ArchSal}
		echo "::: $DSTZ1" >> ${ArchSal}
		echo "$lna" >> ${ArchSal}
		echo "" >> ${ArchSal}
		x1="$x1$DSID:$C;"
	else
		echo ":: ID $DSID : $NC" >>${ArchSal}
		echo "::: $DSTZ1" >> ${ArchSal}
		echo "::::Agregar las opciones siguientes al archivo de configuracion:
					En httpd.conf
						<LimitExcept GET POST HEAD>
							deny from all
						</LimitExcept>" >>${ArchSal}
		echo "$lna" >> ${ArchSal}
		echo "" >> ${ArchSal}
		x1="$x1$DSID:$NC;"
		#PENDIENTES
		echo "::: $DSTZ1" >> ${PENDIENTES}
		echo "::::Agregar las opciones siguientes al archivo de configuracion:
					En httpd.conf
						<LimitExcept GET POST HEAD>
							deny from all
						</LimitExcept>" >>${PENDIENTES}
		echo "$lna" >> ${PENDIENTES}
		echo "" >> ${PENDIENTES}
	fi
else
	echo ":: ID $DSID : $NC" >>${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "::::Agregar las opciones siguientes al archivo de configuracion:
				En httpd.conf
					<LimitExcept GET POST HEAD>
						deny from all
					</LimitExcept>" >>${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
		echo "::: $DSTZ1" >> ${PENDIENTES}
		echo "::::Agregar las opciones siguientes al archivo de configuracion:
					En httpd.conf
						<LimitExcept GET POST HEAD>
							deny from all
						</LimitExcept>" >>${PENDIENTES}
		echo "$lna" >> ${PENDIENTES}
		echo "" >> ${PENDIENTES}
fi

#1490 - AP
DSID="SRV-101"
DSTZ1="El usuario y el grupo con el que corre el servidor web son únicos y diferentes a root."
ID1490U=$(cat $httpd | grep -E "user|User" | grep -E "apache|Apache")
ID1490G=$(cat $httpd | grep -E "group|Group" | grep -E "apache|Apache")
echo "control" >> ${ArchSal}
if [[ $ID1490U != "" && $ID1490G != "" ]]; then
	echo ":: ID $DSID : $C" >> ${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo ":: ID $DSID : $NC" >>${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "::::Agregar las opciones siguientes al archivo de configuracion:
				En httpd.conf
					 User apache
 					 Group apache" >>${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: $DSTZ1" >> ${PENDIENTES}
	echo "::::Agregar las opciones siguientes al archivo de configuracion:
				En httpd.conf
					 User apache
 					 Group apache" >> ${PENDIENTES}
	echo "$lna" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi

#1491 - AP
DSID="SRV-102"
DSTZ1="La cuenta con la que corre el servidor web no tiene passwod y no tiene shell asignado"
ID1491=$(cat /etc/passwd | grep -E 'admwww|apache|Apache' | grep -v -E '/sbin/nologin|/usr/bin/false')
if [[ ID1491 = "" ]]; then
	echo ":: ID $DSID : $C" >> ${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo ":: ID $DSID : $NC" >>${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "::::el siguiente usuario no cumple con la configuracion sugerida" >>${ArchSal}
	echo "$ID1491" >> ${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: $DSTZ1" >> ${PENDIENTES}
	echo "::::el siguiente usuario no cumple con la configuracion sugerida" >> ${PENDIENTES}
	echo "$ID1491" >> ${PENDIENTES}
	echo "$lna" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi

#1492 - AP
DSID="SRV-103"
DSTZ1="El usuario con el que se administra la aplicación o el manejador de contenido, debe ser diferente a root y al usuario con el que corre el servidor web."
ID1492U=$(cat $httpd | grep -E "user|User" | grep -E "apache|Apache")
ID1492G=$(cat $httpd | grep -E "group|Group" | grep -E "apache|Apache")
if [[ $ID1492U != "" && $ID1492G != "" ]]; then
	echo ":: ID $DSID : $C" >> ${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo ":: ID $DSID : $NC" >>${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "::::Agregar las opciones siguientes al archivo de configuracion:
				En httpd.conf
					 User apache
 					 Group apache" >>${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: $DSTZ1" >> ${PENDIENTES}
	echo "::::Agregar las opciones siguientes al archivo de configuracion:
				En httpd.conf
					 User apache
 					 Group apache" >> ${PENDIENTES}
	echo "$lna" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi

#1493

#1494

#1495
DSID="SRV-106"
DSTZ1="Se tienen habilitados los logs de acceso y error por cada aplicación, además se almacenan en directorios propiedad de root con accesos restringidos."
ID1495L=$(cat $httpd | grep -v '#' | grep -E 'CustomLog|TransferLog')
ID1495E=$(cat $httpd | grep -v '#' | grep -E 'ErrorLog')
ID1495D=$(ls -lrtd /var/log/httpd/ | awk '{print $1}')
ID1495R=$(ls -lrtd /var/log/httpd/ | awk '{print $3}')
ID1495ARR=($(ls -lrt /var/log/httpd/ | awk '{print $1}'))
ID1495A=0
for item in ${ID1495ARR[*]}
do 
	if [[ item = "-rw-r-----." ]]; then
		ID1495A = $ID1495A+1
	fi
done

if [[ ID1495L != "" && ID1495E != "" && ID1495D = "drwx-r-x---." && ID1495A -eq ${#ID1495ARR[@]}-1 && ID1495R = "root" ]];then 
	echo ":: ID $DSID : $C" >> ${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo ":: ID $DSID : $NC" >>${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "::::Agregar las opciones siguientes al archivo de configuracion:
				En httpd.conf debe aparecer las siguientes lineas
					 En Apache httpd.conf
						TransferLog o CustomLog
						ErrorLog
					Los directorios /var/log/httpd debe tener los permisos 750 y los archivos de log 640 ambos propiedad de root">>${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: $DSTZ1" >> ${PENDIENTES}
	echo "::::Agregar las opciones siguientes al archivo de configuracion:
				En httpd.conf debe aparecer las siguientes lineas
					 En Apache httpd.conf
						TransferLog o CustomLog
						ErrorLog
					Los directorios /var/log/httpd debe tener los permisos 750 y los archivos de log 640 ambos propiedad de root">>${PENDIENTES}
	echo "$lna" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi

#1496 - AP
DSID="SRV-107"
DSTZ1="Eliminar el contenido default de las carpetas /default  /icons , /errors ,  /htdocs y /cgi-bin."
ID1496=$(ls /var/www | grep -v 'html')
if [[ ID1496 = "" ]]; then
	echo ":: ID $DSID : $C" >> ${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo ":: ID $DSID : $NC" >>${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "::::Borrar el contenido de default ">>${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: $DSTZ1" >> ${PENDIENTES}
	echo "::::Borrar el contenido de default ">>${PENDIENTES}
	echo "$lna" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi

#1497
DSID="SRV-108"
DSTZ1="Los archivos de configuración son propiedad de root y pertenecean al grupo de administradores."
ID1497=$(ls -lrt /etc/httpd/conf/httpd.conf | awk '{print $3$4'})
if [[ $ID1497 = "rootroot" ]]; then
	echo ":: ID $DSID : $C" >> ${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo ":: ID $DSID : $NC" >>${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "::::chown root:root /etc/httpd/conf/httpd.conf ">>${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: $DSTZ1" >> ${PENDIENTES}
	echo "::::chown root:root /etc/httpd/conf/httpd.conf ">> ${PENDIENTES}
	echo "$lna" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi

#1498

#1499
DSID="SRV-117"
DSTZ1="El servidor web esta configurado para no permitir el uso de .htaccess."
ID1499=$(grep -A10 '<Directory>' $httpd | grep -v '#' | grep 'AllowOverride' | grep -E 'none|None')
if [[ $ID1499 != "" ]]; then
	echo ":: ID $DSID : $C" >> ${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo ":: ID $DSID : $NC" >>${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "::::Habilitar AllowOverride None en el directorio Raíz
				<Directory />
				  Options None
				  AllowOverride None
				  Order allow,deny
				  Allow from all
				</Directory>" >>${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: $DSTZ1" >>${PENDIENTES}
	echo "::::Habilitar AllowOverride None en el directorio Raíz
				<Directory />
				  Options None
				  AllowOverride None
				  Order allow,deny
				  Allow from all
				</Directory>" >> ${PENDIENTES}
	echo "$lna" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi

#1500
DSID="SRV-118"
DSTZ1="Tiene deshabilitado el  ReverseProxy"
ID1500=$(cat $httpd | grep -v '#' | grep 'LoadModule' | grep 'proxy_module' | grep 'modules/mod_proxy.so')
if [[ $ID1500 = "" ]]; then
	echo ":: ID $DSID : $C" >> ${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo ":: ID $DSID : $P" >>${ArchSal}
	echo ":: Validacion Manual revisar el archivo httpd.conf" >>${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "::::" >>${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$P;"
fi

#1501
#DSID="1501"
#DSTZ1="El usuario con el que corre el servidor web no es de dominio y no pertenece al grupo de administradores locales"
#echo ":: ID $DSID : $P" >> ${ArchSal}
#echo "::: $DSTZ1" >> ${ArchSal}
#echo "Validacion manual" >> ${ArchSal}
#ps aux | grep httpd >> ${ArchSal}
#echo "$lna" >> ${ArchSal}
#echo "" >> ${ArchSal}
#x1="$x1$DSID:$P;"

#1502
DSID="SRV-120"
DSTZ1="Se deshabilito el modulo mod_proxy o se justificó su uso y se controla el acceso al proxy"
ID1502=$(cat $httpd | grep -v '#' | grep 'LoadModule' | grep 'proxy_module' | grep 'modules/mod_proxy.so')
if [[ $ID1502 = "" ]]; then
	echo ":: ID $DSID : $C" >> ${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo ":: ID $DSID : $NC" >>${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "::::http://httpd.apache.org/docs/2.2/mod/mod_proxy.html" >>${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: $DSTZ1" >> ${PENDIENTES}
	echo "::::http://httpd.apache.org/docs/2.2/mod/mod_proxy.html" >> ${PENDIENTES}
	echo "$lna" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi

#1725
DSID="SRV-121"
DSTZ1="Se coloco la directiva FileETag None en el archivo de configuracion (httpd.conf)"
ID1725=$(cat $httpd | grep 'FileETag' | grep -E 'none|None')
if [[ $ID1725 != "" ]]; then 
	echo ":: ID $DSID : $C" >> ${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo ":: ID $DSID : $NC" >>${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "::::Agregar la siguiente directiva en el archivo httpd.conf
				FileETag None
				Reiniciar Apache" >>${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: $DSTZ1" >> ${PENDIENTES}
	echo "::::Agregar la siguiente directiva en el archivo httpd.conf
				FileETag None
				Reiniciar Apache" >>${PENDIENTES}
	echo "$lna" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi

#1728
DSID="SRV-123"
DSTZ1="Se habilitó la bandera HTTPOnly para el manejo de Cookies"
ID1728=$(cat $httpd | grep 'Header edit Set-Cookie ^(.*)$ $1;HttpOnly;Secure')
if [[ $ID1728 != "" ]]; then 
	echo ":: ID $DSID : $C" >> ${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo ":: ID $DSID : $NC" >>${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "::::Agregar la siguiente directiva en el archivo httpd.conf
				Header edit Set-Cookie ^(.*)$ $1;HttpOnly;Secure
				Reiniciar Apache" >>${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: $DSTZ1" >> ${PENDIENTES}
	echo "::::Agregar la siguiente directiva en el archivo httpd.conf
				Header edit Set-Cookie ^(.*)$ $1;HttpOnly;Secure
				Reiniciar Apache" >> ${PENDIENTES}
	echo "$lna" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi

#1729
DSID="SRV-124"
DSTZ1="Se habilitó la protección contra Cross Site Scripting en el archivo de configuración (httpd.conf)"
ID1729=$(cat $httpd | grep 'Header set X-XSS-Protection “1; mode=block”')
if [[ $ID1729 != "" ]]; then 
	echo ":: ID $DSID : $C" >> ${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$C;"
else
	echo ":: ID $DSID : $NC" >>${ArchSal}
	echo "::: $DSTZ1" >> ${ArchSal}
	echo "::::Agregar la siguiente directiva en el archivo httpd.conf
				Header set X-XSS-Protection “1; mode=block”
				Reiniciar Apache" >>${ArchSal}
	echo "$lna" >> ${ArchSal}
	echo "" >> ${ArchSal}
	x1="$x1$DSID:$NC;"
	#PENDIENTES
	echo "::: $DSTZ1" >> ${PENDIENTES}
	echo "::::Agregar la siguiente directiva en el archivo httpd.conf
				Header set X-XSS-Protection “1; mode=block”
				Reiniciar Apache" >> ${PENDIENTES}
	echo "$lna" >> ${PENDIENTES}
	echo "" >> ${PENDIENTES}
fi
}
lna="----------------------------------------------------------------------------------------------------"
#Informacion del equipo
EQUIPO=$(hostname)
HOSTID=$(hostid)
HOSTID=$(uname -i)
YEAR=$(date '+%y')
MES=$(date '+%m')
DIA=$(date '+%d')
DATE=$(/bin/date +%D' - '%T)
IP=$(ip addr show | grep 'eth' | grep 'inet' | awk '{print $2}' | cut -d'/' -f 1)
#Linux Distribution
LD=$(cat /etc/*release | grep ^NAME | cut -f2 -d=);
#Definicion de archivos de salida
ArchSal="DSICERT-RESULTADO-$YEAR-$MES-$DIA-$EQUIPO-$HOSTID.txt"
HASH="DSICERT-HASH-$YEAR-$MES-$DIA-$EQUIPO-$HOSTID.txt"
JSON="DSICERT-JSON-$YEAR-$MES-$DIA-$EQUIPO-$HOSTID.txt"
GZIP="DSICERT-REVISION-$YEAR-$MES-$DIA-$EQUIPO-$HOSTID.gz"
ZIPFILE="DSICERT-DOCUMENTOS-$YEAR-$MES-$DIA-$EQUIPO-$HOSTID.zip"
TARFILE="DSICERT-DOCUMENTOS-$YEAR-$MES-$DIA-$EQUIPO-$HOSTID.tar"
PENDIENTES="DSICERT-PENDIENTES-$YEAR-$MES-$DIA-$EQUIPO-$HOSTID.txt"

#Inicializacion de JSON
x1='{'

#Controlador de servicios

SS=$(type -a ss | grep 'not found')
SYSTEMCTL=$(type -t systemctl)
CHKCONF=$(type -t /sbin/chkconfig)

if [[ $SYSTEMCTL = 'file' ]]; then
	SYSTEMCTL=1
else
	SYSTEMCTL=0
fi

if [[ $CHKCONF = 'file' ]]; then
	CHKCONF=1
else
	CHKCONF=0
fi

## Leyendas de validacion
P="Por Validar"
NC="Pendiente"
C="Cumple"
GX=" : "
DSIT=":: ID "
DSIZ0=':0::'
DSION=':1::'

#Informacion del SCRIPT y escritura de banner
ta="Security Operation Center - TotalSec - Grupo Salinas"
tb="DSI Certificación de Seguridad de Aplicaciones (CSA)";
tc=""
tz="Script de validación de seguridad - Versión 3.4"

echo $lna; echo $tc;
echo $ta;
echo $tb; 
echo $tbc; 
echo $tz;
echo $lna;
echo $tc;
echo $lnab;
echo "Linux Distribution: " $LD;
echo "El script generá los siguientes archivos:"; echo "";
echo "- DSICERT-PENDIENTES. Describe los puntos pendientes a modificar.";
echo "- DSICERT-RESULTADO. Muestra el detalle del análisis y la configuración del servidor.";
echo "- DSICERT-HASH. Contiene los hashes de validación.";
echo "_ DSICERT-JSON. Contiene una cadena json de validacion;"
echo "- DSICERT-DOCUMENTOS. Archivo que contiene el resultado del script.";
echo $lnab;
echo $tc;


echo $lna >> ${ArchSal};
echo $ta >> ${ArchSal};
echo $tb >> ${ArchSal};
echo $tbc >> ${ArchSal};
echo $tz >> ${ArchSal};
echo $lna >> ${ArchSal};
echo $tc >> ${ArchSal};
echo $tc >> ${ArchSal};
echo $lna >> ${ArchSal};
echo "INFORMACION GENERAL" >> ${ArchSal};
echo $lna >> ${ArchSal};
echo "::: Fecha y hora " >> ${ArchSal};
/bin/date +%D' - '%T >> ${ArchSal};
echo $lnab >> ${ArchSal};
echo "::: IPs del servidor " >> ${ArchSal};
ip -o addr show|awk '/inet /{print $2":",$4}' >> ${ArchSal};
echo $lnab >> ${ArchSal};
echo "::: Hostname :: "$EQUIPO >> ${ArchSal};
echo $lnab >> ${ArchSal};
echo $tc >> ${ArchSal}; echo $tc >> ${ArchSal};
echo $lna >> ${ArchSal};
echo "Resultado de la validación de seguridad" >> ${ArchSal};
echo $lna >> ${ArchSal};
echo $tc >> ${ArchSal};
#------------------------------------------------------------------

#verificar si corre apache o jboss
APHACTIVE=0
if [[ $SYSTEMCTL -eq 1 ]]; then
	APH=$(systemctl status httpd.service | grep Active | cut -f2 -d:)
	if [[ $APH =~ *inactive* || $APH =~ *not\ be\ found* || $APH =~ inactive* || $APH =~ not\ be\ found* ]]; then
			APHACTIVE=0
	else
			APHACTIVE=1
	fi
	
else
	APH=$(pgrep -f httpd)
		if [[ $APH = '' ]]; then
			APHACTIVE=0
		else
			APHACTIVE=1
		fi
fi

JBACTIVE=0
if [ -z "$(pgrep -f org.jboss.as)" ]
then 
 JBACTIVE=0
else
 JBACTIVE=1
fi 

#Corrida de script
if ! [[ $LD =~ .*Ubuntu* ]];then
	if [[ JBACTIVE -eq 0 && APHACTIVE -eq 0 ]];then 
		puntos_generales
		redhatCentos
	else
		if [[ JBACTIVE -eq 1 && APHACTIVE -eq 0 ]];then
			puntos_generales
			redhatCentos
			JBoss
		fi
		if [[ JBACTIVE -eq 0 && APHACTIVE -eq 1 ]];then
			puntos_generales
			redhatCentos
			Apache
		fi
		if [[ JBACTIVE -eq 1 && APHACTIVE -eq 1 ]];then
			puntos_generales
			redhatCentos
			JBoss
			Apache
		fi
	fi
else
	if [[ JBACTIVE -eq 0 && APHACTIVE -eq 0 ]];then 
		puntos_generales
		Ubuntu
	else
		if [[ JBACTIVE -eq 1 && APHACTIVE -eq 0 ]];then
			puntos_generales
			Ubuntu
			JBoss
		fi
		if [[ JBACTIVE -eq 0 && APHACTIVE -eq 1 ]];then
			puntos_generales
			Ubuntu
			Apache
		fi
		if [[ JBACTIVE -eq 1 && APHACTIVE -eq 1 ]];then
			puntos_generales
			Ubuntu
			JBoss
			Apache
		fi
	fi
fi

#Finalizacion del hash		
x1="$x1}"
echo "" >> ${ArchSal}
echo $lna >> ${PENDIENTES}
h1=`echo -n $x1 | openssl md5 -binary | base64`
echo "" >> ${ArchSal}
echo ""
echo $lnab
echo "HASH"
echo $lnab
echo $EQUIPO
echo $DATE
echo $h1 
echo $lnab
/bin/chmod 700 ${ArchSal}
echo $lna >> ${ArchSal}
echo "CONFIGURACION DEL SERVIDOR " >> ${ArchSal}
echo $lna >> ${ArchSal}
echo "" >> ${ArchSal}


echo "::: df -h Para ver la distribución del disco y asegurar que no caerá el servicio por saturación." >> ${ArchSal}
df -h >> ${ArchSal}
echo "--------------------------------------------------" >> ${ArchSal}
echo "" >> ${ArchSal}

echo "ifconfig -a Para saber si existen mas configuraciones de red, incluyendo ips virtuales o flotantes." >> ${ArchSal}
ifconfig -a >> ${ArchSal}
echo "--------------------------------------------------" >> ${ArchSal}
echo "" >> ${ArchSal}

echo "iptables -L Para ver si efectivamente esta corriendo e identificar incongruencias en las mismas." >> ${ArchSal}
iptables -L >> ${ArchSal}
echo "--------------------------------------------------" >> ${ArchSal}
echo "" >> ${ArchSal}

echo "netstat -anoPara ver todos los puertos abiertos, servicios corriendo, Proceso que lo corre." >> ${ArchSal}
netstat -ano >> ${ArchSal}
echo "--------------------------------------------------" >> ${ArchSal}
echo "" >> ${ArchSal}

echo "::: cat /etc/issue " >> ${ArchSal}
echo `cat /etc/issue` >> ${ArchSal}
echo "--------------------------------------------------" >> ${ArchSal}
echo "" >> ${ArchSal}

echo "::: bash -version" >> ${ArchSal}
bash -version >> ${ArchSal}
echo "--------------------------------------------------" >> ${ArchSal}
echo "" >> ${ArchSal}

echo "::: uname -a " >> ${ArchSal}
echo `uname -a` >> ${ArchSal}
echo "--------------------------------------------------" >> ${ArchSal}
echo "" >> ${ArchSal}

echo "::: cat /etc/passwd " >> ${ArchSal}
cat /etc/passwd >> ${ArchSal} 
echo "--------------------------------------------------" >> ${ArchSal}
echo "" >> ${ArchSal}

echo "::: cat /etc/shadow " >> ${ArchSal}
cat /etc/shadow >> ${ArchSal} 
echo "--------------------------------------------------" >> ${ArchSal}
echo "" >> ${ArchSal}

echo "::: cat /etc/group " >> ${ArchSal}
cat /etc/group >> ${ArchSal} 
echo "--------------------------------------------------" >> ${ArchSal}
echo "" >> ${ArchSal}

echo "::: cat /etc/hosts " >> ${ArchSal}
cat /etc/hosts >> ${ArchSal} 
echo "--------------------------------------------------" >> ${ArchSal}
echo ""  >> ${ArchSal}

echo "::: cat /etc/hosts.allow " >> ${ArchSal}
cat /etc/hosts.allow >> ${ArchSal} 
echo "--------------------------------------------------" >> ${ArchSal}
echo ""  >> ${ArchSal}

echo "::: cat /etc/login.defs " >> ${ArchSal}
cat /etc/login.defs >> ${ArchSal}
echo "--------------------------------------------------" >> ${ArchSal}
echo ""  >> ${ArchSal}

echo "::: cat /etc/ssh/sshd_config " >> ${ArchSal}
cat /etc/ssh/sshd_config >> ${ArchSal}
echo "--------------------------------------------------" >> ${ArchSal}
echo ""  >> ${ArchSal}

echo "::: cat /etc/rsyslog.conf" >> ${ArchSal}
cat /etc/rsyslog.conf >> ${ArchSal}
echo "--------------------------------------------------" >> ${ArchSal}
echo ""  >> ${ArchSal}

echo "::: /usr/bin/env" >> ${ArchSal}
/usr/bin/env >> ${ArchSal}
echo "--------------------------------------------------" >> ${ArchSal}
echo ""  >> ${ArchSal}

if ! [[ $LD =~ .*Ubuntu* ]]
then
	echo "::: cat /etc/ntp.conf " >> ${ArchSal}
	cat /etc/ntp.conf >> ${ArchSal}
	echo "--------------------------------------------------" >> ${ArchSal}
	echo ""  >> ${ArchSal}
else
	echo "::: cat /etc/systemd/timesyncd.conf " >> ${ArchSal}
	cat /etc/systemd/timesyncd.conf >> ${ArchSal}
	echo "--------------------------------------------------" >> ${ArchSal}
	echo ""  >> ${ArchSal}
fi

echo "::: Configuración modulo PAM " >> ${ArchSal}
echo "::: cat /etc/pam.d/login " >> ${ArchSal}
cat /etc/pam.d/login  >> ${ArchSal}
echo ""  >> ${ArchSal}


echo "::: cat /etc/sudoers " >> ${ArchSal}
cat /etc/sudoers >> ${ArchSal}
echo "--------------------------------------------------" >> ${ArchSal}
echo ""  >> ${ArchSal}

echo "::: ss -a " >> ${ArchSal}
ss -a >> ${ArchSal}
echo "--------------------------------------------------" >> ${ArchSal}
echo ""  >> ${ArchSal}

if [[ $SYSTEMCTL = 1 ]]; then
	echo "::: systemctl list-unit-files --list " >> ${ArchSal}
	systemctl list-unit-files >> ${ArchSal}
	echo "--------------------------------------------------" >> ${ArchSal}
	echo ""  >> ${ArchSal}
else 
	echo "::: /sbin/chkconfig --list " >> ${ArchSal}
	/sbin/chkconfig --list >> ${ArchSal}
	echo "--------------------------------------------------" >> ${ArchSal}
	echo ""  >> ${ArchSal}
fi
echo "::: ls "$CRONDIR >> ${ArchSal}
ls $CRONDIR >> ${ArchSal}

echo ""  >> ${ArchSal}

CRONL=`ls -l $CRONDIR | awk '{print $9}'`

for item in $( ls $CRONDIR )
do
	echo $'cat '$CRONDIR''$item >> ${ArchSal}
	cat $CRONDIR''$item >> ${ArchSal}
	echo ""  >> ${ArchSal}
done

echo "--------------------------------------------------" >> ${ArchSal}
if ! [[ $LD =~ .*Ubuntu* ]]
then
	echo "::: ls /var/spool/at/spool/ " >> ${ArchSal}
	ls /var/spool/at/spool/ >> ${ArchSal}
	echo "--------------------------------------------------" >> ${ArchSal}
	echo ""  >> ${ArchSal}
else
	echo "::: ls /var/spool/cron/atspool/" >> ${ArchSal}
	ls /var/spool/cron/atspool/ >> ${ArchSal}
	echo "--------------------------------------------------" >> ${ArchSal}
	echo ""  >> ${ArchSal}
fi

if [[ -f '/etc/sysconfig/iptables' ]]; then
	echo "::: cat /etc/sysconfig/iptables " >> ${ArchSal}
	cat /etc/sysconfig/iptables >> ${ArchSal}
	echo "--------------------------------------------------" >> ${ArchSal}
	echo ""  >> ${ArchSal}
fi


if [[ -f  /etc/sysconfig/iptables6 ]]; then
	echo "::: cat /etc/sysconfig/iptables6 " >> ${ArchSal}
	cat /etc/sysconfig/iptables6 >> ${ArchSal}
	echo "--------------------------------------------------" >> ${ArchSal}
	echo ""  >> ${ArchSal}
fi

echo "::: lsof -P -i -n " >> ${ArchSal}
echo "" >> ${ArchSal}
lsof -P -i -n >> ${ArchSal}
echo "--------------------------------------------------" >> ${ArchSal}
echo ""  >> ${ArchSal}

DATE2=`/bin/date +%D' - '%T`

echo "--------------------------------------------------"  >> ${ArchSal}
echo "Estadisticas " >> ${ArchSal}
echo "--------------------------------------------------"  >> ${ArchSal}
echo "Inicio del análisis  : "$DATE  >> ${ArchSal};
echo "Fin del análisis     : "$DATE2 >> ${ArchSal};
echo "--------------------------------------------------" >> ${ArchSal};

echo ""  >> ${ArchSal};
echo $EQUIPO > ${HASH};
echo $DATE >> ${HASH};
echo $h1 >> ${HASH};
echo $x1 >> ${JSON}
echo "";

/bin/chmod 700 ${HASH}
/bin/chmod 700 ${PENDIENTES}
/bin/chmod 700 ${JSON}


if [[ $LD =~ .*Ubuntu* ]]; then
	tar -cf $TARFILE ${HASH} ${ArchSal} ${PENDIENTES} ${JSON};
	/bin/chmod 700 ${TARFILE};
else
	ZIP1=`type zip | grep 'type: zip: not found'`
	if [[ $ZIP1 = '' ]]; then
		FX=`echo $EQUIPO | openssl md5 -binary | base64`;
		zip -q ${ZIPFILE} ${HASH} ${ArchSal} ${PENDIENTES} ${JSON} ;
		/bin/chmod 700 ${ZIPFILE};
	else
		TAR1=`type tar | grep 'type: tar: not found'`

		if [[ $TAR1 = '' ]]; then
			tar -cf $TARFILE ${HASH} ${ArchSal} ${PENDIENTES} ${JSON};
			/bin/chmod 700 ${TARFILE};
		else
			gzip -c ${ArchSal} > $GZIP
			gzip -c ${HASH} >> $GZIP
			gzip -c ${JSON} >> $GZIP
			/bin/chmod 700 ${GZIP}
		fi

	fi
fi

rm DSICERT*.txtl -f
rm /tmp/linux.idx -f


echo "--------------------------------------------------" 
echo "Estadisticas "
echo "--------------------------------------------------" 
echo "Inicio del análisis  : "$DATE;
echo "Fin del análisis     : "$DATE2;
echo "--------------------------------------------------"
echo 
