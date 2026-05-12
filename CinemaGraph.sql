-- ============================================================
--  ГРАФОВАЯ БАЗА ДАННЫХ: «Киноиндустрия и рекомендации»
--  MS SQL Server 2017+ (Graph Tables)
--  Вариант 1 — Классика
--  (Полный скрипт с исправленными представлениями для Power BI)
-- ============================================================

USE master;
GO

-- Пересоздаём базу
IF DB_ID('CinemaGraph') IS NOT NULL
BEGIN
    ALTER DATABASE CinemaGraph SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CinemaGraph;
END
GO

CREATE DATABASE CinemaGraph
    COLLATE Cyrillic_General_CI_AS;
GO

USE CinemaGraph;
GO

-- ============================================================
-- РАЗДЕЛ 1. ТАБЛИЦЫ УЗЛОВ (NODE TABLES)
-- ============================================================

-- 1.1 Актёры
CREATE TABLE dbo.Actors
(
    ActorID    INT           NOT NULL,
    FullName   NVARCHAR(100) NOT NULL,
    BirthDate  DATE          NOT NULL,
    Rating     DECIMAL(3,1)  NOT NULL CHECK (Rating BETWEEN 0 AND 10),
    Nationality NVARCHAR(50) NOT NULL
) AS NODE;
GO

-- 1.2 Фильмы
CREATE TABLE dbo.Movies
(
    MovieID    INT           NOT NULL,
    Title      NVARCHAR(200) NOT NULL,
    ReleaseYear SMALLINT     NOT NULL,
    Budget     DECIMAL(15,2) NOT NULL,   -- в млн. USD
    Genre      NVARCHAR(50)  NOT NULL
) AS NODE;
GO

-- 1.3 Режиссёры
CREATE TABLE dbo.Directors
(
    DirectorID  INT           NOT NULL,
    FullName    NVARCHAR(100) NOT NULL,
    Country     NVARCHAR(50)  NOT NULL,
    AwardsCount INT           NOT NULL DEFAULT 0
) AS NODE;
GO

-- ============================================================
-- РАЗДЕЛ 2. ТАБЛИЦЫ РЁБЕР (EDGE TABLES) + CONNECTION CONSTRAINTS
-- ============================================================

-- 2.1 Актёр снимался в фильме (направление: Actor -> Movie)
CREATE TABLE dbo.ACTED_IN
(
    RoleName  NVARCHAR(100) NOT NULL,
    Salary    DECIMAL(10,2) NOT NULL    -- гонорар, млн. USD
) AS EDGE;
GO

ALTER TABLE dbo.ACTED_IN
    ADD CONSTRAINT EC_ActedIn
    CONNECTION (dbo.Actors TO dbo.Movies);
GO

-- 2.2 Режиссёр снял фильм (направление: Director -> Movie)
CREATE TABLE dbo.DIRECTED
(
    ShootingDays INT  NOT NULL,
    BudgetShare  DECIMAL(5,2) NOT NULL  -- % бюджета под контролем режиссёра
) AS EDGE;
GO

ALTER TABLE dbo.DIRECTED
    ADD CONSTRAINT EC_Directed
    CONNECTION (dbo.Directors TO dbo.Movies);
GO

-- 2.3 Актёр подписан на другого актёра в соцсетях (Actor -> Actor)
CREATE TABLE dbo.FOLLOWS
(
    SinceDate  DATE         NOT NULL,
    Platform   NVARCHAR(30) NOT NULL    -- Instagram, Twitter, TikTok …
) AS EDGE;
GO

ALTER TABLE dbo.FOLLOWS
    ADD CONSTRAINT EC_Follows
    CONNECTION (dbo.Actors TO dbo.Actors);
GO

-- ============================================================
-- РАЗДЕЛ 3. ЗАПОЛНЕНИЕ УЗЛОВ (≥ 10 строк в каждой таблице)
-- ============================================================

-- 3.1 Актёры (11 записей)
INSERT INTO dbo.Actors (ActorID, FullName, BirthDate, Rating, Nationality)
VALUES
    (1,  N'Леонардо ДиКаприо',  '1974-11-11', 9.2, N'США'),
    (2,  N'Мэрил Стрип',         '1949-06-22', 9.5, N'США'),
    (3,  N'Том Хэнкс',           '1956-07-09', 9.3, N'США'),
    (4,  N'Кейт Бланшетт',       '1969-05-14', 9.1, N'Австралия'),
    (5,  N'Брэд Питт',           '1963-12-18', 8.8, N'США'),
    (6,  N'Натали Портман',      '1981-06-09', 8.7, N'Израиль/США'),
    (7,  N'Хоакин Феникс',       '1974-10-28', 9.0, N'США'),
    (8,  N'Скарлетт Йоханссон',  '1984-11-22', 8.5, N'США'),
    (9,  N'Кристиан Бейл',       '1974-01-30', 8.9, N'Великобритания'),
    (10, N'Эмма Стоун',          '1988-11-06', 8.6, N'США'),
    (11, N'Дензел Вашингтон',    '1954-12-28', 9.1, N'США');
GO

-- 3.2 Фильмы (12 записей)
INSERT INTO dbo.Movies (MovieID, Title, ReleaseYear, Budget, Genre)
VALUES
    (1,  N'Начало',                        2010, 160.00, N'Научная фантастика'),
    (2,  N'Волк с Уолл-стрит',             2013, 100.00, N'Биография/Комедия'),
    (3,  N'Список Шиндлера',               1993,  22.00, N'Исторический'),
    (4,  N'Форрест Гамп',                  1994,  55.00, N'Драма'),
    (5,  N'Гравитация',                    2013, 100.00, N'Научная фантастика'),
    (6,  N'Чёрный лебедь',                 2010,  13.00, N'Психологический триллер'),
    (7,  N'Джокер',                        2019,  55.00, N'Триллер/Драма'),
    (8,  N'Под кожей',                     2013,  13.30, N'Научная фантастика'),
    (9,  N'Бэтмен: Начало',                2005, 150.00, N'Боевик'),
    (10, N'Ла-Ла Ленд',                    2016,  30.00, N'Мюзикл/Романтика'),
    (11, N'Дуэт Манкурта',                 2000,  12.00, N'Драма'),
    (12, N'Отступники',                    2006,  90.00, N'Триллер');
GO

-- 3.3 Режиссёры (10 записей)
INSERT INTO dbo.Directors (DirectorID, FullName, Country, AwardsCount)
VALUES
    (1,  N'Кристофер Нолан',   N'Великобритания/США', 12),
    (2,  N'Мартин Скорсезе',   N'США',                 9),
    (3,  N'Стивен Спилберг',   N'США',                11),
    (4,  N'Роберт Земекис',    N'США',                 5),
    (5,  N'Альфонсо Куарон',   N'Мексика',             7),
    (6,  N'Даррен Аронофски',  N'США',                 4),
    (7,  N'Тодд Филлипс',      N'США',                 3),
    (8,  N'Джонатан Глейзер',  N'Великобритания',      2),
    (9,  N'Дэмьен Шазелл',     N'США',                 6),
    (10, N'Мэл Гибсон',        N'США/Австралия',       4);
GO

-- ============================================================
-- РАЗДЕЛ 4. ЗАПОЛНЕНИЕ РЁБЕР
-- ============================================================

-- 4.1 ACTED_IN (Актёр -> Фильм)
INSERT INTO dbo.ACTED_IN ($from_id, $to_id, RoleName, Salary)
VALUES
-- ДиКаприо
((SELECT $node_id FROM dbo.Actors WHERE ActorID=1),
 (SELECT $node_id FROM dbo.Movies  WHERE MovieID=1),  N'Дом Кобб',           20.00),
((SELECT $node_id FROM dbo.Actors WHERE ActorID=1),
 (SELECT $node_id FROM dbo.Movies  WHERE MovieID=2),  N'Джордан Белфорт',    25.00),
-- Том Хэнкс
((SELECT $node_id FROM dbo.Actors WHERE ActorID=3),
 (SELECT $node_id FROM dbo.Movies  WHERE MovieID=4),  N'Форрест Гамп',       20.00),
-- Кейт Бланшетт
((SELECT $node_id FROM dbo.Actors WHERE ActorID=4),
 (SELECT $node_id FROM dbo.Movies  WHERE MovieID=5),  N'Д-р Стоун',          15.00),
-- Брэд Питт
((SELECT $node_id FROM dbo.Actors WHERE ActorID=5),
 (SELECT $node_id FROM dbo.Movies  WHERE MovieID=12), N'Билли Костиган',     20.00),
-- Натали Портман
((SELECT $node_id FROM dbo.Actors WHERE ActorID=6),
 (SELECT $node_id FROM dbo.Movies  WHERE MovieID=6),  N'Нина Сэйерс',        10.00),
-- Хоакин Феникс
((SELECT $node_id FROM dbo.Actors WHERE ActorID=7),
 (SELECT $node_id FROM dbo.Movies  WHERE MovieID=7),  N'Артур Флек',         4.50),
-- Скарлетт Йоханссон
((SELECT $node_id FROM dbo.Actors WHERE ActorID=8),
 (SELECT $node_id FROM dbo.Movies  WHERE MovieID=8),  N'Пришелец',           3.50),
-- Кристиан Бейл
((SELECT $node_id FROM dbo.Actors WHERE ActorID=9),
 (SELECT $node_id FROM dbo.Movies  WHERE MovieID=9),  N'Брюс Уэйн',         10.00),
-- Эмма Стоун
((SELECT $node_id FROM dbo.Actors WHERE ActorID=10),
 (SELECT $node_id FROM dbo.Movies  WHERE MovieID=10), N'Миа Дорланд',        7.00),
-- Дензел Вашингтон
((SELECT $node_id FROM dbo.Actors WHERE ActorID=11),
 (SELECT $node_id FROM dbo.Movies  WHERE MovieID=12), N'Фрэнк Костелло',    18.00),
-- Мэрил Стрип (добавляем в фильм 3 — для цепочек)
((SELECT $node_id FROM dbo.Actors WHERE ActorID=2),
 (SELECT $node_id FROM dbo.Movies  WHERE MovieID=3),  N'Эпизодическая роль', 5.00),
-- ДиКаприо в «Отступниках»
((SELECT $node_id FROM dbo.Actors WHERE ActorID=1),
 (SELECT $node_id FROM dbo.Movies  WHERE MovieID=12), N'Агент под прикрытием',22.00);
GO

-- 4.2 DIRECTED (Режиссёр -> Фильм)
INSERT INTO dbo.DIRECTED ($from_id, $to_id, ShootingDays, BudgetShare)
VALUES
((SELECT $node_id FROM dbo.Directors WHERE DirectorID=1),
 (SELECT $node_id FROM dbo.Movies    WHERE MovieID=1),   148, 85.0),
((SELECT $node_id FROM dbo.Directors WHERE DirectorID=2),
 (SELECT $node_id FROM dbo.Movies    WHERE MovieID=2),   130, 80.0),
((SELECT $node_id FROM dbo.Directors WHERE DirectorID=3),
 (SELECT $node_id FROM dbo.Movies    WHERE MovieID=3),    72, 90.0),
((SELECT $node_id FROM dbo.Directors WHERE DirectorID=4),
 (SELECT $node_id FROM dbo.Movies    WHERE MovieID=4),   110, 75.0),
((SELECT $node_id FROM dbo.Directors WHERE DirectorID=5),
 (SELECT $node_id FROM dbo.Movies    WHERE MovieID=5),    78, 88.0),
((SELECT $node_id FROM dbo.Directors WHERE DirectorID=6),
 (SELECT $node_id FROM dbo.Movies    WHERE MovieID=6),    42, 92.0),
((SELECT $node_id FROM dbo.Directors WHERE DirectorID=7),
 (SELECT $node_id FROM dbo.Movies    WHERE MovieID=7),    96, 70.0),
((SELECT $node_id FROM dbo.Directors WHERE DirectorID=8),
 (SELECT $node_id FROM dbo.Movies    WHERE MovieID=8),    56, 95.0),
((SELECT $node_id FROM dbo.Directors WHERE DirectorID=1),
 (SELECT $node_id FROM dbo.Movies    WHERE MovieID=9),   180, 87.0),
((SELECT $node_id FROM dbo.Directors WHERE DirectorID=9),
 (SELECT $node_id FROM dbo.Movies    WHERE MovieID=10),   54, 82.0),
((SELECT $node_id FROM dbo.Directors WHERE DirectorID=2),
 (SELECT $node_id FROM dbo.Movies    WHERE MovieID=12),  120, 78.0);
GO

-- 4.3 FOLLOWS (Актёр -> Актёр)
INSERT INTO dbo.FOLLOWS ($from_id, $to_id, SinceDate, Platform)
VALUES
-- ДиКаприо следит за Питтом
((SELECT $node_id FROM dbo.Actors WHERE ActorID=1),
 (SELECT $node_id FROM dbo.Actors WHERE ActorID=5),  '2015-03-12', N'Instagram'),
-- Питт следит за Стрип
((SELECT $node_id FROM dbo.Actors WHERE ActorID=5),
 (SELECT $node_id FROM dbo.Actors WHERE ActorID=2),  '2016-07-04', N'Twitter'),
-- Стрип следит за Хэнксом
((SELECT $node_id FROM dbo.Actors WHERE ActorID=2),
 (SELECT $node_id FROM dbo.Actors WHERE ActorID=3),  '2017-01-20', N'Instagram'),
-- Хэнкс следит за Фениксом
((SELECT $node_id FROM dbo.Actors WHERE ActorID=3),
 (SELECT $node_id FROM dbo.Actors WHERE ActorID=7),  '2019-10-05', N'Twitter'),
-- Феникс следит за Бейлом
((SELECT $node_id FROM dbo.Actors WHERE ActorID=7),
 (SELECT $node_id FROM dbo.Actors WHERE ActorID=9),  '2020-02-14', N'Instagram'),
-- Бейл следит за ДиКаприо
((SELECT $node_id FROM dbo.Actors WHERE ActorID=9),
 (SELECT $node_id FROM dbo.Actors WHERE ActorID=1),  '2018-06-30', N'TikTok'),
-- Йоханссон следит за Стоун
((SELECT $node_id FROM dbo.Actors WHERE ActorID=8),
 (SELECT $node_id FROM dbo.Actors WHERE ActorID=10), '2021-03-01', N'Instagram'),
-- Стоун следит за Портман
((SELECT $node_id FROM dbo.Actors WHERE ActorID=10),
 (SELECT $node_id FROM dbo.Actors WHERE ActorID=6),  '2020-11-11', N'Twitter'),
-- Портман следит за Йоханссон
((SELECT $node_id FROM dbo.Actors WHERE ActorID=6),
 (SELECT $node_id FROM dbo.Actors WHERE ActorID=8),  '2019-05-20', N'Instagram'),
-- Вашингтон следит за ДиКаприо
((SELECT $node_id FROM dbo.Actors WHERE ActorID=11),
 (SELECT $node_id FROM dbo.Actors WHERE ActorID=1),  '2022-01-01', N'Twitter'),
-- Бланшетт следит за Стрип
((SELECT $node_id FROM dbo.Actors WHERE ActorID=4),
 (SELECT $node_id FROM dbo.Actors WHERE ActorID=2),  '2017-09-09', N'Instagram'),
-- ДиКаприо следит за Йоханссон
((SELECT $node_id FROM dbo.Actors WHERE ActorID=1),
 (SELECT $node_id FROM dbo.Actors WHERE ActorID=8),  '2023-02-28', N'TikTok');
GO

-- ============================================================
-- РАЗДЕЛ 5. ЗАПРОСЫ С ФУНКЦИЕЙ MATCH (6 запросов)
-- ============================================================

-- 5.1 Фильмы актёров, на которых подписан Леонардо ДиКаприо
PRINT N'=== Запрос 5.1: Фильмы подписок ДиКаприо ===';
SELECT
    a_source.FullName   AS [Кто подписан],
    a_target.FullName   AS [На кого подписан],
    m.Title             AS [Фильм],
    ai.RoleName         AS [Роль]
FROM
    dbo.Actors   AS a_source,
    dbo.FOLLOWS  AS f,
    dbo.Actors   AS a_target,
    dbo.ACTED_IN AS ai,
    dbo.Movies   AS m
WHERE MATCH(a_source-(f)->a_target-(ai)->m)
  AND a_source.FullName = N'Леонардо ДиКаприо';
GO

-- 5.2 Актёры, работавшие с Кристофером Ноланом
PRINT N'=== Запрос 5.2: Актёры Нолана ===';
SELECT DISTINCT
    d.FullName  AS [Режиссёр],
    a.FullName  AS [Актёр],
    m.Title     AS [Фильм]
FROM
    dbo.Directors AS d,
    dbo.DIRECTED  AS dir,
    dbo.Movies    AS m,
    dbo.ACTED_IN  AS ai,
    dbo.Actors    AS a
WHERE MATCH(d-(dir)->m<-(ai)-a)
  AND d.FullName = N'Кристофер Нолан';
GO

-- 5.3 Соактёры Брэда Питта
PRINT N'=== Запрос 5.3: Соактёры Брэда Питта ===';
SELECT
    a1.FullName AS [Актёр],
    m.Title     AS [Общий фильм],
    a2.FullName AS [Соактёр]
FROM
    dbo.Actors   AS a1,
    dbo.ACTED_IN AS ai1,
    dbo.Movies   AS m,
    dbo.ACTED_IN AS ai2,
    dbo.Actors   AS a2
WHERE MATCH(a1-(ai1)->m<-(ai2)-a2)
  AND a1.FullName = N'Брэд Питт'
  AND a1.ActorID  <> a2.ActorID;
GO

-- 5.4 Трёхуровневая социальная цепочка до Тома Хэнкса
PRINT N'=== Запрос 5.4: Цепочка "друзья друзей" до Тома Хэнкса ===';
SELECT
    a1.FullName AS [Уровень 1],
    a2.FullName AS [Уровень 2],
    a3.FullName AS [Конечная цель]
FROM
    dbo.Actors  AS a1,
    dbo.FOLLOWS AS f1,
    dbo.Actors  AS a2,
    dbo.FOLLOWS AS f2,
    dbo.Actors  AS a3
WHERE MATCH(a1-(f1)->a2-(f2)->a3)
  AND a3.FullName = N'Том Хэнкс'
  AND a1.ActorID <> a2.ActorID
  AND a2.ActorID <> a3.ActorID;
GO

-- 5.5 Режиссёры с бюджетом > 50 млн. у подписок ДиКаприо
PRINT N'=== Запрос 5.5: Режиссёры крупных фильмов подписок ДиКаприо ===';
SELECT
    a_src.FullName   AS [Исходный актёр],
    a_fol.FullName   AS [Подписка],
    m.Title          AS [Фильм],
    m.Budget         AS [Бюджет млн.],
    dir.FullName     AS [Режиссёр]
FROM
    dbo.Actors    AS a_src,
    dbo.FOLLOWS   AS f,
    dbo.Actors    AS a_fol,
    dbo.ACTED_IN  AS ai,
    dbo.Movies    AS m,
    dbo.DIRECTED  AS d,
    dbo.Directors AS dir
WHERE MATCH(a_src-(f)->a_fol-(ai)->m<-(d)-dir)
  AND a_src.FullName = N'Леонардо ДиКаприо'
  AND m.Budget > 50;
GO

-- 5.6 Подписчики звёзд, работавших с титулованными режиссёрами
PRINT N'=== Запрос 5.6: Подписчики звёзд титулованных режиссёров ===';
SELECT DISTINCT
    dir.FullName    AS [Режиссёр],
    dir.AwardsCount AS [Наград],
    a_star.FullName AS [Звезда],
    a_fan.FullName  AS [Подписчик]
FROM
    dbo.Directors AS dir,
    dbo.DIRECTED  AS drel,
    dbo.Movies    AS m,
    dbo.ACTED_IN  AS ai,
    dbo.Actors    AS a_star,
    dbo.FOLLOWS   AS f,
    dbo.Actors    AS a_fan
WHERE MATCH(dir-(drel)->m<-(ai)-a_star<-(f)-a_fan)
  AND dir.AwardsCount > 5;
GO

-- ============================================================
-- РАЗДЕЛ 6. ЗАПРОСЫ SHORTEST_PATH (3 запроса)
-- ============================================================

-- 6.1 Кратчайший путь от Кристиана Бейла до Мэрил Стрип
PRINT N'=== 6.1: Шесть рукопожатий – путь от Кристиана Бейла до Мэрил Стрип ===';
WITH PathCTE AS
(
    SELECT
        src.FullName                              AS [Откуда],
        STRING_AGG(n.FullName, N' -> ')
            WITHIN GROUP (GRAPH PATH)            AS [Путь через],
        LAST_VALUE(n.FullName)
            WITHIN GROUP (GRAPH PATH)            AS [Последний узел],
        COUNT(n.FullName)
            WITHIN GROUP (GRAPH PATH)            AS [Длина пути]
    FROM
        dbo.Actors AS src,
        dbo.FOLLOWS FOR PATH AS f,
        dbo.Actors  FOR PATH AS n
    WHERE MATCH(SHORTEST_PATH(src(-(f)->n)+))
      AND src.FullName = N'Кристиан Бейл'
)
SELECT [Откуда], [Путь через], [Длина пути]
FROM PathCTE
WHERE [Последний узел] = N'Мэрил Стрип';
GO

-- 6.2 Кратчайшие пути длиной 1–4 шага до Тома Хэнкса
PRINT N'=== 6.2: Пути длиной 1–4 шага, ведущие к Тому Хэнксу ===';
WITH PathCTE AS
(
    SELECT
        src.FullName                              AS [Исходный актёр],
        STRING_AGG(n.FullName, N' -> ')
            WITHIN GROUP (GRAPH PATH)            AS [Промежуточные узлы],
        LAST_VALUE(n.FullName)
            WITHIN GROUP (GRAPH PATH)            AS [Последний актёр],
        COUNT(n.FullName)
            WITHIN GROUP (GRAPH PATH)            AS [Шагов]
    FROM
        dbo.Actors AS src,
        dbo.FOLLOWS FOR PATH AS f,
        dbo.Actors  FOR PATH AS n
    WHERE MATCH(SHORTEST_PATH(src(-(f)->n){1,4}))
)
SELECT [Исходный актёр], [Промежуточные узлы], [Шагов]
FROM PathCTE
WHERE [Последний актёр] = N'Том Хэнкс'
ORDER BY [Шагов], [Исходный актёр];
GO

-- 6.3 Кратчайшие пути до Хоакина Феникса с платформами
PRINT N'=== 6.3: Кратчайшие пути к Хоакину Фениксу с указанием платформ ===';
WITH PathCTE AS
(
    SELECT
        src.FullName                                   AS [Откуда],
        STRING_AGG(n.FullName, N' --> ')
            WITHIN GROUP (GRAPH PATH)                 AS [Маршрут],
        STRING_AGG(f.Platform, N' | ')
            WITHIN GROUP (GRAPH PATH)                 AS [Платформы],
        COUNT(f.Platform)
            WITHIN GROUP (GRAPH PATH)                 AS [Шагов],
        LAST_VALUE(n.FullName)
            WITHIN GROUP (GRAPH PATH)                 AS [Конечный актёр]
    FROM
        dbo.Actors AS src,
        dbo.FOLLOWS FOR PATH AS f,
        dbo.Actors  FOR PATH AS n
    WHERE MATCH(SHORTEST_PATH(src(-(f)->n){1,5}))
      AND src.FullName <> N'Хоакин Феникс'
)
SELECT [Откуда], [Маршрут], [Платформы], [Шагов]
FROM PathCTE
WHERE [Конечный актёр] = N'Хоакин Феникс'
ORDER BY [Шагов], [Откуда];
GO

-- ============================================================
-- РАЗДЕЛ 7. ПРЕДСТАВЛЕНИЯ ДЛЯ POWER BI (безопасная версия)
-- ============================================================

-- Узлы
CREATE OR ALTER VIEW dbo.vw_Nodes AS
SELECT
    CAST(ActorID AS NVARCHAR(10)) AS NodeID,
    FullName                       AS NodeName,
    N'Актёр'                       AS NodeType,
    Rating                         AS [Weight]
FROM dbo.Actors
UNION ALL
SELECT
    CAST(10000 + MovieID AS NVARCHAR(10)),
    Title,
    N'Фильм',
    Budget / 10.0
FROM dbo.Movies
UNION ALL
SELECT
    CAST(20000 + DirectorID AS NVARCHAR(10)),
    FullName,
    N'Режиссёр',
    CAST(AwardsCount AS DECIMAL(18,2))
FROM dbo.Directors;
GO

-- Рёбра (связи) – без MATCH, с явными JOIN по $node_id
CREATE OR ALTER VIEW dbo.vw_Edges AS
SELECT
    CAST(a.ActorID AS NVARCHAR(10))          AS SourceID,
    CAST(10000 + m.MovieID AS NVARCHAR(10))  AS TargetID,
    N'ACTED_IN'                               AS EdgeType,
    ai.RoleName                               AS EdgeLabel
FROM dbo.Actors a
JOIN dbo.ACTED_IN ai ON a.$node_id = ai.$from_id
JOIN dbo.Movies m    ON ai.$to_id = m.$node_id

UNION ALL

SELECT
    CAST(20000 + d.DirectorID AS NVARCHAR(10)) AS SourceID,
    CAST(10000 + m.MovieID AS NVARCHAR(10))    AS TargetID,
    N'DIRECTED'                                 AS EdgeType,
    CAST(dr.ShootingDays AS NVARCHAR(10)) + N' дней' AS EdgeLabel
FROM dbo.Directors d
JOIN dbo.DIRECTED dr ON d.$node_id = dr.$from_id
JOIN dbo.Movies m     ON dr.$to_id = m.$node_id

UNION ALL

SELECT
    CAST(a1.ActorID AS NVARCHAR(10)) AS SourceID,
    CAST(a2.ActorID AS NVARCHAR(10)) AS TargetID,
    N'FOLLOWS'                        AS EdgeType,
    f.Platform                        AS EdgeLabel
FROM dbo.Actors a1
JOIN dbo.FOLLOWS f ON a1.$node_id = f.$from_id
JOIN dbo.Actors a2  ON f.$to_id = a2.$node_id;
GO

-- ============================================================
-- Готово
-- ============================================================
PRINT N'База данных CinemaGraph успешно создана и заполнена.';
PRINT N'Представления vw_Nodes и vw_Edges готовы для Power BI.';
GO