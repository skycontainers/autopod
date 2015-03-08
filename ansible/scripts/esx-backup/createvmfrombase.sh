echo $@

echo date >> /tmp/request.out
echo $@ >> /tmp/request.out
echo "\n" >> /tmp/request.out



 # defalt variables
 CPU=${3:-1}
 RAM=${4:-2048}
 NETWORK_DEV=${5:-vmxnet3}
 NETWORK_NAME=${6:-VM Network}
 
 ISO=""       
 FLAG=true
 ERR=false
           

TARGETVM_NAME=$1
BASE_VM=$2

/vmfs/volumes/tclouds-vm-images/scripts/vmcloneimage.sh $TARGETVM_NAME tclouds-vm-instances $BASE_VM tclouds-vm-images 
  
 ## Create the VM
TARGET_DATASTORE=/vmfs/volumes/tclouds-vm-instances 
TARGET_VMDK=$TARGET_DATASTORE/$TARGETVM_NAME/$TARGETVM_NAME.vmdk

DEST_VMX=$TARGET_DATASTORE/$TARGETVM_NAME/${TARGETVM_NAME}.vmx
touch $DEST_VMX
echo DEST_VMX: $DEST_VMX

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
scsi0:0.fileName = "${TARGET_VMDK}"
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

VMIP=`vim-cmd vmsvc/getallvms | grep -i $TARGETVM_NAME | cut -d ' ' -f 1 | xargs vim-cmd vmsvc/get.guest | grep ipAddress | sed -n 1p | cut -d '"' -f 2`

echo  sleeping for 15 secs to wait for the IP
sleep 15
echo MYIP : $MYIP


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


		



  
