CREATE DATABASE sgd;
DROP DATABASE sgd;
USE sgd;

CREATE TABLE addresses (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
`name` VARCHAR(50) NOT NULL
);

CREATE TABLE categories (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
`name` VARCHAR(10) NOT NULL
);

CREATE TABLE offices (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
workspace_capacity INT NOT NULL, 
website VARCHAR(50),
address_id INT NOT NULL,
CONSTRAINT `fk_address_id`
FOREIGN KEY (address_id)
REFERENCES addresses (id)
);

CREATE TABLE employees (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
first_name VARCHAR(30) NOT NULL,
last_name VARCHAR(30) NOT NULL,
age INT NOT NULL,
salary DECIMAL(10,2) NOT NULL,
job_title VARCHAR(20) NOT NULL,
happiness_level CHAR(1) NOT NULL
);

CREATE TABLE teams (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
`name` VARCHAR(40) NOT NULL,
office_id INT NOT NULL, 
leader_id INT NOT NULL UNIQUE,
CONSTRAINT `fk_office_id`
FOREIGN KEY (office_id)
REFERENCES offices (id),
CONSTRAINT `fk_leader_id`
FOREIGN KEY (leader_id)
REFERENCES employees (id) 
);

CREATE TABLE games (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
`name` VARCHAR(50) NOT NULL UNIQUE,
`description` TEXT,
rating FLOAT NOT NULL DEFAULT 5.5,
budget DECIMAL(10,2) NOT NULL,
release_date DATE,
team_id INT NOT NULL,
CONSTRAINT `fk_team_id`
FOREIGN KEY (team_id)
REFERENCES teams (id) 
);

CREATE TABLE games_categories (
game_id INT NOT NULL,
category_id INT NOT NULL,
CONSTRAINT `pk_games_categories`
PRIMARY KEY (game_id, category_id), 
CONSTRAINT `fk_game_id`
FOREIGN KEY (game_id)
REFERENCES games (id),
CONSTRAINT `fk_category_id`
FOREIGN KEY (category_id)
REFERENCES categories (id)
);

INSERT INTO games (`name`, rating, budget, team_id) 
SELECT REVERSE(LOWER(SUBSTRING(t.`name`,2))), t.id, t.leader_id * 1000, t.id 
FROM teams AS t
WHERE t.id BETWEEN 1 AND 9; 

UPDATE employees
SET salary = salary + 1000
WHERE age < 40 
AND (SELECT COUNT(*) FROM teams WHERE leader_id = id) > 0  
AND salary <= 5000;

DELETE FROM games AS g
WHERE release_date IS NULL 
AND (SELECT COUNT(*) FROM  games_categories AS gc WHERE g.id = gc.game_id) = 0;

SELECT first_name, last_name, age, salary, happiness_level FROM employees
ORDER BY salary, id;

SELECT t.`name` AS team_name, a.`name` AS address_name, CHAR_LENGTH(a.`name`) AS count_of_characters FROM teams AS t
JOIN offices AS o ON t.office_id = o.id
JOIN addresses AS a ON a.id = o.address_id
WHERE website IS NOT NULL
ORDER BY team_name, address_name;

SELECT c.`name`, COUNT(*) AS games_count, ROUND(AVG(budget),2) AS avg_budget, MAX(rating) AS max_rating FROM categories AS c
JOIN games_categories AS gc ON c.id = gc.category_id
JOIN games AS g ON gc.game_id = g.id
GROUP BY c.id
HAVING max_rating >= 9.5
ORDER BY games_count DESC, c.`name`;

SELECT g.`name`, release_date, CONCAT(LEFT(`description`, 10), '...') AS summary, 
CASE 
WHEN MONTH(release_date) LIKE 02 THEN 'Q1'
WHEN MONTH(release_date) IN (04, 06) THEN 'Q2'
WHEN MONTH(release_date) LIKE 08 THEN 'Q3'
WHEN MONTH(release_date) IN (10, 12) THEN 'Q4'
END
AS `quarter`, t.`name` AS team_name FROM games AS g
JOIN teams AS t ON t.id = team_id
WHERE YEAR(release_date) = 2022 AND MONTH(release_date) % 2 = 0 AND RIGHT(g.`name`, 1) = 2
ORDER BY `quarter`;

SELECT g.`name`,
CASE
WHEN budget < 50000 THEN 'Normal budget'
ELSE 'Insufficient budget'
END
AS budget_level, t.`name` AS team_name, a.`name` AS address_name FROM games AS g
JOIN teams AS t ON t.id = g.team_id
JOIN offices AS o ON t.office_id = o.id
JOIN addresses AS a ON a.id = o.address_id
WHERE release_date IS NULL 
AND (SELECT COUNT(*) FROM  games_categories AS gc WHERE g.id = gc.game_id) = 0
ORDER BY g.`name`;

DELIMITER $$$
CREATE FUNCTION udf_game_info_by_name (game_name VARCHAR (20)) 
RETURNS TEXT
DETERMINISTIC 
BEGIN 
RETURN (SELECT CONCAT('The ', g.`name`, ' is developed by a ', t.`name`, ' in an office with an address ', a.`name`) AS L FROM games AS g 
JOIN teams AS t ON t.id = g.team_id
JOIN offices AS o ON t.office_id = o.id
JOIN addresses AS a ON a.id = o.address_id
WHERE g.`name` LIKE game_name);
END
$$$
DELIMITER ;

SELECT CONCAT('The ', g.`name`, ' is developed by a ', t.`name`, ' in an office with an address ', a.`name`) AS L FROM games AS g 
JOIN teams AS t ON t.id = g.team_id
JOIN offices AS o ON t.office_id = o.id
JOIN addresses AS a ON a.id = o.address_id
WHERE g.`name` LIKE 'Bitwolf';

DELIMITER $$$
CREATE PROCEDURE udp_update_budget (min_game_rating FLOAT)
BEGIN 
UPDATE games AS g
SET budget = budget + 100000, release_date = DATE_ADD(release_date, INTERVAL 1 YEAR)
WHERE (SELECT COUNT(*) FROM  games_categories AS gc WHERE g.id = gc.game_id) = 0 
AND rating > min_game_rating
AND release_date IS NOT NULL;
END
$$$
DELIMITER ;

UPDATE games AS g
SET budget = budget + 100000, release_date = DATE_ADD(release_date, INTERVAL 1 YEAR)
WHERE (SELECT COUNT(*) FROM  games_categories AS gc WHERE g.id = gc.game_id) = 0 
AND rating > 8
AND release_date IS NOT NULL;

SELECT release_date, DATE_ADD(release_date, INTERVAL 1 YEAR) AS WE FROM games;

