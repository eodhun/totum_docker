Удалить все: docker rm -f $(docker ps -a -q) && docker rmi $(docker images -q)  
Собрать контейнер: docker build -t totum_image .  
Создать контейнер: docker run -p 80:80 --name totum -v totum_volume totum_image   
Остановить контейнер: docker stop   
Запустить остановленный контейнер: docker start totum  


Пересобрать и перезапустить контейнер, сохранив данные в БД (при обновлении git):  
docker container rm totum  
docker build -t totum_image .  
docker run -p 80:80 --name totum -v totum_volume totum_image  
