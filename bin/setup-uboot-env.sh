#!/bin/sh

# This distribution contains contributions or derivatives under copyright
# as follows:
#
# Copyright (c) 2010, Texas Instruments Incorporated
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# - Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# - Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
# - Neither the name of Texas Instruments nor the names of its
#   contributors may be used to endorse or promote products derived
#   from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

cwd=`dirname $0`
. $cwd/common.sh

do_expect() {
    echo "expect {" >> $3
    check_status
    echo "    $1" >> $3
    check_status
    echo "}" >> $3
    check_status
    echo $2 >> $3
    check_status
    echo >> $3
}


echo
echo "--------------------------------------------------------------------------------"
echo "This step will set up the U-Boot variables for booting the EVM."
echo

ipdefault=`ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1 }'`
platform=`grep PLATFORM= $cwd/../Rules.make | cut -d= -f2`

# Configure prompt for U-Boot 2016.05
prompt="=>"


echo "Autodetected the following ip address of your host, correct it if necessary"
read -p "[ $ipdefault ] " ip
echo

if [ ! -n "$ip" ]; then
    ip=$ipdefault
fi

if [ -f $cwd/../.targetfs ]; then
    rootpath=`cat $cwd/../.targetfs`
else
    echo "Where is your target filesystem extracted?"
    read -p "[ ${HOME}/targetNFS ]" rootpath

    if [ ! -n "$rootpath" ]; then
        rootpath="${HOME}/targetNFS"
    fi
    echo
fi

kernelimage="zImage-""$platform"".bin"
kernelimagesrc=`ls -1 $cwd/../board-support/prebuilt-images/$kernelimage`
kernelimagedefault=`basename $kernelimagesrc`


echo "Select Linux kernel location:"
echo " 1: TFTP"
echo " 2: SD card"
echo
read -p "[ 1 ] " kernel

if [ ! -n "$kernel" ]; then
    kernel="1"
fi

echo
echo "Select root file system location:"
echo " 1: NFS"
echo " 2: SD card"
echo
read -p "[ 1 ] " fs

if [ ! -n "$fs" ]; then
    fs="1"
fi



if [ "$kernel" -eq "1" ]; then
    echo
    echo "Available kernel images in /tftproot:"
    for file in /tftpboot/*; do
	basefile=`basename $file`
	echo "    $basefile"
    done
    echo
    echo "Which kernel image do you want to boot from TFTP?"
    read -p "[ $kernelimagedefault ] " kernelimage

    if [ ! -n "$kernelimage" ]; then
	kernelimage=$kernelimagedefault
    fi
fi

isBB="n"
isBBBlack="n"
isBBrevA3="n"
configBB="n"

check_for_beaglebone() {
    # First check if there is a rev A3 board which uses the custom VID/PID
    # combination
    lsusb -d 0403:a6d0 > /dev/null

    if [ "$?" = "0" ]
    then
        # We found a beaglebone
        isBB="y"
        isBBrevA3="y"
        return
    fi

    # Now let's check for a standard VID/PID like newer BeagleBones have
    sudo lsusb -vv -d 0403:6010 | grep "Product" | grep "BeagleBone" > /dev/null

    if [ "$?" = "0" ]
    then
        isBB="y"
        return
    fi

    # Now let's check for EVM-SK
    sudo lsusb -vv -d 0403:6010 | grep "Product" | grep "EVM-SK" > /dev/null

    if [ "$?" = "0" ]
    then
        isBB="y"
        return
    fi


    # Now let's check for BeagleBone Black
    sudo lsusb -vv -d 0403:6001 > /dev/null

    if [ "$?" = "0" ]
    then
        isBB="y"
        isBBBlack="y"
        return
     fi

}

echo "timeout 300" > $cwd/setupBoard.minicom
echo "verbose on" >> $cwd/setupBoard.minicom

do_expect "\"abort autoboot\"" "send \" \"" $cwd/setupBoard.minicom
do_expect "\"$prompt\"" "send \"env default -f -a\"" $cwd/setupBoard.minicom
do_expect "\"$prompt\"" "send \"saveenv\"" $cwd/setupBoard.minicom
do_expect "\"$prompt\"" "send \"reset\"" $cwd/setupBoard.minicom
do_expect "\"abort autoboot\"" "send \" \"" $cwd/setupBoard.minicom

if [ "$kernel" -eq "1" ]; then
	if [ "$fs" -eq "1" ]; then
		#TFTP and NFS Boot
		do_expect "\"$prompt\"" "send \"setenv serverip $ip\"" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send setenv rootpath '$rootpath'" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send \"setenv bootfile $kernelimage\"" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send \"setenv ip_method dhcp\"" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send \"setenv nfsopts 'nolock,v3,tcp,rsize=4096,wsize=4096'\"" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send \"setenv getuenv 'if mmc rescan; then if run loadbootenv; then run importbootenv; fi; fi;'\"" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send setenv bootcmd 'run findfdt; run getuenv; setenv autoload no;dhcp ;tftp \${loadaddr} $kernelimage; tftp \${fdtaddr} \${fdtfile}; run netargs; bootz \${loadaddr} - \${fdtaddr}'" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send \"saveenv\"" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send \"boot\"" $cwd/setupBoard.minicom
	else
		#TFTP and SD Boot
		do_expect "\"$prompt\"" "send \"setenv serverip $ip\"" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send \"setenv bootfile $kernelimage\"" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send \"setenv ip_method none\"" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send \"setenv getuenv 'if mmc rescan; then if run loadbootenv; then run importbootenv; fi; fi;'\"" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send setenv bootcmd 'run findfdt; run getuenv; setenv autoload no; dhcp ; tftp \${loadaddr} $kernelimage; tftp \${fdtaddr} \${fdtfile}; run args_mmc; bootz \${loadaddr} - \${fdtaddr}'" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send \"saveenv\"" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send \"boot\"" $cwd/setupBoard.minicom
	fi
else
	if [ "$fs" -eq "1" ]; then
		#SD and NFS Boot
		do_expect "\"$prompt\"" "send \"setenv serverip $ip\"" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send setenv rootpath '$rootpath'" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send \"setenv bootfile zImage\"" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send \"setenv ip_method dhcp\"" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send \"setenv nfsopts 'nolock,v3,tcp,rsize=4096,wsize=4096'\"" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send \"setenv getuenv 'if mmc rescan; then if run loadbootenv; then run importbootenv; fi; fi;'\"" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send setenv bootcmd 'setenv autoload no; mmc rescan; run findfdt; run getuenv; setenv devtype mmc; run loadimage; run loadfdt; run netargs; bootz \${loadaddr} - \${fdtaddr}'" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send \"saveenv\"" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send \"boot\"" $cwd/setupBoard.minicom
	    else
		#SD and SD boot.
		do_expect "\"$prompt\"" "send \"setenv ip_method none\"" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send \"setenv bootfile zImage\"" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send \"setenv getuenv 'if mmc rescan; then if run loadbootenv; then run importbootenv; fi; fi;'\"" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send setenv bootcmd 'mmc rescan; run findfdt; run getuenv; setenv devtype mmc; run loadimage; run loadfdt; run args_mmc; bootz \${loadaddr} - \${fdtaddr}'" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send \"saveenv\"" $cwd/setupBoard.minicom
		do_expect "\"$prompt\"" "send \"boot\"" $cwd/setupBoard.minicom

	fi
fi
echo "! killall -s SIGHUP minicom" >> $cwd/setupBoard.minicom

echo "--------------------------------------------------------------------------------"
echo "Would you like to create a minicom script with the above parameters (y/n)?"
read -p "[ y ] " minicom
echo

if [ ! -n "$minicom" ]; then
    minicom="y"
fi

if [ "$minicom" = "y" ]; then

    echo -n "Successfully wrote "
    readlink -m $cwd/setupBoard.minicom
fi

while [ yes ]
do
	check_for_beaglebone

	if [ "$isBB" = "y" ]
	then
		echo ""
		echo "A BeagleBone (Black) or StarterKit board has been detected"
		echo "Do you want to configure U-Boot for one of the boards mentioned"
		echo "above? An answer of 'n' will configure U-Boot for the"
		echo "General Purpose EVM instead"
		read -p "(y/n) " configBB
		echo

		if [ "$configBB" = "y" ] || [ "$configBB" = "n" ]
		then
			break
		else
			echo "Invalid response"
			echo
			continue
		fi
	else
		echo ""
		echo "No BeagleBone (Black) or StarterKit detected. Assuming"
		echo "general purpose evm is being used. Is this correct?"
		read -p "(y/n) " validevm
		echo ""
		if [ "$validevm" = "y" ]
		then
			configBB="n"
			break
		else
			if [ "$validevm" != "n" ]
			then
				echo "Invalid response"
				echo
				continue
			fi

			echo "Please connect the Beaglebone (Black) or StarterKit to the PC"
			echo "If your using the StarterKit board make sure it is turned on"
			read -p "Press any key to try checking again." temp
		fi
	fi
done

if [ "$configBB" = "y" ]
then
    ftdiInstalled=`lsmod | grep ftdi_sio`
    if [ -z "$ftdiInstalled" ]; then
    #Add the ability to regconize the BeagleBone as two serial ports
        if [ "$isBBrevA3" = "y" ]
        then
            echo "Finishing install by adding drivers for Beagle Bone..."
            sudo modprobe -q ftdi_sio vendor=0x0403 product=0xa6d0

            #Create uDev rule
            echo "# Load ftdi_sio driver including support for XDS100v2." > $cwd/99-custom.rules
            echo "SYSFS{idVendor}=="0403", SYSFS{idProduct}=="a6d0", \\" >>  $cwd/99-custom.rules
            echo "RUN+=\"/sbin/modprobe -q ftdi_sio vendor=0x0403 product=0xa6d0\"" >> $cwd/99-custom.rules
            sudo cp $cwd/99-custom.rules /etc/udev/rules.d/
            rm $cwd/99-custom.rules
        else
            sudo modprobe -q ftdi_sio
        fi
    fi

    #infinite loop to look for board unless user asks to stop
    while [ yes ]
    do
	    echo "Detecting connection to board..."
	    loopCount=0
	    port=`dmesg | grep FTDI | grep "tty" | tail -1 | grep "attached" |  awk '{ print $NF }'`
	    while [ -z "$port" ] && [ "$loopCount" -ne "10" ]
	    do
		    #count to 10 and timeout if no connection is found
		    loopCount=$((loopCount+1))

		    sleep 1
		    port=`dmesg  | grep FTDI | grep "tty" | tail -1 | grep "attached" |  awk '{ print $NF }'`
	    done

	    #check to see if we actually found a port
	    if [ -n "$port" ]; then
		    break;
	    fi

	    #if we didn't find a port and reached the timeout limit then ask to reconnect
	    if [ -z "$port" ] && [ "$loopCount" = "10" ]; then
		    echo ""
		    echo "Unable to detect which port the board is connected to."
		    echo "Please reconnect your board."
		    echo "Press 'y' to attempt to detect your board again or press 'n' to continue..."
		    read -p "(y/n)" retryBoardDetection
	    fi

	    #if they choose not to retry, ask user to reboot manually and exit
	    if [ "$retryBoardDetection" = "n" ]; then
		    echo ""
		    echo "Please reboot your board manually and connect using minicom."
		    exit;
	    fi
    done

    #Change minicom to accurately reflect the bone
    minicomcfg=${HOME}/.minirc.dfl
    echo "pu port             /dev/$port
    pu baudrate         115200
    pu bits             8
    pu parity           N
    pu stopbits         1
    pu minit
    pu mreset
    pu mdialpre
    pu mdialsuf
    pu mdialpre2
    pu mdialsuf2
    pu mdialpre3
    pu mdialsuf3
    pu mconnect
    pu mnocon1          NO CARRIER
    pu mnocon2          BUSY
    pu mnocon3          NO DIALTONE
    pu mnocon4          VOICE
    pu rtscts           No" | tee $minicomcfg > /dev/null
    check_status
fi

echo "Would you like to run the setup script now (y/n)? For the general purpose evm "
echo "you must now connect the RS-232 cable to your evm now. For the Beaglebone (Black)"
echo "or StarterKit this step should of already have been done. Also connect the ethernet"
echo "cable as described in the Quick Start Guide."
echo "**Important**"
echo "Once answering 'y' on the prompt below you will have 300 seconds to turn on the"
echo "board or if it was already on reboot the board before the setup times out"
echo
echo "After successfully executing this script, your board will be set up. You will be "
echo "able to connect to it by executing 'minicom -w' or if you prefer a windows host"
echo "you can set up Tera Term as explained in the Software Developer's Guide."
echo "If you connect minicom or Tera Term and power cycle the board Linux will boot."
echo
read -p "[ y ] " minicomsetup

if [ ! -n "$minicomsetup" ]; then
minicomsetup="y"
fi

if [ "$minicomsetup" = "y" ]; then
cd $cwd
sudo minicom -w -S setupBoard.minicom
cd -
fi

echo "You can manually run minicom in the future with this setup script using: minicom -S $cwd/setupBoard.minicom"
echo "--------------------------------------------------------------------------------"
