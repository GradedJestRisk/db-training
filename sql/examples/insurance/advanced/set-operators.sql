SELECT id_client FROM contrats WHERE id_produit IN (SELECT id_produit FROM produits WHERE categorie = 'INCENDIE')
INTERSECT DISTINCT -- DISTINCT est nécessaire car INTERSECT opère sur des ensembles uniques
SELECT id_client FROM contrats WHERE id_produit IN (SELECT id_produit FROM produits WHERE categorie = 'INONDATION');
