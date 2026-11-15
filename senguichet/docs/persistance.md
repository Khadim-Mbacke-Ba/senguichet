# Persistance des données PostgreSQL avec Docker

## 1. Objectif de l'expérience

L'objectif est de comprendre pourquoi les données stockées directement dans un conteneur Docker disparaissent lorsque celui-ci est supprimé, et comment utiliser un volume Docker pour assurer leur persistance.

## 2. Première expérience : sans volume

Création du conteneur PostgreSQL :

```bash
docker run --name senguichet-db \
-e POSTGRES_DB=senguichet \
-e POSTGRES_USER=postgres \
-e POSTGRES_PASSWORD=postgres \
-p 5432:5432 \
-d postgres:16
```

Connexion à la base :

```bash
docker exec -it senguichet-db psql -U postgres -d senguichet
```

Création d'une table et insertion de données :

```sql
CREATE TABLE utilisateurs (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100),
    email VARCHAR(150)
);

INSERT INTO utilisateurs (nom, email)
VALUES
('Khadim', 'khadim@example.com'),
('Moussa', 'moussa@example.com');
```

Vérification :

```sql
SELECT * FROM utilisateurs;
```

Suppression du conteneur :

```bash
docker rm -f senguichet-db
```

**Constat :** sans volume, les données stockées dans le conteneur sont perdues lors de sa suppression.

## 3. Deuxième expérience : avec un volume Docker

Création d'un volume :

```bash
docker volume create senguichet-data
```

Création du conteneur PostgreSQL avec le volume :

```bash
docker run --name senguichet-db \
-e POSTGRES_DB=senguichet \
-e POSTGRES_USER=postgres \
-e POSTGRES_PASSWORD=postgres \
-p 5432:5432 \
-v senguichet-data:/var/lib/postgresql/data \
-d postgres:16
```

Le volume `senguichet-data` est monté dans le répertoire `/var/lib/postgresql/data`, qui contient les données PostgreSQL.

Après avoir créé la table et inséré les données, suppression du conteneur :

```bash
docker rm -f senguichet-db
```

Recréation du conteneur avec le même volume :

```bash
docker run --name senguichet-db \
-e POSTGRES_DB=senguichet \
-e POSTGRES_USER=postgres \
-e POSTGRES_PASSWORD=postgres \
-p 5432:5432 \
-v senguichet-data:/var/lib/postgresql/data \
-d postgres:16
```

Vérification des données :

```bash
docker exec -it senguichet-db psql -U postgres -d senguichet
```

Puis :

```sql
SELECT * FROM utilisateurs;
```

**Constat :** les données sont toujours présentes après la suppression et la recréation du conteneur.

## 4. Conclusion

Cette expérience montre la différence entre le stockage interne d'un conteneur et un volume Docker.

- Sans volume, les données sont liées au cycle de vie du conteneur.
- Avec un volume, les données sont conservées indépendamment du conteneur.
- Un même volume peut être remonté dans un nouveau conteneur pour retrouver les données.

Pour le projet SenGuichet, l'utilisation d'un volume Docker est indispensable afin de préserver les données PostgreSQL lors des redémarrages ou des recréations du conteneur.

**Volume utilisé :** `senguichet-data`

**Conteneur utilisé :** `senguichet-db`
