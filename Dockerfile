#latest Image Flyway
FROM flyway/flyway:6.5.0
#containing personal instructions.
#COPY testfile.txt .
RUN flyway
LABEL "name"="flwInstance"
COPY ./SQLFiles/*.sql /sql/


