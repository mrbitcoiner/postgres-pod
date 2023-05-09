# Docker Postgres
## A simple dockerized ambient with PostgreSql + Adminer over HTTPS


### Instructions

* Copy and modify .env.example as you want (postgres password inside the file):
```bash
cp .env.example .env
```

* To run:
```bash
./control.sh up
```

* To stop:
```bash
./control.sh down
```

* To clean all the data:
```bash
./control.sh clean 
```

* Probably you will need to dump/restore databases, you can access postgres container with the following command
```bash
docker exec -it postgres bash
```

* Custom configuration for the postgres container will be executed after postgres initialization if inside 'containers/postgres/volume/scripts/custom.sh' (you may create this file)
