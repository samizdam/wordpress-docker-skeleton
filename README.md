# Wordpress Dockerized Skeleton

## Install
```
git clone git@gitlab.samizdam.net:samizdam/wordpress-docker-skeleton.git
cd wordpress-docker-skeleton

cp .env.example .env # change your S3 values for use remote backups

make install # if you want use remote backups
```

## Run
```
make run
```

## Restore Data from Existing Wordpress

### Case 1: I has actual version of WP and want migrate to Dockerized Skeleton
1. Put sql dump to `docker-entrypoint-initdb.d/dump.sql` 
2. Put wp-content files to `./wp-content` 
3. Run `make run`, `make restore-wp-content`

### Case 2: I have old version of WP instance and want migrate to new version with Dockerized Skeleton   
1. Do import on old instance (Tools -> Import -> WordPress Importer)
2. Install new WP from this repository (See Install section) 
3. Login as admin to new instance and do export from file 

## Local Backup and Rollback

```
make dump-db
make dump-wp-content
make restore-db
make restore-wp-content
```

## Working with Remote Backups

For make backups and push it to S3:
```
make backup-all
``` 

Recipe make remove 2 copies of archives:
1. With current datetime in name
2. With latest entry in file name (override previous) 

Pull latest backups and restore:
```
make restore-from-backup
```

For restore backup from custom date, you can use mc client manual (`./mc` binary exists in project after `make install`). 

TODO: 
- Let's Encrypt certificate issue  
- Crontab backup entries