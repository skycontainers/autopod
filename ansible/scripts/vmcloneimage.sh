echo $1
# vmkfstools -i  /vmfs/volumes/tcloudesx2-ds1/E2-C7-Host-001/E2-C7-Host-001.vmdk /vmfs/volumes/tcloudesx2-ds1/E2-C7-Host-D2/E2-C7-Host-D2.vmdk -d thin


TARGETVM_NAME=$1

if [ -z "$TARGETVM_NAME" ]; then
echo "Target vm name not specified Usage: vmclone.sh <target_vmname>"
exit 1 ;
fi

TARGET_DATASTORE=${2:-tclouds-vm-instances}

SOURCE_IMAGE=${3:-tclouds-centos7-base}
SOURCE_DATASTORE=${4:-tclouds-vm-images}


echo $TARGETVM_NAME
SOURCE_DATASOURCEFOLDER=/vmfs/volumes/$SOURCE_DATASTORE
TARGETDATASOURCEFOLDER=/vmfs/volumes/$TARGET_DATASTORE

SOURCE_TEMPLATE_VM=$SOURCE_DATASOURCEFOLDER/$SOURCE_IMAGE/$SOURCE_IMAGE.vmdk
echo source VM Folder $SOURCE_DATASOURCEFOLDER/$SOURCE_TEMPLATE_VM

DEST_VM=$TARGETDATASOURCEFOLDER/$TARGETVM_NAME/${TARGETVM_NAME}.vmdk

echo destination Vm Folder $DEST_VM
mkdir $TARGETDATASOURCEFOLDER/$TARGETVM_NAME

vmkfstools -i  $SOURCE_TEMPLATE_VM $DEST_VM -d thin