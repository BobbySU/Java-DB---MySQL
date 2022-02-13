CREATE DATABASE online_store;
DROP DATABASE online_store;
USE online_store;

CREATE TABLE brands (
id INT
NOT NULL PRIMARY KEY AUTO_INCREMENT, 
`name` VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE categories (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
`name` VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE reviews (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
content TEXT,
rating DECIMAL(10,2) NOT NULL,
picture_url VARCHAR(80) NOT NULL,
published_at DATETIME NOT NULL
);

CREATE TABLE products (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
`name` VARCHAR(40) NOT NULL,
price DECIMAL(19,2) NOT NULL,
quantity_in_stock INT,
`description` TEXT, 
brand_id INT NOT NULL,
category_id INT NOT NULL,
review_id INT,
CONSTRAINT `fk_brand_id`
FOREIGN KEY (brand_id)
REFERENCES brands (id),
CONSTRAINT `fk_category_id`
FOREIGN KEY (category_id)
REFERENCES categories (id),
CONSTRAINT `fk_review_id`
FOREIGN KEY (review_id)
REFERENCES reviews (id)
);

CREATE TABLE customers (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
first_name VARCHAR(20) NOT NULL,
last_name VARCHAR(20) NOT NULL,
phone VARCHAR(30) NOT NULL UNIQUE,
address VARCHAR(60) NOT NULL,
discount_card BIT NOT NULL DEFAULT FALSE
);

CREATE TABLE orders (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
order_datetime DATETIME NOT NULL,
customer_id INT NOT NULL,
CONSTRAINT `fk_customer_id`
FOREIGN KEY (customer_id)
REFERENCES customers (id)
);

CREATE TABLE orders_products (
order_id INT,
product_id INT,
CONSTRAINT `fk_order_id`
FOREIGN KEY (order_id)
REFERENCES orders (id),
CONSTRAINT `fk_product_id`
FOREIGN KEY (product_id)
REFERENCES products (id)
);

INSERT INTO reviews (content, picture_url, published_at, rating) 
SELECT LEFT(`description`,15), REVERSE(`name`), '2010-10-10 00:00:00', price/8
FROM products AS p
WHERE p.id >= 5; 

UPDATE products 
SET quantity_in_stock = quantity_in_stock - 5
WHERE quantity_in_stock BETWEEN 60 AND 70;

SELECT * FROM products 
WHERE quantity_in_stock BETWEEN 60 AND 70;

DELETE FROM customers AS c
WHERE (SELECT COUNT(*) FROM  orders AS o WHERE c.id = o.customer_id) = 0;

SELECT * FROM categories
ORDER BY `name` DESC;

SELECT id, brand_id, `name`, quantity_in_stock FROM products
WHERE price > 1000 AND quantity_in_stock < 30
ORDER BY quantity_in_stock, id;

SELECT id, content, rating, picture_url, published_at FROM reviews
WHERE content LIKE 'My%' AND CHAR_LENGTH(content) > 61
ORDER BY rating DESC;

SELECT CONCAT(first_name, ' ', last_name) AS full_name, address, o.order_datetime AS order_date FROM customers AS c
JOIN orders AS o ON o.customer_id = c.id
WHERE YEAR(o.order_datetime) <= 2018
ORDER BY full_name DESC;

SELECT COUNT(quantity_in_stock) AS items_count, c.`name`, SUM(quantity_in_stock) AS total_quantity FROM categories AS c
JOIN products AS p ON c.id = p.category_id
GROUP BY c.`name`
ORDER BY items_count DESC, total_quantity
LIMIT 5;

DELIMITER $$$
CREATE FUNCTION udf_customer_products_count (`name` VARCHAR(30)) 
RETURNS INT
DETERMINISTIC 
BEGIN 
RETURN (SELECT COUNT(op.product_id) AS total_products FROM customers c
JOIN orders AS o ON o.customer_id = c.id
JOIN orders_products AS op ON o.id = op.order_id
GROUP BY c.first_name
HAVING c.first_name LIKE `name`);
END
$$$
DELIMITER ;

SELECT COUNT(op.product_id) AS total_products FROM customers c
JOIN orders AS o ON o.customer_id = c.id
JOIN orders_products AS op ON o.id = op.order_id
GROUP BY c.first_name
HAVING c.first_name LIKE 'Brian';

SELECT udf_customer_products_count ('Brian');

DELIMITER $$$
CREATE PROCEDURE udp_reduce_price (category_name VARCHAR(50))
BEGIN 
UPDATE products AS p
SET price = price - (price * 0.3)
WHERE (SELECT r.rating FROM reviews AS r WHERE r.id = p.review_id) < 4 
AND (SELECT c.`name` FROM categories AS c WHERE c.id = p.category_id) LIKE category_name;
END
$$$
DELIMITER ;

SET sql_safe_updates=0;

UPDATE products AS p
SET price = price - (price * 0.3)
WHERE (SELECT r.rating FROM reviews AS r WHERE r.id = p.review_id) < 4 
AND (SELECT c.`name` FROM categories AS c WHERE c.id = p.category_id) LIKE 'Phones and tablets';

SELECT * FROM products AS p
WHERE (SELECT r.rating FROM reviews AS r WHERE r.id = p.review_id) < 4 
AND (SELECT c.`name` FROM categories AS c WHERE c.id = p.category_id) LIKE 'Phones and tablets';






