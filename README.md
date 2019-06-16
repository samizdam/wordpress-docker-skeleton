# Wordpress Dockerized Skeleton

## Requirements

1. docker-compose with support 3.5+ file version
2. make
3. bash
4. curl 

## Install
```
git clone git@github.com:samizdam/wordpress-docker-skeleton.git
cd wordpress-docker-skeleton

cp .env.example .env # change your S3 values for use remote backups

make install # if you want use remote backups, optional. If you doesn't want use S3 for backups, you need run `cp docker-compose-network-example.yml docker-compose-network.yml` manual. 
```

## Run
```
make run
```

Now you have fresh WP instance and can pass installation wizard. 

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

## FAQ / Trouble shooting

### My site is running, but styles is broken / I see old domain in URL path for css / Request handled WP with redirect to outdated url. 
A: You need change siteurl option in database: `update wp_options set option_value='http://NEW_DOMAIN/' where option_name=siteurl;`
Wordpress has to _hardcoded_ url in database: 
```
+-----------+-------------+-----------------------+----------+
| option_id | option_name | option_value          | autoload |
+-----------+-------------+-----------------------+----------+
|         1 | siteurl     | https://example.com/ | yes      |
|         2 | home        | https://example.com  | yes      |
+-----------+-------------+-----------------------+----------+
```

### Site ask me about FTP credentials when I try install/update/remove plugins, themes, etc.
A: After restoring wp-content, owner of files your local user, instead `www-data`. You can go to container and run `chown -R www-data:www-data wp-content`. 

### I need SSL certificate for my domain 
1. clone https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion and start it. 
2. Set actual values for variables `HOSTNAME, LETSENCRYPT_EMAIL, EXTERNAL_NETWORK` in .env file.
3. Uncomment `EXTERNAL_NETWORK` value of `wordpress.networks` in docker-compose-network.yml
  
If you use this option, you can drop ports entry in docker-compose-network.yml, nginx-proxy doesn't need it. 

### How to I can backup my block with crontab? 
A: Add next entry to your crontab (`crontab -e`)
- for S3 backups: `0 1 * * * cd PATH_TO_YOUR_PROJECT && make backup-all` 
- for local backups: `0 1 * * * cd PATH_TO_YOUR_PROJECT && make dump-db; make dump-wp-content` 

## TODO: 
- Describe development workflow: how to update WP core, install plugins, change themes localy and delivery changes to production
