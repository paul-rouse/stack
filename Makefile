PKG_VERSION := $(shell cat stack.cabal|grep -e '^version:'|cut -d':' -f2|sed 's/\s//g')
GIT_REV_COUNT := $(shell git rev-list HEAD --count)
GIT_SHA := $(shell PAGER=cat git log --pretty=%h HEAD~1..HEAD|head -n1)
UBUNTU_VERSION ?= 15.04

default: deb

target/ubuntu-$(UBUNTU_VERSION):
	@mkdir -p target/ubuntu-$(UBUNTU_VERSION)

target/ubuntu-$(UBUNTU_VERSION)/stack_$(PKG_VERSION)-$(GIT_REV_COUNT)-$(GIT_SHA)_amd64.deb: | target/ubuntu-$(UBUNTU_VERSION)
	@cp etc/Dockerfile Dockerfile
	@perl -p -i -e "s/<<UBUNTU_VERSION>>/$(UBUNTU_VERSION)/g" Dockerfile
	@perl -p -i -e "s/<<PKG_VERSION>>/$(PKG_VERSION)/g" Dockerfile
	@perl -p -i -e "s/<<GIT_REV_COUNT>>/$(GIT_REV_COUNT)/g" Dockerfile
	@perl -p -i -e "s/<<GIT_SHA>>/$(GIT_SHA)/g" Dockerfile
	@docker build --rm=false --tag=stack-$(UBUNTU_VERSION):$(PKG_VERSION)-$(GIT_REV_COUNT)-$(GIT_SHA) .
	@docker run --rm -v target/ubuntu-$(UBUNTU_VERSION):/mnt stack-$(UBUNTU_VERSION):$(PKG_VERSION)-$(GIT_REV_COUNT)-$(GIT_SHA)

deb: | target/ubuntu-$(UBUNTU_VERSION)/stack_$(PKG_VERSION)-$(GIT_REV_COUNT)-$(GIT_SHA)_amd64.deb

clean:
	@rm -rf Dockerfile target

.PHONY: clean deb default