TARGETS = \
	signature.dat \
	commandline-tricks.dat \
	fortunes-selected.dat \
	quotes.dat \
	tf2.dat

all: $(TARGETS)

clean:
	$(RM) $(TARGETS)

%.dat: %
	strfile $<

.PHONY: all clean
