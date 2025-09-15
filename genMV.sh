#!/bin/bash

#====================================================================================
# 1. Etapes proposées:

# Ecrire un script qui va creer une machine nommée Debian1 de type Linux/Debian 64
# bits, dotée de 4096 MB de RAM d’un DD de 64 GiB et d’une carte réseau connectée en
# NAT, configurée pour booter sur le réseau (PXE)

# Ajouter ensuite une pause dans le script, puis ajouter la commande qui va la détruire.
# Tester l’exécution, et au moment de la pause, vérifier avec la GUI de VB que la machine existe
#====================================================================================

#-- Pour créer une machine nommée Debian1, on fait :
#vboxmanage createvm --name "Debian1" --register  
#-- si on enleve --register, la vm va etre créer mais non afficher dans virtualbox

#-- Pour voir la liste des types d'OS disponible, on fait :
#vboxmanage list ostypes

#-- Pour choisir le type d'OS dés la creation, on fait :
echo "[1] Création de la VM Debian1"
vboxmanage createvm --name Debian1 --ostype Debian13 --register 
#-- Pour vérifier les specifications de la VM créer, on peut faire:
#vboxmanage showvminfo Debian1


#-- Après création, nous pouvons modifier les spécifications de la VM avec la commande :
#vboxmanage modifyvm Debian1 --memory 4096 #taille memoire RAM en MB

#-- Creation d'un disque virtuel de 64 Go (64*1024 = 65536 Mo) :
#  --filename "CheminAbsolutDuFichierHote"
echo "[2] Création du disque virtuel de 64 Go"
vboxmanage createhd --filename "$HOME/VirtualBox VMs/Debian1/Debian1.vdi" --size 65536 --format VDI  

#-- Ensuite on ajoute un controleur de stockage :
echo "[3] Ajout du controleur de stockage"
vboxmanage storagectl Debian1 --name Controller_Sata --add sata --controller IntelAhci 
#   --add "TypeDeControleur" --controller "NomDuControleur"

#-- Pour voir les types de controleurs dispo, on fait :
#vboxmanage list hdds

#-- Ensuite on attache le disque virtuel au controleur :
echo "[4] Attachement du disque virtuel au controleur"
vboxmanage storageattach Debian1 --storagectl Controller_Sata --port 0 --device 0 --type hdd --medium "$HOME/VirtualBox VMs/Debian1/Debian1.vdi" 

#-- Connection en NAT de la VM :
#vboxmanage modifyvm Debian1 --nic1 nat # nic1 cest la carte reseau de la VM, mode "nat"

#-- et configuration pour booter sur le réseau (PXE), donc modification ordre de demarrage de la VM :
#vboxmanage modifyvm Debian1 --boot1 net --boot2 disk --boot3 none --boot4 none

#-- les modifications peuvent etre combinées en une seule commande :
echo "[5] Configuration de la VM (RAM, carte reseau, ordre de boot)"
vboxmanage modifyvm Debian1 --memory 4096 --nic1 nat --boot1 net --boot2 disk --boot3 none --boot4 none

#-- On ajoute ensuite une pause dans le script
echo "[6] Pause de 10 secondes avant destruction de la VM"
echo "    vérifier dans l'interface de VirtualBox que la machine existe"
sleep 10 
#-- puis on détruit la VM
echo "[7] Destruction de la VM Debian1"
echo "    vérifier dans l'interface de VirtualBox que la machine n'existe plus"
vboxmanage unregistervm Debian1 --delete

#====================================================================================


