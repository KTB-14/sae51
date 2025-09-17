@echo off

rem Vérification de l'existence de VboxManage
set "VBOX_PATH=C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
if not exist "%VBOX_PATH%" (
    echo Erreur : VBoxManage introuvable
    exit /b 1
    rem L'option '/b' permet de quitter seulement le script et de ne pas fermer la fenêtre
)

rem Variables
set RAM=4096
set DD=65536
set CPU=1
set VRAM=128

rem Récupération des arguments
set action=%1
set vm_name=%2

rem Vérifie qu'une action est demandé
if "%action%"=="" (
    echo Nombre d'arguments incorrect: Choisissez une action
    exit /b 1
)

rem Création d'une nouvelle VM
if "%action%"=="N" (
    rem Création de la VM
    "%VBOX_PATH%" createvm --name "%vm_name%" --ostype "Debian_64" --register >nul 
    
    rem Test si la machine existe déjà (ERRORLEVEL est supérieur ou égal à 1)
    if errorlevel 1 (
        echo: Attention : la machine %vm_name% existe deja ou une erreur est survenu.
        exit /b 1
    )
    echo La machine %vm_name% est en cours de creation...

    rem Modifications caractéristiques de la VM
    "%VBOX_PATH%" modifyvm "%vm_name%" --memory %RAM% --cpus %CPU% --nic1 nat --boot1 net --boot2 disk --boot3 none --boot4 none --vram %VRAM% >nul || (
        echo Erreur : Impossible de modifier les caracteristiques de la machine 
        exit /b 1
    )

    rem Ajout du DD
    "%VBOX_PATH%" createhd --filename "%USERNAME%\VirtualBox VMs\%vm_name%\%vm_name%.vdi" --size %DD% --format VDI >nul || (
        echo Erreur : Impossible de creer le Disque Dur
        exit /b 1
    )

    rem Ajout du controlleur SATA
    "%VBOX_PATH%" storagectl "%vm_name%"  --name "SATA Controller" --add sata --controller IntelAhci || (
        echo Erreur : Impossible de creer le controlleur SATA
        exit /b 1
    )

    rem Attachement du DD
    "%VBOX_PATH%" storageattach "%vm_name%" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "%USERNAME%\VirtualBox VMs\%vm_name%\%vm_name%.vdi" >nul || (
        echo Erreur : Impossible d'attacher le disque dur à la VM
        exit /b 1
    )

    rem Création métadonnées
    set CreationDate=%date% %time%
    "%VBOX_PATH%" setextradata "%vm_name%" "CreationDate" "%CreationDate%"
    "%VBOX_PATH%" setextradata "%vm_name%" "CreateBy" "%USERNAME%"

    echo Machine cree avec succes mais non boot
    exit /b 0
)

rem Démarrage VM
if "%action%"=="D" (
    "%VBOX_PATH%" startvm "%vm_name%" --type gui >nul || (
        echo Erreur : Impossible de demarrer la machine
        exit /b 1
    )
    echo Machine virtuelle demarre !
    exit /b 0
)

rem Arrêt VM
if "%action%"=="A" (
    echo Arret de la VM...
    "%VBOX_PATH%" controlvm "%vm_name%" poweroff >nul ||(
        echo Erreur : Impossible d'arreter la machine
        exit /b 1
    )
    echo Machine virtuelle arrete !
    exit /b 0
)

rem Suppression VM (à améliorer si besoin)
if "%action%"=="S" (
    "%VBOX_PATH%" unregistervm "%vm_name%" --delete >nul || (
        echo : Erreur : Impossible de supprimer la machine virtuelle
        exit /b 1
    )
    exit /b 0
)

rem Lister les VMs
if "%action%"=="L" (
    echo VMs list and metadata :
    echo.
    "%VBOX_PATH%" list vms
    exit /b 0
)

echo Probleme dans la commande : Mauvaise action demande
exit /b 1
