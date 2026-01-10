-include .env

LOCAL_BIN:=$(CURDIR)/bin
APP_NAME:=chat-server
TAG:=v1
REGISTRY_ID=$(YANDEX_REGISTRY_ID)
REGISTRY:=cr.yandex/$(REGISTRY_ID)
IMAGE_NAME:=$(REGISTRY)/$(APP_NAME):$(TAG)

install-golangci-lint:
	curl -sSfL https://golangci-lint.run/install.sh | sh -s -- -b $(LOCAL_BIN) v2.7.2


lint:
	$(LOCAL_BIN)/golangci-lint run ./... --config .golangci.pipeline.yaml

install-deps:
	GOBIN=$(LOCAL_BIN) go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28.1
	GOBIN=$(LOCAL_BIN) go install -mod=mod google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2

get-deps:
	go get -u google.golang.org/protobuf/cmd/protoc-gen-go
	go get -u google.golang.org/grpc/cmd/protoc-gen-go-grpc

generate:
	make generate-chat-api

generate-chat-api:
	mkdir -p pkg/chat_v1
	protoc --proto_path api/chat_v1 \
	--go_out=pkg/chat_v1 --go_opt=paths=source_relative \
	--plugin=protoc-gen-go=bin/protoc-gen-go \
	--go-grpc_out=pkg/chat_v1 --go-grpc_opt=paths=source_relative \
	--plugin=protoc-gen-go-grpc=bin/protoc-gen-go-grpc \
	api/chat_v1/chat.proto

build-and-push:
	docker buildx build --platform linux/amd64 -t $(IMAGE_NAME) --push .

login:
	yc container registry configure-docker

help:
	@echo "Usage:"
	@echo "  make build-and-push  - Build and push image to Yandex Registry"
	@echo "  make login           - Configure Docker to use Yandex Registry"