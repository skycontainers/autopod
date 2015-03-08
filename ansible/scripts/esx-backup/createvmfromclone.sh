echo $1
# vmkfstools -i  /vmfs/volumes/tcloudesx2-ds1/E2-C7-Host-001/E2-C7-Host-001.vmdk /vmfs/volumes/tcloudesx2-ds1/E2-C7-Host-D2/E2-C7-Host-D2.vmdk -d thin


TARGETVM_NAME=$1

if [ -z "$TARGETVM_NAME" ]; then
 echo "Target vm name not specified Usage: vmclone.sh <target_vmname>"
  exit 1 ;
  fi
  
  
  echo $TARGETVM_NAME
  DATASOURCEFOLDER=/vmfs/volumes/tcloudesx2-ds1
  SOURCE_TEMPLATE_VM=$DATASOURCEFOLDER/E2-C7-Host-001/E2-C7-Host-001.vmdk
  echo source VM Folder $DATASOURCEFOLDER/$SOURCE_TEMPLATE_VM
  
  DEST_VM=$DATASOURCEFOLDER/$TARGETVM_NAME/${TARGETVM_NAME}.vmdk
  
  echo destination Vm Folder $DEST_VM
  mkdir $DATASOURCEFOLDER/$TARGETVM_NAME
  
vmkfstools -i  $SOURCE_TEMPLATE_VM $DEST_VM -d thin
  
  
 ## Create the VM
 
 # defalt variables
 CPU=1
 RAM=2048
 SIZE=20
 ISO=""
 FLAG=true
 ERR=false
 
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
ethernet0.virtualDev = "vmxnet3"
ethernet0.networkName = "VM Network"
ethernet0.addressType = "generated"
guestOS = "other26xlinux-64"

EOF

#Adding Virtual Machine to VM register - modify your path accordingly!!
MYVM=`vim-cmd solo/registervm ${DEST_VMX} `
#Powering up virtual machine:
vim-cmd vmsvc/power.on $MYVM

echo "The Virtual Machine is now setup & the VM has been started up. Your have the following configuration:"
echo "Name: ${NAME}"
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


		



  
