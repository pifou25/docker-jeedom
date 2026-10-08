-- same user name and database name 
FLUSH PRIVILEGES;
CREATE USER IF NOT EXISTS 'npm'@'%' IDENTIFIED BY 'npm';
CREATE DATABASE IF NOT EXISTS `npm`;
GRANT ALL PRIVILEGES ON `npm`.* TO 'npm'@'%';
-- GRANT ALL PRIVILEGES ON `npm`.* TO 'npm'@'localhost';
