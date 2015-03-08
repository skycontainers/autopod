echo $@

echo date >> /tmp/request.out
echo $@ >> /tmp/request.out
echo "\n" >> /tmp/request.out


phelp() {
	echo "Script for automatic Virtual Machine creation for ESX"
	echo "Usage: ./create.sh options: t b <|c|i|r|s>"
	echo "Where t: Name of VM (required), c: Number of virtual CPUs, i: location of an ISO image, r: RAM size in MB, s: Disk size in GB"
	echo "Default values are: CPU: 2, RAM: 4096MB, HDD-SIZE: 20GB"
}
 
 
CPU=1
RAM=2048
ISO=""
FLAG=true
ERR=false
NETWORK_DEV=vmxnet3
NETWORK_NAME=VM Network
TARGETVM_DS=tclouds-vm-instances
BASEVM_DS=tclouds-vm-images 
POWER_ON=true

 #Error checking will take place as well
#the NAME has to be filled out (i.e. the $NAME variable needs to exist)
#The CPU has to be an integer and it has to be between 1 and 32. Modify the if statement if you want to give more than 32 cores to your Virtual Machine, and also email me pls :)
#You need to assign more than 1 MB of ram, and of course RAM has to be an integer as well
#The HDD-size has to be an integer and has to be greater than 0.
#If the ISO parameter is added, we are checking for an actual .iso extension
while getopts t:n:c:i:r:s:b:d:p: option
do
        case $option in
                t)
					TARGETVM_NAME=${OPTARG};
					FLAG=false;
					if [ -z $TARGETVM_NAME ]; then
						ERR=true
						MSG="$MSG | Please make sure to enter a VM name."
					fi
					;;
			    b)
					BASE_VM=${OPTARG};
					FLAG=false;
					if [ -z $BASE_VM ]; then
						ERR=true
						MSG="$MSG | Please make sure to enter a base VM name."
					fi
					;;
				 s)
					BASEVM_DS=${OPTARG};
					FLAG=false;
					if [ -z $BASEVM_DS ]; then
						ERR=true
						MSG="$MSG | Please make sure to enter the data store for base vm."
					fi
					;;
				d)
					TARGETVM_DS=${OPTARG};
					FLAG=false;
					if [ -z $TARGETVM_DS ]; then
						ERR=true
						MSG="$MSG | Please make sure to enter the data store name for target vm."
					fi
					;;	
                c)
					CPU=${OPTARG}
					if [ `echo "$CPU" | egrep "^-?[0-9]+$"` ]; then
						if [ "$CPU" -le "0" ] || [ "$CPU" -ge "32" ]; then
							ERR=true
							MSG="$MSG | The number of cores has to be between 1 and 32."
						fi
					else
						ERR=true
						MSG="$MSG | The CPU core number has to be an integer."
					fi
					;;
				i)
					ISO=${OPTARG}
					if [ ! `echo "$ISO" | egrep "^.*\.(iso)$"` ]; then
						ERR=true
						MSG="$MSG | The extension should be .iso"
					fi
					;;
                r)
					RAM=${OPTARG}
					if [ `echo "$RAM" | egrep "^-?[0-9]+$"` ]; then
						if [ "$RAM" -le "0" ]; then
							ERR=true
							MSG="$MSG | Please assign more than 1MB memory to the VM."
						fi
					else
						ERR=true
						MSG="$MSG | The RAM size has to be an integer."
					fi
					;;
			    n)
					NETWORK_NAME=${OPTARG};
					FLAG=false;
					if [ -z $NETWORK_NAME ]; then
						ERR=true
						MSG="$MSG | Please make sure to enter te network name for the VM."
					fi
					;;
                 p)
					POWER_ON=${OPTARG};
					FLAG=false;
					if [ -z $POWER_ON ]; then
						ERR=true
						MSG="$MSG | Please make sure to enter true or false for power on."
					fi
					;;
					
				\?) echo "Unknown option: -$OPTARG" >&2; phelp; exit 1;;
        		:) echo "Missing option argument for -$OPTARG" >&2; phelp; exit 1;;
        		*) echo "Unimplimented option: -$OPTARG" >&2; phelp; exit 1;;
        esac
done

 	if [ -z $TARGETVM_NAME ]; then
		ERR=true
		MSG="$MSG | Please make sure to enter a VM name."
	fi
	
			  
    if [ -z $BASE_VM ]; then
		ERR=true
		MSG="$MSG | Please make sure to enter a base VM name."
	fi

    if $ERR; then
	    echo $MSG
	    exit 1
    fi



/vmfs/volumes/tclouds-vm-images/scripts/vmcloneimage.sh $TARGETVM_NAME $TARGETVM_DS $BASE_VM $BASEVM_DS 
  
 ## Create the VM
TARGET_DATASTORE=/vmfs/volumes/$TARGETVM_DS 
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

if ["$POWER_ON" == "true"]
    #Powering up virtual machine:
    vim-cmd vmsvc/power.on $MYVM
    
    echo VM ID: $MYVM
    
    VMIP=`vim-cmd vmsvc/getallvms | grep -i $TARGETVM_NAME | cut -d ' ' -f 1 | xargs vim-cmd vmsvc/get.guest | grep ipAddress | sed -n 1p | cut -d '"' -f 2`
    
    echo  sleeping for 15 secs to wait for the IP
    sleep 15
    echo MYIP : $MYIP
else
   echo POWER ON IS : "$POWER_ON"
fi


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
