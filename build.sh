docker stop hadoop
docker rm hadoop
docker build -t gentijo/hadoop .
docker run -it -p 8020:8020 -p 10000:10000 --name hadoop gentijo/hadoop
