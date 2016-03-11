TARGETS = \
	signature.dat \
	commandline-tricks.dat \
	fortunes-selected.dat \
	quotes.dat

all: $(TARGETS)

clean:
	$(RM) $(TARGETS)

%.dat: %
	strfile $<

.PHONY: all clean
