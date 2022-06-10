PRODUCT_NAME:=codw
VERSION:=0.1.0

LINUX_TARGET:=x86_64-unknown-linux-gnu
MACOSX_TARGET:=x86_64-apple-darwn
WINDOWS_TARGET:=x86_64-pc-windows-gnu

.PHONY: setup build-release release-for-macosx release-for-linux release-for-windows test format clippy check install help

ARGS:=list

.DEFAULT_GOAL := help

setup: ## setup environment ## make setup
	rustup component add rustfmt clippy 
	cargo install cross

debug: ## run in local environment ## make run add ms-python.vscode-pylance
	RUST_BACKTRACE=true cargo run -- ${ARGS}

build-release: 
	cargo build --release

release-for-macosx:  ## release for Mac OS X ## make release-for-macosx
	cross build --target ${MACOSX_TARGET} --release
	strip target/release/${PRODUCT_NAME}
	otool -L target/release/${PRODUCT_NAME}
	mkdir -p release
	tar -C ./target/${MACOSX_TARGET}/release/ -czvf ./release/${PRODUCT_NAME}-macosx.tar.gz ./${PRODUCT_NAME}

release-for-linux: ## release for Linux ## make release-for-linux
	cross build --target ${LINUX_TARGET} --release
	strip target/${LINUX_TARGET}/release/${PRODUCT_NAME}
	mkdir -p release
	tar -C ./target/${LINUX_TARGET}/release/ -czvf ./release/${PRODUCT_NAME}-linux-unknown.tar.gz ./${PRODUCT_NAME}

release-for-windows: ## release for Windows ## make release-for-windows
	cross build --target ${WINDOWS_TARGET} --release
	mkdir -p release
	tar -C ./target/${WINDOWS_TARGET}/release/ -czvf ./release/${PRODUCT_NAME}-windows.tar.gz ./${PRODUCT_NAME}.exe

test: ## run test ## make test
	cargo test

format: ## check format with rustfmt ## make format
	cargo fmt -- --check

clippy: ## code check with clippy ## make clippy 
	cargo clippy --all-features

check: ## format+clippy+test ## make check
	@make format 
	@make clippy test
	@make test

install: ## install codw in current directory ## make install
	cargo install --path "." --offline

help:  
	@echo "Example operations by makefile."
	@echo ""
	@echo "Usage: make SUB_COMMAND"
	@echo ""
	@echo "Command list:"
	@echo ""
	@printf "\033[36m%-30s\033[0m %-50s %s\n" "[Sub command]" "[Description]" "[Example]"
	@grep -E '^[/a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | perl -pe 's%^([/a-zA-Z_-]+):.*?(##)%$$1 $$2%' | sort | \
	awk -F " *?## *?" '{printf "\033[36m%-30s\033[0m %-50s %s\n", $$1, $$2, $$3}'
