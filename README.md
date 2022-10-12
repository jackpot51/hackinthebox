# Hackintosh inside VirtualBox

To start, download the macOS ISO from
https://www.wikigain.com/install-macos-monterey-on-virtualbox/
and place it at `macOS.iso`

Make sure to install the VirtualBox extension pack from:
https://www.virtualbox.org/wiki/Downloads

`make build` - to build the VM

`make run` - to run the VM

The default resolution is 1920x1080. If you would like to change that, instead
run with the following:

`make run RESOLUTION=2560x1440`
