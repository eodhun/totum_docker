# Totum docker
Установить докер на чистую систему (debian):
```sh
wget -q -O - https://get.docker.com  | sudo bash
systemctl enable docker
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
docker build --tag totum_image .
docker-compose up -d
```
При запуске через docker-compose сервис будет автоматически стартовать после загрузки системы. 


Запустить totum в докере без docker-compose:
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

# Dump
Для того чтобы сдлеать dump:
```sh
docker exec $container pg_dump --dbname="postgresql://$user:$password@localhost/$database" -O --schema=main --no-tablespaces --exclude-table-data='_tmp_tables' | grep -v '^--' > $path
```
$container - наименование контейнера, либо его id
$user - пользователь postgres
$password - пароль postgres
$database - название базы postgres
$path - путь для сохраннения dump файла
Для восстановление системы из дампа необходимо скопировать существующий файл дампа с названием totum_dump.sql в директорию data

## Авторизация
Эти команды создают уже установленный экземпляр totum, в который достаточно авторизоваться с логином и паролем admin/admin
Если необходимо установить отличный от стандартного логин и пароль:
```sh
apt update && apt install git -y
git clone https://github.com/vvzvlad/totum_docker.git && cd totum_docker
docker build --tag totum_image --build-arg totum_user=user --build-arg totum_password=password --build-arg postgres_user=user --build-arg postgres_password=password . 
docker run -p 80:80 --name totum --volume totum_volume --detach totum_image
```
totum_user - логин для входа в систему тотум
totum_password - пароль для входа в систему тотум
postgres_user - логин для пользователя postgres
postgres_password - пароль для пользователя postgres
totum_database - название базы данных postgres
domain - личный сервер
email - email адрес
postgres_schema - название схемы базы данных postgres

### Остальные команды:  
Удалить все: docker rm -f $(docker ps -a -q) && docker rmi $(docker images -q)  
Собрать контейнер: docker build -t totum_image .  
Создать контейнер: docker run -p 80:80 --name totum -v totum_volume totum_image   
Остановить контейнер: docker stop   
Запустить остановленный контейнер: docker start totum  
Зайти в запущенный контейнер для диагностики: docker exec -it totum_docker_totum_1 /bin/bash
