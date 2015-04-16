# care of modern.ie
DOWNLOAD_LIST_URL = https://az412801.vo.msecnd.net/vhd/VMBuild_20141027/VirtualBox/IE11/Linux/IE11.Win7.For.Linux.VirtualBox.txt

OVA = IE11\ -\ Win7.ova
VMDK = IE11\ -\ Win7-disk1.vmdk
DRIVE_C = drive_c.qcow2
URL_LIST = urls.lst

all: $(DRIVE_C)

$(URL_LIST):
	wget -O $@ "$(DOWNLOAD_LIST_URL)"
	sed -i -e 's,\r,,g' $@

download: $(URL_LIST)
	echo "Retrieving parts from Modern.IE"
	for url in $$(<$<); do \
		wget --continue "$$url" ;\
	done

combined.zip: download
	(for url in $$(<$(URL_LIST)); do \
		cat $$(basename -- "$$url") ;\
	done) >$@

$(OVA): combined.zip
	echo "Extracting virtualbox image"
	unzip "$<"
	touch "$@"

$(VMDK): $(OVA)
	tar xf $(OVA) "$@"

$(DRIVE_C): $(VMDK)
	echo "Converting virtualbox image to qcow2 format"
	qemu-img convert -c -f vmdk -O qcow2 "$<" "$@"

clean: $(URL_LIST)
	for url in $$(<$(URL_LIST)); do \
		$(RM) $$(basename -- "$$url") ;\
	done
	$(RM) $(URL_LIST) $(OVA) $(VMDK) combined.zip

.PHONY: download clean

.PRECIOUS: $(DRIVE_C)
