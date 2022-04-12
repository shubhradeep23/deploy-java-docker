FROM adoptopenjdk/openjdk11
ADD target/springboot-example.jar app.jar
EXPOSE 8080
EXPOSE 80
ENTRYPOINT ["java","-jar","app.jar"]