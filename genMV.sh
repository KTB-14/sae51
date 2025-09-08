
vboxmanage list ostype #liste les types d'os et comment ils sont nommés

# Donc pour creer une vm de type Linux/debian 12 apres avoir verifier le ID 
# on fait :
vboxmanage createvm --name "Debian12" --ostype Debian12 --register

# Ainsi pour verifier que cest bien creer avec le bon type d'OS on fait :
vboxmanage showvminfo "Debian12"

# Ainsi pour modifier les propriétés de la vm, avec une memoire de 4096,
# on fait:
vboxmanage modifyvm "Debian12" --memory 4096 #memory en MB


# Pour créer un stockage de 64GB 
# on fait: 
vboxmanage storagectl "Debian12" \
--name "sata01" --add sata --controller IntelAHCI

# ensuite on attache le stockage 
# on fait :
vboxmanage storageattach "Debian12" \
--storagectl sata01 \
--port 0 \
--device 0 \
--type hdd \
--medium /'VirtualBox VMs'/Debian12/Debian12.vdi


