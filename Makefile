SERVER_A=35.243.102.51
SERVER_B=34.84.67.160
SERVER_C=34.84.11.210
SERVER_BENCH=10.10.10.10

build:
	go build

copy-key:
	ssh-copy-id -i ${HOME}/.ssh/id_ed25519.pub ${SERVER_A}
	ssh-copy-id -i ${HOME}/.ssh/id_ed25519.pub ${SERVER_B}
	ssh-copy-id -i ${HOME}/.ssh/id_ed25519.pub ${SERVER_C}

init-load:
	mkdir -p initfiles
	scp ${SERVER_A}:/etc/nginx/nginx.conf initfiles/nginx.conf-a
	scp ${SERVER_B}:/etc/nginx/nginx.conf initfiles/nginx.conf-b

deploy-daemon:
	cat isubata.service | ssh isucon@${SERVER_A} "sudo tee /etc/systemd/system/isubata.service"
	ssh ${SERVER_A} sudo systemctl daemon-reload
	cat nginx.conf | ssh isucon@${SERVER_A} "sudo tee /etc/nginx/nginx.conf"
	ssh ${SERVER_A} sudo systemctl restart nginx

deploy:
	go build
	ssh ${SERVER_A} sudo systemctl stop isubata
	scp isucon7-qual ${SERVER_A}:/home/isucon/isubata/webapp/go/isubata
	scp start.sh ${SERVER_A}:/home/isucon/start.sh
	scp run.sh ${SERVER_A}:/home/isucon/isubata/webapp/go/run.sh
	ssh ${SERVER_A} sudo systemctl start isubata

bench:
	ssh ${SERVER_BENCH} "cd isucon9-final && bench/bin/bench_linux run --payment=http://10.146.15.196:15000 --target=http://10.146.15.196:80 --assetdir=webapp/frontend/dist"

pprof:
	go tool pprof -http="127.0.0.1:8020" logs/latest/cpu.pprof

synclogs:
	rsync -av isucon@${SERVER_A}:/tmp/isucon/logs/ logs/
