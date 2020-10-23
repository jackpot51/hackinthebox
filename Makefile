VM=macOS
ISO=$(VM).iso
VDI=$(VM).vdi
VBM=VBoxManage
VB_AUDIO=pulse

run:
	"$(VBM)" startvm "$(VM)"

#TODO: automatic extensions install?
build:
	echo "Delete VM"
	-"$(VBM)" unregistervm "$(VM)" --delete; \
	if [ $$? -ne 0 ]; \
	then \
		if [ -d "$$HOME/VirtualBox VMs/$(VM)" ]; \
		then \
			echo "VM directory exists, deleting..."; \
			$(RM) -rf "$$HOME/VirtualBox VMs/$(VM)"; \
		fi \
	fi
	echo "Create VM"
	"$(VBM)" createvm --name "$(VM)" --register
	echo "Set Configuration"
	"$(VBM)" modifyvm "$(VM)" --ostype MacOS_64
	"$(VBM)" modifyvm "$(VM)" --memory 8192
	"$(VBM)" modifyvm "$(VM)" --vram 128
	"$(VBM)" modifyvm "$(VM)" --cpus 4
	"$(VBM)" modifyvm "$(VM)" --rtcuseutc on
	"$(VBM)" modifyvm "$(VM)" --firmware efi
	"$(VBM)" modifyvm "$(VM)" --chipset ich9
	if [ "$(net)" != "no" ]; \
	then \
		"$(VBM)" modifyvm "$(VM)" --nic1 nat; \
		"$(VBM)" modifyvm "$(VM)" --nictype1 82545EM; \
		"$(VBM)" modifyvm "$(VM)" --cableconnected1 on; \
	fi
	"$(VBM)" modifyvm "$(VM)" --usbxhci on
	"$(VBM)" modifyvm "$(VM)" --keyboard usb
	"$(VBM)" modifyvm "$(VM)" --mouse usbtablet
	"$(VBM)" modifyvm "$(VM)" --audio $(VB_AUDIO)
	"$(VBM)" modifyvm "$(VM)" --audiocontroller hda
	"$(VBM)" modifyvm "$(VM)" --nestedpaging on
	echo "Magic"
	"$(VBM)" modifyvm "$(VM)" --cpuidset 00000001 000106e5 00100800 0098e3fd bfebfbff
	"$(VBM)" setextradata "$(VM)" "VBoxInternal/Devices/efi/0/Config/DmiSystemProduct" "iMac11,3"
	"$(VBM)" setextradata "$(VM)" "VBoxInternal/Devices/efi/0/Config/DmiSystemVersion" "1.0"
	"$(VBM)" setextradata "$(VM)" "VBoxInternal/Devices/efi/0/Config/DmiBoardProduct" "Iloveapple"
	"$(VBM)" setextradata "$(VM)" "VBoxInternal/Devices/smc/0/Config/DeviceKey" "ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
	"$(VBM)" setextradata "$(VM)" "VBoxInternal/Devices/smc/0/Config/GetKeyFromRealSMC" 1
	echo "Attach Disks"
	"$(VBM)" storagectl "$(VM)" --name SATA --add sata --controller IntelAHCI --portcount 2 --hostiocache on --bootable on
	if [ -e "$(VDI)" ]; \
	then \
		"$(VBM)" closemedium disk "$(VDI)" --delete; \
	fi
	"$(VBM)" createmedium disk --filename "$(VDI)" --size 131072 --format VDI
	"$(VBM)" storageattach "$(VM)" --storagectl SATA --port 0 --device 0 --type hdd --nonrotational on --medium "$(VDI)"
	"$(VBM)" storageattach "$(VM)" --storagectl SATA --port 1 --device 0 --type dvddrive --medium "$(ISO)"
