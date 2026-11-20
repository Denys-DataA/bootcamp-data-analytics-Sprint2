/* ==============================================================================
   PROYECTO:     Especialización Data Analytics
   SPRINT:       02 - Tarea S2.01. Nociones básicas SQL - Nivel 1
   AUTOR:        Denys Geanina Doros Curti
   FECHA:        20 Noviembre 2026
   DESCRIPCIÓN:  Resolución de ejercicios Sprint 2 - Nivel 1
   ============================================================================== */

-- Configuración de entorno
USE transactions;

-- ============================================================
-- NIVEL 1: CONSULTAS SQL
-- ============================================================

-- Ejercicio 1.1: Creación y análisis del esquema
/* ============================================================
   - Importación de los archivos estructura_datos y datos_introducir.
   - Creación de la base de datos 'transactions'.
   - Creación de las tablas 'company' y 'transaction'.
   - Comprobación de los registros importados:
       company: 100 registros
       transaction: 100.000 registros
   - Identificación de las claves primarias (PK).
   - Verificación de la clave foránea (FK):
       transaction.company_id -> company.id
   - Relación entre tablas: 1:N (uno a muchos).
   - Creación del diagrama EER mediante Reverse Engineer.

   El procedimiento y las capturas están documentados
   en el archivo PDF de entrega del Sprint 2 (261117_Denys_Doros_Sprint2).
   ============================================================ */
   
-- Ejercicio 2.1: Listado de los países que están generando ventas.
-- Objetivo: Mostrar los países con transacciones no rechazadas.

SELECT DISTINCT c.country AS COUNTRY
FROM company c
INNER JOIN transaction t
ON c.id = t.company_id
WHERE t.declined = 0
ORDER BY c.country ASC;

-- Ejercicio 2.2: Desde cuántos países se generan las ventas.
-- Objetivo: Contar los países distintos con ventas.

SELECT COUNT(DISTINCT c.country) AS Total_Países
FROM company c
INNER JOIN transaction t
ON c.id = t.company_id
WHERE t.declined = 0;

-- Ejercicio 2.3: Identifica a la compañía con la mayor media de ventas.
-- Objetivo: Identificar la empresa con mayor importe medio.

SELECT c.company_name AS Empresa, 
	ROUND(AVG(t.amount), 2) AS Importe_medio
FROM company c
INNER JOIN transaction t
ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY c.id, c.company_name
ORDER BY Importe_medio DESC
LIMIT 1;

-- Ejercicio 3.1: Muestra todas las transacciones realizadas por empresas de Alemania.

SELECT * FROM transaction
WHERE company_id IN (
	SELECT id
	FROM company
	WHERE country = 'Germany'
    );

-- Ejercicio 3.2: Lista las empresas que han realizado transacciones 
-- por un amount superior a la media de todas las transacciones.

SELECT c.company_name AS Empresas
FROM company c
WHERE id IN (
	SELECT company_id
    FROM transaction
    WHERE amount > (
		SELECT AVG(amount)
        FROM transaction
        )
);

-- Ejercicio 3.3: Eliminarán del sistema las empresas que carecen de 
-- transacciones registradas, entrega el listado de estas empresas.

SELECT c.id, c.company_name
FROM company c
WHERE c.id NOT IN (
	SELECT t.company_id
    FROM transaction t
    WHERE t.company_id IS NOT NULL
    );

-- Ejercicio 4: Creación de credit_card, importación de datos y relaciónes entre tablas
-- crear tabla llamada "credit_card" 

CREATE TABLE credit_card (
	id VARCHAR (15) NOT NULL,
    iban VARCHAR (40),
    pan VARCHAR (20),
    pin VARCHAR (4),
    cvv VARCHAR (3),
    expiring_date VARCHAR (8),
    PRIMARY KEY (id)
);

-- verificar y comprobar antes de hacer la relación de las tablas
/* ============================================================
SELECT COUNT(*) AS Total_tj
FROM credit_card;

SELECT COUNT(DISTINCT t.credit_card_id) AS tj_sin_coincidencia
FROM transaction t
LEFT JOIN credit_card cc
	ON t.credit_card_id = cc.id
WHERE t.credit_card_id IS NOT NULL
	AND cc.id IS NULL;
  ============================================================ */

-- crear la clave foránea entre transaction y credit_card

ALTER TABLE transaction                        -- modificamos la estructura de la tabla transaction        
ADD CONSTRAINT fk_transaction_credit_card      -- añadimos una restricción a la tabla y le damos nombre a la relación
FOREIGN KEY (credit_card_id)                   -- indicamos que columna contiene la FK
REFERENCES credit_card(id);                    -- indicamos a que tabla y columna hace referencia

-- Ejercicio 5: Actualización del numero de cuenta bancaria de una tarjeta de crédito

-- actualizamos el dato
UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';

-- mostramos que el cambio se realizo
SELECT id, iban
FROM credit_card
WHERE id = 'CcU-2938';

-- Ejercicio 6: En la tabla "transaction" ingresa una nueva transacción:

-- primero verificamos si los datos existen
SELECT id
FROM company
WHERE id = 'b-9999';

SELECT id
FROM credit_card
WHERE id = 'CcU-9999';

SELECT *
FROM transaction
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';

-- PASO 1: Creo la empresa que no existe
INSERT INTO company (id, company_name)  -- Indico la tabla y las columnas
VALUES ('b-9999', 'Empresa b-9999');    -- Introduzco la empresa con su ID

-- PASO 2: Creo la tarjeta que no existe
INSERT INTO credit_card (id)            -- Indico la tabla y la columna
VALUES ('CcU-9999');                    -- Introduzco la tarjeta con su ID

-- PASO 3: Inserto la nueva transacción
INSERT INTO `transaction` (             -- Indico la tabla donde inserto la fila
    id,                                 -- Clave primaria de la transacción
    credit_card_id,                     -- Clave foránea de credit_card
    company_id,                         -- Clave foránea de company
    user_id,                            -- ID del usuario
    lat,                                -- Latitud
    longitude,                          -- Longitud
    amount,                             -- Importe
    declined                            -- Estado: 0 = no rechazada
)
VALUES (                                -- Introduzco los datos del enunciado
    '108B1D1D-5B23-A76C-55EF-C568E49A99DD',
    'CcU-9999',
    'b-9999',
    9999,
    829.999,
    -117.999,
    111.11,
    0
);

-- PASO 4: Compruebo que se ha insertado correctamente
SELECT *                                				-- Muestro todos los datos
FROM `transaction`                      				-- De la tabla transaction
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD'; 		-- Busco la nueva fila

-- Ejercicio 7: Eliminar la columna pan de la tabla credit_card

ALTER TABLE credit_card
DROP COLUMN pan;

-- verificamos que se ha eliminado
DESCRIBE credit_card;

-- EJERCICIO 8: Creacion del modelo en estrella
-- importacion y transformacion de datos mediante SQL

-- Creo una nueva base de datos sin modificar las anteriores

CREATE DATABASE IF NOT EXISTS transactions_sprint2;

-- Selecciono la base de datos con la que voy a trabajar

USE transactions_sprint2;

-- Compruebo que la base de datos se ha creado

SELECT DATABASE() AS Base_Datos_Actual;

-- Compruebo si MySQL permite importar archivos CSV locales mediante SQL
SHOW GLOBAL VARIABLES LIKE 'local_infile';

-- Habilito temporalmente la importación de archivos locales

SET GLOBAL local_infile = ON;
SHOW GLOBAL VARIABLES LIKE 'local_infile';

-- creo la tabla american_users

CREATE TABLE american_users (
    id INT PRIMARY KEY,
    name VARCHAR(30),
    surname VARCHAR(50),
    phone VARCHAR(30),
    email VARCHAR(100),
    birth_date DATE,
    country VARCHAR(30),
    city VARCHAR(50),
    postal_code VARCHAR(20),
    address VARCHAR(100),
    signup_date DATE,
    user_segment VARCHAR(50),
    income_band VARCHAR(30)
);

-- Importo los usuarios americanos desde el archivo CSV
-- Convierto las fechas directamente al formato DATE

LOAD DATA LOCAL INFILE 'C:/Users/Denys GDC/Desktop/ESTUDIOS/261109 Curso Especializacion Analisis de datos - ItAcademy/Sprint 2/american_users.csv'
INTO TABLE american_users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    id,
    name,
    surname,
    phone,
    email,
    @birth_date,
    country,
    city,
    postal_code,
    address,
    @signup_date,
    user_segment,
    income_band
)
SET
    birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y'),
    signup_date = STR_TO_DATE(@signup_date, '%Y-%m-%d');
    
SELECT COUNT(*) AS Total_Usuarios
FROM american_users;

-- Creo european_users copiando la estructura de american_users

CREATE TABLE european_users LIKE american_users;
DESCRIBE european_users;

LOAD DATA LOCAL INFILE "C:/Users/Denys GDC/Desktop/ESTUDIOS/261109 Curso Especializacion Analisis de datos - ItAcademy/Sprint 2/european_users.csv"
INTO TABLE european_users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    id,
    name,
    surname,
    phone,
    email,
    @birth_date,
    country,
    city,
    postal_code,
    address,
    @signup_date,
    user_segment,
    income_band
)
SET
    birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y'),
    signup_date = STR_TO_DATE(@signup_date, '%Y-%m-%d');
    
SELECT COUNT(*) AS Total_Usuarios_Europeos
FROM european_users;

-- Creo la tabla companies y defino los tipos de datos

CREATE TABLE companies (
    company_id VARCHAR(15) PRIMARY KEY,
    company_name VARCHAR(100),
    phone VARCHAR(30),
    email VARCHAR(100),
    country VARCHAR(50),
    website VARCHAR(150),
    merchant_category VARCHAR(50),
    merchant_price_position VARCHAR(30)
);

-- Importo los datos desde el archivo CSV

LOAD DATA LOCAL INFILE "C:/Users/Denys GDC/Desktop/ESTUDIOS/261109 Curso Especializacion Analisis de datos - ItAcademy/Sprint 2/companies.csv"
INTO TABLE companies
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Compruebo el total de empresas importadas

SELECT COUNT(*) AS Total_Empresas
FROM companies;

-- Creo la tabla credit_cards y defino los tipos de datos

CREATE TABLE IF NOT EXISTS credit_cards (
    id VARCHAR(15) PRIMARY KEY,
    user_id INT,
    iban VARCHAR(40),
    pan VARCHAR(25),
    pin VARCHAR(4),
    cvv VARCHAR(3),
    track1 VARCHAR(100),
    track2 VARCHAR(100),
    expiring_date VARCHAR(10),
    card_type VARCHAR(30),
    card_renewal_flag TINYINT
);

-- Importo las tarjetas desde el archivo CSV

LOAD DATA LOCAL INFILE "C:/Users/Denys GDC/Desktop/ESTUDIOS/261109 Curso Especializacion Analisis de datos - ItAcademy/Sprint 2/credit_cards.csv"
INTO TABLE credit_cards
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Compruebo los registros importados

SELECT COUNT(*) AS Total_Tarjetas
FROM credit_cards;

-- Creo la tabla transactions

CREATE TABLE transactions (
    id VARCHAR(36) PRIMARY KEY,
    card_id VARCHAR(15),
    business_id VARCHAR(15),
    `timestamp` DATETIME,
    amount DECIMAL(10,2),
    declined TINYINT,
    product_ids VARCHAR(100),
    user_id INT,
    lat DOUBLE,
    longitude DOUBLE,
    discount_amount DECIMAL(10,2),
    tax_amount DECIMAL(10,2),
    shipping_amount DECIMAL(10,2),
    channel VARCHAR(30),
    campaign_id VARCHAR(50),
    device_type VARCHAR(30),
    is_international TINYINT,
    decline_reason VARCHAR(100),
    distance_km DECIMAL(12,2)
);

-- Importo las transacciones desde el archivo CSV
-- Este archivo utiliza punto y coma como separador

LOAD DATA LOCAL INFILE "C:/Users/Denys GDC/Desktop/ESTUDIOS/261109 Curso Especializacion Analisis de datos - ItAcademy/Sprint 2/transactions.csv"
INTO TABLE transactions
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    id,
    card_id,
    business_id,
    `timestamp`,
    amount,
    declined,
    product_ids,
    user_id,
    lat,
    longitude,
    discount_amount,
    tax_amount,
    shipping_amount,
    channel,
    campaign_id,
    device_type,
    is_international,
    @decline_reason,
    distance_km
)
SET decline_reason = NULLIF(@decline_reason, '');

-- Compruebo los registros importados

SELECT COUNT(*) AS Total_Transacciones
FROM transactions;

-- Compruebo todos los registros importados

SELECT 'american_users' AS Tabla, COUNT(*) AS Total_Registros
FROM american_users
UNION ALL
SELECT 'european_users', COUNT(*)
FROM european_users
UNION ALL
SELECT 'companies', COUNT(*)
FROM companies
UNION ALL
SELECT 'credit_cards', COUNT(*)
FROM credit_cards
UNION ALL
SELECT 'transactions', COUNT(*)
FROM transactions;

-- Compruebo si hay identificadores duplicados en american_users

SELECT id, COUNT(*) AS Veces
FROM american_users
GROUP BY id
HAVING COUNT(*) > 1;

-- Compruebo si existen ID repetidos entre usuarios americanos y europeos

SELECT id
FROM american_users
WHERE id IN (
    SELECT id
    FROM european_users
);

-- Compruebo si hay valores nulos en las columnas que utilizaremos para relacionar tablas

-- Usuarios europeos
SELECT COUNT(*) - COUNT(id) AS ids_Nulos
FROM european_users;

-- Empresas
SELECT COUNT(*) - COUNT(company_id) AS ids_Nulos
FROM companies;

-- Tarjetas
SELECT COUNT(*) - COUNT(id) AS ids_Nulos,
       COUNT(*) - COUNT(user_id) AS usuarios_nulos
FROM credit_cards;

-- Transacciones
SELECT COUNT(*) - COUNT(id) AS ids_nulos,
       COUNT(*) - COUNT(card_id) AS tarjetas_nulas,
       COUNT(*) - COUNT(business_id) AS empresas_nulas,
       COUNT(*) - COUNT(user_id) AS usuarios_nulos
FROM transactions;

-- Compruebo que los identificadores no tengan valores NULL
-- para evitar problemas al relacionar las tablas.

SELECT COUNT(*) AS empresas_sin_coincidencia
FROM transactions t
LEFT JOIN companies c
    ON t.business_id = c.company_id
WHERE c.company_id IS NULL;

-- Compruebo si hay usuarios con el mismo ID en ambas tablas

SELECT id
FROM american_users
WHERE id IN (
    SELECT id
    FROM european_users
);

-- Creo la tabla users copiando la estructura de american_users
-- sin copiar sus registros

CREATE TABLE users LIKE american_users;  -- Crea users copiando su estructura y PK

-- Unifico los usuarios americanos y europeos en una sola tabla

INSERT INTO users               -- Introduce registros en users
SELECT * FROM american_users    -- Selecciona los usuarios americanos
UNION ALL						-- Añade los usuarios europeos sin eliminar filas
SELECT * FROM european_users;   -- Selecciona los usuarios europeos

-- Compruebo el número total de usuarios unificados

SELECT COUNT(*) AS Total_Usuarios
FROM users;

-- Compruebo que la tabla users conserva su clave primaria
-- Mantengo las tablas originales american_users y european_users
-- como respaldo y utilizo users para el modelo estrella.

DESCRIBE users;

-- Añado una columna para identificar el origen de los usuarios

ALTER TABLE users										-- Modifico la tabla users
ADD COLUMN region_usuarios VARCHAR (15);				-- creo la nueva columna

-- Identifico los usuarios americanos

UPDATE users											-- actualizo la tabla users
SET region_usuarios = 'Americano'						-- asigno su origen
WHERE id IN (SELECT id FROM american_users);			-- BUsco los ID americanos

-- Identifico los usuarios europeos

UPDATE users											-- Actualizo la tabla users
SET region_usuarios = 'Europeos'						-- asigno su origen
WHERE id IN (SELECT id FROM european_users);			-- BUsco los ID americanos

-- Compruebo el resultado

SELECT region_usuarios,
	COUNT(*) AS Total_usuarios
FROM users
GROUP BY region_usuarios;

-- Relaciono las transacciones con los usuarios

ALTER TABLE transactions                      -- Modifico la tabla transactions
ADD CONSTRAINT fk_transactions_users          -- Creo la FK y le pongo un nombre
FOREIGN KEY (user_id)                         -- Indico la columna que será la FK
REFERENCES users(id);                         -- Indico la tabla y la PK con la que se relaciona

-- Relaciono las transacciones con las empresas

ALTER TABLE transactions                      -- Modifico la tabla transactions
ADD CONSTRAINT fk_transactions_companies      -- Creo la FK y le pongo un nombre
FOREIGN KEY (business_id)                     -- Indico la columna que será la FK
REFERENCES companies(company_id);             -- Indico la tabla y la PK con la que se relaciona

-- Relaciono las transacciones con las tarjetas

ALTER TABLE transactions                      -- Modifico la tabla transactions
ADD CONSTRAINT fk_transactions_cards          -- Creo la FK y le pongo un nombre
FOREIGN KEY (card_id)                          -- Indico la columna que será la FK
REFERENCES credit_cards(id);                  -- Indico la tabla y la PK con la que se relaciona

-- Compruebo que las claves foráneas se han creado correctamente

SELECT
    TABLE_NAME,                               -- Nombre de la tabla que tiene la FK
    COLUMN_NAME,                              -- Columna que contiene la FK
    REFERENCED_TABLE_NAME,                    -- Tabla con la que se relaciona
    REFERENCED_COLUMN_NAME                    -- Columna a la que hace referencia
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE     -- Consulto la información de las claves
WHERE TABLE_SCHEMA = 'transactions_sprint2'  -- Busco en mi base de datos
  AND REFERENCED_TABLE_NAME IS NOT NULL;      -- Muestro solamente las claves foráneas
  
-- Desactivo la importación de archivos locales por seguridad
SET GLOBAL local_infile = OFF;

-- Compruebo que la opción está desactivada
SHOW GLOBAL VARIABLES LIKE 'local_infile';
-- Y quito el OPT_LOCAL_INFILE=1 en Edit Connection → Advanced → Others.

-- EJERCICIO 9: Muestro los usuarios con más de 80 transacciones

SELECT u.id AS Users            -- Muestro el ID del usuario
FROM users u					-- De la tabla de usuarios
WHERE u.id IN (					-- Busco usuarios que cumplen la subconsulta...
	SELECT t.user_id			-- Selecciono ID del usuario en transactions
    FROM transactions t			-- De la tabla de transacciones
    GROUP BY t.user_id			-- Agrupo las transacciones por usuario
    HAVING COUNT(*) > 80		-- Filtro los usuarios con mas de 80 transacciones
);


-- EJERCICIO 10: Media de amount por IBAN de Donec Ltd.

SELECT
    cc.iban,                                    -- Muestro el IBAN
    ROUND(AVG(t.amount), 2) AS Media_amount 	-- Calculo la media con 2 decimales
FROM transactions t                        		-- Tabla de transacciones
INNER JOIN companies c                     		-- Relaciono las empresas
    ON t.business_id = c.company_id        		-- Mediante el ID de empresa
INNER JOIN credit_cards cc                 		-- Relaciono las tarjetas
    ON t.card_id = cc.id                   		-- Mediante el ID de tarjeta
WHERE c.company_name = 'Donec Ltd'         		-- Filtro la empresa solicitada
GROUP BY cc.iban;                          		-- Calculo la media por IBAN


-- ============================================================
-- NIVEL 2: CONSULTAS SQL y análisis de datos
-- ============================================================
   
USE transactions_sprint2;
SELECT * FROM transactions;

-- EJERCICIO 1: Los cinco días con mayores ingresos

SELECT DATE(t.`timestamp`) AS Fecha,  			-- extraigo solo la fecha
	ROUND(SUM(t.amount), 2) AS Total_ventas 	-- sumo los importes por dia
FROM transactions t 							-- de la tabla de transacciones
WHERE t.declined = 0							-- solo las operaciones efectuadas
GROUP BY Fecha									-- agrupo las ventas por dia
ORDER BY Total_ventas DESC						-- ordeno de mayor a menor
LIMIT 5;										-- muestro los 5 primeros dias

-- EJERCICIO 2: Transacciones entre 350 eur y 400 eur en fechas concretas

SELECT c.company_name AS Empresa,			-- selecciono las columnas que me piden mostrar
	c.phone AS Telefono,
    c.country AS Pais,
    DATE(t.`timestamp`) AS Fecha,
    t.amount AS Importe
FROM companies c							-- de la tabla de empresas
INNER JOIN transactions t					-- relaciono las transacciones
	ON c.company_id = t.business_id			-- mediante el ID de empresa
WHERE t.amount BETWEEN 350 AND 400  		-- importes entre 350 y 400 eur
	AND DATE(t.`timestamp`) IN (			-- filtro las 3 fechas
		'2015-04-29',
        '2018-07-20',
        '2024-03-13'
	)
ORDER BY t.amount DESC;						-- ordeno de mayor a menor

-- EJERCICIO 3: Clasifico las empresas según sus transacciones

SELECT c.company_name AS Empresa,				-- muestro e lnombre de la empresa
	COUNT(t.id) AS Total_transacciones,			-- cuanto sus transacciones
    CASE										-- creo una clasificacion
		WHEN COUNT(t.id) >= 400 THEN '400 o mas'
        ELSE 'Menos de 400'						-- si no cumple la condicion
	END AS Clasificacion						-- nombre de la nueva columna
FROM companies c								-- de la tabla de empresas
LEFT JOIN transactions t 						-- incluyo todas las empresas
	ON c.company_id = t.business_id 			-- relaciono mediante la FK
GROUP BY c.company_id, c.company_name 			-- agrupo por empresa
ORDER BY Total_transacciones DESC; 				-- ordeno de mayor a menor

-- EJERCICIO 4: Elimino la transacción indicada

-- compruebo que la transaccion existe
SELECT * FROM transactions
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- inicio una transaccion para poder deshacer el cambio en caso de error
-- nota: START TRANSACTION da la posibilidad de recuperar los datos si todavía no has confirmado la operación
START TRANSACTION;	  -- permite realizar cambios y deshacerlos con ROLLBACK antes de confirmarlos con COMMIT

DELETE FROM transactions								-- elimino el registro
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';		-- filtro por su id

-- compruebo que ya no aparece
SELECT * FROM transactions
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- confirmo la eliminacion solo si todo es correcto, guardando el cambio con COMMIT
COMMIT;

-- EJERCICIO 5: Crear una vista para Marketing

CREATE VIEW VistaMarketing AS 				-- nombre de la vista
SELECT c.company_name AS Empresa,
	c.phone AS Telefono,
    c.country AS Pais,
    ROUND(AVG(t.amount), 2) AS Media_compra
FROM companies c
INNER JOIN transactions t					-- relaciono las transacciones
	ON c.company_id = t.business_id			-- mediante el id de empresa
WHERE t.declined = 0						-- solo compras no rechazadas
GROUP BY c.company_id,						-- agrupo por empresa
	c.company_name,
    c.phone,
    c.country;
    
-- consulto la vista creada
SELECT * FROM VistaMarketing				-- muestro todos los campos 
ORDER BY Media_compra DESC;					-- ordeno de mayor a menor

-- ============================================================
-- NIVEL 3: Análisis avanzado y relaciones entre tablas
-- ============================================================
   
-- EJERCICIO 1: Clasifico las tarjetas según sus 3 últimas transacciones

CREATE TABLE estado_tarjetas AS             	-- creo una tabla nueva para guardar los estados
SELECT 
	card_id,                             		-- muestro el identificador de cada tarjeta
	CASE
		WHEN COUNT(*) < 3 THEN 'Sin datos suficientes' -- menos de 3 operaciones
		WHEN SUM(declined) = 3 THEN 'Inactiva'         -- 1 + 1 + 1 = las 3 rechazadas
    ELSE 'Activa'                               -- por lo menos una aceptada
END AS Estado                          			-- nombre de la columna calculada
FROM (                                      	-- creo una subconsulta para ordenar las operaciones
    SELECT card_id,                         	-- identifico a qué tarjeta pertenece
        declined,                           	-- compruebo si fue rechazada (1) o no (0)
        ROW_NUMBER() OVER (                 	-- asigno un número a cada operación
            PARTITION BY card_id            	-- reinicio la numeración por cada tarjeta
            ORDER BY `timestamp` DESC, id DESC  -- ordeno desde la operación más reciente
        ) AS numero                         	-- nombre de la columna con la posición
    FROM transactions                       	-- obtengo los datos de las transacciones
) t1                                        	-- le pongo alias de la subconsulta
WHERE numero <= 3                           	-- me quedo solo con las 3 últimas operaciones
GROUP BY card_id;                           	-- agrupo las operaciones de cada tarjeta

-- Compruebo si existen tarjetas con menos de 3 transacciones

SELECT
    cc.id AS Tarjeta,                       -- id de la tarjeta
    COUNT(t.id) AS Total_Transacciones      -- cuento sus operaciones
FROM credit_cards cc                        -- tabla de tarjetas
LEFT JOIN transactions t                    -- incluyo todas las tarjetas
    ON cc.id = t.card_id                    -- relaciono mediante el ID
GROUP BY cc.id                              -- agrupo por tarjeta
HAVING COUNT(t.id) < 3;                     -- busco tarjetas con menos de 3

-- Compruebo cuántas tarjetas están activas

SELECT
    COUNT(*) AS Tarjetas_Activas            -- cuento las tarjetas clasificadas como activas
FROM estado_tarjetas                        -- consulto la tabla que he creado
WHERE Estado = 'Activa';                    -- filtro únicamente las tarjetas activas

-- Compruebo cuántas tarjetas hay de cada estado

SELECT
    Estado,                                 -- muestro el estado de las tarjetas
    COUNT(*) AS Total_Tarjetas              -- cuento cuántas hay de cada estado
FROM estado_tarjetas                        -- consulto la nueva tabla
GROUP BY Estado;                            -- agrupo las tarjetas por su estado


-- EJERCICIO 2: Relacionar productos y transacciones

SHOW TABLES;                          -- compruebo las tablas existentes

-- verificamos como vienen separados los productos del atributo product_ids
SELECT
    id,                               -- id de la transacción
    product_ids                       -- productos de la operación
FROM transactions                     -- tabla de transacciones
WHERE product_ids IS NOT NULL         -- excluyo los valores nulos
LIMIT 10;                             -- muestro 10 ejemplos

-- creo la entidad de los productos e importo el csv
CREATE TABLE products (
	id INT PRIMARY KEY,
    product_name VARCHAR (100),
    price DECIMAL (10, 2),
    colour VARCHAR (10),
    weight DECIMAL (5,2),
    warehouse_id VARCHAR (15),
    category VARCHAR (50),
    brand VARCHAR (50),
    cost DECIMAL (10,2),
    launch_date DATE
);
    
-- Compruebo si MySQL permite importar archivos CSV locales mediante SQL
SHOW GLOBAL VARIABLES LIKE 'local_infile';

-- Habilito temporalmente la importación de archivos locales

SET GLOBAL local_infile = ON;
SHOW GLOBAL VARIABLES LIKE 'local_infile';
-- OPT_LOCAL_INFILE=1 

-- Importo los productos desde el CSV
-- Como MySQL Workbench bloqueaba la importación local, he ejecutado la consulta desde MySQL Command Line mediante PowerShell.
LOAD DATA LOCAL INFILE 'C:/Users/Denys GDC/Desktop/ESTUDIOS/261109 Curso Especializacion Analisis de datos - ItAcademy/Sprint 2/N1-Ex.8__products.csv'
INTO TABLE products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    id,
    product_name,
    @price,
    colour,
    weight,
    warehouse_id,
    category,
    brand,
    @cost,
    launch_date
)
SET
    price = REPLACE(@price, '$', ''),
    cost = REPLACE(@cost, '$', '');

SELECT COUNT(*) AS Total_Productos       -- Compruebo los productos importados
FROM products;

SET GLOBAL local_infile = OFF;           -- Desactivo la importación local
SHOW GLOBAL VARIABLES LIKE 'local_infile'; -- Compruebo que esté OFF
-- Y quito el OPT_LOCAL_INFILE=1 en Edit Connection → Advanced → Others.

-- creo la tabla intermedia
CREATE TABLE transaction_products AS         -- creo una tabla intermedia
SELECT
    t.id AS transaction_id,                  -- id de la transacción
    p.id AS product_id                       -- id del producto
FROM transactions t                          -- tabla de transacciones
INNER JOIN products p                        -- relaciono los productos
    ON FIND_IN_SET(                          -- busco el producto dentro de la lista
        p.id,
        REPLACE(t.product_ids, ' ', '')       -- quito los espacios entre los ID
    ) > 0;                                    -- solo los productos encontrados

-- compruebo las relaciones creadas
SELECT *                                    -- muestro las relaciones
FROM transaction_products                   -- tabla que he creado
LIMIT 20;                                   -- primeros 20 registros

-- creo la clave primaria compuesta
ALTER TABLE transaction_products                  -- Modifico la tabla intermedia
ADD CONSTRAINT pk_transaction_products            -- Nombre de la restricción
PRIMARY KEY (transaction_id, product_id);         -- Evito combinaciones repetidas

-- relaciono la tabla con transactions
ALTER TABLE transaction_products                  -- Modifico la tabla intermedia
ADD CONSTRAINT fk_tp_transactions                 -- Nombre de la clave foránea
FOREIGN KEY (transaction_id)                      -- Columna de la tabla intermedia
REFERENCES transactions(id);                      -- Referencia a la PK de transactions

-- relaciono la tabla con products
ALTER TABLE transaction_products                  -- Modifico la tabla intermedia
ADD CONSTRAINT fk_tp_products                     -- Nombre de la clave foránea
FOREIGN KEY (product_id)                          -- Columna de la tabla intermedia
REFERENCES products(id);                          -- Referencia a la PK de products

-- Cuento cuántas veces se ha vendido cada producto

SELECT
    p.id AS ID_Producto,                    -- identificador del producto
    p.product_name AS Producto,             -- nombre del producto
    COUNT(t.id) AS Veces_vendido            -- cuento sus ventas aceptadas
FROM products p                             -- tabla de productos
LEFT JOIN transaction_products tp           -- relaciono los productos
    ON p.id = tp.product_id                 -- por su identificador
LEFT JOIN transactions t                    -- relaciono las transacciones
    ON tp.transaction_id = t.id             -- mediante el ID de transacción
    AND t.declined = 0                      -- solo ventas no rechazadas
GROUP BY p.id, p.product_name               -- agrupo por producto
ORDER BY Veces_vendido DESC;                -- ordeno de mayor a menor












