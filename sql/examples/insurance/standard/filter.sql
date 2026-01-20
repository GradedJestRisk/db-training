
SELECT
    description AS "Description",
    montant_indemnise AS "Montant à Indemniser",
    date_declaration AS "Date de Déclaration"
FROM
    sinistres
WHERE 1=1
 --   AND id_contrat = 101
 --   AND montant_indemnise > 5000
    AND id_gestionnaire IS NULL
ORDER BY
    date_declaration ASC
;
