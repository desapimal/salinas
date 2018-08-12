############################
Con base a las reuniones establecidas con Grupo Salinas el órden de ejecución de sus Scripts de Procesos son:

############################
Órden de Ejecución para APP:

sshRoot
serviciosOff
loginEncrypt
configNtp
iptables_app
usersUnix
usersMonitor
configSelinux
preAPP

############################
Órden de Ejecución para BD:

sshRoot
serviciosOff
loginEncrypt
configNtp
iptables_bd
usersUnix
usersMonitor
usersOracle
configSelinux
preBD