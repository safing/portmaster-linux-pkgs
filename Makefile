#!/usr/bin/make -f
STARTURL ?= https://updates.safing.io/latest/linux_amd64/start/portmaster-start\?CI

.PHONY: icons test-debian test-ubuntu  nfpm.yaml

all: deb rpm

nfpm.yaml: portmaster-start
	sed -e "s/^version:.*$$/version: v$(shell ./portmaster-start version --short)-$(shell cat ./pkgrev)/g" ./nfpm.yaml.template > ./nfpm.yaml

# We don't build here, we download the built binaries
build: icons nfpm.yaml

#portmaster.png:
#	convert logo.png -resize 32x32 portmaster.png

icons:
	for res in 16 32 48 96 128 ; do \
		mkdir -p icons/$$res ; \
		convert ./portmaster_logo.png -resize $${res}x$${res} icons/$${res}/portmaster.png ; \
	done

portmaster-start:
	curl --fail --user-agent GitHub -o portmaster-start $(STARTURL)
	chmod +x ./portmaster-start

deb: distdir build
	nfpm package --packager deb -t dist

rpm: distdir build
	nfpm package --packager rpm -t dist

distdir:
	mkdir -p ./dist

clean:
	rm -r ./portmaster-start ./dist icons/ nfpm.yaml || true

test-debian: build deb
	docker run -ti --rm -v $(shell pwd)/dist:/work -w /work debian:latest bash -c 'apt update && apt install -y ca-certificates && dpkg -i /work/portmaster*.deb ; bash'

test-ubuntu: build deb
	docker run -ti --rm -v $(shell pwd)/dist:/work -w /work ubuntu:latest bash -c 'apt update && apt install -y ca-certificates && dpkg -i /work/portmaster*.deb ; bash'