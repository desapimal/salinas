#! /bin/bash

opcion=$1

#======	Array's ===================================================================================
services=(cups sendmail bluetooth hplip postfix autofs atd ip6tables rhnsd nfs nfslock rpcgssd rpcidmapd rpcsvcgssd ) 


#====== Valida los parametros de la configuracion de OpenSSH ======================================
function sshRoot(){
	echo "  [ Desactivando acceso a ROOT por ssh ]"	
	sed -i s/"#PermitRootLogin yes"/"PermitRootLogin no"/g /etc/ssh/sshd_config	
	service sshd reload
	echo
}

#====== Valida servivios NO necesarios ============================================================
function serviciosOff(){
	echo "  [ Desactivando servicios NO necesarios ]        "
	for i in "${services[@]}"; do
        	activo=$(chkconfig --list | grep  $i | grep -e 3:on -e 5:on -e 3:activo -e 5:activo )
        	if [ -z "$activo" ]; then
                	echo " El servicio $i NO existe o ya esta desactivado."
        	else
                	echo " El servicio $i existe y se desactivara."
                	chkconfig $i off
        	fi
	done
	echo
}

#====== Valida el metodo de encryptado ============================================================
function loginEncrypt(){
	echo "  [ Verificando el metodo de encrytacion ]        "
	cadena=SHA512
	encrypt=$(grep "ENCRYPT_METHOD" /etc/login.defs | awk '{print $2}')
	if [ "$cadena" = "$encrypt" ]; then 
		echo " El metodo de encryptado es: $encrypt" 
	else 
		echo " El metodo de encryptado es: $encrypt" 
		echo "	.: Se cambia a SHA512 :."
		sha=$(grep "ENCRYPT_METHOD" /etc/login.defs)
		sed -i s/"$sha"/"ENCRYPT_METHOD SHA512"/g /etc/login.defs
	fi
	echo
}

#====== Servicio NTP ==============================================================================
function configNtp(){ 
	echo "  [ Activando syncronizacion de hora y fecha ]        "
	sed -i s/"server 0.rhel.pool.ntp.org"/"server 10.53.21.136"/g           /etc/ntp.conf
	sed -i s/"server 1.rhel.pool.ntp.org"/"#server 1.rhel.pool.ntp.org"/g   /etc/ntp.conf
	sed -i s/"server 2.rhel.pool.ntp.org"/"#server 2.rhel.pool.ntp.org"/g   /etc/ntp.conf
	sed -i s/"server 3.rhel.pool.ntp.org"/"#server 3.rhel.pool.ntp.org"/g   /etc/ntp.conf
	sed -i s/"server	127.127.1.0	# local clock"/"#server        127.127.1.0     # local clock"/g /etc/ntp.conf
	sed -i s/"fudge	127.127.1.0 stratum 10"/"#fudge	127.127.1.0 stratum 10"/g /etc/ntp.conf 
	ntpdate -u 10.53.21.136
	chkconfig ntpd on
	service ntpd restart
	echo
}

#====== Iptables ==================================================================================
function iptables_app(){
		echo "  [ Configurando reglas base con iptables ]     "
		chkconfig iptables on
		service iptables stop
		cat iptablesAPP > /etc/sysconfig/iptables
		service iptables start
		echo	
}

function iptables_bd(){
		echo "  [ Configurando reglas base con iptables ]     "
		chkconfig iptables on
		service iptables stop
		cat iptablesBD > /etc/sysconfig/iptables
		service iptables restart
		echo
}

#====== Prerrequisitos Software ===================================================================

function preAPP(){
	echo "  [ Aplicando prerrequisitos para servidores de aplicaciones ]     "
	sh prerrequisitosAPP
	echo
}

function preBD(){
	echo "  [ Aplicando prerrequisitos para Servidores de Base de Datos ]     "
	sh prerrequisitosBD
	echo
} 

#====== Creacion de Usuarios y grupos =============================================================

function usersUnix(){
	echo "  [ Creando usuarios para los SUPER Administradores de Sistemas UNIX ]     "
	sh creacionUsuarios unix
}

function usersOracle(){
	echo "  [ Creando usuarios para los DBA's ]     "
	sh creacionUsuarios oracle
}
function usersMonitor(){
	echo "  [ Creando usuarios para los de Monitoreo ]     "
	sh creacionUsuarios monitoreo
}
#====== Configuracion de Seleinux =================================================================
function configSelinux(){
	echo "  [ Deshabilitado SeLinux (algun dia te usaremos) ]     "
	bolean=$(getenforce)
	if [ "Enforcing" = $bolean -o "Permissive" = $bolean  ]; then 
		sed  -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config
		sed  -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/sysconfig/selinux
		setenforce 0
	else 
		echo "SeLinux ya esta deshabilitado." 
	fi
	echo
}

function fin(){
	echo "[		!! Hasta la vista BABY!!		]"	
	sync
	sync
	reboot	
}

case $opcion in
	app)
		sshRoot
		serviciosOff			
		loginEncrypt
		configNtp
		iptables_app
		usersUnix
		usersMonitor
		#motd
		configSelinux
		sleep 15
		#preAPP
		# fin
	;;

	bd)
		sshRoot
		serviciosOff			
		loginEncrypt
		configNtp
		iptables_bd
		usersUnix
		usersMonitor
		usersOracle
		#motd
		configSelinux
		sleep 15
		#preBD
		# fin
	;;
	
	hyper)
		serviciosOff
		loginEncrypt
		configNtp
		usersUnix
		#motd
		configSelinux
		#fin
	;;
	
	*)
		echo
		echo "	=====	Script para la lista de chequeos de Seguridad	====="
		echo "	=====							====="
		echo "	Modo de uso: sh securityCheck.bash [ app | bd | hyper ]"
		echo
	;;
esac
