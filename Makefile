CONFIG_FILE ?= mpg123.config
BUILDROOT_URL ?= https://github.com/buildroot/buildroot.git
FS_OVERLAY ?= /music

.PHONY: build rpios

all: rpios

buildroot:
	@echo "downloading buildroot..."
	git clone $(BUILDROOT_URL)
	@echo "download complete."

music:
	@mkdir -p $@

buildroot/.config: buildroot music
	@echo "setting up config file..."
	@sed -i -e "s/BR2_ROOTFS_OVERLAY=\"\"/BR2_ROOTFS_OVERLAY=\"..\$(FS_OVERLAY)\"/" $(CONFIG_FILE)
	@cp $(CONFIG_FILE) buildroot/.config

build: buildroot/.config
	@echo "starting build, this will take a while if done for the first time..."
	@cd buildroot/ && make
	@echo "build done."

final:
	@echo "creating final directory..."
	@mkdir -p $@

final/sdcard.img: final
	@echo "copying image to final directory..."
	@cp -ar buildroot/output/images/sdcard.img final

rpios: build final/sdcard.img
	@echo "image generation complete."
	@echo "run command \"sudo dd if=sdcard.img of=/dev/{YOUR_DEVICE_ID_HERE} bs=1M status=progress\" from the final directory to copy image to your sd card"
