# Equates to: [a-z]* + .dat suffix
TARGETS = $(addsuffix .dat,$(filter-out $(wildcard *.dat),$(wildcard [a-z]*)))

all: $(TARGETS)

clean:
	$(RM) $(TARGETS)

%.dat: %
	strfile $<

.PHONY: all clean
