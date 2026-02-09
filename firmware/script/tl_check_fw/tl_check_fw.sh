#!/bin/bash 
echo "*****************************************************"
echo "this is post build!! current configure is :$1"

os=$(uname)
echo "OS from uname is: ${os}"
echo $1
echo $2

tc32-elf-objcopy -v -O binary $2.elf  $1.bin

#par of tl_auth_check_fw.exe are defined as follows:
#par[0]:EXE path;
#par[1]:bin path; 
#par[2]: 1 means FW_CHECK_AGTHM1, 2 means FW_CHECK_AGTHM2;  other values is invalid; In encryption mode, AGTHM2 is automatically used.
#par[3]: signature private key with 32 bytes. 0 means no signature.  (Optional)
#par[4]: "2.elf" means that if there is 'key_encode_bin' in firmware, encryption mode will be enable. 0 means no encryption mode. (Optional)

if [ "${os}" = "Linux" ] ; then
    echo "Linux OS"
    echo "check_fw in Linux..."
    chmod 755 ../../../../script/tl_check_fw/tl_auth_check_fw_linux
    ../tl_auth_check_fw_linux  output/$1.bin  2  0  $2.elf
    exec_result=$?
else
    echo "Windows OS"
    echo "check_fw in Windows..."
    ../../../../script/tl_check_fw/tl_auth_check_fw.exe  $1.bin  2  0  $2.elf
    exec_result=$?
	filesize=$(stat -c%s "$1.bin")
    filesize_k_1=$((filesize/1024))
	filesize_k_2=$((((filesize-filesize/1024*1024)*10 + 512)/1024))
    echo "File: $1.bin Size: ${filesize} bytes, "$filesize_k_1"."$filesize_k_2" kByte"
	echo  "---------------------------  SRAM info ---------------------------"
	str=$(grep -E "^[0-9a-f]{8} g[ ]+\*ABS\*.*_ram_use_end_" --text -o $1.lst)
	dec_num=$((16#${str:4:4}))
	dec_k_1=$((dec_num/1024))
	dec_k_2=$((((dec_num-dec_num/1024*1024)*10+512)/1024))
	echo "Total SRAM Usage(exclude code stack): "$dec_num" Byte", $dec_k_1"."$dec_k_2" kByte"
	echo "----------------(code stack is about 3 kByte for default code)"
	str=$(grep -E "^[0-9a-f]{8} g[ ]+\*ABS\*.*_retention_size_" --text -o $1.lst)
	dec_num=$((16#${str:4:4}))
	dec_k_1=$((dec_num/1024))
	dec_k_2=$((((dec_num-dec_num/1024*1024)*10 + 512)/1024))
	echo "Retention SRAM Usage: "$dec_num" Byte", $dec_k_1"."$dec_k_2" kByte"
	echo  "---------------------------  SRAM info end  ---------------------------"
fi

#echo result=${exec_result}
if [ "${exec_result}" == "0" ]
then
echo  "exec successful"
else
echo  "###########################  Error: Run tl_auth_check_fw.exe failed  ###########################"
echo  "###########################  Error: Run tl_auth_check_fw.exe failed  ###########################"
echo  "###########################  Error: Run tl_auth_check_fw.exe failed  ###########################"
echo  "Error: exec failed, exit code=${exec_result}"
rm -rf $1.bin
exit ${exec_result}
fi

echo  "---------------------------  SDK version info ---------------------------"
str=$(grep -E "[\$]{3}[a-zA-Z0-9 _.]+[\$]{3}" --text -o $1.bin | sed 's/\$//g')
if [ -z "$str" ]; then
    echo "no SDK version found at the end of firmware, please check sdk_version.c and sdk_version.h"
else
    echo "$str"
fi
echo  "---------------------------  SDK version end  ---------------------------"

echo "**************** end of post build ******************"
