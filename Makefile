# Bootstrap
setup:
	sh dep_install.sh
	cd goslib && protoc -I src/gos_rpc_proto --go_out=plugins=grpc:src/gos_rpc_proto src/gos_rpc_proto/*.proto
	cd game && ./tools/gen_routes
	cd game && ./tools/gen_protocol
	cd game && bundle exec rake generate_config
	cd game && bundle exec rake generate_tables

# Install dependent go packages
dep_install:
	sh dep_install.sh

# Build apps: auth, agent, game, world
build:
	sh build_gos.sh

start_all:
	mkdir -p logs
	nohup ./auth/bin/auth > logs/auth.log &
	nohup ./agent/bin/agent > logs/agent.log &
	nohup ./game/bin/game > logs/game.log &
	nohup ./world/bin/world > logs/world.log &

# Generate framework grpc proto
rpc_proto:
	cd goslib && protoc -I src/gos_rpc_proto --go_out=plugins=grpc:src/gos_rpc_proto src/gos_rpc_proto/*.proto

# Generate client-server communicate protocol files
tcp_protocol:
	cd game && ./tools/gen_routes
	cd game && ./tools/gen_protocol

generate_tables:
	cd game && bundle exec rake generate_tables

# Generate config files from excels
generate_configs:
	cd game && bundle exec rake generate_config

######################## Docker ######################## 
build_ubuntu_apps:
	docker run --rm -v $(shell pwd):/usr/src/gos -w /usr/src/gos -e GOOS=linux -e GOARCH=amd64 golang:ubuntu sh build_gos.sh

build_docker_images:
	docker run --rm -v $(shell pwd):/usr/src/gos -w /usr/src/gos -e GOOS=linux -e GOARCH=amd64 golang:alpine sh build_gos.sh
	cd dockers && ./build-dockers

push_docker_images:
	docker tag gos-auth-app savin198/gos-auth-app
	docker tag gos-connect-app savin198/gos-connect-app
	docker tag gos-game-app savin198/gos-game-app
	docker tag gos-world-app savin198/gos-world-app
	docker push savin198/gos-auth-app
	docker push savin198/gos-connect-app
	docker push savin198/gos-game-app
	docker push savin198/gos-world-app

run_dockers:
	cd dockers && ./run-apps

load_docker_images:
	cd dockers && ./load-images
