SRV_A=34.84.242.242
SRV_BENCH=10.10.10.10

build:
	go build

init-load:
	scp ${SRV_A}:/etc/nginx/nginx.conf .

deploy-daemon:
	cat isubata.service | ssh isucon@${SRV_A} "sudo tee /etc/systemd/system/isubata.service"
	ssh ${SRV_A} sudo systemctl daemon-reload
	cat nginx.conf | ssh isucon@${SRV_A} "sudo tee /etc/nginx/nginx.conf"
	ssh ${SRV_A} sudo systemctl restart nginx

deploy:
	go build
	ssh ${SRV_A} sudo systemctl stop isubata
	scp isucon7-qual ${SRV_A}:/home/isucon/isubata/webapp/go/isubata
	scp start.sh ${SRV_A}:/home/isucon/start.sh
	ssh ${SRV_A} sudo systemctl start isubata

bench:
	ssh ${SRV_BENCH} "cd isucon9-final && bench/bin/bench_linux run --payment=http://10.146.15.196:15000 --target=http://10.146.15.196:80 --assetdir=webapp/frontend/dist"

pprof:
	go tool pprof -http="127.0.0.1:8020" logs/latest/cpu.pprof

synclogs:
	rsync -av isucon@${SRV_A}:/tmp/isucon/logs/ logs/
