build:
	@mkdir -p ./output && echo "Create output directory"
	@echo "Start build"
	@docker build -q -t i3ed . && echo "Build complete"
	@docker run -ti --mount type=bind,source=$(CURDIR)/output,target=/opt/output i3ed && echo "Exported deb"
	@echo "Build complete, run \"make install\" to finish installation"

install:
	@echo "Installing..."
	@sudo apt install -y ./output/i3-gaps_1.0-2.deb fzf aptitude neovim lxappearance pavucontrol zsh && echo "Installed apt packages."
	@pip3 install --user parse bumblebee-status pynvim && echo "Installed pip packages."
	@echo "Install complete"

clean:
	rm -rf ./output


