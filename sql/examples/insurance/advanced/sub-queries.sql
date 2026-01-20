-- scalar
SELECT numero_police, valeur_assuree
FROM contrats
WHERE valeur_assuree > (SELECT AVG(valeur_assuree)
                        FROM contrats);

SELECT
    numero_police,
    valeur_assuree
FROM
    contrats
WHERE
    valeur_assuree > (
        -- Cette sous-requête est exécutée une seule fois et retourne une seule valeur
        SELECT AVG(valeur_assuree) FROM contrats
    );

-- correlated


-- multi-line IN

SELECT nom, prenom
FROM clients
WHERE id_client IN (
    SELECT id_client FROM contrats
    WHERE id_produit IN (
        SELECT id_produit
        FROM produits
        WHERE categorie = 'INCENDIE'
    )
);


-- multi-line EXISTS

SELECT cl.id_client, cl.nom, cl.prenom
FROM clients AS cl
WHERE EXISTS ( -- La condition est VRAIE si la sous-requête ci-dessous retourne au moins une ligne
        SELECT 1 -- On sélectionne une constante (1) car le contenu n'a pas d'importance
        FROM contrats AS co
        JOIN sinistres AS s ON co.id_contrat = s.id_contrat
        WHERE co.id_client = cl.id_client -- C'est la CORRELATION : on lie la sous-requête à la requête principale
    );


-- in FROM clause

SELECT cl.nom, cl.prenom, stats_clients.total_cotise
FROM clients AS cl
JOIN ( -- Début de la table dérivée
    SELECT co.id_client, SUM(cot.montant) AS total_cotise
    FROM cotisations AS cot
    JOIN contrats AS co ON cot.id_contrat = co.id_contrat
    WHERE cot.statut_paiement = 'VALIDE'
    GROUP BY co.id_client
) AS stats_clients ON cl.id_client = stats_clients.id_client -- Fin de la table dérivée
WHERE stats_clients.total_cotise > 100;
