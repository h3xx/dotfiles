
fix:
	(for bashrc in ~/.bashrc* ~/.bash_profile; do \
		if [[ "$$(readlink "$$bashrc")" =~ dotfiles/home ]]; then \
			ln -svTf "$$(readlink "$$bashrc" |sed -e 's,dotfiles/home,dotfiles/bash,')" "$$bashrc" ;\
		fi ;\
	done)

.PHONY: fix
