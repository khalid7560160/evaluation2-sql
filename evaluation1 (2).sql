--Q1. Afficher dans l'ordre alphabétique et sur une seule colonne les noms et prénoms des employés qui ont des enfants, présenter d'abord ceux qui en ont le plus.

SELECT emp_lastname,emp_firstname,emp_children
FROM EMPLOYEES
WHERE emp_children >= '1' 
ORDER BY  emp_children DESC

--Q2. Y-a-t-il des clients étrangers ? Afficher leur nom, prénom et pays de résidence.

SELECT cus_lastname, cus_firstname, cus_countries_id
FROM customers
JOIN countries ON cus_countries_id = cou_id
WHERE cou_name != 'France'
ORDER BY cou_name, cus_lastname, cus_firstname, cus_countries_id;

--Q3. Afficher par ordre alphabétique les villes de résidence des clients ainsi que le code (ou le nom) du pays.

SELECT cus_city,cus_countries_id
FROM customers
order by cus_city asc

--Q4. Afficher le nom des clients dont les fiches ont été modifiées

SELECT cus_lastname,cus_update_date 
FROM customers 
WHERE cus_update_date is not null;

--Q5. La commerciale Coco Merce veut consulter la fiche d'un client, mais la seule chose dont elle se souvienne est qu'il habite une ville genre 'divos'. Pouvez-vous l'aider ?

SELECT cus_id AS 'Client n°', CONCAT(cus_lastname, ' ', cus_firstname) AS 'Nom',  cus_city, cou_name
FROM customers
JOIN countries ON cus_countries_id = cou_id
WHERE cus_city LIKE '%divos%';

--Q6. Quel est le produit vendu le moins cher ? Afficher le prix, l'id et le nom du produit.

SELECT pro_id, pro_name, pro_price
FROM products
WHERE pro_price IN (
                    SELECT MIN(pro_price)
                        FROM products
);

--Q7. Lister les produits qui n'ont jamais été vendus
****
SELECT pro_id,pro_ref,pro_name
FROM products
WHERE pro_id NOT IN (SELECT ode_pro_id FROM orders_details)

--Q8. Afficher les produits commandés par Madame Pikatchien.
SELECT pro_id, pro_ref, pro_name,  cus_id, ord_id, ode_id
FROM products
JOIN orders_details ON pro_id = ode_pro_id
JOIN orders ON ode_ord_id = ord_id
JOIN customers ON ord_cus_id = cus_id
WHERE cus_lastname = 'Pikatchien';

--Q9. Afficher le catalogue des produits par catégorie, le nom des produits et de la catégorie doivent être affichés.
SELECT cat_id,cat_name,pro_name
FROM products
JOIN categories ON pro_id = cat_id
ORDER BY cat_name ASC, pro_name

--Q10. Afficher l'organigramme hiérarchique (nom et prénom et poste des employés) du magasin de Compiègne, classer par ordre alphabétique. Afficher le nom et prénom des employés, éventuellement le poste (si vous y parvenez).

SELECT CONCAT(emp_comp.emp_lastname, ' ', emp_comp.emp_firstname) AS 'Employé', pos_comp.pos_libelle AS 'Poste', CONCAT(supp.emp_lastname, ' ', supp.emp_firstname) AS 'Supérieur', pos_supp.pos_libelle AS 'Poste'
FROM employees emp_comp
JOIN shops ON emp_comp.emp_sho_id = sho_id
JOIN posts pos_comp ON emp_comp.emp_pos_id = pos_comp.pos_id
JOIN employees supp ON emp_comp.emp_superior_id = supp.emp_id
JOIN posts pos_supp on supp.emp_pos_id = pos_supp.pos_id
WHERE sho_city = 'Compiègne'
ORDER BY Employé ASC;

--Fonctions d'agrégation
--Q11. Quel produit a été vendu avec la remise la plus élevée ? Afficher le montant de la remise, le numéro et le nom du produit, le numéro de commande et de ligne de commande.
SELECT CONCAT(ode_discount, '%') AS 'Remise', pro_id AS 'Produit n°', pro_name AS 'Nom',  ord_id AS 'Commande n°', ode_id AS 'Ligne de commande n°'
FROM orders_details
JOIN products ON ode_pro_id = pro_id
JOIN orders ON ode_ord_id = ord_id
WHERE ode_discount IN (
                        SELECT MAX(ode_discount)
                        FROM orders_details
);

--Q13. Combien y-a-t-il de clients canadiens ? Afficher dans une colonne intitulée 'Nb clients Canada'

SELECT COUNT(cus_countries_id),cou_name,cou_id
FROM customers
JOIN countries ON cus_countries_id = cou_id
WHERE cou_name = 'Canada'

-- Q14. Afficher le détail des commandes de 2020.

SELECT ode_id, ode_unit_price, ode_discount, ode_quantity , ode_ord_id, ode_pro_id, ord_order_date
FROM orders
JOIN orders_details ON ord_id = ode_ord_id
JOIN products ON ode_pro_id = pro_id
WHERE YEAR(ord_order_date) = 2020
ORDER BY ord_id, ode_id

--Q15. Afficher les coordonnées des fournisseurs pour lesquels des commandes ont été passées.

SELECT DISTINCT sup_name AS 'Fournisseur', CONCAT(sup_address, ' ', sup_zipcode, ' ', sup_city, ' ', cou_name) AS 'Adresse', sup_phone AS 'Téléphone', sup_mail AS 'Email'
FROM orders_details
JOIN products ON ode_pro_id = pro_id
JOIN suppliers ON pro_sup_id = sup_id
JOIN countries ON sup_countries_id = cou_id;

--Q16. Quel est le chiffre d'affaires de 2020 ?

SELECT CONCAT(ROUND(SUM((ode_quantity*ode_unit_price)*((100-ode_discount)/100)), 2), '€') as 'résultat'
FROM orders
JOIN orders_details ON ord_id = ode_ord_id
WHERE YEAR(ord_order_date) = 2020;

--Q17. Quel est le panier moyen ?
SELECT CONCAT(ROUND(SUM((ode_quantity*ode_unit_price)*((100-ode_discount)/100))/COUNT(DISTINCT ord_id), 2), '€') AS 'Moyenne des paniers'
FROM orders
JOIN orders_details ON ord_id = ode_ord_id;

--Q18. Lister le total de chaque commande par total décroissant (Afficher numéro de commande, date, total et nom du client).

SELECT ord_id, cus_lastname, ord_order_date, CONCAT(ROUND(SUM((ode_quantity*ode_unit_price)*((100-ode_discount)/100)), 2)) AS 'Total'
FROM orders
JOIN orders_details ON ord_id = ode_ord_id
JOIN customers ON ord_cus_id = cus_id
GROUP BY ord_id
ORDER BY SUM((ode_quantity*ode_unit_price)*((100-ode_discount)/100)) DESC, ord_order_date;

--Q19.La version 2020 du produit barb004 s'appelle désormais Camper et, bonne nouvelle, son prix subit une baisse de 10%.
***
select pro_price
UPDATE  products 
SET  pro_price =pro_price - pro_price/100 * 10, pro_name='Camper'
where pro_ref='barb004

--Q20. L'inflation en France en 2019 a été de 1,1%, appliquer cette augmentation à la gamme de parasols.
***
UPDATE products 
SET  pro_price =pro_price + pro_price/100 *(1.1)
where pro_cat_id = (SELECT cat_id FROM categories where cat_name = "parasols")

--Q21. Supprimer les produits non vendus de la catégorie "Tondeuses électriques". Vous devez utiliser une sous-requête sans indiquer de valeurs de clés.
--Les besoins de mise à jour

DELETE p
FROM products p
INNER JOIN categories c ON c.cat_id = p.pro_cat_id
WHERE NOT EXISTS(
        SELECT od.ode_pro_id
        FROM orders_details od
        WHERE od.ode_pro_id = p.pro_id
    )
  AND c.cat_name LIKE "Tondeuses électriques";


--5. Rôles
--A partir de la base Gescom :

--Créez un groupe marketing qui peut ajouter, modifier et supprimer des produits et des catégories, consulter des commandes, leur détails et les clients. 
--Ce groupe ne peut rien faire sur les autres tables.
CREATE USER 'LUFFY' IDENTIFIED BY 'mot_de_passe1';
CREATE USER 'ZORO' IDENTIFIED BY 'mot_de_passe2';
CREATE USER 'NANI' IDENTIFIED BY 'mot_de_passe3';

DROP ROLE marketing
CREATE ROLE marketing

GRANT select,Insert,update,delete 
ON gescom.products
TO marketing;

GRANT select,Insert,update,delete 
ON gescom.categories
TO marketing;

GRANT select
ON gescom.orders
TO marketing;

GRANT select
ON gescom.orders_details
TO marketing;


--6. Assurer les sauvegardes
--Présentez la commande de backup de la base Gescom et assurez-vous que la restauration fonctionne.
