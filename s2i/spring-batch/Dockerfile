FROM arm32v7/openjdk:8-jdk 
ARG user=spring
ARG group=spring
ARG uid=1000
ARG gid=1000
RUN groupadd -g ${gid} ${group} && useradd -u ${uid} -g ${gid} -m -s /bin/bash ${user}
USER ${user}
ARG DEPENDENCY=target/dependency
COPY ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY ${DEPENDENCY}/META-INF /app/META-INF
COPY ${DEPENDENCY}/BOOT-INF/classes /app
COPY csv /app/csv
ENTRYPOINT ["java","-cp","app:app/lib/*","com.capgemini.main.Application"]