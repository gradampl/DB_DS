DROP Table Regions;
DROP TABLE Countries CASCADE CONSTRAINTS;
DROP TABLE Locations CASCADE CONSTRAINTS;
DROP TABLE Departments CASCADE CONSTRAINTS;
DROP TABLE Employees CASCADE CONSTRAINTS;
DROP TABLE Job_History CASCADE CONSTRAINTS;
DROP TABLE Jobs CASCADE CONSTRAINTS;

CREATE TABLE countries AS SELECT * FROM HR.countries;
CREATE TABLE regions AS SELECT * FROM HR.regions;
CREATE TABLE locations AS SELECT * FROM HR.locations;
CREATE TABLE departments AS SELECT * FROM HR.departments;
CREATE TABLE employees AS SELECT * FROM HR.employees;
CREATE TABLE Job_History AS SELECT * FROM HR.Job_History;
CREATE TABLE Jobs AS SELECT * FROM HR.Jobs;

ALTER TABLE regions
ADD CONSTRAINT PK_Regions PRIMARY KEY (region_id);

ALTER TABLE countries
ADD CONSTRAINT PK_Countries PRIMARY KEY (country_id);

ALTER TABLE countries
ADD FOREIGN KEY (region_id) REFERENCES regions(region_id);

ALTER TABLE locations
ADD CONSTRAINT PK_Locations PRIMARY KEY (location_id);

ALTER TABLE locations
ADD FOREIGN KEY (country_id) REFERENCES countries(country_id);

------------------------------------------------------------------

ALTER TABLE departments
ADD CONSTRAINT PK_Departments PRIMARY KEY (department_id);

ALTER TABLE departments
ADD FOREIGN KEY (location_id) REFERENCES locations(location_id);

ALTER TABLE employees
ADD CONSTRAINT PK_Employees PRIMARY KEY (employee_id);

ALTER TABLE employees
ADD FOREIGN KEY (department_id) REFERENCES departments(department_id);

ALTER TABLE employees
ADD FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

ALTER TABLE departments
ADD FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

ALTER TABLE jobs
ADD CONSTRAINT PK_Jobs PRIMARY KEY (job_id);

ALTER TABLE employees
ADD FOREIGN KEY (job_id) REFERENCES jobs(job_id);

ALTER TABLE job_history
ADD CONSTRAINT PK_Job_History PRIMARY KEY (employee_id, start_date);

ALTER TABLE job_history
ADD FOREIGN KEY (employee_id) REFERENCES employees(employee_id);

ALTER TABLE job_history
ADD FOREIGN KEY (department_id) REFERENCES departments(department_id);

ALTER TABLE job_history
ADD FOREIGN KEY (job_id) REFERENCES jobs(job_id);


CREATE VIEW zad_1 AS 
SELECT department_id, last_name||' '||salary AS remuneration 
FROM employees 
WHERE department_id IN (20,50)
AND salary BETWEEN 2000 AND 7000
ORDER BY department_id, last_name;


CREATE VIEW zad_2 AS 
SELECT last_name, hire_date, &X as user_column
FROM employees
WHERE manager_id IS NOT NULL AND hire_date BETWEEN '05/01/01' AND '05/12/31'
ORDER BY user_column;


CREATE VIEW zad_3 AS
SELECT last_name||' '||first_name AS employee, salary, phone_number
FROM employees
WHERE last_name LIKE '__e%' AND first_name LIKE '%' || '&czesc_imienia' || '%'
ORDER BY 1 DESC, 2 ASC;


CREATE VIEW zad_4 AS
SELECT first_name, last_name, salary,
ROUND(MONTHS_BETWEEN
(sysdate, hire_date),0) "summed_months"
FROM employees;


CREATE VIEW zad_4a AS -- to działa
SELECT first_name, last_name, salary, "summed_months",
CASE
WHEN "summed_months" BETWEEN 1 AND 149 THEN salary*0.1
WHEN "summed_months" BETWEEN 150 AND 200 THEN salary*0.2
WHEN "summed_months" > 200 THEN salary*0.3
END AS Bonus
FROM zad_4;


CREATE VIEW zad_5 AS 
SELECT department_id, MIN(salary) AS min_salary, 
SUM(salary) AS sum_salary, ROUND(AVG(salary),0) AS avg_salary
FROM employees
GROUP BY department_id
HAVING MIN(salary) > 5000;


CREATE VIEW zad_6 AS 
SELECT a.last_name, a.department_id, b.department_name, a.job_id
FROM employees a, departments b, locations c
WHERE a.department_id = b.department_id 
AND b.location_id = c.location_id AND city = 'Toronto';


CREATE VIEW zad_7 AS 
SELECT last_name, first_name, department_id
FROM employees
WHERE department_id IN
(SELECT DISTINCT department_id 
FROM employees 
WHERE first_name = 'Jennifer');


CREATE VIEW zad_8 AS 
SELECT *
FROM departments
WHERE department_id NOT IN (SELECT department_id FROM employees 
WHERE department_id IS NOT NULL);



-- ZADANIE 9

CREATE TABLE Job_grades  AS SELECT * FROM HR.Job_grades; 

SELECT * FROM Job_grades;




CREATE VIEW zad_10 AS  -- ta wersja działa
SELECT last_name, first_name, job_id, salary, department_name, grade
FROM employees a, departments b, Job_grades
WHERE a.department_id = b.department_id AND salary BETWEEN MIN_SALARY AND MAX_SALARY; 


CREATE VIEW zad_11 AS 
SELECT last_name, first_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;


CREATE VIEW zad_12 AS 
SELECT last_name, first_name, department_id
FROM employees
WHERE department_id IN
(SELECT DISTINCT department_id 
FROM employees 
WHERE last_name LIKE '%u%');


------------------------------------------------------------

--Dla każdego departamentu wypisać jego nazwę, 
--imię i nazwisko osoby, która ma w tym dziale 
--drugie zarobki pod względem wysokości 
--oraz wysokość tych zarobków


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
				 
				 
