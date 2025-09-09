#/bin/bash

#Variables
RAM=4096
DD=65536
CPU=1
VRAM=128

action="$1"
vm_name="$2"

#Vérification nombre argumenents
if [ $# == 2 ]; then

    #Création d'une nouvelle VM
    if [ "$action" == "N" ]; then
        #Vérification existence VM
        if vboxmanage list vms | grep -q "\"$vm_name\""; then 
            echo $vm_name "existe déjà, suppression en cours..."
            vboxmanage unregistervm "$vm_name" --delete > /dev/null 2>&1
            rm -rf "/home/$USER/VirtualBox VMs/$vm_name/"
            echo -e $vm_name "est supprimé !\n"
        fi

        #Configuration VM
        vboxmanage createvm --name "$vm_name" --ostype "Debian_64" --register
        vboxmanage modifyvm "$vm_name" --memory $RAM --cpus $CPU --nic1 nat --boot1 net --boot2 disk --boot3 none --boot4 none --vram $VRAM
        vboxmanage createhd --filename "/home/$USER/VirtualBox VMs/$vm_name/$vm_name.vdi" --size $DD --format VDI > /dev/null 2>&1
        vboxmanage storagectl "$vm_name" --name "SATA Controller" --add sata --controller IntelAhci 
        vboxmanage storageattach "$vm_name" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "/home/$USER/VirtualBox VMs/$vm_name/$vm_name.vdi" 
        
        #Création métadonnées
        vboxmanage setextradata "$vm_name" "CreationDate" "$(date +"%Y-%m-%d %H:%M:%S")"
        vboxmanage setextradata "$vm_name" "CreatedBy" "$USER"

        exit 0
    fi

    #Démarrage VM
    if [ "$action" == "D" ]; then
        vboxmanage startvm "$vm_name"
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
        if [ -n "$VM_FILES" ]; then
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

            echo "VM: $vm"
            echo "  Creation : $date_creation"
            echo -e "  By : $created_by \n"
        done < "$temp_file"

        rm "$temp_file"
        exit 0
    fi
    
    #Erreur : Commande inconnué
    echo "Commande incorrect"
    exit 1
fi

#Erreur : Nombre arguments 
echo "Nombre d'arguments incorrect"
exit 1
