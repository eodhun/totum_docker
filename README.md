# Totum docker
Установить докер на чистую систему (debian):
```sh
wget -q -O - https://get.docker.com  | sudo bash
systemctl enable docker
```

Запустить totum в докере:
```sh
apt update && apt install git -y
git clone https://github.com/vvzvlad/totum_docker.git && cd totum_docker
docker build --tag totum_image .
docker run -p 80:80 --name totum --volume totum_volume --detach totum_image
```

Пересобрать и перезапустить контейнер, сохранив данные в БД (при обновлении git):  
```sh
docker container rm totum  
docker build --tag totum_image .  
docker run -p 80:80 --name totum --volume totum_volume totum_image  
```

Установить docker-compose:
```sh
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

Запустить totum через docker-compose:
```sh
apt update && apt install git -y
git clone https://github.com/vvzvlad/totum_docker.git && cd totum_docker
docker-compose up -d
```


Остальные команды:  
Удалить все: docker rm -f $(docker ps -a -q) && docker rmi $(docker images -q)  
Собрать контейнер: docker build -t totum_image .  
Создать контейнер: docker run -p 80:80 --name totum -v totum_volume totum_image   
Остановить контейнер: docker stop   
Запустить остановленный контейнер: docker start totum  
