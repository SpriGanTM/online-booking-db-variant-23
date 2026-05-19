-- =====================================================
-- ВАРИАНТ 23
-- Система онлайн-записи в велоремонт
-- =====================================================

DROP DATABASE IF EXISTS online_bike_repair_variant23;

CREATE DATABASE online_bike_repair_variant23
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE online_bike_repair_variant23;

-- =====================================================
-- ТАБЛИЦА КЛИЕНТОВ
-- =====================================================

CREATE TABLE clients (
    client_id INT AUTO_INCREMENT PRIMARY KEY,

    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,

    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE
);

-- =====================================================
-- ТАБЛИЦА ВЕЛОСИПЕДОВ
-- =====================================================

CREATE TABLE bicycles (
    bicycle_id INT AUTO_INCREMENT PRIMARY KEY,

    client_id INT NOT NULL,

    brand VARCHAR(50) NOT NULL,
    frame_type VARCHAR(50) NOT NULL,

    wheel_size INT NOT NULL
        CHECK (wheel_size BETWEEN 20 AND 29),

    brake_type ENUM(
        'ободные',
        'дисковые',
        'гидравлические'
    ) NOT NULL,

    FOREIGN KEY (client_id)
        REFERENCES clients(client_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- =====================================================
-- ТАБЛИЦА МАСТЕРОВ
-- =====================================================

CREATE TABLE masters (
    master_id INT AUTO_INCREMENT PRIMARY KEY,

    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,

    experience_years INT NOT NULL
        CHECK (experience_years >= 0),

    priority_level INT NOT NULL
        CHECK (priority_level BETWEEN 1 AND 5)
);

-- =====================================================
-- ТАБЛИЦА УСЛУГ
-- =====================================================

CREATE TABLE services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,

    service_name VARCHAR(100) NOT NULL UNIQUE,

    repair_type ENUM(
        'простая',
        'сложная'
    ) NOT NULL,

    price DECIMAL(10,2) NOT NULL
        CHECK (price > 0),

    duration_minutes INT NOT NULL
        CHECK (duration_minutes BETWEEN 15 AND 300)
);

-- =====================================================
-- ТАБЛИЦА ЗАПЧАСТЕЙ
-- =====================================================

CREATE TABLE spare_parts (
    part_id INT AUTO_INCREMENT PRIMARY KEY,

    part_name VARCHAR(100) NOT NULL UNIQUE,

    quantity_in_stock INT NOT NULL
        CHECK (quantity_in_stock >= 0),

    price DECIMAL(10,2) NOT NULL
        CHECK (price > 0)
);

-- =====================================================
-- ТАБЛИЦА АНАЛОГОВ ЗАПЧАСТЕЙ
-- =====================================================

CREATE TABLE part_analogs (
    analog_id INT AUTO_INCREMENT PRIMARY KEY,

    original_part_id INT NOT NULL,
    analog_part_id INT NOT NULL,

    FOREIGN KEY (original_part_id)
        REFERENCES spare_parts(part_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (analog_part_id)
        REFERENCES spare_parts(part_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- =====================================================
-- ТАБЛИЦА РЕМОНТОВ
-- =====================================================

CREATE TABLE repairs (
    repair_id INT AUTO_INCREMENT PRIMARY KEY,

    bicycle_id INT NOT NULL,
    master_id INT NOT NULL,
    service_id INT NOT NULL,

    repair_datetime DATETIME NOT NULL,

    completion_datetime DATETIME,

    status ENUM(
        'запланирован',
        'в работе',
        'завершён',
        'отменён'
    ) DEFAULT 'запланирован',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (bicycle_id)
        REFERENCES bicycles(bicycle_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    FOREIGN KEY (master_id)
        REFERENCES masters(master_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    FOREIGN KEY (service_id)
        REFERENCES services(service_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    UNIQUE KEY unique_master_time (
        master_id,
        repair_datetime
    )
);

-- =====================================================
-- ИНДЕКСЫ
-- =====================================================

CREATE INDEX idx_repairs_datetime
ON repairs(repair_datetime);

CREATE INDEX idx_repairs_master
ON repairs(master_id);

CREATE INDEX idx_services_type
ON services(repair_type);

-- =====================================================
-- ТРИГГЕР:
-- сложный ремонт только мастеру > 2 лет опыта
-- =====================================================

DELIMITER $$

CREATE TRIGGER check_master_experience
BEFORE INSERT ON repairs
FOR EACH ROW
BEGIN

    DECLARE exp_years INT;
    DECLARE repair_type_value VARCHAR(20);

    SELECT experience_years
    INTO exp_years
    FROM masters
    WHERE master_id = NEW.master_id;

    SELECT repair_type
    INTO repair_type_value
    FROM services
    WHERE service_id = NEW.service_id;

    IF repair_type_value = 'сложная'
       AND exp_years <= 2 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Мастер не имеет достаточного опыта';

    END IF;

END$$

DELIMITER ;

-- =====================================================
-- ТЕСТОВЫЕ ДАННЫЕ
-- =====================================================

INSERT INTO clients
(last_name, first_name, phone, email)
VALUES
('Иванов', 'Иван',
 '+79990001111',
 'ivanov@mail.ru'),

('Петров', 'Алексей',
 '+79990002222',
 'petrov@mail.ru'),

('Сидоров', 'Максим',
 '+79990003333',
 'sidorov@mail.ru'),

('Козлов', 'Денис',
 '+79990004444',
 'kozlov@mail.ru'),

('Орлова', 'Мария',
 '+79990005555',
 'orlova@mail.ru');

-- =====================================================

INSERT INTO bicycles
(client_id, brand, frame_type,
 wheel_size, brake_type)
VALUES
(1, 'Trek', 'горный',
 29, 'дисковые'),

(2, 'Scott', 'шоссейный',
 28, 'ободные'),

(3, 'Cube', 'горный',
 27, 'гидравлические'),

(4, 'Merida', 'городской',
 26, 'ободные'),

(5, 'Giant', 'горный',
 29, 'дисковые');

-- =====================================================

INSERT INTO masters
(last_name, first_name,
 experience_years, priority_level)
VALUES
('Смирнов', 'Олег', 5, 1),

('Кузнецов', 'Игорь', 1, 3),

('Васильев', 'Дмитрий', 4, 2),

('Павлов', 'Антон', 7, 1),

('Морозов', 'Егор', 2, 4);

-- =====================================================

INSERT INTO services
(service_name, repair_type,
 price, duration_minutes)
VALUES
('Настройка тормозов',
 'простая',
 1200,
 30),

('Замена цепи',
 'простая',
 1800,
 40),

('Переборка вилки',
 'сложная',
 5500,
 120),

('Ремонт гидравлики',
 'сложная',
 7000,
 150),

('Замена колеса',
 'простая',
 2000,
 45);

-- =====================================================

INSERT INTO spare_parts
(part_name,
 quantity_in_stock,
 price)
VALUES
('Цепь Shimano',
 15,
 2500),

('Тормозные колодки',
 30,
 900),

('Гидролиния',
 8,
 1800),

('Втулка задняя',
 10,
 3200),

('Покрышка Maxxis',
 20,
 4000);

-- =====================================================

INSERT INTO part_analogs
(original_part_id,
 analog_part_id)
VALUES
(1, 2),
(3, 4);

-- =====================================================

INSERT INTO repairs
(
 bicycle_id,
 master_id,
 service_id,
 repair_datetime,
 completion_datetime,
 status
)
VALUES

(
 1,
 1,
 3,
 '2026-05-20 10:00:00',
 '2026-05-20 13:00:00',
 'завершён'
),

(
 2,
 3,
 1,
 '2026-05-21 11:00:00',
 '2026-05-21 11:40:00',
 'завершён'
),

(
 3,
 4,
 4,
 '2026-05-22 09:30:00',
 '2026-05-22 13:30:00',
 'завершён'
),

(
 4,
 1,
 2,
 '2026-05-23 14:00:00',
 NULL,
 'в работе'
),

(
 5,
 3,
 5,
 '2026-05-24 16:00:00',
 NULL,
 'запланирован'
);

-- =====================================================
-- ЗАПРОС 1
-- Все ремонты
-- =====================================================

SELECT
    r.repair_id,

    c.last_name,
    c.first_name,

    b.brand,

    s.service_name,

    m.last_name AS master_last_name,

    r.repair_datetime,

    r.status

FROM repairs r

JOIN bicycles b
ON r.bicycle_id = b.bicycle_id

JOIN clients c
ON b.client_id = c.client_id

JOIN services s
ON r.service_id = s.service_id

JOIN masters m
ON r.master_id = m.master_id

ORDER BY r.repair_datetime;

-- =====================================================
-- ЗАПРОС 2
-- Мастера с количеством ремонтов
-- =====================================================

SELECT
    m.last_name,
    m.first_name,

    COUNT(r.repair_id)
    AS total_repairs

FROM masters m

LEFT JOIN repairs r
ON m.master_id = r.master_id

GROUP BY m.master_id

HAVING total_repairs > 1

ORDER BY total_repairs DESC;

-- =====================================================
-- ЗАПРОС 3
-- Среднее время ремонта
-- =====================================================

SELECT
    m.last_name,
    m.first_name,

    AVG(
        TIMESTAMPDIFF(
            MINUTE,
            r.repair_datetime,
            r.completion_datetime
        )
    ) AS avg_repair_time_minutes

FROM masters m

JOIN repairs r
ON m.master_id = r.master_id

WHERE r.status = 'завершён'

GROUP BY m.master_id

ORDER BY avg_repair_time_minutes;

-- =====================================================
-- ОКОННАЯ ФУНКЦИЯ
-- =====================================================

SELECT
    repair_id,
    master_id,
    repair_datetime,

    ROW_NUMBER() OVER(
        PARTITION BY master_id
        ORDER BY repair_datetime
    ) AS repair_number

FROM repairs;

-- =====================================================
-- ПРОВЕРКА UNIQUE
-- =====================================================

/*
INSERT INTO repairs
(
 bicycle_id,
 master_id,
 service_id,
 repair_datetime
)
VALUES
(
 2,
 1,
 1,
 '2026-05-20 10:00:00'
);
*/

-- =====================================================
-- ПРОВЕРКА FOREIGN KEY
-- =====================================================

/*
DELETE FROM masters
WHERE master_id = 1;
*/

-- =====================================================
-- ПРОВЕРКА CHECK
-- =====================================================

/*
INSERT INTO services
(
 service_name,
 repair_type,
 price,
 duration_minutes
)
VALUES
(
 'Тест',
 'простая',
 -100,
 20
);
*/

-- =====================================================
-- ПРОВЕРКА TRIGGER
-- =====================================================

/*
INSERT INTO repairs
(
 bicycle_id,
 master_id,
 service_id,
 repair_datetime
)
VALUES
(
 1,
 2,
 3,
 '2026-06-01 12:00:00'
);
*/
