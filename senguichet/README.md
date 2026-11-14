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
