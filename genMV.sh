#!/bin/bash

#======================================================================================================================================
# 1. Etapes proposées:

# Ecrire un script qui va creer une machine nommée Debian1 de type Linux/Debian 64
# bits, dotée de 4096 MB de RAM d’un DD de 64 GiB et d’une carte réseau connectée en
# NAT, configurée pour booter sur le réseau (PXE)

# Ajouter ensuite une pause dans le script, puis ajouter la commande qui va la détruire.
# Tester l’exécution, et au moment de la pause, vérifier avec la GUI de VB que la machine existe


# DEBUT SCRIPT ETAPE 1 ---------------------------------------------------------------


# #-- Pour créer une machine nommée Debian1, on fait :
# #vboxmanage createvm --name "Debian1" --register  
# #-- si on enleve --register, la vm va etre créer mais non afficher dans virtualbox

# #-- Pour voir la liste des types d'OS disponible, on fait :
# #vboxmanage list ostypes

# #-- Pour choisir le type d'OS dés la creation, on fait :
# echo "[1] Création de la VM Debian1"
# vboxmanage createvm --name Debian1 --ostype Debian13 --register 
# #-- Pour vérifier les specifications de la VM créer, on peut faire:
# #vboxmanage showvminfo Debian1


# #-- Après création, nous pouvons modifier les spécifications de la VM avec la commande :
# #vboxmanage modifyvm Debian1 --memory 4096 #taille memoire RAM en MB

# #-- Creation d'un disque virtuel de 64 Go (64*1024 = 65536 Mo) :
# #  --filename "CheminAbsolutDuFichierHote"
# echo "[2] Création du disque virtuel de 64 Go"
# vboxmanage createhd --filename "$HOME/VirtualBox VMs/Debian1/Debian1.vdi" --size 65536 --format VDI  

# #-- Ensuite on ajoute un controleur de stockage :
# echo "[3] Ajout du controleur de stockage"
# vboxmanage storagectl Debian1 --name Controller_Sata --add sata --controller IntelAhci 
# #   --add "TypeDeControleur" --controller "NomDuControleur"

# #-- Pour voir les types de controleurs dispo, on fait :
# #vboxmanage list hdds

# #-- Ensuite on attache le disque virtuel au controleur :
# echo "[4] Attachement du disque virtuel au controleur"
# vboxmanage storageattach Debian1 --storagectl Controller_Sata --port 0 --device 0 --type hdd --medium "$HOME/VirtualBox VMs/Debian1/Debian1.vdi" 

# #-- Connection en NAT de la VM :
# #vboxmanage modifyvm Debian1 --nic1 nat # nic1 cest la carte reseau de la VM, mode "nat"

# #-- et configuration pour booter sur le réseau (PXE), donc modification ordre de demarrage de la VM :
# #vboxmanage modifyvm Debian1 --boot1 net --boot2 disk --boot3 none --boot4 none

# #-- les modifications peuvent etre combinées en une seule commande :
# echo "[5] Configuration de la VM (RAM, carte reseau, ordre de boot)"
# vboxmanage modifyvm Debian1 --memory 4096 --nic1 nat --boot1 net --boot2 disk --boot3 none --boot4 none

# #-- On ajoute ensuite une pause dans le script
# echo "[6] Pause de 10 secondes avant destruction de la VM"
# echo "    vérifier dans l'interface de VirtualBox que la machine existe"
# sleep 10 
# #-- puis on détruit la VM
# echo "[7] Destruction de la VM Debian1"
# echo "    vérifier dans l'interface de VirtualBox que la machine n'existe plus"
# vboxmanage unregistervm Debian1 --delete


# FIN SCRIPT ETAPE 1 ----------------------------------------------------------------


#======================================================================================================================================
# 2. Etapes proposées:

# Ajouter dans le script une vérification qu’une machine de même nom n’existe pas
# déjà. Ajouter la commande de suppression le cas échéant (on doit donc pouvoir exécuter
# le script de manière répétée sans que cela provoque d’erreur).


# DEBUT SCRIPT ETAPE 1,2 ---------------------------------------------------------------


#-- Nous allons en premier essayer de creer la VM, si elle existe deja, ya un message d'erreur qui s'affiche

# et donc l'objectif est de capture le code de retour de la commande de creation
# si le code de retour est different de 0, alors cela veut dire que la VM existe deja
# ainsi on la supprime avant de continuer le script

# echo "[1] Vérification si la VM Debian1 existe déjà"
# #-- 2> /dev/null permet de rediriger le message d'erreur vers null, donc on ne le voit pas
# #-- 2>&1 permet de rediriger le message d'erreur vers la sortie standard (stdout)
# #-- 2>&1 > /dev/null permet de rediriger le message d'erreur vers la sortie standard (stdout) et ensuite rediriger la sortie standard vers null
# #-- &> /dev/null permet de rediriger la sortie standard et le message d'erreur vers null    (Nouvelle syntaxe bash)

# if ! vboxmanage createvm --name Debian1 --ostype Debian13 --register &> /dev/null; then
#     echo "La VM Debian1 existe déjà, suppression en cours..."
#     vboxmanage unregistervm Debian1 --delete
    
#     echo "Suppression terminée. Recréation de la VM Debian1..."
#     vboxmanage createvm --name Debian1 --ostype Debian13 --register
# else
#     echo "La VM Debian1 n'existe pas, création en cours..."
# fi

# # puis le reste du script est identique que l'etape 1 detaillee et expliquee au dessus

# echo "[2] Création du disque virtuel de 64 Go"
# vboxmanage createhd --filename "$HOME/VirtualBox VMs/Debian1/Debian1.vdi" --size 65536 --format VDI  &> /dev/null

# echo "[3] Ajout du controleur de stockage"
# vboxmanage storagectl Debian1 --name Controller_Sata --add sata --controller IntelAhci 

# echo "[4] Attachement du disque virtuel au controleur"
# vboxmanage storageattach Debian1 --storagectl Controller_Sata --port 0 --device 0 --type hdd --medium "$HOME/VirtualBox VMs/Debian1/Debian1.vdi" 

# echo "[5] Configuration de la VM (RAM, carte reseau, ordre de boot)"
# vboxmanage modifyvm Debian1 --memory 4096 --nic1 nat --boot1 net --boot2 disk --boot3 none --boot4 none

# echo "[6] Pause de 10 secondes avant destruction de la VM"
# echo "    vérifier dans l'interface de VirtualBox que la machine existe"
# sleep 10 

# echo "[7] Destruction de la VM Debian1"
# echo "    vérifier dans l'interface de VirtualBox que la machine est supprimée"
# vboxmanage unregistervm Debian1 --delete


# FIN SCRIPT ETAPE 1,2 ---------------------------------------------------------------


#======================================================================================================================================

# 3. Etapes proposées:

# Vérifier via la GUI de VB que la machine démarre bien sur le boot PXE. 
# Configurer le serveur TFTP interne à VirtualBox de façon à ce que la machine démarre sur 
# l’installation d’une Debian stable, type netinst (télécharger une ISO au préalable).


# DEBUT SCRIPT ETAPE 1,2,3 ---------------------------------------------------------------

echo "[1] Vérification si la VM Debian1 existe déjà"
if ! vboxmanage createvm --name Debian1 --ostype Debian13 --register &> /dev/null; then
    echo "La VM Debian1 existe déjà, suppression en cours..."
    vboxmanage unregistervm Debian1 --delete
    
    echo "Suppression terminée. Recréation de la VM Debian1..."
    vboxmanage createvm --name Debian1 --ostype Debian13 --register &> /dev/null
else
    echo "La VM Debian1 n'existe pas, création en cours..."
fi

echo "[2] Création du disque virtuel de 64 Go"
vboxmanage createhd --filename "$HOME/VirtualBox VMs/Debian1/Debian1.vdi" --size 65536 --format VDI  &> /dev/null

echo "[3] Ajout du controleur de stockage"
vboxmanage storagectl Debian1 --name Controller_Sata --add sata --controller IntelAhci 

echo "[4] Attachement du disque virtuel au controleur"
vboxmanage storageattach Debian1 --storagectl Controller_Sata --port 0 --device 0 --type hdd --medium "$HOME/VirtualBox VMs/Debian1/Debian1.vdi" 

echo "[5] Configuration de la VM (RAM, carte reseau, ordre de boot)"
vboxmanage modifyvm Debian1 --memory 4096 --nic1 nat --boot1 net --boot2 disk --boot3 none --boot4 none


#-- Suppression des commandes 6 et 7 (temps d'attente et destruction de la VM)
#   car l'objectif est de mettre en place le boot PXE et de demarrer la VM ensuite de verifier qu'elle boot bien en PXE


#== DEBUT PXE =======================================

#-- Liste des variables utilisées pour la configuration du serveur TFTP interne à VirtualBox
#   et le boot PXE de l'installateur Debian

#-- Lien de téléchargement de l'archive netboot.tar.gz
NETBOOT_URL="http://http.us.debian.org/debian/dists/trixie/main/installer-amd64/current/images/netboot/netboot.tar.gz"
#   Cette archive contient les fichiers nécessaires pour le boot PXE de l'installateur Debian

#-- Répertoire TFTP utilisé par VirtualBox
TFTP_DIR="$HOME/.config/VirtualBox/TFTP"

#-- Chemin absolu du répertoire où les fichiers de netboot seront extraits
NETBOOT_TAR="$TFTP_DIR/netboot.tar.gz"


#-- Création du répertoire TFTP s'il n'existe pas
mkdir -p "$TFTP_DIR"


#-- Téléchargement de l'archive netboot.tar.gz si elle n'existe pas déjà
echo "[6] Verification si besoin de téléchargement de l'archive netboot.tar.gz " 

if test ! -f "$NETBOOT_TAR"; then
    # test [ condition ] : est une commande qui permet de vérifier une condition
    # ! : négation (si la condition est fausse)
    # -f : option qui vérifie si le fichier existe et est un fichier régulier (que veut dire fichier regulier ? 
    #      un fichier regulier est un fichier qui n'est pas un répertoire, un lien symbolique, ou un autre type spécial de fichier)

    echo "Téléchargement de l'archive netboot.tar.gz..."  

    if which curl 2>&1 > /dev/null ; then
        curl -L -o "$NETBOOT_TAR" "$NETBOOT_URL"
        # -L : permet de suivre les redirections (si l'URL redirige vers une autre URL)
        # -o : permet de choisir le nom du fichier de sortie
    elif which wget 2>&1 > /dev/null ; then
        wget -O "$NETBOOT_TAR" "$NETBOOT_URL"
        # -O : permet de choisir le nom du fichier de sortie
    else
        echo "!!! Les commandes 'curl' ou 'wget' ne sont pas installées."
        echo " Veuillez les installer et réessayer"
        exit 1
    fi    

    echo "Extraction de netboot.tar.gz..."
    tar -xzf "$NETBOOT_TAR" -C "$TFTP_DIR"
    # -x : extraire
    # -z : passer par gzip (parce que c’est .tar.gz)
    # -f = file indique le nom du fichier à extraire (ici "$NETBOOT_TAR")
    # -C "$TFTP_DIR" = changer de repertoire et extraire directement dans ce dossier (ici "$TFTP_DIR")
    
    rm -f "$NETBOOT_TAR"
    # -f : forcer la supression
fi

#-- Vérification finale
if test ! -f "$TFTP_DIR/pxelinux.0" ; then
    echo "!!! pxelinux.0 introuvable après extraction."
    exit 1
fi

#-- Création du lien <VM>.pxe avec pxelinux.0
ln -sf "pxelinux.0" "$TFTP_DIR/$vm_name.pxe"

    # ln : Création d’un lien symbolique vers pxelinux.0
    # -s : lien symbolique (comme un raccourci)
    # -f : force la création (écrase l’ancien lien si présent)
    # Donc chaque VM aura son propre fichier de boot ($vm_name.pxe)
    # "pxelinux.0" est la cible réelle (le fichier du boot PXE).
    # "$TFTP_DIR/$vm_name.pxe" est le nom du lien symbolique qu’on crée.

# FIN PXE =======================================

echo "[7] Démarrage de la VM Debian1 en mode GUI"
vboxmanage startvm Debian1 --type gui

# FIN SCRIPT ETAPE 1,2,3 ---------------------------------------------------------------

