-- docker rm insurance-dataset || docker run --name insurance-dataset --publish 5432:5432 --env POSTGRES_PASSWORD=password --detach postgres:latest
-- psql --host localhost --port 5432 --username postgres

DROP TABLE IF EXISTS  sinistres;
DROP TABLE IF EXISTS  cotisations;
DROP TABLE IF EXISTS  contrats;
DROP TABLE IF EXISTS  clients;
DROP TABLE IF EXISTS  produits;


CREATE TABLE produits (
    id_produit  INT PRIMARY KEY,
    nom_produit  VARCHAR,
    categorie  VARCHAR UNIQUE,
    description  TEXT
);

INSERT INTO produits (id_produit, nom_produit, categorie, description)
VALUES (0, 'Assurance incendie', 'INCENDIE', 'Remboursement à valeur du bien, sur justificatif');

INSERT INTO produits (id_produit, nom_produit, categorie, description)
VALUES (1, 'Assurance inondation', 'INONDATION', 'Hors catastrophe naturelle');

SELECT * FROM produits;

DROP TABLE IF EXISTS clients;

CREATE TABLE clients (
    id_client  INT PRIMARY KEY,
    nom  VARCHAR,
    prenom  VARCHAR,
    date_naissance  DATE,
    adresse  VARCHAR,
    email  VARCHAR
);

INSERT INTO clients (id_client, nom, prenom, date_naissance, adresse, email)
VALUES (0, 'DUPOND', 'Hélène', '01/01/1900', '3 rue du pont 75000 PARIS', 'helene.dupond@paris.fr');

INSERT INTO clients (id_client, nom, prenom, date_naissance, adresse, email)
VALUES (1, 'FUTAILLE', 'Susie', '01/01/1950', '1 rue de la place 75000 PARIS', 'susie.futaille@paris.fr');

DROP TABLE IF EXISTS contrats;

CREATE TABLE contrats (
    id_contrat  INT PRIMARY KEY,
    numero_police  VARCHAR UNIQUE,
    date_souscription  DATE,
    date_echeance  DATE,
    statut  VARCHAR,
    valeur_assuree  DECIMAL,
    id_client  INT REFERENCES clients(id_client),
    id_produit  INT REFERENCES produits(id_produit)
);

TRUNCATE TABLE contrats;

INSERT INTO contrats (id_contrat, numero_police, date_souscription, date_echeance, statut, valeur_assuree, id_client, id_produit)
VALUES (0, 'LP98GT', '01/01/2010', '01/01/2020', 'INACTIF', 100000, 0, 0);

INSERT INTO contrats (id_contrat, numero_police, date_souscription, date_echeance, statut, valeur_assuree, id_client, id_produit)
VALUES (1, 'LK985LO', '01/01/2025', '01/01/2030', 'ACTIF', 200000, 0, 0);


CREATE TABLE cotisations (
    id_cotisation INT PRIMARY KEY,
    date_echeance DATE,
    date_paiement DATE,
    montant DECIMAL,
    statut_paiement VARCHAR,
    id_contrat INT references contrats(id_contrat)
);

TRUNCATE TABLE cotisations;

INSERT INTO cotisations (id_cotisation, date_echeance, date_paiement, montant, statut_paiement, id_contrat)
VALUES (0, '01/01/2010', '01/12/2009', 100,'VALIDE', 0 );

INSERT INTO cotisations (id_cotisation, date_echeance, date_paiement, montant, statut_paiement, id_contrat)
VALUES (1, '01/02/2010', '01/01/2010', 100,'VALIDE', 0 );


DROP TABLE sinistres;

CREATE TABLE sinistres (
    id_sinistre INT PRIMARY KEY,
    date_sinistre DATE,
    date_declaration DATE,
    description TEXT,
    statut VARCHAR,
    montant_indemnise DECIMAL,
    id_contrat INT references contrats(id_contrat),
    id_gestionnaire INT
);

TRUNCATE TABLE sinistres;

INSERT INTO sinistres (id_sinistre, date_sinistre, date_declaration, description, statut, montant_indemnise, id_contrat, id_gestionnaire)
VALUES (0, '01/01/2015', '03/02/2015', 'Feu de cheminée', 'SOLDE', 10000, 0, NULL);

INSERT INTO sinistres (id_sinistre, date_sinistre, date_declaration, description, statut, montant_indemnise, id_contrat, id_gestionnaire)
VALUES (1, '01/01/2025', '03/02/2025', 'Chute de tuiles', 'OUVERT', 500, 0, 1);