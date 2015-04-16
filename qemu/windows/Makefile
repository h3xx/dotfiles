MAIN_DRIVE = drive_c.qcow2
PLAYGROUND_BASE = drive_c-base_playground.qcow2
SIZE_SWAP = 2G
CLEAN_SNAPSHOT = initial

PLAYGROUND = drive_c-playground.qed
SWAP = swap.raw

all: $(PLAYGROUND) $(SWAP)

$(PLAYGROUND_BASE): $(MAIN_DRIVE)
	qemu-img create -f qcow2 -b $< $@

# note: guessing size when creating against a backing file will make a bad image
%.qed: $(PLAYGROUND_BASE)
	qemu-img create -f qed -b $< $@

$(SWAP):
	qemu-img create -f raw $@ $(SIZE_SWAP)

list: $(MAIN_DRIVE)
	qemu-img snapshot -l $<

clean:
	$(RM) $(PLAYGROUND)
