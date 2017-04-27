all: cflinuxfs3.tar.gz

arch:=$(shell uname -m)
ifeq ("$(arch)","ppc64le")
        docker_image := "ppc64le/ubuntu:trusty"
        docker_file := cflinuxfs3/Dockerfile.$(arch)
        $(shell cp cflinuxfs3/Dockerfile $(docker_file))
        $(shell sed -i 's/FROM ubuntu:trusty/FROM ppc64le\/ubuntu:trusty/g' $(docker_file))
else
        docker_image := "ubuntu:trusty"
        docker_file := cflinuxfs3/Dockerfile
endif

cflinuxfs3.cid:
	docker build --no-cache -f $(docker_file) -t cloudfoundry/cflinuxfs3 cflinuxfs3
	docker run --cidfile=cflinuxfs3.cid cloudfoundry/cflinuxfs3 dpkg -l | tee cflinuxfs3/cflinuxfs3_dpkg_l.out

cflinuxfs3.tar: cflinuxfs3.cid
	mkdir -p tmp
	docker export `cat cflinuxfs3.cid` > tmp/cflinuxfs3.tar
	# Always remove the cid file in order to grab updated package versions.
	rm cflinuxfs3.cid

cflinuxfs3.tar.gz: cflinuxfs3.tar
	docker run -w /cflinuxfs3 -v `pwd`:/cflinuxfs3 $(docker_image) ./bin/make_tarball.sh cflinuxfs3
