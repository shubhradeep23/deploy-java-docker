FROM adoptopenjdk/openjdk11
ADD target/springboot-example.jar app.jar
ENTRYPOINT ["java","-jar","app.jar"]