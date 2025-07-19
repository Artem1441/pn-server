Запусть:

docker-compose up -d

Остановить:

docker-compose down

Остановить и стереть данные:

docker-compose down -v

Тест подключения:

docker exec -it docker-db-postgresql-1 psql -U postgres -d nails
