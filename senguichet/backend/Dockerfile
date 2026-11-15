
# Image de base : Java 17 (JDK)
FROM eclipse-temurin:17-jdk

# Répertoire de travail dans le conteneur
WORKDIR /app

# Copier le fichier JAR compilé dans l'image
COPY target/*.jar app.jar

# Exposer le port d'écoute de Spring Boot
EXPOSE 8080

# Commande de démarrage du conteneur
ENTRYPOINT ["java", "-jar", "app.jar"]
