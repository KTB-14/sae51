#/bin/bash

if [ $# -ne 1 ]; then
    echo "PB"
    exit 1
fi

vm_name="$1"

if vboxmanage list vms | grep -q "\"$vm_name\""; then 
    echo $vm_name "existe déjà, supp en cours..."
    vboxmanage unregistervm "$vm_name" --delete
    echo $vm_name "supp !!!"
fi

vboxmanage createvm --name "$vm_name" --ostype "Debian_64" --register
vboxmanage modifyvm "$vm_name" --memory 4096 --cpus 1 --nic1 nat --boot1 net --vram 128
vboxmanage createhd --filename "~/VirtualBox VMs/$vm_name/$vm_name.vdi" --size 65536 --format VDI
vboxmanage storagectl "$vm_name" --name "SATA Controller" --add sata --controller IntelAhci
vboxmanage storageattach "$vm_name" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "~/VirtualBox VMs/$vm_name/$vm_name.vdi"

vboxmanage list vms

read -p "attente"

vboxmanage unregistervm "$vm_name" --delete
exit 0