##Connect to Flyway container,
##Use SQL Server driver through JDBC

docker run --rm -v /my/sqldir:/flyway/sql -v /my/confdir:/flyway/conf \
-v /my/driverdir:/flyway/drivers flyway/flyway migrate


##installation
docker pull maven
##container creation
docker run -it --rm --name mvnInstance -v "$(pwd)":/usr/src/mymaven -w /usr/src/mymaven maven:3.3-jdk-8 mvn clean install

docker build --tag my_local_maven:3.5.2-jdk-8 .