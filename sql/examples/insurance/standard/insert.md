# Insert


## Single value : VALUES

Get the last value
```sql
SELECT MAX(contrats.id_contrat)
FROM contrats;
```

```sql
INSERT INTO contrats (id_contrat, numero_police, date_souscription, date_echeance, statut, valeur_assuree, id_client, id_produit)
VALUES (2,'AV-004', CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL '1 YEAR'), 'Actif', 100000, 4, 40);
```

```sql
INSERT INTO contrats (id_contrat, 
                      numero_police, date_souscription, date_echeance, statut, valeur_assuree, id_client, id_produit)
VALUES ((SELECT MAX(contrats.id_contrat) + 1 FROM contrats),
        'AV-004', CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL '1 YEAR'), 'Actif', 100000, 4, 40);
```
