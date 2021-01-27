--Dla każdego departamentu wypisać jego nazwę, 
--imię i nazwisko osoby, która ma w tym dziale 
--drugie zarobki pod względem wysokości 
--oraz wysokość tych zarobków

-----------------------------------------------------
--ROZWIĄZANIE PIERWSZE - NIE NAJLEPSZE:

CREATE VIEW zad_13 AS
SELECT a.department_id, b.department_name, a.employee_id, a.first_name, a.last_name, a.salary
FROM employees a, departments b
WHERE a.department_id = b.department_id;


CREATE VIEW zad_13a AS
SELECT a.department_id, a.employee_id, a.salary
FROM zad_13 a
WHERE a.salary = (SELECT MAX(salary)
FROM zad_13
WHERE a.department_id = department_id
GROUP BY department_id);
	


CREATE VIEW zad_13b AS
SELECT * FROM employees	p	
WHERE NOT EXISTS
(SELECT * FROM zad_13a d 
WHERE p.department_id = d. department_id
AND p.employee_id = d.employee_id);


CREATE VIEW zad_13c AS
SELECT *
FROM zad_13b a
WHERE a.salary = (SELECT MAX(salary)
FROM zad_13b
WHERE a.department_id = department_id
GROUP BY a.department_id);		

------------------------------------------------------

-- ROZWIĄZANIE DRUGIE - LEPSZE:

CREATE VIEW zad_13bis AS
SELECT a.department_id, a.employee_id, a.last_name, a.first_name, a.salary
FROM employees a
WHERE a.salary < (SELECT MAX(salary)
FROM employees
WHERE a.department_id = department_id
GROUP BY department_id);


CREATE VIEW zad_13abis AS
SELECT a.department_id, b.department_name, a.employee_id, a.last_name, a.first_name, a.salary
FROM zad_13bis a, departments b
WHERE a.salary = (SELECT MAX(salary)
FROM zad_13bis
WHERE a.department_id = department_id AND a.department_id = b.department_id
GROUP BY a.department_id);	



--==============================================================================

-- 2.	Stwórz tabelę mecz z kolumnami gospodarz, gosc, gole_gospodarza,
-- gole_goscia. Uzupełnij tabelę przykładowymi danymi (co najmniej 12 rekordów)


CREATE TABLE mecz (gospodarz VARCHAR(50), gosc VARCHAR(50), gole_gospodarza int, gole_goscia int);

INSERT INTO mecz VALUES('legia','gornik',2,0);
INSERT INTO mecz VALUES('legia','korona',1,2);
INSERT INTO mecz VALUES('legia','lech',0,0);
INSERT INTO mecz VALUES('gornik','ruch',5,0);
INSERT INTO mecz VALUES('gornik','stomil',3,5);
INSERT INTO mecz VALUES('gornik','pogon',1,1);
INSERT INTO mecz VALUES('widzew','lks',4,2);
INSERT INTO mecz VALUES('widzew','legia',2,3);
INSERT INTO mecz VALUES('widzew','gornik',2,0);
INSERT INTO mecz VALUES('amica','ruch',0,1);
INSERT INTO mecz VALUES('amica','stomil',2,2);
INSERT INTO mecz VALUES('amica','gornik',3,2);



--3.	Stwórz zapytanie zwracające klasyfikację drużyn na podstawie
-- tabeli mecz, wypisujące nazwę drużyny liczbę punktów,
-- gole strzelone, gole stracone,  uwzględniając: 3 punkty za zwycięstwo,
-- 1 za remis, 0 za porażkę. W klasyfikacji w pierwszej kolejności 
--liczą się punkty, potem różnica bramek strzelonych i straconych.
-- Uwzględnij również sytuację, że drużyna może być tylko gospodarzem
-- lub tylko gościem.


DROP zad_mecz1, zad_mecz2, zad_mecz3,zad_mecz4;

CREATE VIEW zad_mecz1 AS
SELECT gospodarz, gole_gospodarza, gole_goscia 
FROM mecz
WHERE gospodarz != gosc;


CREATE VIEW zad_mecz2 AS
SELECT gosc, gole_goscia, gole_gospodarza
FROM mecz
WHERE gospodarz != gosc;


INSERT INTO zad_mecz1(gospodarz, gole_gospodarza, gole_goscia)
SELECT gosc, gole_goscia, gole_gospodarza
FROM zad_mecz2
WHERE gosc NOT IN(SELECT DISTINCT a.gospodarz FROM zad_mecz1 a OR gosc = a.gospodarz);



CREATE VIEW zad_mecz3 AS
SELECT gospodarz,COUNT(*) AS liczba_meczy, SUM(gole_gospodarza) AS bramki_strzelone,
SUM(gole_goscia) AS bramki_stracone, SUM(gole_gospodarza) - SUM(gole_goscia) AS roznica_bramek,
SUM(
CASE
WHEN gole_gospodarza > gole_goscia THEN 3
WHEN gole_gospodarza = gole_goscia THEN 1
ELSE 0
END) AS punkty_zdobyte
FROM zad_mecz1
GROUP BY gospodarz;



