VM=macOS
VMDK=$(VM).vmdk
VBM=VBoxManage
VB_AUDIO=pulse

all:
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
	"$(VBM)" modifyvm "$(VM)" --ostype MacOS1013_64
	"$(VBM)" modifyvm "$(VM)" --memory 4096
	"$(VBM)" modifyvm "$(VM)" --vram 128
	"$(VBM)" modifyvm "$(VM)" --cpus 2
	"$(VBM)" modifyvm "$(VM)" --rtcuseutc on
	"$(VBM)" modifyvm "$(VM)" --firmware efi
	"$(VBM)" modifyvm "$(VM)" --chipset ich9
	if [ "$(net)" != "no" ]; \
	then \
		"$(VBM)" modifyvm "$(VM)" --nic1 nat; \
		"$(VBM)" modifyvm "$(VM)" --nictype1 82545EM; \
		"$(VBM)" modifyvm "$(VM)" --cableconnected1 on; \
	fi
	"$(VBM)" modifyvm "$(VM)" --usb on
	"$(VBM)" modifyvm "$(VM)" --keyboard ps2
	"$(VBM)" modifyvm "$(VM)" --mouse ps2
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
	echo "Attach Disk"
	"$(VBM)" storagectl "$(VM)" --name ATA --add sata --controller IntelAHCI --portcount 1 --hostiocache on --bootable on
	"$(VBM)" storageattach "$(VM)" --storagectl ATA --port 0 --device 0 --type hdd --medium "$(VMDK)"
	echo "Run VM"
	"$(VBM)" startvm "$(VM)"
