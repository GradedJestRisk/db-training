
-- Right join

SELECT c.numero_police, -- Sera NULL si un produit n'a jamais été vendu
       p.nom_produit
FROM contrats c
         RIGHT JOIN
     produits AS p
     ON c.id_produit = p.id_produit;

-- Full join

SELECT
    cl.id_client,
    cl.nom,
    co.id_contrat,
    co.numero_police
FROM  clients AS cl
FULL OUTER JOIN
    contrats AS co ON cl.id_client = co.id_client;

-- Cross join
-- Toutes les combinaisons possibles entre chaque catégorie de produit  et chaque statut de contrat possible

WITH
categories_uniques AS (
    SELECT DISTINCT categorie FROM  produits
),
statuts_uniques AS (
    SELECT DISTINCT statut FROM contrats
)
SELECT
    cat.categorie,
    st.statut
FROM
    categories_uniques AS cat
CROSS JOIN
    statuts_uniques AS st;
