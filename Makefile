SHELL := bash

include .env
export

install:
	curl -o mc https://dl.min.io/client/mc/release/linux-amd64/mc
	chmod +x mc
	./mc config host add minio $(S3_URL) $(S3_ACCESS_KEY) $(S3_SECRET_KEY)

run:
	docker-compose up -d

stop:
	docker-compose down

clean:
	docker-compose rm --stop --force

dump-db:
	docker exec $(DB_CONTAINER_NAME) mysqldump -u $(DB_USER) -p$(DB_PASSWORD) $(DB_NAME) > docker-entrypoint-initdb.d/dump.sql

restore-db:
	docker exec -i $(DB_CONTAINER_NAME) mysql -u $(DB_USER) -p$(DB_PASSWORD) $(DB_NAME) < docker-entrypoint-initdb.d/dump.sql

dump-wp-content:
	docker cp $(WP_CONTAINER_NAME):/var/www/html/wp-content ./

restore-wp-content:
	docker cp ./wp-content $(WP_CONTAINER_NAME):/var/www/html

backup-all: dump-db dump-wp-content
	gzip -c ./docker-entrypoint-initdb.d/dump.sql > backups/dump.sql.gz
	./mc cp ./backups/dump.sql.gz minio/$(PROJECT_NAME)/$$(date +%Y%m%d%H%M%S).sql.gz
	./mc cp ./backups/dump.sql.gz minio/$(PROJECT_NAME)/latest.sql.gz

	tar -zcvf ./backups/wp-content.tar.gz ./wp-content
	./mc cp ./backups/wp-content.tar.gz minio/$(PROJECT_NAME)/$$(date +%Y%m%d%H%M%S).wp-content.tar.gz
	./mc cp ./backups/wp-content.tar.gz minio/$(PROJECT_NAME)/latest.wp-content.tar.gz

restore-from-backup:
	./mc cp minio/$(PROJECT_NAME)/latest.sql.gz ./backups/dump.sql.gz
	./mc cp minio/$(PROJECT_NAME)/latest.wp-content.tar.gz ./backups/wp-content.tar.gz

	gzip -cd ./backups/dump.sql.gz > ./docker-entrypoint-initdb.d/dump.sql
	tar -xvf ./backups/wp-content.tar.gz -C ./wp-content/

	make restore-wp-content
	make restore-db