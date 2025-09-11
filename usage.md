# Guide d’utilisation du script `genMV`

**Auteurs :** Canu Antoine & Brook Tamrat Kifle  
**Date :** Années 2025-2026  

## Résumé
Ce document décrit le fonctionnement du script `genMV` permettant d’automatiser la gestion de machines virtuelles avec VirtualBox.  
Il explique comment l’utiliser, détaille les fonctionnalités disponibles, 

---

## 1. Pré-requis
- VirtualBox installé sur la machine hôte  
- Accès à la commande `VBoxManage` dans le `PATH` du système  
- Droits suffisants pour créer, démarrer et supprimer des VM  

---

## 2. Installation du script
1. Télécharger/copier le fichier `genMV.sh` (Linux) ou `genMV.bat` (Windows).  
2. Sous Linux, rendre le script exécutable :  
    sudo chmod u+x genMV.sh
3. Possibilité de modifier les caractéristiques en modifiant la tête du script

---

## 3. Utilisation du script
1. Sythaxe à suivre : ./genMV.sh <action> [nom_VM]
2. Actions disponibles :
    - L => Lister toutes les VMs enregistrés (possibilité de préciser ou non le nom)
    - N => Créer une nouvelle VM (nom obligatoire)
    - S => Supprimer une VM existante (nom obligatoire)
    - D => Démarrer une VM (nom obligatoire)
    - A => Arrêter une VM (nom obligatoire)
3. Exemple d'utilisation :
    - #Lister toutes les VMs  
    ./genMV.sh L
    - #Lister une VM en particulier (Debian1)  
    ./genMV.sh L Debian1
    - #Créer une VM nommé "Debian1"  
    ./genMV.sh N Debian1
    - #supprimer une VM nommé "Debian1"  
    ./genMV.sh S Debian1
    - #Demarrer une VM nommé "Debian1"  
    ./genMV.sh D Debian1
    - #Arrêter une VM nommé "Debian1"  
    ./genMV.sh A Debian1