CREATE DATABASE instd;
DROP DATABASE instd;
USE instd;

CREATE TABLE photos (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
`description` TEXT NOT NULL,
`date` DATETIME NOT NULL,
views INT NOT NULL DEFAULT 0);

CREATE TABLE comments (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
`comment` VARCHAR(255) NOT NULL,
`date` DATETIME NOT NULL,
photo_id INT NOT NULL,
CONSTRAINT `fk_photo_id`
FOREIGN KEY (photo_id )
REFERENCES photos (id)
);

CREATE TABLE users (
id INT NOT NULL PRIMARY KEY, 
username VARCHAR(30) NOT NULL UNIQUE,
`password` VARCHAR(30) NOT NULL,
email VARCHAR(50) NOT NULL,
gender CHAR(1) NOT NULL,
age INT NOT NULL,
job_title VARCHAR(40) NOT NULL,
ip VARCHAR(30) NOT NULL
);

CREATE TABLE users_photos (
user_id INT NOT NULL,
photo_id INT NOT NULL,
CONSTRAINT `fk_user_id`
FOREIGN KEY (user_id)
REFERENCES users (id),
CONSTRAINT `fk_photo1_id`
FOREIGN KEY (photo_id)
REFERENCES photos (id)
);

CREATE TABLE likes (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
photo_id INT,
user_id INT,
CONSTRAINT `fk_photo2_id`
FOREIGN KEY (photo_id)
REFERENCES photos (id),
CONSTRAINT `fk_user1_id`
FOREIGN KEY (user_id)
REFERENCES users (id)
);

CREATE TABLE addresses (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
address VARCHAR(30) NOT NULL,
town VARCHAR(30) NOT NULL,
country VARCHAR(30) NOT NULL,
user_id INT NOT NULL, 
CONSTRAINT `fk_user2_id`
FOREIGN KEY (user_id)
REFERENCES users (id)
);

INSERT INTO addresses (address, town, country, user_id)
SELECT username, `password`, ip, age
FROM users 
WHERE gender LIKE 'M'; 

UPDATE addresses 
SET country = (CASE 
WHEN country LIKE 'B%' THEN 'Blocked'
WHEN country LIKE 'T%' THEN 'Test'
WHEN country LIKE 'P%' THEN 'In Progress'
ELSE country 
END);

DELETE FROM addresses WHERE id % 3 = 0; 

SELECT username, gender, age FROM users
ORDER BY age DESC, username;

SELECT p.id, p.`date` AS date_and_time, p.`description`, COUNT(c.id) AS commentsCount FROM photos AS p
JOIN comments AS c ON p.id = c.photo_id
GROUP BY p.id
ORDER BY commentsCount DESC, p.id
LIMIT 5;

SELECT CONCAT(u.id, ' ', u.username) AS id_username, u.email FROM users AS u
JOIN users_photos AS up ON u.id = up.user_id
JOIN photos AS p ON up.photo_id = p.id
WHERE u.id = p.id
ORDER BY u.id;

SELECT p.id AS photo_id, COUNT(DISTINCT l.id) AS likes_count, COUNT(DISTINCT c.id) AS comments_count FROM photos AS p
LEFT JOIN likes AS l ON  p.id = l.photo_id
LEFT JOIN comments AS c ON p.id = c.photo_id
GROUP BY p.id 
ORDER BY likes_count DESC, comments_count DESC, p.id;

SELECT CONCAT(LEFT(`description`, 30), '...') AS summary,`date` FROM photos
WHERE DAY(`date`) = 10
ORDER BY `date` DESC;

DELIMITER $$$
CREATE FUNCTION udf_users_photos_count (username1 VARCHAR(30))
RETURNS INT
DETERMINISTIC 
BEGIN 
RETURN (SELECT COUNT(*) FROM photos AS p 
JOIN users_photos AS up ON p.id = up.photo_id
JOIN users AS u ON u.id = up.user_id
WHERE u.username LIKE username1);
END
$$$
DELIMITER ;

SELECT COUNT(*) FROM photos AS p 
JOIN users_photos AS up ON p.id = up.photo_id
JOIN users AS u ON u.id = up.user_id
WHERE u.username LIKE 'ssantryd';

DELIMITER $$$
CREATE PROCEDURE udp_modify_user (address VARCHAR(30), town VARCHAR(30))
BEGIN 
IF ((SELECT a.address FROM addresses AS a WHERE a.address LIKE address) IS NOT NULL)
THEN UPDATE users AS u
JOIN addresses AS aa ON u.id = aa.user_id
SET u.age = u.age + 10
WHERE aa.address LIKE address AND aa.town LIKE town;
END IF;
END
$$$
DELIMITER ;

CALL udp_modify_user ('97 Valley Edge Parkway', 'Divinópolis');
SELECT u.username, u.email,u.gender,u.age,u.job_title FROM users AS u
WHERE u.username = 'eblagden21';

