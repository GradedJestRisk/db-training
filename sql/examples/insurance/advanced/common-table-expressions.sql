-- Étape 1 : Calculer le total impayé pour chaque client
WITH impayes_par_client AS (
    SELECT
        co.id_client,
        SUM(cot.montant) AS total_impaye
    FROM cotisations AS cot
    JOIN contrats AS co ON cot.id_contrat = co.id_contrat
    WHERE cot.statut_paiement = 'Impayée'
    GROUP BY co.id_client
),

-- Étape 2 : Calculer la moyenne globale des impayés (une seule valeur)
moyenne_impayes AS (
    SELECT AVG(total_impaye) AS moyenne FROM impayes_par_client
)

-- Étape 3 (Requête Principale) : Combiner les deux pour filtrer
SELECT
    cl.nom,
    cl.prenom,
    ipc.total_impaye
FROM
    impayes_par_client AS ipc
CROSS JOIN
    moyenne_impayes AS m  -- Astuce : CROSS JOIN avec une ligne unique est très efficace
JOIN
    clients AS cl ON ipc.id_client = cl.id_client
WHERE
    ipc.total_impaye > m.moyenne
ORDER BY
    ipc.total_impaye DESC;
