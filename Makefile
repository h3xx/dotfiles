SUBDIRS = \
		  ack

all: dootfiles

check:
	@err=0 ;\
	for dir in $(SUBDIRS); do \
		make -C $$dir check || err=1 ;\
	done ;\
	exit $$err

fix:
	(for bashrc in ~/.bashrc* ~/.bash_profile; do \
		if [[ "$$(readlink "$$bashrc")" =~ dotfiles/home ]]; then \
			ln -svTf "$$(readlink "$$bashrc" |sed -e 's,dotfiles/home,dotfiles/bash,')" "$$bashrc" ;\
		fi ;\
	done)
	(if [[ "$$(readlink ~/.ipager)" =~ dotfiles/home ]]; then \
		nl="$$(readlink ~/.ipager |sed -e 's,dotfiles/home/\.ipager,dotfiles/ipager,')" ;\
		rm ~/.ipager &&\
		ln -svTf "$$nl" ~/.ipager ;\
	fi)

dootfiles:
	@echo "thank mr skeltal"

.PHONY: all fix dootfiles
