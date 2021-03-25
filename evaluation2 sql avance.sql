evaluation2 sql avance 
--Vues
--Créez une vue qui affiche le catalogue produits. L'id, la référence et le nom des produits, ainsi que l'id et le nom de la catégorie doivent apparaître.

CREATE VIEW v_products_catalog
AS
SELECT pro_id,pro_ref,pro_name,pro_cat_id,cat_name
FROM products
JOIN categories on pro_cat_id = cat_id; 





----------------------------------------------------------------------------------------------------------


DROP PROCEDURE IF EXISTS facture|

CREATE PROCEDURE facture(

    p_ord_id    int UNSIGNED

)


select cus_id,cus_lastname,cus_firstname,cus_address,cus_zipcode,cus_city,cus_mail,cus_phone
from customers

select ord_id,ord_order_date,ord_payment_date
from orders

select ode_unit_price, ode_quantity,ode_ord_id,ode_pro_id



----------------------------------------------------------------------------------------------------------------------
--Procédures stockées
--Créez la procédure stockée facture qui permet d'afficher les informations nécessaires à une facture en fonction d'un numéro de commande. Cette procédure doit sortir le montant total de la commande.

--Pensez à vous renseigner sur les informations légales que doit comporter une facture.



--DELIMITER |



DROP PROCEDURE IF EXISTS facture|

CREATE PROCEDURE facture(

    p_ord_id    int UNSIGNED

)

BEGIN

    DECLARE ord_verif   varchar(50);

    /* DECLARE total_ord   double; */

    SET ord_verif = (

        SELECT ord_id

        FROM orders

        WHERE ord_id = p_ord_id

    );

    IF ISNULL(ord_verif)

    THEN

        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Ce numéro de commande n'existe pas";  
        --SIGNAL is the way to “return” an error. SIGNAL provides error information to a handler, 
        --to an outer portion of the application, or to the client. Also, it provides control over the error's characteristics (error number, SQLSTATE value, message). Without SIGNAL, 
        --it is necessary to resort to workarounds such as deliberately referring to a nonexistent table to cause a routine to return an error.
        --To signal a generic SQLSTATE value, use '45000', which means “unhandled user-defined exception.”

        SELECT commande.ord_id AS 'Numéro de commande',

        commande.ord_order_date AS 'Datée du',

        CONCAT(commande.cus_firstname, ' ', commande.cus_lastname, ' à ', commande.cus_city) AS 'Client',

        produits.ode_id AS 'Ligne de commande',

        CONCAT(produits.pro_ref, ' - ', produits.pro_name, ' - ', produits.pro_color) AS 'Produit',

        produits.ode_quantity AS 'Quantité produit',

        CONCAT(ROUND(produits.ode_unit_price, 2), '€') AS 'Prix unitaire',

        CONCAT(produits.ode_discount, '%') AS 'Remise',

        CONCAT(ROUND(totalcomm.total, 2), '€') AS 'Total'

        FROM (

            SELECT *

            FROM orders

            JOIN customers ON ord_cus_id = cus_id

            WHERE ord_id = p_ord_id

        ) commande,

        (

            SELECT *

            FROM orders

            JOIN orders_details ON ord_id = ode_ord_id

            JOIN products ON ode_pro_id = pro_id

            WHERE ord_id = p_ord_id

        ) produits,

        (

            SELECT SUM((ode_quantity*ode_unit_price)*((100-ode_discount)/100)) AS 'total'

            FROM orders

            JOIN orders_details ON ord_id = ode_ord_id

            WHERE ord_id = p_ord_id

        ) totalcomm;

        

    END IF;

END |



DELIMITER ;

--------------------------------------------------------------------------------------------------------------------------------------
--Triggers
--Présentez le déclencheur after_products_update demandé dans la phase 2 de la séance sur les déclencheurs.


DELIMITER |



DROP TRIGGER IF EXISTS after_products_update|

CREATE TRIGGER after_products_update

AFTER UPDATE ON products

FOR EACH ROW

BEGIN

    DECLARE stock_p int;

    DECLARE alert_p int;

    DECLARE id_p    int;

    DECLARE new_qte int;

    DECLARE verif   varchar(50);

    SET stock_p = NEW.pro_stock;

    SET alert_p = NEW.pro_stock_alert;

    SET id_p = NEW.pro_id;

    IF (stock_p < alert_p)

    THEN

        SET new_qte = alert_p - stock_p;

        SET verif = (

            SELECT codart

            FROM commander_articles

            WHERE codart = id_p

        );

        IF ISNULL(verif)

        THEN

            INSERT INTO commander_articles

            (codart, qte, date)

            VALUES

            (id_p, new_qte, CURRENT_DATE());

        ELSE

            UPDATE commander_articles

            SET qte = new_qte,

            date = CURRENT_DATE()

            WHERE codart = id_p;

        END IF;

    ELSE

        DELETE

        FROM commander_articles

        WHERE codart = id_p;

    END IF;

END|



DELIMITER ;

/*

Pour le jeu de test de votre déclencheur, on prendra le produit 8 (barbecue 'Athos') auquel on mettra les valeurs de stock :

6, 4, 3 
-- pro_stock_alert = 5
*/



SELECT *

FROM commander_articles;



UPDATE products

SET pro_stock = 6

WHERE pro_id = 8;



SELECT *

FROM commander_articles;



UPDATE products

SET pro_stock = 4

WHERE pro_id = 8;



SELECT *

FROM commander_articles;



UPDATE products

SET pro_stock = 3

WHERE pro_id = 8;



SELECT *

FROM commander_articles;



UPDATE products

SET pro_stock = 6

WHERE pro_id = 8;



SELECT *

FROM commander_articles








-------------------------------------------------------------------------------------------------------------------------------------------------
--Transactions
--Amity HANAH, Manageuse au sein du magasin d'Arras, vient de prendre sa retraite. Il a été décidé, après de nombreuses tractations, de confier son poste au pépiniériste le plus ancien en poste dans ce magasin. Ce dernier voit alors son salaire augmenter de 5% et ses anciens collègues pépiniéristes passent sous sa direction.

--Ecrire la transaction permettant d'acter tous ces changements en base des données.

--La base de données ne contient actuellement que des employés en postes. Il a été choisi de garder en base une liste des anciens collaborateurs de l'entreprise parti en retraite. Il va donc vous falloir ajouter une ligne dans la table posts pour référencer les employés à la retraite.

--Décrire les opérations qui seront à réaliser sur la table posts.

--Ecrire les requêtes correspondant à ces opéarations.

--Ecrire la transaction
START TRANSACTION;
INSERT INTO posts (pos_libelle)
VALUES ('Retraité');


--Dans un 1er temps il faut mettre en retraite Amity HANNAH la rechercher dans la base de données et la faire passer en retraité dans le magasin d Arras
UPDATE posts SET                       WHERE arras 

--rechecher via po_id 2 et la passer en retraite 
--rechercher via pos_id 14 et pos-libelle pepinieriste pour la remplacer avec une uagmentation de salaire de 5%
--all pos_id 14 deviennent sous la direction des pos_id 2

UPDATE employees SET emp_pos_id =                      

 pos_id FROM posts WHERE pos_libelle = 'Pepinieriste';
SELECT *
FROM Employees
--emp_lastname,emp_firstname,emp_pos_id

--emp_enter_date= anciennete,


START TRANSACTION;
INSERT INTO posts (pos_libelle)
VALUES ('Retraité');
SET @idshop = (select sho_id from shops where sho_city = 'Arras');
SET @idretraite = (select pos_id from posts where pos_libelle = 'Retraité');
update employees set emp_pos_id = @idretraite where emp_lastname = 'HANNAH' AND  emp_firstname = 'Amity'AND emp_sho_id = @idshop;
SELECT pos_id FROM posts WHERE pos_libelle = 'Pépinieriste';
SELECT *
From Employees
JOIN posts ON emp_pos_id = posts.pos_id
WHERE pos_libelle = 'Pépiniériste' AND emp_sho_id = @idshop;
SET @id_new_manager = (SELECT emp_id
FROM employees 
JOIN posts ON emp_pos_id = posts.pos_id
WHERE pos_libelle = 'Pépiniériste' AND emp_sho_id = @idshop
ORDER BY emp_enter_date
limit 1);
SET @post_id_manager = (SELECT pos_id
FROM posts 
WHERE pos_libelle LIKE '%Manage%'
limit 1);
UPDATE employees
SET 
emp_salary = (emp_salary*1.05),
emp_pos_id = @post_id_manager 
WHERE emp_id = @id_new_manager;
SET @les_pepinieristes = (SELECT pos_id
FROM posts
WHERE pos_libelle = 'Pépinieriste');
SET @id_new_manager = (SELECT emp_id 
FROM employees 
WHERE emp_firstname = 'Dorian');
UPDATE employees
SET 
emp_superior_id = @id_new_manager
WHERE emp_pos_id = @les_pepinieristes;
COMMIT



