#! /bin/bash

# 编译协议文件

ROOTDIR=$(cd $(dirname $0);pwd)

for protofile in $(find $ROOTDIR/ -type f -name '*.proto')
do
	protodir=$(dirname $protofile)
	file=$(basename $protofile)
	which clang-format >/dev/null 2>&1 && clang-format -i $protofile
	cd $protodir
	# 生成golang的grpc代码
	protoc -I/usr/local/include \
		-I${GOPATH}/src \
		-I. \
		--go_out=plugins=grpc:. \
		${file}
	protogo="${protodir}/$(basename $protofile|awk -F'.proto' '{print $1}').pb.go"
	if [ -f "$protogo" ];then
		serviceDesc=$(grep -E '^var .*_serviceDesc' $protogo |awk '{print $2}')
		for desc in $serviceDesc
		do
			if [ -n "$desc" ];then
				serviceDescNounderline=$(echo $desc|sed 's/^_//g')
				# 把serviceDesc前面的下划线去掉
				sed -i "s%${desc}%${serviceDescNounderline}%g" $protogo
			fi
		done

	fi

	if [ -f "${protodir}/gateway.yaml" ];then
		# 生成grpc-gateway的代码
		protoc -I/usr/local/include \
			-I${GOPATH}/src \
			-I. \
			--grpc-gateway_out=logtostderr=true,grpc_api_configuration=${protodir}/gateway.yaml:. \
			${file}
		# 生成grpc-gateway的swagger的API文档
		protoc -I/usr/local/include \
			-I${GOPATH}/src \
			-I${protodir} \
			--swagger_out=logtostderr=true,grpc_api_configuration=${protodir}/gateway.yaml:. \
			${file}
	fi
done

# -I$GOPATH/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \

