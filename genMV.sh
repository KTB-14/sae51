#/bin/bash

if [ $# -ne 2 ]; then
    echo "PB"
    exit 1
fi

vm_name="$1"

if [ "$2" == "create" ]; then
    if vboxmanage list vms | grep -q "\"$vm_name\""; then 
        echo $vm_name "existe déjà, supp en cours..."
        vboxmanage unregistervm "$vm_name" --delete
        rm -rf "/home/$USER/VirtualBox VMs/$vm_name/"
        echo $vm_name "supp !!!"
    fi

    vboxmanage createvm --name "$vm_name" --ostype "Debian_64" --register
    vboxmanage modifyvm "$vm_name" --memory 4096 --cpus 1 --nic1 nat --boot1 net --boot2 disk --boot3 none --boot4 none --vram 128
    vboxmanage createhd --filename "/home/$USER/VirtualBox VMs/$vm_name/$vm_name.vdi" --size 65536 --format VDI
    vboxmanage storagectl "$vm_name" --name "SATA Controller" --add sata --controller IntelAhci
    vboxmanage storageattach "$vm_name" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "/home/$USER/VirtualBox VMs/$vm_name/$vm_name.vdi"
    
    vboxmanage startvm "$vm_name" --type headless

fi

if [ "$2" == "show" ]; then
    vboxmanage list vms
    exit 0
fi

if [ "$2" == "delete" ]; then
    vboxmanage unregistervm "$vm_name" --delete
    exit 0
fi
