TARGETVM_NAME=$1
echo TARGETVM_NAME: $TARGETVM_NAME

VMIP=`vim-cmd vmsvc/getallvms | grep -i $TARGETVM_NAME | cut -d ' ' -f 1 | xargs vim-cmd vmsvc/get.guest | grep ipAddress | sed -n 1p | cut -d '"' -f 2`
echo VMIP: $VMIP
