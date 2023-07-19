# Docker Postgres
## A simple container environment with PostgreSql


### Getting Started

* Copy and modify .env.example as you want (postgres password inside the file):
```bash
cp .env.example .env
```

* Build the image:
```bash
./control.sh build
```

* Start the container:
```bash
./control.sh up
```

* Stop the container:
```bash
./control.sh down
```

* Clean all the data:
```bash
./control.sh clean 
```

* Check control options:
```bash
./control.sh help
```
