-include Rules.make

MAKE_JOBS ?= 1

all: linux matrix-gui arm-benchmarks am-sysinfo oprofile-example matrix-gui-browser refresh-screen u-boot-spl ti-crypto-examples linux-dtbs cryptodev ti-sgx-ddk-km pru-icss barcode-roi uio-module-drv evse-hmi protection-relays-hmi 
clean: linux_clean matrix-gui_clean arm-benchmarks_clean am-sysinfo_clean oprofile-example_clean matrix-gui-browser_clean refresh-screen_clean u-boot-spl_clean ti-crypto-examples_clean linux-dtbs_clean cryptodev_clean ti-sgx-ddk-km_clean pru-icss_clean barcode-roi_clean uio-module-drv_clean evse-hmi_clean protection-relays-hmi_clean 
install: linux_install matrix-gui_install arm-benchmarks_install am-sysinfo_install oprofile-example_install matrix-gui-browser_install refresh-screen_install u-boot-spl_install ti-crypto-examples_install linux-dtbs_install cryptodev_install ti-sgx-ddk-km_install pru-icss_install barcode-roi_install uio-module-drv_install evse-hmi_install protection-relays-hmi_install 
# Kernel build targets
linux: linux-dtbs
	@echo =================================
	@echo     Building the Linux Kernel
	@echo =================================
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) $(DEFCONFIG)
	$(MAKE) -j $(MAKE_JOBS) -C $(LINUXKERNEL_INSTALL_DIR) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) zImage
	$(MAKE) -j $(MAKE_JOBS) -C $(LINUXKERNEL_INSTALL_DIR) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) modules

linux_install: linux-dtbs_install
	@echo ===================================
	@echo     Installing the Linux Kernel
	@echo ===================================
	@if [ ! -d $(DESTDIR) ] ; then \
		echo "The extracted target filesystem directory doesn't exist."; \
		echo "Please run setup.sh in the SDK's root directory and then try again."; \
		exit 1; \
	fi
	install -d $(DESTDIR)/boot
	install $(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/zImage $(DESTDIR)/boot
	install $(LINUXKERNEL_INSTALL_DIR)/vmlinux $(DESTDIR)/boot
	install $(LINUXKERNEL_INSTALL_DIR)/System.map $(DESTDIR)/boot
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) INSTALL_MOD_PATH=$(DESTDIR) INSTALL_MOD_STRIP=$(INSTALL_MOD_STRIP) modules_install

linux_clean:
	@echo =================================
	@echo     Cleaning the Linux Kernel
	@echo =================================
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) mrproper
# Make Rules for matrix-gui project
matrix-gui:
	@echo =============================
	@echo      Building Matrix GUI
	@echo =============================
	@echo    NOTHING TO DO.  COMPILATION NOT REQUIRED

matrix-gui_clean:
	@echo =============================
	@echo      Cleaning Matrix GUI
	@echo =============================
	@echo    NOTHING TO DO.

matrix-gui_install:
	@echo =============================
	@echo     Installing Matrix GUI
	@echo =============================
	@cd example-applications; cd `find . -name "*matrix-gui-2.0*"`; make install
# arm-benchmarks build targets
arm-benchmarks:
	@echo =============================
	@echo    Building ARM Benchmarks
	@echo =============================
	@cd example-applications; cd `find . -name "*arm-benchmarks*"`; make

arm-benchmarks_clean:
	@echo =============================
	@echo    Cleaning ARM Benchmarks
	@echo =============================
	@cd example-applications; cd `find . -name "*arm-benchmarks*"`; make clean

arm-benchmarks_install:
	@echo ==============================================
	@echo   Installing ARM Benchmarks - Release version
	@echo ==============================================
	@cd example-applications; cd `find . -name "*arm-benchmarks*"`; make install

arm-benchmarks_install_debug:
	@echo ============================================
	@echo   Installing ARM Benchmarks - Debug Version
	@echo ============================================
	@cd example-applications; cd `find . -name "*arm-benchmarks*"`; make install_debug
# am-sysinfo build targets
am-sysinfo:
	@echo =============================
	@echo    Building AM Sysinfo
	@echo =============================
	@cd example-applications; cd `find . -name "*am-sysinfo*"`; make

am-sysinfo_clean:
	@echo =============================
	@echo    Cleaning AM Sysinfo
	@echo =============================
	@cd example-applications; cd `find . -name "*am-sysinfo*"`; make clean

am-sysinfo_install:
	@echo ===============================================
	@echo     Installing AM Sysinfo - Release version
	@echo ===============================================
	@cd example-applications; cd `find . -name "*am-sysinfo*"`; make install

am-sysinfo_install_debug:
	@echo =============================================
	@echo     Installing AM Sysinfo - Debug version
	@echo =============================================
	@cd example-applications; cd `find . -name "*am-sysinfo*"`; make install_debug
# oprofile-example build targets
oprofile-example:
	@echo =============================
	@echo    Building OProfile Example
	@echo =============================
	@cd example-applications; cd `find . -name "*oprofile-example*"`; make

oprofile-example_clean:
	@echo =============================
	@echo    Cleaning OProfile Example
	@echo =============================
	@cd example-applications; cd `find . -name "*oprofile-example*"`; make clean

oprofile-example_install:
	@echo =============================================
	@echo     Installing OProfile Example - Debug version
	@echo =============================================
	@cd example-applications; cd `find . -name "*oprofile-example*"`; make install
# matrix-gui-browser build targets
matrix-gui-browser:
	@echo =================================
	@echo    Building Matrix GUI Browser
	@echo =================================
	@cd example-applications; cd `find . -name "*matrix-gui-browser*"`; make -f Makefile.build release

matrix-gui-browser_clean:
	@echo =================================
	@echo    Cleaning Matrix GUI Browser
	@echo =================================
	@cd example-applications; cd `find . -name "*matrix-gui-browser*"`; make -f Makefile.build clean

matrix-gui-browser_install:
	@echo ===================================================
	@echo   Installing Matrix GUI Browser - Release version
	@echo ===================================================
	@cd example-applications; cd `find . -name "*matrix-gui-browser*"`; make -f Makefile.build install

matrix-gui-browser_install_debug:
	@echo =================================================
	@echo   Installing Matrix GUI Browser - Debug Version
	@echo =================================================
	@cd example-applications; cd `find . -name "*matrix-gui-browser*"`; make -f Makefile.build install_debug
# refresh-screen build targets
refresh-screen:
	@echo =============================
	@echo    Building Refresh Screen
	@echo =============================
	@cd example-applications; cd `find . -name "*refresh-screen*"`; make -f Makefile.build release

refresh-screen_clean:
	@echo =============================
	@echo    Cleaning Refresh Screen
	@echo =============================
	@cd example-applications; cd `find . -name "*refresh-screen*"`; make -f Makefile.build clean

refresh-screen_install:
	@echo ================================================
	@echo   Installing Refresh Screen - Release version
	@echo ================================================
	@cd example-applications; cd `find . -name "*refresh-screen*"`; make -f Makefile.build install

refresh-screen_install_debug:
	@echo ==============================================
	@echo   Installing Refresh Screen - Debug Version
	@echo ==============================================
	@cd example-applications; cd `find . -name "*refresh-screen*"`; make -f Makefile.build install_debug
# u-boot build targets
u-boot-spl: u-boot
u-boot-spl_clean: u-boot_clean
u-boot-spl_install: u-boot_install

u-boot: linux-dtbs
	@echo ===================================
	@echo    Building U-boot
	@echo ===================================
	$(MAKE) -j $(MAKE_JOBS) -C $(TI_SDK_PATH)/board-support/u-boot-* CROSS_COMPILE=$(CROSS_COMPILE) $(UBOOT_MACHINE)
	$(MAKE) -j $(MAKE_JOBS) -C $(TI_SDK_PATH)/board-support/u-boot-* CROSS_COMPILE=$(CROSS_COMPILE) DTC=$(LINUXKERNEL_INSTALL_DIR)/scripts/dtc/dtc

u-boot_clean:
	@echo ===================================
	@echo    Cleaining U-boot
	@echo ===================================
	$(MAKE) -C $(TI_SDK_PATH)/board-support/u-boot-* CROSS_COMPILE=$(CROSS_COMPILE) distclean

u-boot_install:
	@echo ===================================
	@echo    Installing U-boot
	@echo ===================================
	@echo "Nothing to do"
# ti-crypto-examples build targets
ti-crypto-examples:
	@echo =================================
	@echo    Building TI Crypto Examples
	@echo =================================
	@cd example-applications; cd `find . -name "*ti-crypto-examples*"`; make release

ti-crypto-examples_clean:
	@echo =================================
	@echo    Cleaning TI Crypto Examples
	@echo =================================
	@cd example-applications; cd `find . -name "*ti-crypto-examples*"`; make clean

ti-crypto-examples_install:
	@echo ===================================================
	@echo   Installing TI Crypto Examples - Release version
	@echo ===================================================
	@cd example-applications; cd `find . -name "*ti-crypto-examples*"`; make install

ti-crypto-examples_install_debug:
	@echo =================================================
	@echo   Installing TI Crypto Examples - Debug Version
	@echo =================================================
	@cd example-applications; cd `find . -name "*ti-crypto-examples*"`; make install_debug
# Kernel DTB build targets
linux-dtbs:
	@echo =====================================
	@echo     Building the Linux Kernel DTBs
	@echo =====================================
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) $(DEFCONFIG)
	$(MAKE) -j $(MAKE_JOBS) -C $(LINUXKERNEL_INSTALL_DIR) ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE) am335x-evm.dtb am335x-evmsk.dtb am335x-bone.dtb am335x-boneblack.dtb am335x-bonegreen.dtb am335x-icev2.dtb am335x-icev2-pru-excl-uio.dtb am335x-boneblack-iot-cape.dtb am335x-icev2-pru-excl-uio.dtb

linux-dtbs_install:
	@echo =======================================
	@echo     Installing the Linux Kernel DTBs
	@echo =======================================
	@if [ ! -d $(DESTDIR) ] ; then \
		echo "The extracted target filesystem directory doesn't exist."; \
		echo "Please run setup.sh in the SDK's root directory and then try again."; \
		exit 1; \
	fi
	install -d $(DESTDIR)/boot
	@cp -f $(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/*.dtb $(DESTDIR)/boot/

linux-dtbs_clean:
	@echo =======================================
	@echo     Cleaning the Linux Kernel DTBs
	@echo =======================================
	@echo "Nothing to do"

cryptodev: linux
	@echo ================================
	@echo      Building cryptodev-linux
	@echo ================================
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -name "cryptodev*"`; \
	make ARCH=arm KERNEL_DIR=$(LINUXKERNEL_INSTALL_DIR)

cryptodev_clean:
	@echo ================================
	@echo      Cleaning cryptodev-linux
	@echo ================================
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -name "cryptodev*"`; \
	make ARCH=arm KERNEL_DIR=$(LINUXKERNEL_INSTALL_DIR) clean

cryptodev_install:
	@echo ================================
	@echo      Installing cryptodev-linux
	@echo ================================
	@if [ ! -d $(DESTDIR) ] ; then \
		echo "The extracted target filesystem directory doesn't exist."; \
		echo "Please run setup.sh in the SDK's root directory and then try again."; \
		exit 1; \
	fi
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -name "cryptodev*"`; \
	make ARCH=arm  KERNEL_DIR=$(LINUXKERNEL_INSTALL_DIR)  INSTALL_MOD_PATH=$(DESTDIR) PREFIX=$(SDK_PATH_TARGET) INSTALL_MOD_STRIP=$(INSTALL_MOD_STRIP) install
# ti-sgx-ddk-km module
ti-sgx-ddk-km: linux
	@echo ================================
	@echo      Building ti-sgx-ddk-km
	@echo ================================
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -name "ti-sgx-ddk-km*" -type d`; \
	make -C ./eurasia_km/eurasiacon/build/linux2/omap_linux ARCH=arm TARGET_PRODUCT=ti335x KERNELDIR=$(LINUXKERNEL_INSTALL_DIR)

ti-sgx-ddk-km_clean:
	@echo ================================
	@echo      Cleaning ti-sgx-ddk-km
	@echo ================================
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -name "ti-sgx-ddk-km*" -type d`; \
	make -C ./eurasia_km/eurasiacon/build/linux2/omap_linux ARCH=arm KERNELDIR=$(LINUXKERNEL_INSTALL_DIR) clean

ti-sgx-ddk-km_install:
	@echo ================================
	@echo      Installing ti-sgx-ddk-km
	@echo ================================
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -name "ti-sgx-ddk-km*" -type d`; \
	cd ./eurasia_km/eurasiacon/binary2_omap_linux_release/target/kbuild; \
	make -C $(LINUXKERNEL_INSTALL_DIR) SUBDIRS=`pwd` INSTALL_MOD_PATH=$(DESTDIR) PREFIX=$(SDK_PATH_TARGET) INSTALL_MOD_STRIP=$(INSTALL_MOD_STRIP) modules_install

# PRU-ICSS build targets
pru-icss:
	@echo =================================
	@echo    Building PRU-ICSS
	@echo =================================
	@cd example-applications; cd `find . -name "*pru-icss*"`; \
	for dir in examples pru_cape/pru_fw lib/src labs; \
	do \
		make -C $$dir PRU_CGT=$(LINUX_DEVKIT_PATH)/sysroots/x86_64-arago-linux/usr/share/ti/cgt-pru; \
	done

pru-icss_clean:
	@echo =================================
	@echo    Cleaning PRU-ICSS
	@echo =================================
	@cd example-applications; cd `find . -name "*pru-icss*"`; \
	for dir in examples pru_cape/pru_fw lib/src labs; \
	do \
		make -C $$dir clean PRU_CGT=$(LINUX_DEVKIT_PATH)/sysroots/x86_64-arago-linux/usr/share/ti/cgt-pru; \
	done

pru-icss_install: pru-icss_install_am335x

pru-icss_install_common:
	@echo ===================================================
	@echo   Installing PRU-ICSS
	@echo ===================================================
	@if [ ! -d $(DESTDIR) ] ; then \
		echo "The extracted target filesystem directory doesn't exist."; \
		echo "Please run setup.sh in the SDK's root directory and then try again."; \
		exit 1; \
	fi
	@install -d $(DESTDIR)/lib/firmware/pru

pru-icss_install_none:
	@echo ===================================================
	@echo   Nothing to install
	@echo ===================================================

pru-icss_install_am335x: pru-icss_install_common
	@cd example-applications; cd `find . -name "*pru-icss*"`; \
	install -m 0644 ./examples/am335x/PRU_Halt/gen/PRU_Halt.out \
		$(DESTDIR)/lib/firmware/pru; \
	for i in 0 1; \
	do \
		install -m 0644 ./examples/am335x/PRU_RPMsg_Echo_Interrupt$${i}/gen/PRU_RPMsg_Echo_Interrupt$${i}.out \
			$(DESTDIR)/lib/firmware/pru; \
	done

pru-icss_install_am437x: pru-icss_install_common
	@cd example-applications; cd `find . -name "*pru-icss*"`; \
	install -m 0644 ./examples/am437x/PRU_Halt/gen/PRU_Halt.out \
		$(DESTDIR)/lib/firmware/pru; \
	for i in 0 1; \
	do \
		install -m 0644 ./examples/am437x/PRU_RPMsg_Echo_Interrupt$${i}/gen/PRU_RPMsg_Echo_Interrupt$${i}.out \
			$(DESTDIR)/lib/firmware/pru; \
	done

pru-icss_install_am572x: pru-icss_install_common
	@cd example-applications; cd `find . -name "*pru-icss*"`; \
	install -m 0644 ./examples/am572x/PRU_Halt/gen/PRU_Halt.out \
		$(DESTDIR)/lib/firmware/pru; \
	for i in 1 2; \
	do \
		for j in 0 1; \
		do \
			install -m 0644 ./examples/am572x/PRU_RPMsg_Echo_Interrupt$${i}_$${j}/gen/PRU_RPMsg_Echo_Interrupt$${i}_$${j}.out \
				$(DESTDIR)/lib/firmware/pru; \
		done; \
	done

pru-icss_install_k2g: pru-icss_install_common
	@cd example-applications; cd `find . -name "*pru-icss*"`; \
	install -m 0644 ./examples/k2g/PRU_Halt/gen/PRU_Halt.out \
		$(DESTDIR)/lib/firmware/pru; \
	for i in 0 1; \
	do \
		for j in 0 1; \
		do \
			install -m 0644 ./examples/k2g/PRU_RPMsg_Echo_Interrupt$${i}_$${j}/gen/PRU_RPMsg_Echo_Interrupt$${i}_$${j}.out \
				$(DESTDIR)/lib/firmware/pru; \
		done; \
	done
# barcode-roi build targets

barcode-roi:
	@echo =============================
	@echo    Building Barcode ROI
	@echo =============================
	@cd example-applications; cd `find . -name "*barcode-roi*"`; make -f Makefile.build release

barcode-roi_clean:
	@echo =============================
	@echo    Cleaning Barcode ROI
	@echo =============================
	@cd example-applications; cd `find . -name "*barcode-roi*"`; make -f Makefile.build clean

barcode-roi_install:
	@echo ================================================
	@echo   Installing Barcode ROI - Release version
	@echo ================================================
	@cd example-applications; cd `find . -name "*barcode-roi*"`; make -f Makefile.build install
uio-module-drv: linux
	@echo ================================
	@echo      Building uio-module-drv
	@echo ================================
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -name "uio-module-drv*"`; \
	make ARCH=arm KERNEL_SRC=$(LINUXKERNEL_INSTALL_DIR)

uio-module-drv_clean:
	@echo ================================
	@echo      Cleaning uio-module-drv
	@echo ================================
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -name "uio-module-drv*"`; \
	make ARCH=arm KERNEL_SRC=$(LINUXKERNEL_INSTALL_DIR) clean

uio-module-drv_install:
	@echo ================================
	@echo      Installing uio-module-drv
	@echo ================================
	@if [ ! -d $(DESTDIR) ] ; then \
		echo "The extracted target filesystem directory doesn't exist."; \
		echo "Please run setup.sh in the SDK's root directory and then try again."; \
		exit 1; \
	fi
	@cd board-support/extra-drivers; \
	cd `find . -maxdepth 1 -name "uio-module-drv*"`; \
	make ARCH=arm  KERNEL_SRC=$(LINUXKERNEL_INSTALL_DIR)  INSTALL_MOD_PATH=$(DESTDIR) PREFIX=$(SDK_PATH_TARGET) INSTALL_MOD_STRIP=$(INSTALL_MOD_STRIP) modules_install
# Evse HMI build targets
evse-hmi:
	@echo ================================
	@echo    Building Evse HMI Demo
	@echo ================================
	@cd example-applications; cd `find . -name "*evse-hmi*"`; make -f Makefile.build

evse-hmi_clean:
	@echo ================================
	@echo    Building Evse HMI Demo
	@echo ================================
	@cd example-applications; cd `find . -name "*evse-hmi*"`; make -f Makefile.build clean

evse-hmi_install:
	@echo ===================================================
	@echo   Installing Evse HMI Demo - Release version
	@echo ===================================================
	@cd example-applications; cd `find . -name "*evse-hmi*"`; make -f Makefile.build install

evse-hmi_install_debug:
	@echo =================================================
	@echo   Installing Evse HMI Demo - Debug version
	@echo =================================================
	@cd example-applications; cd `find . -name "*evse-hmi*"`; make -f Makefile.build install_debug
#Protection Relays HMI build targets
protection-relays-hmi:
	@echo ================================
	@echo    Building Protection Relays HMI Demo
	@echo ================================
	@cd example-applications; cd `find . -name "*protection-relays-hmi*"`; make -f Makefile.build

protection-relays-hmi_clean:
	@echo ================================
	@echo    Building Protection Relays HMI Demo
	@echo ================================
	@cd example-applications; cd `find . -name "*protection-relays-hmi*"`; make -f Makefile.build clean

protection-relays-hmi_install:
	@echo ===================================================
	@echo   Installing Protection Relays HMI Demo - Release version
	@echo ===================================================
	@cd example-applications; cd `find . -name "*protection-relays-hmi*"`; make -f Makefile.build install

protection-relays-hmi_install_debug:
	@echo =================================================
	@echo   Installing Protection Relays HMI Demo - Debug version
	@echo =================================================
	@cd example-applications; cd `find . -name "*protection-relays-hmi*"`; make -f Makefile.build install_debug
