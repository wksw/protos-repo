include ../maintain/Makefile

clean: clear.sh ## 清理
	/bin/bash clear.sh

build: build.sh ## 编译协议文件
	# 拉取编译镜像
	$(DOCKER_PULL) $(DOCKERHUBPULLHOST)/$(BUILDIMAGE) || true
	# 编译
	$(DOCKER_RUN) -w /go/src/$(GITREPO)/$(PROJECT)/protos-repo \
		-v $$(pwd):/go/src/$(GITREPO)/$(PROJECT)/protos-repo \
		$(DOCKERHUBPULLHOST)/$(BUILDIMAGE) /bin/bash build.sh

