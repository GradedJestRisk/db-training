-- clients et contrats
SELECT
    cl.id_client,
    cl.nom,
    co.id_contrat,
    co.numero_police
FROM
    clients AS cl
FULL OUTER JOIN
    contrats AS co ON cl.id_client = co.id_client;


-- clients sans contrat ET contrats sans client
SELECT
    cl.id_client,
    cl.nom,
    co.id_contrat,
    co.numero_police
FROM
    clients AS cl
FULL OUTER JOIN
    contrats AS co ON cl.id_client = co.id_client
WHERE
    cl.id_client IS NULL OR co.id_contrat IS NULL;
