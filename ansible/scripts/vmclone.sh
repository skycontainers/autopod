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

