#!/usr/bin/env bash
# ============================================================
#  creer-senguichet.sh
#  Genere le code de base du projet fil rouge SenGuichet
#  Cours : Ateliers de Genie Logiciel (AGL) - Master 1 SIR
#  DMI/FST/UCAD
# ============================================================
#
#  USAGE :
#    chmod +x creer-senguichet.sh
#    ./creer-senguichet.sh [nom-du-dossier]
#
#  Si aucun nom n'est fourni, le projet est cree dans ./senguichet
#
#  Ce script cree toute l'arborescence backend (Spring Boot) +
#  frontend (React/Vite), avec le wrapper Maven embarque (mvnw),
#  puis installe les dependances npm.
#
#  PREREQUIS : JDK 17+ et Node.js 18+. Maven n'est PAS requis
#  (le wrapper mvnw telecharge Maven automatiquement).
# ============================================================

set -e

PROJET="${1:-senguichet}"

if [ -d "$PROJET" ]; then
  echo "ERREUR : le dossier '$PROJET' existe deja. Choisissez un autre nom ou supprimez-le."
  exit 1
fi

echo "=========================================="
echo "  Creation du projet SenGuichet"
echo "  Dossier : $PROJET"
echo "=========================================="
echo ""

mkdir -p "$PROJET"
cd "$PROJET"

# Fonction : cree un fichier en creant ses dossiers parents
ecrire_fichier() {
  local chemin="$1"
  mkdir -p "$(dirname "$chemin")"
  cat > "$chemin"
}

# Fonction : ecrit un fichier depuis du base64 (pour mvnw etc.)
ecrire_base64() {
  local chemin="$1"
  mkdir -p "$(dirname "$chemin")"
  base64 -d > "$chemin"
}

echo "Creation des fichiers source..."


echo "  - .gitignore"
ecrire_fichier '.gitignore' << 'SENGUICHET_EOF_MARKER'
# ===== Java / Spring Boot =====
backend/target/
*.class

# Le wrapper Maven (mvnw, mvnw.cmd, .mvn/) DOIT etre versionne :
# c'est lui qui permet de lancer le projet sans installer Maven.

# ===== React / Node =====
frontend/node_modules/
frontend/dist/
frontend/build/

# ===== Variables d'environnement (secrets) =====
.env
.env.local
*.env

# ===== IDE =====
.idea/
.vscode/
*.iml
.classpath
.project
.settings/

# ===== Systeme =====
.DS_Store
Thumbs.db

# ===== Logs =====
*.log
SENGUICHET_EOF_MARKER

echo "  - README.md"
ecrire_fichier 'README.md' << 'SENGUICHET_EOF_MARKER'
# SénGuichet

Guichet unique universitaire — projet fil rouge du cours **Ateliers de Génie Logiciel (AGL)**, Master 1 SIR, DMI/FST/UCAD.

Application web de gestion des demandes administratives étudiantes : dépôt d'une demande, suivi de son statut, traitement par l'administration.

## Stack technique

| Composant | Technologie |
|-----------|-------------|
| Backend | Spring Boot 3 (Java 17) + Spring Data JPA |
| Frontend | React 18 + Vite |
| Base de données | PostgreSQL 16 (ou H2 en mémoire pour démarrer) |

## Prérequis

- **JDK 17 ou supérieur** (pour le backend). Vérifiez avec `java -version`.
- **Node.js 18 ou supérieur** (pour le frontend). Vérifiez avec `node -v`.

Maven n'est **pas** requis : le projet inclut le *wrapper Maven* (`mvnw`), qui télécharge automatiquement la bonne version de Maven au premier lancement.

## Structure du projet

```
senguichet/
|-- backend/      Application Spring Boot (API REST)
|-- frontend/     Application React (interface)
|-- README.md
```

## Démarrer en local (sans Docker)

### Backend

Le backend démarre par défaut avec une base **H2 en mémoire** : aucune installation de base de données n'est requise.

```bash
cd backend
./mvnw spring-boot:run
```

L'API est disponible sur http://localhost:8080/api/demandes

La console H2 (pour voir la base) est sur http://localhost:8080/h2-console
(JDBC URL : `jdbc:h2:mem:senguichet`, utilisateur : `sa`, pas de mot de passe).

### Frontend

```bash
cd frontend
npm install
npm run dev
```

L'interface est disponible sur http://localhost:3000

Le proxy Vite redirige automatiquement les appels `/api` vers le backend.

## L'API REST

| Méthode | Route | Description |
|---------|-------|-------------|
| GET | `/api/demandes` | Liste toutes les demandes |
| GET | `/api/demandes/{id}` | Récupère une demande |
| POST | `/api/demandes` | Crée une demande |
| PUT | `/api/demandes/{id}/statut` | Change le statut |
| DELETE | `/api/demandes/{id}` | Supprime une demande |

### Exemple : créer une demande

```bash
curl -X POST http://localhost:8080/api/demandes \
  -H "Content-Type: application/json" \
  -d '{"type":"ATTESTATION","nomEtudiant":"Fatou Diop"}'
```

### Exemple : changer un statut

```bash
curl -X PUT http://localhost:8080/api/demandes/1/statut \
  -H "Content-Type: application/json" \
  -d '{"statut":"VALIDEE"}'
```

## Le modèle de données

Pour l'instant, une seule entité : **Demande** (numéro, type, nom de l'étudiant, statut, date de dépôt).

Les statuts suivent ce cycle :

```
DEPOSEE -> EN_COURS -> VALIDEE
                    -> REJETEE
```

Ce modèle est volontairement minimal. Au fil des labs, vous l'enrichirez : entités Étudiant, Agent, Document, authentification, prise de rendez-vous...

## Lancer les tests

```bash
cd backend
./mvnw test
```

## Pour aller plus loin (les labs)

- **Lab 1** : conteneuriser cette application avec Docker (backend + frontend + PostgreSQL)
- **Lab 2** : automatiser les tests avec GitLab CI
- **Lab 3** : déployer automatiquement sur Render et Vercel
- **Lab 4** : optimiser et sécuriser le pipeline

---

*Projet fil rouge AGL — Master 1 SIR — DMI/FST/UCAD — 2025-2026*
SENGUICHET_EOF_MARKER

echo "  - backend/pom.xml"
ecrire_fichier 'backend/pom.xml' << 'SENGUICHET_EOF_MARKER'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.3.4</version>
        <relativePath/>
    </parent>

    <groupId>sn.ucad</groupId>
    <artifactId>senguichet</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>senguichet</name>
    <description>Guichet unique universitaire - UCAD</description>

    <properties>
        <java.version>17</java.version>
    </properties>

    <dependencies>
        <!-- API REST -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <!-- Persistance JPA -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>

        <!-- Validation des donnees -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>

        <!-- Pilote PostgreSQL -->
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>

        <!-- Base H2 en memoire (pour lancer sans PostgreSQL et pour les tests) -->
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>runtime</scope>
        </dependency>

        <!-- Tests -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
SENGUICHET_EOF_MARKER

echo "  - backend/.mvn/wrapper/maven-wrapper.properties"
ecrire_fichier 'backend/.mvn/wrapper/maven-wrapper.properties' << 'SENGUICHET_EOF_MARKER'
# Configuration du Maven Wrapper (mode script-only, sans jar)
# Telecharge Maven automatiquement au premier lancement de ./mvnw
distributionUrl=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.9/apache-maven-3.9.9-bin.zip
SENGUICHET_EOF_MARKER

echo "  - backend/src/main/java/sn/ucad/senguichet/SenGuichetApplication.java"
ecrire_fichier 'backend/src/main/java/sn/ucad/senguichet/SenGuichetApplication.java' << 'SENGUICHET_EOF_MARKER'
package sn.ucad.senguichet;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Point d'entree de l'application SenGuichet.
 * Guichet unique universitaire - UCAD.
 */
@SpringBootApplication
public class SenGuichetApplication {

    public static void main(String[] args) {
        SpringApplication.run(SenGuichetApplication.class, args);
    }
}
SENGUICHET_EOF_MARKER

echo "  - backend/src/main/java/sn/ucad/senguichet/config/DataSeeder.java"
ecrire_fichier 'backend/src/main/java/sn/ucad/senguichet/config/DataSeeder.java' << 'SENGUICHET_EOF_MARKER'
package sn.ucad.senguichet.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import sn.ucad.senguichet.entity.Demande;
import sn.ucad.senguichet.entity.Statut;
import sn.ucad.senguichet.repository.DemandeRepository;

/**
 * Insere quelques demandes de demonstration au demarrage,
 * uniquement si la base est vide.
 *
 * Cela permet aux etudiants de voir des donnees des le premier
 * lancement, sans avoir a en saisir manuellement.
 */
@Configuration
public class DataSeeder {

    @Bean
    CommandLineRunner initData(DemandeRepository repository, sn.ucad.senguichet.service.DemandeService service) {
        return args -> {
            if (repository.count() == 0) {
                // On passe par le service pour que les numeros soient
                // generes de facon coherente (meme annee que les demandes
                // creees ensuite par les utilisateurs).
                Demande d1 = new Demande();
                d1.setType("ATTESTATION");
                d1.setNomEtudiant("Fatou Diop");
                service.creer(d1);
                service.changerStatut(d1.getId(), Statut.VALIDEE);

                Demande d2 = new Demande();
                d2.setType("INSCRIPTION");
                d2.setNomEtudiant("Moussa Ndiaye");
                service.creer(d2);
                service.changerStatut(d2.getId(), Statut.EN_COURS);

                Demande d3 = new Demande();
                d3.setType("BOURSE");
                d3.setNomEtudiant("Aminata Sow");
                service.creer(d3);

                System.out.println(">>> SenGuichet : 3 demandes de demonstration inserees.");
            }
        };
    }
}
SENGUICHET_EOF_MARKER

echo "  - backend/src/main/java/sn/ucad/senguichet/controller/DemandeController.java"
ecrire_fichier 'backend/src/main/java/sn/ucad/senguichet/controller/DemandeController.java' << 'SENGUICHET_EOF_MARKER'
package sn.ucad.senguichet.controller;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sn.ucad.senguichet.entity.Demande;
import sn.ucad.senguichet.entity.Statut;
import sn.ucad.senguichet.service.DemandeService;

import java.util.List;
import java.util.Map;

/**
 * API REST des demandes.
 *
 * Expose les operations sous /api/demandes :
 *   GET    /api/demandes        -> liste toutes les demandes
 *   GET    /api/demandes/{id}   -> une demande
 *   POST   /api/demandes        -> creer une demande
 *   PUT    /api/demandes/{id}/statut -> changer le statut
 *   DELETE /api/demandes/{id}   -> supprimer
 */
@RestController
@RequestMapping("/api/demandes")
@CrossOrigin(origins = "*")
public class DemandeController {

    private final DemandeService service;

    public DemandeController(DemandeService service) {
        this.service = service;
    }

    /** Liste toutes les demandes */
    @GetMapping
    public List<Demande> listerToutes() {
        return service.listerToutes();
    }

    /** Retourne une demande par son id, ou 404 si absente */
    @GetMapping("/{id}")
    public ResponseEntity<Demande> trouverParId(@PathVariable Long id) {
        return service.trouverParId(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /** Cree une nouvelle demande */
    @PostMapping
    public ResponseEntity<Demande> creer(@Valid @RequestBody Demande demande) {
        Demande creee = service.creer(demande);
        return ResponseEntity.status(HttpStatus.CREATED).body(creee);
    }

    /**
     * Change le statut d'une demande.
     * Le corps de la requete doit contenir : { "statut": "VALIDEE" }
     */
    @PutMapping("/{id}/statut")
    public ResponseEntity<Demande> changerStatut(
            @PathVariable Long id,
            @RequestBody Map<String, String> corps) {

        String valeurStatut = corps.get("statut");
        if (valeurStatut == null) {
            return ResponseEntity.badRequest().build();
        }

        try {
            Statut nouveauStatut = Statut.valueOf(valeurStatut);
            return service.changerStatut(id, nouveauStatut)
                    .map(ResponseEntity::ok)
                    .orElse(ResponseEntity.notFound().build());
        } catch (IllegalArgumentException e) {
            // Statut invalide
            return ResponseEntity.badRequest().build();
        }
    }

    /** Supprime une demande */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> supprimer(@PathVariable Long id) {
        if (service.supprimer(id)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}
SENGUICHET_EOF_MARKER

echo "  - backend/src/main/java/sn/ucad/senguichet/entity/Demande.java"
ecrire_fichier 'backend/src/main/java/sn/ucad/senguichet/entity/Demande.java' << 'SENGUICHET_EOF_MARKER'
package sn.ucad.senguichet.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import java.time.LocalDateTime;

/**
 * Une demande administrative deposee par un etudiant.
 * C'est l'entite centrale du fil rouge SenGuichet.
 *
 * Les etudiants enrichiront ce modele au fil des labs
 * (ajout des entites Etudiant, Agent, Document, etc.).
 */
@Entity
@Table(name = "demandes")
public class Demande {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Numero unique de la demande, ex : DEM-2025-0001.
     *  Defini apres le premier enregistrement (derive de l'id). */
    @Column(unique = true)
    private String numero;

    /** Type de demarche : ATTESTATION, INSCRIPTION, BOURSE, RELEVE... */
    @NotBlank(message = "Le type de demande est obligatoire")
    @Column(nullable = false)
    private String type;

    /** Nom complet de l'etudiant demandeur */
    @NotBlank(message = "Le nom de l'etudiant est obligatoire")
    @Column(nullable = false)
    private String nomEtudiant;

    /** Statut courant de la demande */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Statut statut = Statut.DEPOSEE;

    /** Date et heure de depot */
    @Column(nullable = false)
    private LocalDateTime dateDepot = LocalDateTime.now();

    // ===== Constructeurs =====

    public Demande() {
    }

    public Demande(String numero, String type, String nomEtudiant) {
        this.numero = numero;
        this.type = type;
        this.nomEtudiant = nomEtudiant;
        this.statut = Statut.DEPOSEE;
        this.dateDepot = LocalDateTime.now();
    }

    // ===== Getters et Setters =====

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNumero() {
        return numero;
    }

    public void setNumero(String numero) {
        this.numero = numero;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getNomEtudiant() {
        return nomEtudiant;
    }

    public void setNomEtudiant(String nomEtudiant) {
        this.nomEtudiant = nomEtudiant;
    }

    public Statut getStatut() {
        return statut;
    }

    public void setStatut(Statut statut) {
        this.statut = statut;
    }

    public LocalDateTime getDateDepot() {
        return dateDepot;
    }

    public void setDateDepot(LocalDateTime dateDepot) {
        this.dateDepot = dateDepot;
    }
}
SENGUICHET_EOF_MARKER

echo "  - backend/src/main/java/sn/ucad/senguichet/entity/Statut.java"
ecrire_fichier 'backend/src/main/java/sn/ucad/senguichet/entity/Statut.java' << 'SENGUICHET_EOF_MARKER'
package sn.ucad.senguichet.entity;

/**
 * Les statuts possibles d'une demande administrative.
 *
 * Le cycle de vie d'une demande :
 *   DEPOSEE -> EN_COURS -> VALIDEE
 *                       -> REJETEE
 */
public enum Statut {
    DEPOSEE,
    EN_COURS,
    VALIDEE,
    REJETEE
}
SENGUICHET_EOF_MARKER

echo "  - backend/src/main/java/sn/ucad/senguichet/repository/DemandeRepository.java"
ecrire_fichier 'backend/src/main/java/sn/ucad/senguichet/repository/DemandeRepository.java' << 'SENGUICHET_EOF_MARKER'
package sn.ucad.senguichet.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import sn.ucad.senguichet.entity.Demande;

/**
 * Acces aux donnees des demandes.
 *
 * En etendant JpaRepository, on dispose gratuitement de toutes
 * les operations de base : findAll, findById, save, deleteById...
 */
public interface DemandeRepository extends JpaRepository<Demande, Long> {
    // JpaRepository fournit deja toutes les operations necessaires :
    // findAll, findById, save, deleteById, existsById, count...
}
SENGUICHET_EOF_MARKER

echo "  - backend/src/main/java/sn/ucad/senguichet/service/DemandeService.java"
ecrire_fichier 'backend/src/main/java/sn/ucad/senguichet/service/DemandeService.java' << 'SENGUICHET_EOF_MARKER'
package sn.ucad.senguichet.service;

import org.springframework.stereotype.Service;
import sn.ucad.senguichet.entity.Demande;
import sn.ucad.senguichet.entity.Statut;
import sn.ucad.senguichet.repository.DemandeRepository;

import java.time.Year;
import java.util.List;
import java.util.Optional;

/**
 * Logique metier des demandes.
 *
 * C'est ici que vivent les regles : generation du numero,
 * changement de statut, etc. Le controleur ne fait qu'appeler
 * ces methodes.
 */
@Service
public class DemandeService {

    private final DemandeRepository repository;

    public DemandeService(DemandeRepository repository) {
        this.repository = repository;
    }

    /** Retourne toutes les demandes */
    public List<Demande> listerToutes() {
        return repository.findAll();
    }

    /** Retourne une demande par son identifiant */
    public Optional<Demande> trouverParId(Long id) {
        return repository.findById(id);
    }

    /**
     * Cree une nouvelle demande.
     * Le numero est genere automatiquement au format DEM-ANNEE-XXXX,
     * derive de l'identifiant (monotone, jamais reutilise meme apres
     * une suppression).
     */
    public Demande creer(Demande demande) {
        demande.setStatut(Statut.DEPOSEE);
        // Premier enregistrement : Hibernate genere l'id
        Demande enregistree = repository.save(demande);
        // On derive le numero de l'id, ce qui garantit son unicite
        String numero = String.format("DEM-%d-%04d",
                Year.now().getValue(), enregistree.getId());
        enregistree.setNumero(numero);
        return repository.save(enregistree);
    }

    /**
     * Change le statut d'une demande.
     * Retourne la demande mise a jour, ou Optional.empty() si elle n'existe pas.
     */
    public Optional<Demande> changerStatut(Long id, Statut nouveauStatut) {
        return repository.findById(id).map(demande -> {
            demande.setStatut(nouveauStatut);
            return repository.save(demande);
        });
    }

    /** Supprime une demande. Retourne true si elle existait. */
    public boolean supprimer(Long id) {
        if (repository.existsById(id)) {
            repository.deleteById(id);
            return true;
        }
        return false;
    }
}
SENGUICHET_EOF_MARKER

echo "  - backend/src/main/resources/application.properties"
ecrire_fichier 'backend/src/main/resources/application.properties' << 'SENGUICHET_EOF_MARKER'
# ============================================================
# Configuration SenGuichet
# ============================================================
# Par defaut, l'application demarre avec une base H2 en memoire,
# ce qui permet de la lancer SANS PostgreSQL (pratique au debut).
#
# Quand vous conteneurisez (Lab 1), vous activez le profil
# "postgres" en passant la variable d'environnement :
#   SPRING_PROFILES_ACTIVE=postgres
# ============================================================

spring.application.name=senguichet

# Profil actif (surcharge possible par variable d'environnement
# SPRING_PROFILES_ACTIVE). Par defaut : h2.
spring.profiles.active=${SPRING_PROFILES_ACTIVE:h2}

# Affiche les requetes SQL dans les logs (utile pour apprendre)
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true

# Desactive l'Open Session In View (bonne pratique, evite un warning)
spring.jpa.open-in-view=false
SENGUICHET_EOF_MARKER

echo "  - backend/src/main/resources/application-h2.properties"
ecrire_fichier 'backend/src/main/resources/application-h2.properties' << 'SENGUICHET_EOF_MARKER'
# ============================================================
# Profil H2 : base de donnees en memoire
# ============================================================
# Aucune installation requise. Les donnees sont perdues a chaque
# arret de l'application. Parfait pour developper et tester
# rapidement, AVANT de conteneuriser avec PostgreSQL.
# ============================================================

spring.datasource.url=jdbc:h2:mem:senguichet
spring.datasource.driver-class-name=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=

spring.jpa.hibernate.ddl-auto=create-drop

# Console H2 accessible sur http://localhost:8080/h2-console
spring.h2.console.enabled=true
SENGUICHET_EOF_MARKER

echo "  - backend/src/main/resources/application-postgres.properties"
ecrire_fichier 'backend/src/main/resources/application-postgres.properties' << 'SENGUICHET_EOF_MARKER'
# ============================================================
# Profil PostgreSQL : base de donnees persistante
# ============================================================
# Active avec SPRING_PROFILES_ACTIVE=postgres
#
# Les informations de connexion sont lues depuis des variables
# d'environnement, avec des valeurs par defaut pour le local.
# C'est ce profil que vous utiliserez dans Docker (Lab 1).
# ============================================================

spring.datasource.url=jdbc:postgresql://${DB_HOST:localhost}:${DB_PORT:5432}/${DB_NAME:senguichet}
spring.datasource.username=${DB_USER:postgres}
spring.datasource.password=${DB_PASSWORD:postgres}
spring.datasource.driver-class-name=org.postgresql.Driver

spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.hibernate.ddl-auto=update
SENGUICHET_EOF_MARKER

echo "  - backend/src/test/java/sn/ucad/senguichet/DemandeServiceTest.java"
ecrire_fichier 'backend/src/test/java/sn/ucad/senguichet/DemandeServiceTest.java' << 'SENGUICHET_EOF_MARKER'
package sn.ucad.senguichet;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import sn.ucad.senguichet.entity.Demande;
import sn.ucad.senguichet.entity.Statut;
import sn.ucad.senguichet.service.DemandeService;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Tests du service des demandes.
 *
 * Ces tests serviront au Lab 2 (GitLab CI) : le pipeline les
 * executera automatiquement a chaque push. Les etudiants en
 * ajouteront d'autres au fil des labs.
 */
@SpringBootTest
class DemandeServiceTest {

    @Autowired
    private DemandeService service;

    @Test
    void creer_genere_un_numero_et_statut_depose() {
        Demande demande = new Demande();
        demande.setType("ATTESTATION");
        demande.setNomEtudiant("Ibrahima Fall");

        Demande creee = service.creer(demande);

        assertNotNull(creee.getId());
        assertNotNull(creee.getNumero());
        assertTrue(creee.getNumero().startsWith("DEM-"));
        assertEquals(Statut.DEPOSEE, creee.getStatut());
    }

    @Test
    void changer_statut_met_a_jour_la_demande() {
        Demande demande = new Demande();
        demande.setType("BOURSE");
        demande.setNomEtudiant("Awa Ba");
        Demande creee = service.creer(demande);

        service.changerStatut(creee.getId(), Statut.VALIDEE);

        Demande rechargee = service.trouverParId(creee.getId()).orElseThrow();
        assertEquals(Statut.VALIDEE, rechargee.getStatut());
    }

    @Test
    void supprimer_retourne_false_si_inexistante() {
        boolean resultat = service.supprimer(999999L);
        assertFalse(resultat);
    }
}
SENGUICHET_EOF_MARKER

echo "  - frontend/package.json"
ecrire_fichier 'frontend/package.json' << 'SENGUICHET_EOF_MARKER'
{
  "name": "senguichet-frontend",
  "private": true,
  "version": "0.0.1",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.3.1",
    "vite": "^5.4.1"
  }
}
SENGUICHET_EOF_MARKER

echo "  - frontend/vite.config.js"
ecrire_fichier 'frontend/vite.config.js' << 'SENGUICHET_EOF_MARKER'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// Configuration de Vite
// Le serveur de dev tourne sur le port 3000.
// Les appels vers /api sont rediriges vers le backend (port 8080),
// ce qui evite les problemes de CORS en developpement.
export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
      },
    },
  },
})
SENGUICHET_EOF_MARKER

echo "  - frontend/index.html"
ecrire_fichier 'frontend/index.html' << 'SENGUICHET_EOF_MARKER'
<!DOCTYPE html>
<html lang="fr">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SénGuichet - Guichet unique UCAD</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
SENGUICHET_EOF_MARKER

echo "  - frontend/src/main.jsx"
ecrire_fichier 'frontend/src/main.jsx' << 'SENGUICHET_EOF_MARKER'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
SENGUICHET_EOF_MARKER

echo "  - frontend/src/api.js"
ecrire_fichier 'frontend/src/api.js' << 'SENGUICHET_EOF_MARKER'
// ============================================================
// Module d'acces a l'API SenGuichet
// ============================================================
// Toutes les fonctions qui parlent au backend sont regroupees ici.
// En developpement, les appels vers /api sont rediriges vers
// http://localhost:8080 par le proxy Vite (voir vite.config.js).
// ============================================================

const BASE_URL = '/api/demandes'

// Recupere toutes les demandes
export async function listerDemandes() {
  const reponse = await fetch(BASE_URL)
  if (!reponse.ok) throw new Error('Erreur lors du chargement des demandes')
  return reponse.json()
}

// Cree une nouvelle demande
export async function creerDemande(demande) {
  const reponse = await fetch(BASE_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(demande),
  })
  if (!reponse.ok) throw new Error('Erreur lors de la creation de la demande')
  return reponse.json()
}

// Change le statut d'une demande
export async function changerStatut(id, statut) {
  const reponse = await fetch(`${BASE_URL}/${id}/statut`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ statut }),
  })
  if (!reponse.ok) throw new Error('Erreur lors du changement de statut')
  return reponse.json()
}

// Supprime une demande
export async function supprimerDemande(id) {
  const reponse = await fetch(`${BASE_URL}/${id}`, { method: 'DELETE' })
  if (!reponse.ok) throw new Error('Erreur lors de la suppression')
}
SENGUICHET_EOF_MARKER

echo "  - frontend/src/App.jsx"
ecrire_fichier 'frontend/src/App.jsx' << 'SENGUICHET_EOF_MARKER'
import { useState, useEffect } from 'react'
import {
  listerDemandes,
  creerDemande,
  changerStatut,
  supprimerDemande,
} from './api'

// Les types de demarches proposes dans le formulaire
const TYPES = ['ATTESTATION', 'INSCRIPTION', 'BOURSE', 'RELEVE']

// Les statuts possibles et leur couleur d'affichage
const STATUTS = {
  DEPOSEE: { libelle: 'Déposée', couleur: '#5a6c80' },
  EN_COURS: { libelle: 'En cours', couleur: '#ea7d2b' },
  VALIDEE: { libelle: 'Validée', couleur: '#3aa84d' },
  REJETEE: { libelle: 'Rejetée', couleur: '#cc1f1f' },
}

function App() {
  const [demandes, setDemandes] = useState([])
  const [nomEtudiant, setNomEtudiant] = useState('')
  const [type, setType] = useState(TYPES[0])
  const [erreur, setErreur] = useState(null)
  const [chargement, setChargement] = useState(true)

  // Charge les demandes au premier affichage
  useEffect(() => {
    rafraichir()
  }, [])

  async function rafraichir() {
    try {
      setChargement(true)
      const data = await listerDemandes()
      setDemandes(data)
      setErreur(null)
    } catch (e) {
      setErreur(e.message)
    } finally {
      setChargement(false)
    }
  }

  async function soumettre(e) {
    e.preventDefault()
    if (!nomEtudiant.trim()) return
    try {
      await creerDemande({ type, nomEtudiant })
      setNomEtudiant('')
      setType(TYPES[0])
      await rafraichir()
    } catch (e) {
      setErreur(e.message)
    }
  }

  async function modifierStatut(id, statut) {
    try {
      await changerStatut(id, statut)
      await rafraichir()
    } catch (e) {
      setErreur(e.message)
    }
  }

  async function retirer(id) {
    try {
      await supprimerDemande(id)
      await rafraichir()
    } catch (e) {
      setErreur(e.message)
    }
  }

  return (
    <div className="conteneur">
      <header className="entete">
        <h1>SénGuichet</h1>
        <p>Guichet unique universitaire — UCAD</p>
      </header>

      {erreur && <div className="erreur">{erreur}</div>}

      <section className="carte">
        <h2>Déposer une demande</h2>
        <form onSubmit={soumettre} className="formulaire">
          <input
            type="text"
            placeholder="Nom de l'étudiant"
            value={nomEtudiant}
            onChange={(e) => setNomEtudiant(e.target.value)}
          />
          <select value={type} onChange={(e) => setType(e.target.value)}>
            {TYPES.map((t) => (
              <option key={t} value={t}>
                {t}
              </option>
            ))}
          </select>
          <button type="submit">Déposer</button>
        </form>
      </section>

      <section className="carte">
        <h2>Demandes ({demandes.length})</h2>
        {chargement ? (
          <p>Chargement...</p>
        ) : demandes.length === 0 ? (
          <p>Aucune demande pour le moment.</p>
        ) : (
          <table className="tableau">
            <thead>
              <tr>
                <th>Numéro</th>
                <th>Type</th>
                <th>Étudiant</th>
                <th>Statut</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {demandes.map((d) => (
                <tr key={d.id}>
                  <td>{d.numero}</td>
                  <td>{d.type}</td>
                  <td>{d.nomEtudiant}</td>
                  <td>
                    <span
                      className="badge"
                      style={{ backgroundColor: STATUTS[d.statut]?.couleur }}
                    >
                      {STATUTS[d.statut]?.libelle || d.statut}
                    </span>
                  </td>
                  <td className="actions">
                    <select
                      value={d.statut}
                      onChange={(e) => modifierStatut(d.id, e.target.value)}
                    >
                      {Object.keys(STATUTS).map((s) => (
                        <option key={s} value={s}>
                          {STATUTS[s].libelle}
                        </option>
                      ))}
                    </select>
                    <button className="bouton-suppr" onClick={() => retirer(d.id)}>
                      Supprimer
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>

      <footer className="pied">
        <p>SénGuichet — Projet fil rouge AGL — Master 1 SIR — DMI/FST/UCAD</p>
      </footer>
    </div>
  )
}

export default App
SENGUICHET_EOF_MARKER

echo "  - frontend/src/index.css"
ecrire_fichier 'frontend/src/index.css' << 'SENGUICHET_EOF_MARKER'
/* ============================================================
   Styles SenGuichet - CSS classique (pas de framework)
   ============================================================ */

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;
  background-color: #f8f9fb;
  color: #1a3a5c;
  line-height: 1.5;
}

.conteneur {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}

/* En-tete */
.entete {
  text-align: center;
  margin-bottom: 2rem;
}

.entete h1 {
  color: #1a3a5c;
  font-size: 2.2rem;
}

.entete p {
  color: #5a6c80;
  font-size: 1rem;
}

/* Cartes */
.carte {
  background: #fff;
  border: 1px solid #e0e4ea;
  border-radius: 10px;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
}

.carte h2 {
  color: #1a5599;
  font-size: 1.3rem;
  margin-bottom: 1rem;
}

/* Formulaire */
.formulaire {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.formulaire input,
.formulaire select,
.actions select {
  padding: 0.5rem 0.75rem;
  border: 1px solid #c0c8d4;
  border-radius: 6px;
  font-size: 0.95rem;
  font-family: inherit;
}

.formulaire input {
  flex: 1;
  min-width: 200px;
}

.formulaire button {
  background-color: #1a5599;
  color: #fff;
  border: none;
  padding: 0.5rem 1.25rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.95rem;
  font-weight: 600;
}

.formulaire button:hover {
  background-color: #14457d;
}

/* Tableau */
.tableau {
  width: 100%;
  border-collapse: collapse;
}

.tableau th,
.tableau td {
  text-align: left;
  padding: 0.6rem 0.5rem;
  border-bottom: 1px solid #eceef2;
  font-size: 0.9rem;
}

.tableau th {
  color: #5a6c80;
  font-weight: 600;
  text-transform: uppercase;
  font-size: 0.75rem;
  letter-spacing: 0.03em;
}

/* Badge de statut */
.badge {
  display: inline-block;
  padding: 0.2rem 0.6rem;
  border-radius: 12px;
  color: #fff;
  font-size: 0.75rem;
  font-weight: 600;
}

/* Actions */
.actions {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.actions select {
  font-size: 0.8rem;
  padding: 0.3rem 0.5rem;
}

.bouton-suppr {
  background-color: #fff;
  color: #cc1f1f;
  border: 1px solid #cc1f1f;
  padding: 0.3rem 0.7rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.8rem;
}

.bouton-suppr:hover {
  background-color: #cc1f1f;
  color: #fff;
}

/* Message d'erreur */
.erreur {
  background-color: #ffebeb;
  color: #cc1f1f;
  border: 1px solid #cc1f1f;
  padding: 0.75rem 1rem;
  border-radius: 8px;
  margin-bottom: 1.5rem;
}

/* Pied de page */
.pied {
  text-align: center;
  color: #5a6c80;
  font-size: 0.85rem;
  margin-top: 2rem;
}
SENGUICHET_EOF_MARKER

echo ""
echo "Installation du wrapper Maven (mvnw)..."

echo "  - backend/mvnw"
ecrire_base64 'backend/mvnw' << 'SENGUICHET_EOF_MARKER'
IyEvYmluL3NoCiMgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQojIExpY2Vuc2VkIHRvIHRoZSBBcGFjaGUg
U29mdHdhcmUgRm91bmRhdGlvbiAoQVNGKSB1bmRlciBvbmUKIyBvciBtb3JlIGNvbnRyaWJ1dG9y
IGxpY2Vuc2UgYWdyZWVtZW50cy4gIFNlZSB0aGUgTk9USUNFIGZpbGUKIyBkaXN0cmlidXRlZCB3
aXRoIHRoaXMgd29yayBmb3IgYWRkaXRpb25hbCBpbmZvcm1hdGlvbgojIHJlZ2FyZGluZyBjb3B5
cmlnaHQgb3duZXJzaGlwLiAgVGhlIEFTRiBsaWNlbnNlcyB0aGlzIGZpbGUKIyB0byB5b3UgdW5k
ZXIgdGhlIEFwYWNoZSBMaWNlbnNlLCBWZXJzaW9uIDIuMCAodGhlCiMgIkxpY2Vuc2UiKTsgeW91
IG1heSBub3QgdXNlIHRoaXMgZmlsZSBleGNlcHQgaW4gY29tcGxpYW5jZQojIHdpdGggdGhlIExp
Y2Vuc2UuICBZb3UgbWF5IG9idGFpbiBhIGNvcHkgb2YgdGhlIExpY2Vuc2UgYXQKIwojICAgIGh0
dHA6Ly93d3cuYXBhY2hlLm9yZy9saWNlbnNlcy9MSUNFTlNFLTIuMAojCiMgVW5sZXNzIHJlcXVp
cmVkIGJ5IGFwcGxpY2FibGUgbGF3IG9yIGFncmVlZCB0byBpbiB3cml0aW5nLAojIHNvZnR3YXJl
IGRpc3RyaWJ1dGVkIHVuZGVyIHRoZSBMaWNlbnNlIGlzIGRpc3RyaWJ1dGVkIG9uIGFuCiMgIkFT
IElTIiBCQVNJUywgV0lUSE9VVCBXQVJSQU5USUVTIE9SIENPTkRJVElPTlMgT0YgQU5ZCiMgS0lO
RCwgZWl0aGVyIGV4cHJlc3Mgb3IgaW1wbGllZC4gIFNlZSB0aGUgTGljZW5zZSBmb3IgdGhlCiMg
c3BlY2lmaWMgbGFuZ3VhZ2UgZ292ZXJuaW5nIHBlcm1pc3Npb25zIGFuZCBsaW1pdGF0aW9ucwoj
IHVuZGVyIHRoZSBMaWNlbnNlLgojIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KCiMgLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLQojIEFwYWNoZSBNYXZlbiBXcmFwcGVyIHN0YXJ0dXAgYmF0Y2ggc2NyaXB0LCB2ZXJz
aW9uIDMuMy4yCiMKIyBPcHRpb25hbCBFTlYgdmFycwojIC0tLS0tLS0tLS0tLS0tLS0tCiMgICBK
QVZBX0hPTUUgLSBsb2NhdGlvbiBvZiBhIEpESyBob21lIGRpciwgcmVxdWlyZWQgd2hlbiBkb3du
bG9hZCBtYXZlbiB2aWEgamF2YSBzb3VyY2UKIyAgIE1WTldfUkVQT1VSTCAtIHJlcG8gdXJsIGJh
c2UgZm9yIGRvd25sb2FkaW5nIG1hdmVuIGRpc3RyaWJ1dGlvbgojICAgTVZOV19VU0VSTkFNRS9N
Vk5XX1BBU1NXT1JEIC0gdXNlciBhbmQgcGFzc3dvcmQgZm9yIGRvd25sb2FkaW5nIG1hdmVuCiMg
ICBNVk5XX1ZFUkJPU0UgLSB0cnVlOiBlbmFibGUgdmVyYm9zZSBsb2c7IGRlYnVnOiB0cmFjZSB0
aGUgbXZudyBzY3JpcHQ7IG90aGVyczogc2lsZW5jZSB0aGUgb3V0cHV0CiMgLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLQoKc2V0IC1ldWYKWyAiJHtNVk5XX1ZFUkJPU0UtfSIgIT0gZGVidWcgXSB8fCBzZXQg
LXgKCiMgT1Mgc3BlY2lmaWMgc3VwcG9ydC4KbmF0aXZlX3BhdGgoKSB7IHByaW50ZiAlc1xcbiAi
JDEiOyB9CmNhc2UgIiQodW5hbWUpIiBpbgpDWUdXSU4qIHwgTUlOR1cqKQogIFsgLXogIiR7SkFW
QV9IT01FLX0iIF0gfHwgSkFWQV9IT01FPSIkKGN5Z3BhdGggLS11bml4ICIkSkFWQV9IT01FIiki
CiAgbmF0aXZlX3BhdGgoKSB7IGN5Z3BhdGggLS1wYXRoIC0td2luZG93cyAiJDEiOyB9CiAgOzsK
ZXNhYwoKIyBzZXQgSkFWQUNNRCBhbmQgSkFWQUNDTUQKc2V0X2phdmFfaG9tZSgpIHsKICAjIEZv
ciBDeWd3aW4gYW5kIE1pbkdXLCBlbnN1cmUgcGF0aHMgYXJlIGluIFVuaXggZm9ybWF0IGJlZm9y
ZSBhbnl0aGluZyBpcyB0b3VjaGVkCiAgaWYgWyAtbiAiJHtKQVZBX0hPTUUtfSIgXTsgdGhlbgog
ICAgaWYgWyAteCAiJEpBVkFfSE9NRS9qcmUvc2gvamF2YSIgXTsgdGhlbgogICAgICAjIElCTSdz
IEpESyBvbiBBSVggdXNlcyBzdHJhbmdlIGxvY2F0aW9ucyBmb3IgdGhlIGV4ZWN1dGFibGVzCiAg
ICAgIEpBVkFDTUQ9IiRKQVZBX0hPTUUvanJlL3NoL2phdmEiCiAgICAgIEpBVkFDQ01EPSIkSkFW
QV9IT01FL2pyZS9zaC9qYXZhYyIKICAgIGVsc2UKICAgICAgSkFWQUNNRD0iJEpBVkFfSE9NRS9i
aW4vamF2YSIKICAgICAgSkFWQUNDTUQ9IiRKQVZBX0hPTUUvYmluL2phdmFjIgoKICAgICAgaWYg
WyAhIC14ICIkSkFWQUNNRCIgXSB8fCBbICEgLXggIiRKQVZBQ0NNRCIgXTsgdGhlbgogICAgICAg
IGVjaG8gIlRoZSBKQVZBX0hPTUUgZW52aXJvbm1lbnQgdmFyaWFibGUgaXMgbm90IGRlZmluZWQg
Y29ycmVjdGx5LCBzbyBtdm53IGNhbm5vdCBydW4uIiA+JjIKICAgICAgICBlY2hvICJKQVZBX0hP
TUUgaXMgc2V0IHRvIFwiJEpBVkFfSE9NRVwiLCBidXQgXCJcJEpBVkFfSE9NRS9iaW4vamF2YVwi
IG9yIFwiXCRKQVZBX0hPTUUvYmluL2phdmFjXCIgZG9lcyBub3QgZXhpc3QuIiA+JjIKICAgICAg
ICByZXR1cm4gMQogICAgICBmaQogICAgZmkKICBlbHNlCiAgICBKQVZBQ01EPSIkKAogICAgICAn
c2V0JyArZQogICAgICAndW5zZXQnIC1mIGNvbW1hbmQgMj4vZGV2L251bGwKICAgICAgJ2NvbW1h
bmQnIC12IGphdmEKICAgICkiIHx8IDoKICAgIEpBVkFDQ01EPSIkKAogICAgICAnc2V0JyArZQog
ICAgICAndW5zZXQnIC1mIGNvbW1hbmQgMj4vZGV2L251bGwKICAgICAgJ2NvbW1hbmQnIC12IGph
dmFjCiAgICApIiB8fCA6CgogICAgaWYgWyAhIC14ICIke0pBVkFDTUQtfSIgXSB8fCBbICEgLXgg
IiR7SkFWQUNDTUQtfSIgXTsgdGhlbgogICAgICBlY2hvICJUaGUgamF2YS9qYXZhYyBjb21tYW5k
IGRvZXMgbm90IGV4aXN0IGluIFBBVEggbm9yIGlzIEpBVkFfSE9NRSBzZXQsIHNvIG12bncgY2Fu
bm90IHJ1bi4iID4mMgogICAgICByZXR1cm4gMQogICAgZmkKICBmaQp9CgojIGhhc2ggc3RyaW5n
IGxpa2UgSmF2YSBTdHJpbmc6Omhhc2hDb2RlCmhhc2hfc3RyaW5nKCkgewogIHN0cj0iJHsxOi19
IiBoPTAKICB3aGlsZSBbIC1uICIkc3RyIiBdOyBkbwogICAgY2hhcj0iJHtzdHIlIiR7c3RyIz99
In0iCiAgICBoPSQoKChoICogMzEgKyAkKExDX0NUWVBFPUMgcHJpbnRmICVkICInJGNoYXIiKSkg
JSA0Mjk0OTY3Mjk2KSkKICAgIHN0cj0iJHtzdHIjP30iCiAgZG9uZQogIHByaW50ZiAleFxcbiAk
aAp9Cgp2ZXJib3NlKCkgeyA6OyB9ClsgIiR7TVZOV19WRVJCT1NFLX0iICE9IHRydWUgXSB8fCB2
ZXJib3NlKCkgeyBwcmludGYgJXNcXG4gIiR7MS19IjsgfQoKZGllKCkgewogIHByaW50ZiAlc1xc
biAiJDEiID4mMgogIGV4aXQgMQp9Cgp0cmltKCkgewogICMgTVdSQVBQRVItMTM5OgogICMgICBU
cmltcyB0cmFpbGluZyBhbmQgbGVhZGluZyB3aGl0ZXNwYWNlLCBjYXJyaWFnZSByZXR1cm5zLCB0
YWJzLCBhbmQgbGluZWZlZWRzLgogICMgICBOZWVkZWQgZm9yIHJlbW92aW5nIHBvb3JseSBpbnRl
cnByZXRlZCBuZXdsaW5lIHNlcXVlbmNlcyB3aGVuIHJ1bm5pbmcgaW4gbW9yZQogICMgICBleG90
aWMgZW52aXJvbm1lbnRzIHN1Y2ggYXMgbWluZ3cgYmFzaCBvbiBXaW5kb3dzLgogIHByaW50ZiAi
JXMiICIkezF9IiB8IHRyIC1kICdbOnNwYWNlOl0nCn0KCiMgcGFyc2UgZGlzdHJpYnV0aW9uVXJs
IGFuZCBvcHRpb25hbCBkaXN0cmlidXRpb25TaGEyNTZTdW0sIHJlcXVpcmVzIC5tdm4vd3JhcHBl
ci9tYXZlbi13cmFwcGVyLnByb3BlcnRpZXMKd2hpbGUgSUZTPSI9IiByZWFkIC1yIGtleSB2YWx1
ZTsgZG8KICBjYXNlICIke2tleS19IiBpbgogIGRpc3RyaWJ1dGlvblVybCkgZGlzdHJpYnV0aW9u
VXJsPSQodHJpbSAiJHt2YWx1ZS19IikgOzsKICBkaXN0cmlidXRpb25TaGEyNTZTdW0pIGRpc3Ry
aWJ1dGlvblNoYTI1NlN1bT0kKHRyaW0gIiR7dmFsdWUtfSIpIDs7CiAgZXNhYwpkb25lIDwiJHsw
JS8qfS8ubXZuL3dyYXBwZXIvbWF2ZW4td3JhcHBlci5wcm9wZXJ0aWVzIgpbIC1uICIke2Rpc3Ry
aWJ1dGlvblVybC19IiBdIHx8IGRpZSAiY2Fubm90IHJlYWQgZGlzdHJpYnV0aW9uVXJsIHByb3Bl
cnR5IGluICR7MCUvKn0vLm12bi93cmFwcGVyL21hdmVuLXdyYXBwZXIucHJvcGVydGllcyIKCmNh
c2UgIiR7ZGlzdHJpYnV0aW9uVXJsIyMqL30iIGluCm1hdmVuLW12bmQtKmJpbi4qKQogIE1WTl9D
TUQ9bXZuZC5zaCBfTVZOV19SRVBPX1BBVFRFUk49L21hdmVuL212bmQvCiAgY2FzZSAiJHtQUk9D
RVNTT1JfQVJDSElURUNUVVJFLX0ke1BST0NFU1NPUl9BUkNISVRFVzY0MzItfTokKHVuYW1lIC1h
KSIgaW4KICAqQU1ENjQ6Q1lHV0lOKiB8ICpBTUQ2NDpNSU5HVyopIGRpc3RyaWJ1dGlvblBsYXRm
b3JtPXdpbmRvd3MtYW1kNjQgOzsKICA6RGFyd2luKng4Nl82NCkgZGlzdHJpYnV0aW9uUGxhdGZv
cm09ZGFyd2luLWFtZDY0IDs7CiAgOkRhcndpbiphcm02NCkgZGlzdHJpYnV0aW9uUGxhdGZvcm09
ZGFyd2luLWFhcmNoNjQgOzsKICA6TGludXgqeDg2XzY0KikgZGlzdHJpYnV0aW9uUGxhdGZvcm09
bGludXgtYW1kNjQgOzsKICAqKQogICAgZWNobyAiQ2Fubm90IGRldGVjdCBuYXRpdmUgcGxhdGZv
cm0gZm9yIG12bmQgb24gJCh1bmFtZSktJCh1bmFtZSAtbSksIHVzZSBwdXJlIGphdmEgdmVyc2lv
biIgPiYyCiAgICBkaXN0cmlidXRpb25QbGF0Zm9ybT1saW51eC1hbWQ2NAogICAgOzsKICBlc2Fj
CiAgZGlzdHJpYnV0aW9uVXJsPSIke2Rpc3RyaWJ1dGlvblVybCUtYmluLip9LSRkaXN0cmlidXRp
b25QbGF0Zm9ybS56aXAiCiAgOzsKbWF2ZW4tbXZuZC0qKSBNVk5fQ01EPW12bmQuc2ggX01WTldf
UkVQT19QQVRURVJOPS9tYXZlbi9tdm5kLyA7OwoqKSBNVk5fQ01EPSJtdm4kezAjIyovbXZud30i
IF9NVk5XX1JFUE9fUEFUVEVSTj0vb3JnL2FwYWNoZS9tYXZlbi8gOzsKZXNhYwoKIyBhcHBseSBN
Vk5XX1JFUE9VUkwgYW5kIGNhbGN1bGF0ZSBNQVZFTl9IT01FCiMgbWF2ZW4gaG9tZSBwYXR0ZXJu
OiB+Ly5tMi93cmFwcGVyL2Rpc3RzL3thcGFjaGUtbWF2ZW4tPHZlcnNpb24+LG1hdmVuLW12bmQt
PHZlcnNpb24+LTxwbGF0Zm9ybT59LzxoYXNoPgpbIC16ICIke01WTldfUkVQT1VSTC19IiBdIHx8
IGRpc3RyaWJ1dGlvblVybD0iJE1WTldfUkVQT1VSTCRfTVZOV19SRVBPX1BBVFRFUk4ke2Rpc3Ry
aWJ1dGlvblVybCMqIiRfTVZOV19SRVBPX1BBVFRFUk4ifSIKZGlzdHJpYnV0aW9uVXJsTmFtZT0i
JHtkaXN0cmlidXRpb25VcmwjIyovfSIKZGlzdHJpYnV0aW9uVXJsTmFtZU1haW49IiR7ZGlzdHJp
YnV0aW9uVXJsTmFtZSUuKn0iCmRpc3RyaWJ1dGlvblVybE5hbWVNYWluPSIke2Rpc3RyaWJ1dGlv
blVybE5hbWVNYWluJS1iaW59IgpNQVZFTl9VU0VSX0hPTUU9IiR7TUFWRU5fVVNFUl9IT01FOi0k
e0hPTUV9Ly5tMn0iCk1BVkVOX0hPTUU9IiR7TUFWRU5fVVNFUl9IT01FfS93cmFwcGVyL2Rpc3Rz
LyR7ZGlzdHJpYnV0aW9uVXJsTmFtZU1haW4tfS8kKGhhc2hfc3RyaW5nICIkZGlzdHJpYnV0aW9u
VXJsIikiCgpleGVjX21hdmVuKCkgewogIHVuc2V0IE1WTldfVkVSQk9TRSBNVk5XX1VTRVJOQU1F
IE1WTldfUEFTU1dPUkQgTVZOV19SRVBPVVJMIHx8IDoKICBleGVjICIkTUFWRU5fSE9NRS9iaW4v
JE1WTl9DTUQiICIkQCIgfHwgZGllICJjYW5ub3QgZXhlYyAkTUFWRU5fSE9NRS9iaW4vJE1WTl9D
TUQiCn0KCmlmIFsgLWQgIiRNQVZFTl9IT01FIiBdOyB0aGVuCiAgdmVyYm9zZSAiZm91bmQgZXhp
c3RpbmcgTUFWRU5fSE9NRSBhdCAkTUFWRU5fSE9NRSIKICBleGVjX21hdmVuICIkQCIKZmkKCmNh
c2UgIiR7ZGlzdHJpYnV0aW9uVXJsLX0iIGluCio/LWJpbi56aXAgfCAqP21hdmVuLW12bmQtPyot
PyouemlwKSA7OwoqKSBkaWUgImRpc3RyaWJ1dGlvblVybCBpcyBub3QgdmFsaWQsIG11c3QgbWF0
Y2ggKi1iaW4uemlwIG9yIG1hdmVuLW12bmQtKi56aXAsIGJ1dCBmb3VuZCAnJHtkaXN0cmlidXRp
b25VcmwtfSciIDs7CmVzYWMKCiMgcHJlcGFyZSB0bXAgZGlyCmlmIFRNUF9ET1dOTE9BRF9ESVI9
IiQobWt0ZW1wIC1kKSIgJiYgWyAtZCAiJFRNUF9ET1dOTE9BRF9ESVIiIF07IHRoZW4KICBjbGVh
bigpIHsgcm0gLXJmIC0tICIkVE1QX0RPV05MT0FEX0RJUiI7IH0KICB0cmFwIGNsZWFuIEhVUCBJ
TlQgVEVSTSBFWElUCmVsc2UKICBkaWUgImNhbm5vdCBjcmVhdGUgdGVtcCBkaXIiCmZpCgpta2Rp
ciAtcCAtLSAiJHtNQVZFTl9IT01FJS8qfSIKCiMgRG93bmxvYWQgYW5kIEluc3RhbGwgQXBhY2hl
IE1hdmVuCnZlcmJvc2UgIkNvdWxkbid0IGZpbmQgTUFWRU5fSE9NRSwgZG93bmxvYWRpbmcgYW5k
IGluc3RhbGxpbmcgaXQgLi4uIgp2ZXJib3NlICJEb3dubG9hZGluZyBmcm9tOiAkZGlzdHJpYnV0
aW9uVXJsIgp2ZXJib3NlICJEb3dubG9hZGluZyB0bzogJFRNUF9ET1dOTE9BRF9ESVIvJGRpc3Ry
aWJ1dGlvblVybE5hbWUiCgojIHNlbGVjdCAuemlwIG9yIC50YXIuZ3oKaWYgISBjb21tYW5kIC12
IHVuemlwID4vZGV2L251bGw7IHRoZW4KICBkaXN0cmlidXRpb25Vcmw9IiR7ZGlzdHJpYnV0aW9u
VXJsJS56aXB9LnRhci5neiIKICBkaXN0cmlidXRpb25VcmxOYW1lPSIke2Rpc3RyaWJ1dGlvblVy
bCMjKi99IgpmaQoKIyB2ZXJib3NlIG9wdApfX01WTldfUVVJRVRfV0dFVD0tLXF1aWV0IF9fTVZO
V19RVUlFVF9DVVJMPS0tc2lsZW50IF9fTVZOV19RVUlFVF9VTlpJUD0tcSBfX01WTldfUVVJRVRf
VEFSPScnClsgIiR7TVZOV19WRVJCT1NFLX0iICE9IHRydWUgXSB8fCBfX01WTldfUVVJRVRfV0dF
VD0nJyBfX01WTldfUVVJRVRfQ1VSTD0nJyBfX01WTldfUVVJRVRfVU5aSVA9JycgX19NVk5XX1FV
SUVUX1RBUj12CgojIG5vcm1hbGl6ZSBodHRwIGF1dGgKY2FzZSAiJHtNVk5XX1BBU1NXT1JEOito
YXMtcGFzc3dvcmR9IiBpbgonJykgTVZOV19VU0VSTkFNRT0nJyBNVk5XX1BBU1NXT1JEPScnIDs7
Cmhhcy1wYXNzd29yZCkgWyAtbiAiJHtNVk5XX1VTRVJOQU1FLX0iIF0gfHwgTVZOV19VU0VSTkFN
RT0nJyBNVk5XX1BBU1NXT1JEPScnIDs7CmVzYWMKCmlmIFsgLXogIiR7TVZOV19VU0VSTkFNRS19
IiBdICYmIGNvbW1hbmQgLXYgd2dldCA+L2Rldi9udWxsOyB0aGVuCiAgdmVyYm9zZSAiRm91bmQg
d2dldCAuLi4gdXNpbmcgd2dldCIKICB3Z2V0ICR7X19NVk5XX1FVSUVUX1dHRVQ6KyIkX19NVk5X
X1FVSUVUX1dHRVQifSAiJGRpc3RyaWJ1dGlvblVybCIgLU8gIiRUTVBfRE9XTkxPQURfRElSLyRk
aXN0cmlidXRpb25VcmxOYW1lIiB8fCBkaWUgIndnZXQ6IEZhaWxlZCB0byBmZXRjaCAkZGlzdHJp
YnV0aW9uVXJsIgplbGlmIFsgLXogIiR7TVZOV19VU0VSTkFNRS19IiBdICYmIGNvbW1hbmQgLXYg
Y3VybCA+L2Rldi9udWxsOyB0aGVuCiAgdmVyYm9zZSAiRm91bmQgY3VybCAuLi4gdXNpbmcgY3Vy
bCIKICBjdXJsICR7X19NVk5XX1FVSUVUX0NVUkw6KyIkX19NVk5XX1FVSUVUX0NVUkwifSAtZiAt
TCAtbyAiJFRNUF9ET1dOTE9BRF9ESVIvJGRpc3RyaWJ1dGlvblVybE5hbWUiICIkZGlzdHJpYnV0
aW9uVXJsIiB8fCBkaWUgImN1cmw6IEZhaWxlZCB0byBmZXRjaCAkZGlzdHJpYnV0aW9uVXJsIgpl
bGlmIHNldF9qYXZhX2hvbWU7IHRoZW4KICB2ZXJib3NlICJGYWxsaW5nIGJhY2sgdG8gdXNlIEph
dmEgdG8gZG93bmxvYWQiCiAgamF2YVNvdXJjZT0iJFRNUF9ET1dOTE9BRF9ESVIvRG93bmxvYWRl
ci5qYXZhIgogIHRhcmdldFppcD0iJFRNUF9ET1dOTE9BRF9ESVIvJGRpc3RyaWJ1dGlvblVybE5h
bWUiCiAgY2F0ID4iJGphdmFTb3VyY2UiIDw8LUVORAoJcHVibGljIGNsYXNzIERvd25sb2FkZXIg
ZXh0ZW5kcyBqYXZhLm5ldC5BdXRoZW50aWNhdG9yCgl7CgkgIHByb3RlY3RlZCBqYXZhLm5ldC5Q
YXNzd29yZEF1dGhlbnRpY2F0aW9uIGdldFBhc3N3b3JkQXV0aGVudGljYXRpb24oKQoJICB7Cgkg
ICAgcmV0dXJuIG5ldyBqYXZhLm5ldC5QYXNzd29yZEF1dGhlbnRpY2F0aW9uKCBTeXN0ZW0uZ2V0
ZW52KCAiTVZOV19VU0VSTkFNRSIgKSwgU3lzdGVtLmdldGVudiggIk1WTldfUEFTU1dPUkQiICku
dG9DaGFyQXJyYXkoKSApOwoJICB9CgkgIHB1YmxpYyBzdGF0aWMgdm9pZCBtYWluKCBTdHJpbmdb
XSBhcmdzICkgdGhyb3dzIEV4Y2VwdGlvbgoJICB7CgkgICAgc2V0RGVmYXVsdCggbmV3IERvd25s
b2FkZXIoKSApOwoJICAgIGphdmEubmlvLmZpbGUuRmlsZXMuY29weSggamF2YS5uZXQuVVJJLmNy
ZWF0ZSggYXJnc1swXSApLnRvVVJMKCkub3BlblN0cmVhbSgpLCBqYXZhLm5pby5maWxlLlBhdGhz
LmdldCggYXJnc1sxXSApLnRvQWJzb2x1dGVQYXRoKCkubm9ybWFsaXplKCkgKTsKCSAgfQoJfQoJ
RU5ECiAgIyBGb3IgQ3lnd2luL01pbkdXLCBzd2l0Y2ggcGF0aHMgdG8gV2luZG93cyBmb3JtYXQg
YmVmb3JlIHJ1bm5pbmcgamF2YWMgYW5kIGphdmEKICB2ZXJib3NlICIgLSBDb21waWxpbmcgRG93
bmxvYWRlci5qYXZhIC4uLiIKICAiJChuYXRpdmVfcGF0aCAiJEpBVkFDQ01EIikiICIkKG5hdGl2
ZV9wYXRoICIkamF2YVNvdXJjZSIpIiB8fCBkaWUgIkZhaWxlZCB0byBjb21waWxlIERvd25sb2Fk
ZXIuamF2YSIKICB2ZXJib3NlICIgLSBSdW5uaW5nIERvd25sb2FkZXIuamF2YSAuLi4iCiAgIiQo
bmF0aXZlX3BhdGggIiRKQVZBQ01EIikiIC1jcCAiJChuYXRpdmVfcGF0aCAiJFRNUF9ET1dOTE9B
RF9ESVIiKSIgRG93bmxvYWRlciAiJGRpc3RyaWJ1dGlvblVybCIgIiQobmF0aXZlX3BhdGggIiR0
YXJnZXRaaXAiKSIKZmkKCiMgSWYgc3BlY2lmaWVkLCB2YWxpZGF0ZSB0aGUgU0hBLTI1NiBzdW0g
b2YgdGhlIE1hdmVuIGRpc3RyaWJ1dGlvbiB6aXAgZmlsZQppZiBbIC1uICIke2Rpc3RyaWJ1dGlv
blNoYTI1NlN1bS19IiBdOyB0aGVuCiAgZGlzdHJpYnV0aW9uU2hhMjU2UmVzdWx0PWZhbHNlCiAg
aWYgWyAiJE1WTl9DTUQiID0gbXZuZC5zaCBdOyB0aGVuCiAgICBlY2hvICJDaGVja3N1bSB2YWxp
ZGF0aW9uIGlzIG5vdCBzdXBwb3J0ZWQgZm9yIG1hdmVuLW12bmQuIiA+JjIKICAgIGVjaG8gIlBs
ZWFzZSBkaXNhYmxlIHZhbGlkYXRpb24gYnkgcmVtb3ZpbmcgJ2Rpc3RyaWJ1dGlvblNoYTI1NlN1
bScgZnJvbSB5b3VyIG1hdmVuLXdyYXBwZXIucHJvcGVydGllcy4iID4mMgogICAgZXhpdCAxCiAg
ZWxpZiBjb21tYW5kIC12IHNoYTI1NnN1bSA+L2Rldi9udWxsOyB0aGVuCiAgICBpZiBlY2hvICIk
ZGlzdHJpYnV0aW9uU2hhMjU2U3VtICAkVE1QX0RPV05MT0FEX0RJUi8kZGlzdHJpYnV0aW9uVXJs
TmFtZSIgfCBzaGEyNTZzdW0gLWMgPi9kZXYvbnVsbCAyPiYxOyB0aGVuCiAgICAgIGRpc3RyaWJ1
dGlvblNoYTI1NlJlc3VsdD10cnVlCiAgICBmaQogIGVsaWYgY29tbWFuZCAtdiBzaGFzdW0gPi9k
ZXYvbnVsbDsgdGhlbgogICAgaWYgZWNobyAiJGRpc3RyaWJ1dGlvblNoYTI1NlN1bSAgJFRNUF9E
T1dOTE9BRF9ESVIvJGRpc3RyaWJ1dGlvblVybE5hbWUiIHwgc2hhc3VtIC1hIDI1NiAtYyA+L2Rl
di9udWxsIDI+JjE7IHRoZW4KICAgICAgZGlzdHJpYnV0aW9uU2hhMjU2UmVzdWx0PXRydWUKICAg
IGZpCiAgZWxzZQogICAgZWNobyAiQ2hlY2tzdW0gdmFsaWRhdGlvbiB3YXMgcmVxdWVzdGVkIGJ1
dCBuZWl0aGVyICdzaGEyNTZzdW0nIG9yICdzaGFzdW0nIGFyZSBhdmFpbGFibGUuIiA+JjIKICAg
IGVjaG8gIlBsZWFzZSBpbnN0YWxsIGVpdGhlciBjb21tYW5kLCBvciBkaXNhYmxlIHZhbGlkYXRp
b24gYnkgcmVtb3ZpbmcgJ2Rpc3RyaWJ1dGlvblNoYTI1NlN1bScgZnJvbSB5b3VyIG1hdmVuLXdy
YXBwZXIucHJvcGVydGllcy4iID4mMgogICAgZXhpdCAxCiAgZmkKICBpZiBbICRkaXN0cmlidXRp
b25TaGEyNTZSZXN1bHQgPSBmYWxzZSBdOyB0aGVuCiAgICBlY2hvICJFcnJvcjogRmFpbGVkIHRv
IHZhbGlkYXRlIE1hdmVuIGRpc3RyaWJ1dGlvbiBTSEEtMjU2LCB5b3VyIE1hdmVuIGRpc3RyaWJ1
dGlvbiBtaWdodCBiZSBjb21wcm9taXNlZC4iID4mMgogICAgZWNobyAiSWYgeW91IHVwZGF0ZWQg
eW91ciBNYXZlbiB2ZXJzaW9uLCB5b3UgbmVlZCB0byB1cGRhdGUgdGhlIHNwZWNpZmllZCBkaXN0
cmlidXRpb25TaGEyNTZTdW0gcHJvcGVydHkuIiA+JjIKICAgIGV4aXQgMQogIGZpCmZpCgojIHVu
emlwIGFuZCBtb3ZlCmlmIGNvbW1hbmQgLXYgdW56aXAgPi9kZXYvbnVsbDsgdGhlbgogIHVuemlw
ICR7X19NVk5XX1FVSUVUX1VOWklQOisiJF9fTVZOV19RVUlFVF9VTlpJUCJ9ICIkVE1QX0RPV05M
T0FEX0RJUi8kZGlzdHJpYnV0aW9uVXJsTmFtZSIgLWQgIiRUTVBfRE9XTkxPQURfRElSIiB8fCBk
aWUgImZhaWxlZCB0byB1bnppcCIKZWxzZQogIHRhciB4emYke19fTVZOV19RVUlFVF9UQVI6KyIk
X19NVk5XX1FVSUVUX1RBUiJ9ICIkVE1QX0RPV05MT0FEX0RJUi8kZGlzdHJpYnV0aW9uVXJsTmFt
ZSIgLUMgIiRUTVBfRE9XTkxPQURfRElSIiB8fCBkaWUgImZhaWxlZCB0byB1bnRhciIKZmkKcHJp
bnRmICVzXFxuICIkZGlzdHJpYnV0aW9uVXJsIiA+IiRUTVBfRE9XTkxPQURfRElSLyRkaXN0cmli
dXRpb25VcmxOYW1lTWFpbi9tdm53LnVybCIKbXYgLS0gIiRUTVBfRE9XTkxPQURfRElSLyRkaXN0
cmlidXRpb25VcmxOYW1lTWFpbiIgIiRNQVZFTl9IT01FIiB8fCBbIC1kICIkTUFWRU5fSE9NRSIg
XSB8fCBkaWUgImZhaWwgdG8gbW92ZSBNQVZFTl9IT01FIgoKY2xlYW4gfHwgOgpleGVjX21hdmVu
ICIkQCIK
SENGUICHET_EOF_MARKER
chmod +x 'backend/mvnw'

echo "  - backend/mvnw.cmd"
ecrire_base64 'backend/mvnw.cmd' << 'SENGUICHET_EOF_MARKER'
PCMgOiBiYXRjaCBwb3J0aW9uCkBSRU0gLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQpAUkVNIExpY2Vuc2Vk
IHRvIHRoZSBBcGFjaGUgU29mdHdhcmUgRm91bmRhdGlvbiAoQVNGKSB1bmRlciBvbmUKQFJFTSBv
ciBtb3JlIGNvbnRyaWJ1dG9yIGxpY2Vuc2UgYWdyZWVtZW50cy4gIFNlZSB0aGUgTk9USUNFIGZp
bGUKQFJFTSBkaXN0cmlidXRlZCB3aXRoIHRoaXMgd29yayBmb3IgYWRkaXRpb25hbCBpbmZvcm1h
dGlvbgpAUkVNIHJlZ2FyZGluZyBjb3B5cmlnaHQgb3duZXJzaGlwLiAgVGhlIEFTRiBsaWNlbnNl
cyB0aGlzIGZpbGUKQFJFTSB0byB5b3UgdW5kZXIgdGhlIEFwYWNoZSBMaWNlbnNlLCBWZXJzaW9u
IDIuMCAodGhlCkBSRU0gIkxpY2Vuc2UiKTsgeW91IG1heSBub3QgdXNlIHRoaXMgZmlsZSBleGNl
cHQgaW4gY29tcGxpYW5jZQpAUkVNIHdpdGggdGhlIExpY2Vuc2UuICBZb3UgbWF5IG9idGFpbiBh
IGNvcHkgb2YgdGhlIExpY2Vuc2UgYXQKQFJFTQpAUkVNICAgIGh0dHA6Ly93d3cuYXBhY2hlLm9y
Zy9saWNlbnNlcy9MSUNFTlNFLTIuMApAUkVNCkBSRU0gVW5sZXNzIHJlcXVpcmVkIGJ5IGFwcGxp
Y2FibGUgbGF3IG9yIGFncmVlZCB0byBpbiB3cml0aW5nLApAUkVNIHNvZnR3YXJlIGRpc3RyaWJ1
dGVkIHVuZGVyIHRoZSBMaWNlbnNlIGlzIGRpc3RyaWJ1dGVkIG9uIGFuCkBSRU0gIkFTIElTIiBC
QVNJUywgV0lUSE9VVCBXQVJSQU5USUVTIE9SIENPTkRJVElPTlMgT0YgQU5ZCkBSRU0gS0lORCwg
ZWl0aGVyIGV4cHJlc3Mgb3IgaW1wbGllZC4gIFNlZSB0aGUgTGljZW5zZSBmb3IgdGhlCkBSRU0g
c3BlY2lmaWMgbGFuZ3VhZ2UgZ292ZXJuaW5nIHBlcm1pc3Npb25zIGFuZCBsaW1pdGF0aW9ucwpA
UkVNIHVuZGVyIHRoZSBMaWNlbnNlLgpAUkVNIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KCkBSRU0gLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLQpAUkVNIEFwYWNoZSBNYXZlbiBXcmFwcGVyIHN0YXJ0dXAgYmF0Y2gg
c2NyaXB0LCB2ZXJzaW9uIDMuMy4yCkBSRU0KQFJFTSBPcHRpb25hbCBFTlYgdmFycwpAUkVNICAg
TVZOV19SRVBPVVJMIC0gcmVwbyB1cmwgYmFzZSBmb3IgZG93bmxvYWRpbmcgbWF2ZW4gZGlzdHJp
YnV0aW9uCkBSRU0gICBNVk5XX1VTRVJOQU1FL01WTldfUEFTU1dPUkQgLSB1c2VyIGFuZCBwYXNz
d29yZCBmb3IgZG93bmxvYWRpbmcgbWF2ZW4KQFJFTSAgIE1WTldfVkVSQk9TRSAtIHRydWU6IGVu
YWJsZSB2ZXJib3NlIGxvZzsgb3RoZXJzOiBzaWxlbmNlIHRoZSBvdXRwdXQKQFJFTSAtLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tCgpASUYgIiVfX01WTldfQVJHMF9OQU1FX18lIj09IiIgKFNFVCBfX01WTldf
QVJHMF9OQU1FX189JX5ueDApCkBTRVQgX19NVk5XX0NNRF9fPQpAU0VUIF9fTVZOV19FUlJPUl9f
PQpAU0VUIF9fTVZOV19QU01PRFVMRVBfU0FWRT0lUFNNb2R1bGVQYXRoJQpAU0VUIFBTTW9kdWxl
UGF0aD0KQEZPUiAvRiAidXNlYmFja3EgdG9rZW5zPTEqIGRlbGltcz09IiAlJUEgSU4gKGBwb3dl
cnNoZWxsIC1ub3Byb2ZpbGUgIiYgeyRzY3JpcHREaXI9JyV+ZHAwJzsgJHNjcmlwdD0nJV9fTVZO
V19BUkcwX05BTUVfXyUnOyBpY20gLVNjcmlwdEJsb2NrIChbU2NyaXB0YmxvY2tdOjpDcmVhdGUo
KEdldC1Db250ZW50IC1SYXcgJyV+ZjAnKSkpIC1Ob05ld1Njb3BlfSJgKSBETyBAKAogIElGICIl
JUEiPT0iTVZOX0NNRCIgKHNldCBfX01WTldfQ01EX189JSVCKSBFTFNFIElGICIlJUIiPT0iIiAo
ZWNobyAlJUEpIEVMU0UgKGVjaG8gJSVBPSUlQikKKQpAU0VUIFBTTW9kdWxlUGF0aD0lX19NVk5X
X1BTTU9EVUxFUF9TQVZFJQpAU0VUIF9fTVZOV19QU01PRFVMRVBfU0FWRT0KQFNFVCBfX01WTldf
QVJHMF9OQU1FX189CkBTRVQgTVZOV19VU0VSTkFNRT0KQFNFVCBNVk5XX1BBU1NXT1JEPQpASUYg
Tk9UICIlX19NVk5XX0NNRF9fJSI9PSIiICglX19NVk5XX0NNRF9fJSAlKikKQGVjaG8gQ2Fubm90
IHN0YXJ0IG1hdmVuIGZyb20gd3JhcHBlciA+JjIgJiYgZXhpdCAvYiAxCkBHT1RPIDpFT0YKOiBl
bmQgYmF0Y2ggLyBiZWdpbiBwb3dlcnNoZWxsICM+CgokRXJyb3JBY3Rpb25QcmVmZXJlbmNlID0g
IlN0b3AiCmlmICgkZW52Ok1WTldfVkVSQk9TRSAtZXEgInRydWUiKSB7CiAgJFZlcmJvc2VQcmVm
ZXJlbmNlID0gIkNvbnRpbnVlIgp9CgojIGNhbGN1bGF0ZSBkaXN0cmlidXRpb25VcmwsIHJlcXVp
cmVzIC5tdm4vd3JhcHBlci9tYXZlbi13cmFwcGVyLnByb3BlcnRpZXMKJGRpc3RyaWJ1dGlvblVy
bCA9IChHZXQtQ29udGVudCAtUmF3ICIkc2NyaXB0RGlyLy5tdm4vd3JhcHBlci9tYXZlbi13cmFw
cGVyLnByb3BlcnRpZXMiIHwgQ29udmVydEZyb20tU3RyaW5nRGF0YSkuZGlzdHJpYnV0aW9uVXJs
CmlmICghJGRpc3RyaWJ1dGlvblVybCkgewogIFdyaXRlLUVycm9yICJjYW5ub3QgcmVhZCBkaXN0
cmlidXRpb25VcmwgcHJvcGVydHkgaW4gJHNjcmlwdERpci8ubXZuL3dyYXBwZXIvbWF2ZW4td3Jh
cHBlci5wcm9wZXJ0aWVzIgp9Cgpzd2l0Y2ggLXdpbGRjYXJkIC1jYXNlc2Vuc2l0aXZlICggJCgk
ZGlzdHJpYnV0aW9uVXJsIC1yZXBsYWNlICdeLiovJywnJykgKSB7CiAgIm1hdmVuLW12bmQtKiIg
ewogICAgJFVTRV9NVk5EID0gJHRydWUKICAgICRkaXN0cmlidXRpb25VcmwgPSAkZGlzdHJpYnV0
aW9uVXJsIC1yZXBsYWNlICctYmluXC5bXi5dKiQnLCItd2luZG93cy1hbWQ2NC56aXAiCiAgICAk
TVZOX0NNRCA9ICJtdm5kLmNtZCIKICAgIGJyZWFrCiAgfQogIGRlZmF1bHQgewogICAgJFVTRV9N
Vk5EID0gJGZhbHNlCiAgICAkTVZOX0NNRCA9ICRzY3JpcHQgLXJlcGxhY2UgJ15tdm53JywnbXZu
JwogICAgYnJlYWsKICB9Cn0KCiMgYXBwbHkgTVZOV19SRVBPVVJMIGFuZCBjYWxjdWxhdGUgTUFW
RU5fSE9NRQojIG1hdmVuIGhvbWUgcGF0dGVybjogfi8ubTIvd3JhcHBlci9kaXN0cy97YXBhY2hl
LW1hdmVuLTx2ZXJzaW9uPixtYXZlbi1tdm5kLTx2ZXJzaW9uPi08cGxhdGZvcm0+fS88aGFzaD4K
aWYgKCRlbnY6TVZOV19SRVBPVVJMKSB7CiAgJE1WTldfUkVQT19QQVRURVJOID0gaWYgKCRVU0Vf
TVZORCkgeyAiL29yZy9hcGFjaGUvbWF2ZW4vIiB9IGVsc2UgeyAiL21hdmVuL212bmQvIiB9CiAg
JGRpc3RyaWJ1dGlvblVybCA9ICIkZW52Ok1WTldfUkVQT1VSTCRNVk5XX1JFUE9fUEFUVEVSTiQo
JGRpc3RyaWJ1dGlvblVybCAtcmVwbGFjZSAnXi4qJyskTVZOV19SRVBPX1BBVFRFUk4sJycpIgp9
CiRkaXN0cmlidXRpb25VcmxOYW1lID0gJGRpc3RyaWJ1dGlvblVybCAtcmVwbGFjZSAnXi4qLycs
JycKJGRpc3RyaWJ1dGlvblVybE5hbWVNYWluID0gJGRpc3RyaWJ1dGlvblVybE5hbWUgLXJlcGxh
Y2UgJ1wuW14uXSokJywnJyAtcmVwbGFjZSAnLWJpbiQnLCcnCiRNQVZFTl9IT01FX1BBUkVOVCA9
ICIkSE9NRS8ubTIvd3JhcHBlci9kaXN0cy8kZGlzdHJpYnV0aW9uVXJsTmFtZU1haW4iCmlmICgk
ZW52Ok1BVkVOX1VTRVJfSE9NRSkgewogICRNQVZFTl9IT01FX1BBUkVOVCA9ICIkZW52Ok1BVkVO
X1VTRVJfSE9NRS93cmFwcGVyL2Rpc3RzLyRkaXN0cmlidXRpb25VcmxOYW1lTWFpbiIKfQokTUFW
RU5fSE9NRV9OQU1FID0gKFtTeXN0ZW0uU2VjdXJpdHkuQ3J5cHRvZ3JhcGh5Lk1ENV06OkNyZWF0
ZSgpLkNvbXB1dGVIYXNoKFtieXRlW11dW2NoYXJbXV0kZGlzdHJpYnV0aW9uVXJsKSB8IEZvckVh
Y2gtT2JqZWN0IHskXy5Ub1N0cmluZygieDIiKX0pIC1qb2luICcnCiRNQVZFTl9IT01FID0gIiRN
QVZFTl9IT01FX1BBUkVOVC8kTUFWRU5fSE9NRV9OQU1FIgoKaWYgKFRlc3QtUGF0aCAtUGF0aCAi
JE1BVkVOX0hPTUUiIC1QYXRoVHlwZSBDb250YWluZXIpIHsKICBXcml0ZS1WZXJib3NlICJmb3Vu
ZCBleGlzdGluZyBNQVZFTl9IT01FIGF0ICRNQVZFTl9IT01FIgogIFdyaXRlLU91dHB1dCAiTVZO
X0NNRD0kTUFWRU5fSE9NRS9iaW4vJE1WTl9DTUQiCiAgZXhpdCAkPwp9CgppZiAoISAkZGlzdHJp
YnV0aW9uVXJsTmFtZU1haW4gLW9yICgkZGlzdHJpYnV0aW9uVXJsTmFtZSAtZXEgJGRpc3RyaWJ1
dGlvblVybE5hbWVNYWluKSkgewogIFdyaXRlLUVycm9yICJkaXN0cmlidXRpb25VcmwgaXMgbm90
IHZhbGlkLCBtdXN0IGVuZCB3aXRoICotYmluLnppcCwgYnV0IGZvdW5kICRkaXN0cmlidXRpb25V
cmwiCn0KCiMgcHJlcGFyZSB0bXAgZGlyCiRUTVBfRE9XTkxPQURfRElSX0hPTERFUiA9IE5ldy1U
ZW1wb3JhcnlGaWxlCiRUTVBfRE9XTkxPQURfRElSID0gTmV3LUl0ZW0gLUl0ZW10eXBlIERpcmVj
dG9yeSAtUGF0aCAiJFRNUF9ET1dOTE9BRF9ESVJfSE9MREVSLmRpciIKJFRNUF9ET1dOTE9BRF9E
SVJfSE9MREVSLkRlbGV0ZSgpIHwgT3V0LU51bGwKdHJhcCB7CiAgaWYgKCRUTVBfRE9XTkxPQURf
RElSLkV4aXN0cykgewogICAgdHJ5IHsgUmVtb3ZlLUl0ZW0gJFRNUF9ET1dOTE9BRF9ESVIgLVJl
Y3Vyc2UgLUZvcmNlIHwgT3V0LU51bGwgfQogICAgY2F0Y2ggeyBXcml0ZS1XYXJuaW5nICJDYW5u
b3QgcmVtb3ZlICRUTVBfRE9XTkxPQURfRElSIiB9CiAgfQp9CgpOZXctSXRlbSAtSXRlbXR5cGUg
RGlyZWN0b3J5IC1QYXRoICIkTUFWRU5fSE9NRV9QQVJFTlQiIC1Gb3JjZSB8IE91dC1OdWxsCgoj
IERvd25sb2FkIGFuZCBJbnN0YWxsIEFwYWNoZSBNYXZlbgpXcml0ZS1WZXJib3NlICJDb3VsZG4n
dCBmaW5kIE1BVkVOX0hPTUUsIGRvd25sb2FkaW5nIGFuZCBpbnN0YWxsaW5nIGl0IC4uLiIKV3Jp
dGUtVmVyYm9zZSAiRG93bmxvYWRpbmcgZnJvbTogJGRpc3RyaWJ1dGlvblVybCIKV3JpdGUtVmVy
Ym9zZSAiRG93bmxvYWRpbmcgdG86ICRUTVBfRE9XTkxPQURfRElSLyRkaXN0cmlidXRpb25VcmxO
YW1lIgoKJHdlYmNsaWVudCA9IE5ldy1PYmplY3QgU3lzdGVtLk5ldC5XZWJDbGllbnQKaWYgKCRl
bnY6TVZOV19VU0VSTkFNRSAtYW5kICRlbnY6TVZOV19QQVNTV09SRCkgewogICR3ZWJjbGllbnQu
Q3JlZGVudGlhbHMgPSBOZXctT2JqZWN0IFN5c3RlbS5OZXQuTmV0d29ya0NyZWRlbnRpYWwoJGVu
djpNVk5XX1VTRVJOQU1FLCAkZW52Ok1WTldfUEFTU1dPUkQpCn0KW05ldC5TZXJ2aWNlUG9pbnRN
YW5hZ2VyXTo6U2VjdXJpdHlQcm90b2NvbCA9IFtOZXQuU2VjdXJpdHlQcm90b2NvbFR5cGVdOjpU
bHMxMgokd2ViY2xpZW50LkRvd25sb2FkRmlsZSgkZGlzdHJpYnV0aW9uVXJsLCAiJFRNUF9ET1dO
TE9BRF9ESVIvJGRpc3RyaWJ1dGlvblVybE5hbWUiKSB8IE91dC1OdWxsCgojIElmIHNwZWNpZmll
ZCwgdmFsaWRhdGUgdGhlIFNIQS0yNTYgc3VtIG9mIHRoZSBNYXZlbiBkaXN0cmlidXRpb24gemlw
IGZpbGUKJGRpc3RyaWJ1dGlvblNoYTI1NlN1bSA9IChHZXQtQ29udGVudCAtUmF3ICIkc2NyaXB0
RGlyLy5tdm4vd3JhcHBlci9tYXZlbi13cmFwcGVyLnByb3BlcnRpZXMiIHwgQ29udmVydEZyb20t
U3RyaW5nRGF0YSkuZGlzdHJpYnV0aW9uU2hhMjU2U3VtCmlmICgkZGlzdHJpYnV0aW9uU2hhMjU2
U3VtKSB7CiAgaWYgKCRVU0VfTVZORCkgewogICAgV3JpdGUtRXJyb3IgIkNoZWNrc3VtIHZhbGlk
YXRpb24gaXMgbm90IHN1cHBvcnRlZCBmb3IgbWF2ZW4tbXZuZC4gYG5QbGVhc2UgZGlzYWJsZSB2
YWxpZGF0aW9uIGJ5IHJlbW92aW5nICdkaXN0cmlidXRpb25TaGEyNTZTdW0nIGZyb20geW91ciBt
YXZlbi13cmFwcGVyLnByb3BlcnRpZXMuIgogIH0KICBJbXBvcnQtTW9kdWxlICRQU0hPTUVcTW9k
dWxlc1xNaWNyb3NvZnQuUG93ZXJTaGVsbC5VdGlsaXR5IC1GdW5jdGlvbiBHZXQtRmlsZUhhc2gK
ICBpZiAoKEdldC1GaWxlSGFzaCAiJFRNUF9ET1dOTE9BRF9ESVIvJGRpc3RyaWJ1dGlvblVybE5h
bWUiIC1BbGdvcml0aG0gU0hBMjU2KS5IYXNoLlRvTG93ZXIoKSAtbmUgJGRpc3RyaWJ1dGlvblNo
YTI1NlN1bSkgewogICAgV3JpdGUtRXJyb3IgIkVycm9yOiBGYWlsZWQgdG8gdmFsaWRhdGUgTWF2
ZW4gZGlzdHJpYnV0aW9uIFNIQS0yNTYsIHlvdXIgTWF2ZW4gZGlzdHJpYnV0aW9uIG1pZ2h0IGJl
IGNvbXByb21pc2VkLiBJZiB5b3UgdXBkYXRlZCB5b3VyIE1hdmVuIHZlcnNpb24sIHlvdSBuZWVk
IHRvIHVwZGF0ZSB0aGUgc3BlY2lmaWVkIGRpc3RyaWJ1dGlvblNoYTI1NlN1bSBwcm9wZXJ0eS4i
CiAgfQp9CgojIHVuemlwIGFuZCBtb3ZlCkV4cGFuZC1BcmNoaXZlICIkVE1QX0RPV05MT0FEX0RJ
Ui8kZGlzdHJpYnV0aW9uVXJsTmFtZSIgLURlc3RpbmF0aW9uUGF0aCAiJFRNUF9ET1dOTE9BRF9E
SVIiIHwgT3V0LU51bGwKUmVuYW1lLUl0ZW0gLVBhdGggIiRUTVBfRE9XTkxPQURfRElSLyRkaXN0
cmlidXRpb25VcmxOYW1lTWFpbiIgLU5ld05hbWUgJE1BVkVOX0hPTUVfTkFNRSB8IE91dC1OdWxs
CnRyeSB7CiAgTW92ZS1JdGVtIC1QYXRoICIkVE1QX0RPV05MT0FEX0RJUi8kTUFWRU5fSE9NRV9O
QU1FIiAtRGVzdGluYXRpb24gJE1BVkVOX0hPTUVfUEFSRU5UIHwgT3V0LU51bGwKfSBjYXRjaCB7
CiAgaWYgKCEgKFRlc3QtUGF0aCAtUGF0aCAiJE1BVkVOX0hPTUUiIC1QYXRoVHlwZSBDb250YWlu
ZXIpKSB7CiAgICBXcml0ZS1FcnJvciAiZmFpbCB0byBtb3ZlIE1BVkVOX0hPTUUiCiAgfQp9IGZp
bmFsbHkgewogIHRyeSB7IFJlbW92ZS1JdGVtICRUTVBfRE9XTkxPQURfRElSIC1SZWN1cnNlIC1G
b3JjZSB8IE91dC1OdWxsIH0KICBjYXRjaCB7IFdyaXRlLVdhcm5pbmcgIkNhbm5vdCByZW1vdmUg
JFRNUF9ET1dOTE9BRF9ESVIiIH0KfQoKV3JpdGUtT3V0cHV0ICJNVk5fQ01EPSRNQVZFTl9IT01F
L2Jpbi8kTVZOX0NNRCIK
SENGUICHET_EOF_MARKER


echo ""
echo "Fichiers source crees, wrapper Maven installe."
echo ""

# ===== Installation des dependances npm =====
echo "Installation des dependances du frontend (npm install)..."
cd frontend
if command -v npm >/dev/null 2>&1; then
  npm install --silent && echo "  Dependances npm installees." || \
    echo "  (Echec npm install : lancez-le manuellement dans frontend/.)"
else
  echo "  npm n'est pas installe : lancez 'npm install' dans frontend/ plus tard."
fi
cd ..

echo ""
echo "=========================================="
echo "  SenGuichet est pret !"
echo "=========================================="
echo ""
echo "Pour demarrer le backend (base H2, sans Docker ni Maven) :"
echo "   cd $PROJET/backend && ./mvnw spring-boot:run"
echo "   API : http://localhost:8080/api/demandes"
echo ""
echo "Pour demarrer le frontend :"
echo "   cd $PROJET/frontend && npm run dev"
echo "   Interface : http://localhost:3000"
echo ""
echo "N'oubliez pas d'initialiser Git :"
echo "   cd $PROJET && git init && git add . && git commit -m 'Code de base SenGuichet'"
echo ""

