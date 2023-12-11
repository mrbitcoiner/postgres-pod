# Postgres Pod
## A simple container environment with PostgreSql and Adminer

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

* With the container running, dump your databases:
```bash
./control.sh dumpdb <db_name> <dump_label>
```

* Stop the containers:
```bash
./control.sh down
```

* Pull master:
```bash
git pull origin master
```

* Build the image:
```bash
./control.sh build
```

* Start the container:
```bash
./control.sh up
```

* Restore your databases from dumps:
```bash
./control.sh loaddb <db_name> <dump_label>
```

### If you have some improvement suggestion, please leave it in the issues.
