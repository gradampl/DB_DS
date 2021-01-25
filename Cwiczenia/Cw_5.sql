-- Zadanie 1 (funkcje)

-- Stwórz funkcje:

-- a)
-- Zwracającą nazwę pracy dla podanego parametru id, dodaj wyjątek,
-- jeśli taka praca nie istnieje


CREATE OR REPLACE FUNCTION job_name(jobid VARCHAR)
RETURN VARCHAR IS
name jobs.job_title%TYPE;
BEGIN
    SELECT job_title INTO name FROM jobs WHERE job_id = jobid;
    RETURN name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           DBMS_OUTPUT.PUT_LINE('No job found with this id number!'); 
END job_name;


-- b)
-- zwracającą roczne zarobki (wynagrodzenie 12-to miesięczne plus premia
-- jako wynagrodzenie * commission_pct) dla pracownika o podanym id


CREATE OR REPLACE FUNCTION year_salary(emplid NUMBER)
RETURN NUMBER IS
sal employees.salary%TYPE;
compct employees.commission_pct%TYPE;
BEGIN
    SELECT salary, commission_pct INTO sal, compct FROM employees WHERE employee_id = emplid;
    IF compct IS NULL THEN
        RETURN sal*12;
    END IF;
    RETURN (sal * 12 + sal * compct);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           DBMS_OUTPUT.PUT_LINE('No employee found with this id number!'); 
END year_salary;


-- c)
-- biorącą w nawias numer kierunkowy z numeru telefonu podanego jako varchar


CREATE OR REPLACE FUNCTION area_code(phonenumber VARCHAR)
RETURN VARCHAR IS
BEGIN
    RETURN '(' || SUBSTR(phonenumber, 1, 2) || ')' || SUBSTR(phonenumber, 3);
END area_code;


-- d)
-- Dla podanego w parametrze ciągu znaków zmieniającą pierwszą i ostatnią
-- literę na wielką – pozostałe na małe


CREATE OR REPLACE FUNCTION change_string(str VARCHAR)
RETURN VARCHAR IS
BEGIN
    RETURN UPPER(SUBSTR(str, 1, 1)) || LOWER(SUBSTR(str, 2, LENGTH(str) - 2)) || (SUBSTR(str, -1, 1));
END change_string;


-- e)
-- Dla podanego peselu - przerabiającą pesel na datę urodzenia w formacie ‘yyyy-mm-dd’


CREATE OR REPLACE FUNCTION extract_date_as_date(pesel VARCHAR)
RETURN DATE IS
BEGIN
    RETURN TO_DATE('19' || SUBSTR(pesel, 1, 2) || '-' || SUBSTR(pesel, 3, 2) || '-' || SUBSTR(pesel, 5, 2));
END extract_date_as_date;



CREATE OR REPLACE FUNCTION extract_date_as_varchar(pesel VARCHAR)
RETURN VARCHAR IS
BEGIN
    RETURN '19' || SUBSTR(pesel, 1, 2) || '-' || SUBSTR(pesel, 3, 2) || '-' || SUBSTR(pesel, 5, 2);
END extract_date_as_varchar;


-- f)
-- Zwracającą liczbę pracowników oraz liczbę departamentów które znajdują się w kraju podanym
-- jako parametr (nazwa kraju). W przypadku braku kraju - odpowiedni wyjątek


CREATE OR REPLACE FUNCTION zad_1f(select_country VARCHAR) 
RETURN VARCHAR IS
depart_num NUMBER;
empl_num NUMBER;
BEGIN 
SELECT COUNT(*) AS num_of_depts INTO depart_num 
FROM departments 
WHERE location_id IN (SELECT l.location_id FROM locations l WHERE l.country_id = select_country);

SELECT COUNT(*) AS num_of_empls INTO empl_num
FROM employees 
WHERE department_id 
IN (SELECT department_id
FROM departments 
WHERE location_id 
IN (SELECT l.location_id FROM locations l WHERE l.country_id = select_country));
RETURN depart_num || ' ' || empl_num;
EXCEPTION 
WHEN NO_DATA_FOUND THEN
RETURN 'No data found!';
END zad_1f;

