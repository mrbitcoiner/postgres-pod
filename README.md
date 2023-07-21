# Docker Postgres
## A simple container environment with PostgreSql

### CLI Features
* Create databases
* Dump databases
* Add databases to dump schedules
* Load databases from dump files

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

### Upgrading

* Build the image:
```bash
./control.sh build
```

* Start the container:
```bash
./control.sh up
```

### If you have some improvement suggestion, please leave it in the issues section.
