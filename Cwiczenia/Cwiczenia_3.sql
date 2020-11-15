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
