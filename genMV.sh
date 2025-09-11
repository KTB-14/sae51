#!/bin/bash

#Variables
RAM=4096
DD=65536
CPU=1
VRAM=128


# --- Auto-install (preseed) ---
PRESEED_DIR="$HOME/.local/share/vbox-preseed"
PRESEED_PORT=8080
PRESEED_HOST="10.0.2.2"      # l'hôte vu depuis la VM en NAT
PRESEED_FILE="debian-base.cfg"
INSTALL_USER="admin"
INSTALL_PASS="admin"
HOSTNAME_DEF="vbox-debian"




action="$1"
vm_name="$2"

#Vérification nombre argumenents
if [ $# -eq 2 ] || [ $# -eq 1 ]; then

    #Création d'une nouvelle VM
    if [ "$action" == "N" ]; then
        #Vérification existence VM
        if vboxmanage list vms | grep -q "\"$vm_name\""; then 
            echo "Attention," $vm_name "existe déjà : Impossible de poursuivre"
            exit 1
        fi

        #Configuration VM
        vboxmanage createvm --name "$vm_name" --ostype "Debian_64" --register
        vboxmanage modifyvm "$vm_name" --memory $RAM --cpus $CPU --nic1 nat --boot1 net --boot2 disk --boot3 none --boot4 none --vram $VRAM
        vboxmanage createhd --filename "/home/$USER/VirtualBox VMs/$vm_name/$vm_name.vdi" --size $DD --format VDI > /dev/null 2>&1
        vboxmanage storagectl "$vm_name" --name "SATA Controller" --add sata --controller IntelAhci 
        vboxmanage storageattach "$vm_name" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "/home/$USER/VirtualBox VMs/$vm_name/$vm_name.vdi" 
        
        #Création métadonnées
        vboxmanage setextradata "$vm_name" "CreationDate" "$(TZ=Europe/Paris date +"%Y-%m-%d %H:%M:%S")"
        vboxmanage setextradata "$vm_name" "CreatedBy" "$USER"

        # === PXE/TFTP VirtualBox (auto-download) ===
        TFTP_DIR="$HOME/.config/VirtualBox/TFTP"
        NETBOOT_URL="http://http.us.debian.org/debian/dists/trixie/main/installer-amd64/current/images/netboot/netboot.tar.gz"
        NETBOOT_TAR="$TFTP_DIR/netboot.tar.gz"

        mkdir -p "$TFTP_DIR"

        # Téléchargement si pxelinux.0 absent
        if [ ! -f "$TFTP_DIR/pxelinux.0" ]; then
            echo "Téléchargement des fichiers netboot Debian..."
            if command -v curl >/dev/null 2>&1; then
                curl -L -o "$NETBOOT_TAR" "$NETBOOT_URL"
            elif command -v wget >/dev/null 2>&1; then
                wget -O "$NETBOOT_TAR" "$NETBOOT_URL"
            else
                echo "!!! Installe 'curl' ou 'wget' pour télécharger automatiquement."
                exit 1
            fi

            echo "Extraction de netboot.tar.gz..."
            tar -xzf "$NETBOOT_TAR" -C "$TFTP_DIR"
            rm -f "$NETBOOT_TAR"
        fi

        # Vérification finale
        if [ ! -f "$TFTP_DIR/pxelinux.0" ]; then
            echo "!!! pxelinux.0 introuvable après extraction."
            exit 1
        fi

        # Création du lien <VM>.pxe → pxelinux.0
        ln -sf "pxelinux.0" "$TFTP_DIR/$vm_name.pxe"
        # === fin ajout PXE/TFTP ===


        exit 0
    fi

    #Démarrage VM
    if [ "$action" == "D" ]; then
        vboxmanage startvm "$vm_name" --type gui
        exit 0
    fi

    #Arrêt VM
    if [ "$action" == "A" ]; then
        echo "Arrêt de la VM"
        vboxmanage controlvm "$vm_name" poweroff
        exit 0
    fi

    #Suppression VM
    if [ "$action" == "S" ]; then
        if vboxmanage list vms | grep -q "\"$vm_name\""; then
            if vboxmanage list runningvms | grep -q "\"$vm_name\""; then 
                echo "Arrêt de la VM..."
                vboxmanage controlvm "$vm_name" poweroff
                sleep 10
            fi
            echo "Suppresion de la VM"
            vboxmanage unregistervm "$vm_name" --delete
        fi
        vm_files=$(find ~/VirtualBox\ VMs/ -name "*$VM_NAME*" 2>/dev/null)
        if [ -n "$vm_files" ]; then
            rm -rf $vm_files
            echo "Suppresion des fichiers de la VM"
        fi
        exit 0
    fi

    #Lister les VMs
    if [ "$action" == "L" ]; then
        temp_file=$(mktemp)
        vboxmanage list vms > "$temp_file"

        echo -e "VMs list and metadata :\n"
        while read -r line; do
            vm=$(echo "$line" | cut -d '"' -f2)
            date_creation=$(vboxmanage getextradata "$vm" "CreationDate" 2>/dev/null | cut -d' ' -f2-)
            created_by=$(vboxmanage getextradata "$vm" "CreatedBy" 2>/dev/null | cut -d' ' -f2-)
            [ -z "$date_creation" ] && date_creation="Unknow"
            [ -z "$created_by" ] && created_by="Unknow"
        
            if [ $# == 1 ]; then
                echo "VM: $vm"
                echo "  Creation : $date_creation"
                echo -e "  By : $created_by \n"
            fi
        done < "$temp_file"
        if [ $# == 2 ]; then
            echo "VM: $vm_name"
            echo "  Creation : $date_creation"
            echo -e "   By : $created_by \n"
        fi
        rm "$temp_file"
        exit 0
    fi

#===================================================================================
    # Installation auto (preseed + HTTP + PXE)
    if [ "$action" == "I" ]; then
        TFTP_DIR="$HOME/.config/VirtualBox/TFTP"
        mkdir -p "$TFTP_DIR/pxelinux.cfg" "$PRESEED_DIR"

        # 2.1 Écrire un preseed minimal (login manuel, pas d'autologin)
        cat > "$PRESEED_DIR/$PRESEED_FILE" <<EOF
### Localisation
d-i debian-installer/locale string fr_FR.UTF-8
d-i keyboard-configuration/xkb-keymap select fr

### Réseau
d-i netcfg/choose_interface select auto
d-i netcfg/get_hostname string ${HOSTNAME_DEF}
d-i netcfg/get_domain string local

### Miroir
d-i mirror/country string manual
d-i mirror/http/hostname string deb.debian.org
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string

### Utilisateur (admin/admin à changer ensuite)
d-i passwd/root-login boolean false
d-i passwd/user-fullname string ${INSTALL_USER}
d-i passwd/username string ${INSTALL_USER}
d-i passwd/user-password password ${INSTALL_PASS}
d-i passwd/user-password-again password ${INSTALL_PASS}

### Horloge
d-i time/zone string Europe/Paris
d-i clock-setup/ntp boolean true

### Partitionnement auto (disque entier)
d-i partman-auto/method string regular
d-i partman-auto/choose_recipe select atomic
d-i partman-auto/disk string /dev/sda
d-i partman/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

### Paquets
tasksel tasksel/first multiselect standard, ssh-server
d-i pkgsel/include string sudo curl ca-certificates

### Grub
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean true

### Fin
d-i finish-install/reboot_in_progress note
EOF

        # 2.2 Lancer un mini serveur HTTP sur l'hôte pour servir le preseed
        pkill -f "python3 -m http.server $PRESEED_PORT" >/dev/null 2>&1 || true
        ( cd "$PRESEED_DIR" && nohup python3 -m http.server $PRESEED_PORT >/tmp/preseed_http.log 2>&1 & echo $! > /tmp/preseed_http.pid )
        echo "HTTP preseed sur http://$PRESEED_HOST:$PRESEED_PORT/$PRESEED_FILE (PID $(cat /tmp/preseed_http.pid))"

        # 2.3 Écrire le menu PXE par défaut (pointe sur netboot + preseed HTTP)
        cat > "$TFTP_DIR/pxelinux.cfg/default" <<EOF
DEFAULT auto
PROMPT 0
TIMEOUT 10

LABEL auto
    MENU LABEL Debian Auto Install (preseed)
    KERNEL debian-installer/amd64/linux
    APPEND initrd=debian-installer/amd64/initrd.gz auto=true priority=critical \
           preseed/url=http://$PRESEED_HOST:$PRESEED_PORT/$PRESEED_FILE \
           netcfg/choose_interface=auto \
           debian-installer=fr locale=fr_FR.UTF-8 keyboard-configuration/xkb-keymap=fr
EOF

        echo "PXE prêt. Enchaîne: ./genMV.sh N \"$vm_name\" puis ./genMV.sh D \"$vm_name\""
        exit 0
    fi


#===================================================================================

    #Erreur : Commande inconnué
    echo "Commande incorrect"
    exit 1
fi

#Erreur : Nombre arguments 
echo "Nombre d'arguments incorrect"
exit 1
