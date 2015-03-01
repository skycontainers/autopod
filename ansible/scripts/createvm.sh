echo $@

echo date >> /tmp/request.out
echo $@ >> /tmp/request.out
echo "\n" >> /tmp/request.out


DATASTORE=$1
BASE_VMDK=$2
TARGETVM_NAME=$3

 # defalt variables
 CPU=${4:-1}
 RAM=${5:-2048}
 
 
 NETWORK_DEV=${6:-vmxnet3}
 NETWORK_NAME=${7:-VM Network}
 
 ISO=""
 FLAG=true
 ERR=false
 
 

if [ -z "$TARGETVM_NAME" ]; then
 echo "Target vm name not specified Usage: vmclone.sh <target_vmname>"
  exit 1 ;
  fi


  echo $TARGETVM_NAME
  DATASOURCEFOLDER=/vmfs/volumes/${DATASTORE}
  SOURCE_TEMPLATE_VM=$DATASOURCEFOLDER/$BASE_VMDK
  echo source VM Folder $DATASOURCEFOLDER/$SOURCE_TEMPLATE_VM

  DEST_VM=$DATASOURCEFOLDER/$TARGETVM_NAME/${TARGETVM_NAME}.vmdk

  echo destination Vm Folder $DEST_VM
  mkdir $DATASOURCEFOLDER/$TARGETVM_NAME

vmkfstools -i  $SOURCE_TEMPLATE_VM $DEST_VM -d thin


 ## Create the VM
DEST_VMX=$DATASOURCEFOLDER/$TARGETVM_NAME/${TARGETVM_NAME}.vmx
touch $DEST_VMX

#writing information into the configuration file
cat << EOF > $DEST_VMX
config.version = "8"
virtualHW.version = "8"
vmci0.present = "TRUE"
displayName = "${TARGETVM_NAME}"
floppy0.present = "FALSE"
numvcpus =  "${CPU}"
memsize = "${RAM}"
scsi0.present = "TRUE"
scsi0.sharedBus = "none"
scsi0.virtualDev = "lsilogic"
scsi0:0.present = "TRUE"
scsi0:0.fileName = "${DEST_VM}"
scsi0:0.deviceType = "scsi-hardDisk"
ide1:0.present = "TRUE"
ide1:0.fileName = "${ISO}"
ide1:0.deviceType = "cdrom-image"
pciBridge0.present = "TRUE"
pciBridge4.present = "TRUE"
pciBridge4.virtualDev = "pcieRootPort"
pciBridge4.functions = "8"
pciBridge5.present = "TRUE"
pciBridge5.virtualDev = "pcieRootPort"
pciBridge5.functions = "8"
pciBridge6.present = "TRUE"
pciBridge6.virtualDev = "pcieRootPort"
pciBridge6.functions = "8"
pciBridge7.present = "TRUE"
pciBridge7.virtualDev = "pcieRootPort"
pciBridge7.functions = "8"
ethernet0.pciSlotNumber = "32"
ethernet0.present = "TRUE"
ethernet0.virtualDev = "${NETWORK_DEV}"
ethernet0.networkName = "${NETWORK_NAME}"
ethernet0.addressType = "generated"
guestOS = "other26xlinux-64"

EOF

#Adding Virtual Machine to VM register - modify your path accordingly!!
MYVM=`vim-cmd solo/registervm ${DEST_VMX} `
#Powering up virtual machine:
vim-cmd vmsvc/power.on $MYVM

echo "The Virtual Machine is now setup & the VM has been started up. Your have the following configuration:"
echo "Name: ${TARGETVM_NAME}"
echo "CPU: ${CPU}"
echo "RAM: ${RAM}"
echo "HDD-size: ${SIZE}"
if [ -n "$ISO" ]; then
  echo "ISO: ${ISO}"
 else
  echo "No ISO added."
fi

echo "Thank you."
exit

