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




--================================================================================
--================================================================================



-- Zadanie 2 (wyzwalacze)

-- a)
-- Stworzyć tabelę archiwum_departamentów (id, nazwa, data_zamknięcia,
-- ostatni_manager jako imię i nazwisko). Po usunięciu departamentu 
-- dodać odpowiedni rekord do tej tabeli


CREATE TABLE archiwum_departamentow (
  department_id int,
  department_name VARCHAR2(20),
  event_date DATE,
  manager_first_name VARCHAR2(20),
  manager_last_name VARCHAR2(20)
);	   
	   
CREATE OR REPLACE TRIGGER do_archiwum
  AFTER DELETE
  ON hr.DEPARTMENTS
  FOR EACH ROW
  DECLARE
   imie Varchar(20); nazwisko VARCHAR(20);
BEGIN
  SELECT first_name, last_name INTO imie, nazwisko from employees WHERE employee_id = old.manager_id;
  INSERT INTO archiwum_departamentow (department_id, department_name, event_date, manager_first_name, manager_last_name)
  VALUES(old.department_id, old.department_name, SYSDATE, imie, nazwisko);
END;



-- b)
-- W razie UPDATE i INSERT na tabeli employees, sprawdzić czy zarobki
-- łapią się w widełkach 2000 - 26000. Jeśli nie łapią się - zabronić
-- dodania. Dodać tabelę złodziej(id, USER, czas_zmiany), do której
-- będą wrzucane logi, jeśli będzie próba dodania, bądź zmiany
-- wynagrodzenia poza widełki.

CREATE SEQUENCE zlodziej_id_seq
INCREMENT BY 1
    START WITH 1
    MINVALUE 1
    MAXVALUE 100000
    CYCLE
    CACHE 2;


CREATE TABLE zlodziej (
  zlodziej_id int,
  user_name VARCHAR2(20),
  event_date DATE  
);	 


CREATE OR REPLACE TRIGGER lap_zlodzieja
  BEFORE INSERT OR UPDATE 
  ON EMPLOYEES
  FOR EACH ROW
   
BEGIN
    IF :new.salary >26000 or :new.salary < 2000
	 THEN 
	  INSERT INTO zlodziej (zlodziej_id, user_name, event_date)
      VALUES(zlodziej_id_seq.nextval, USER, SYSDATE);
	  RAISE_APPLICATION_ERROR(-20243,'jakistekst');
	 ELSE
     DBMS_OUTPUT.PUT_LINE('Alles gut.');
    END IF;  
END;



-- c)
-- Stworzyć sekwencję i wyzwalacz, który będzie odpowiadał 
-- za auto_increment w tabeli employees.


CREATE SEQUENCE employees_id_seq START WITH 1;

CREATE OR REPLACE TRIGGER empl_id_auto_incr 
BEFORE INSERT ON EMPLOYEES 
FOR EACH ROW

BEGIN
  SELECT employees_id_seq.NEXTVAL
  INTO   :new.employee_id
  FROM   dual;
END;




-- d)
-- Stworzyć wyzwalacz, który zabroni dowolnej operacji
-- na tabeli JOD_GRADES (INSERT, UPDATE, DELETE)


CREATE OR REPLACE TRIGGER prohibit
  BEFORE INSERT OR UPDATE OR DELETE
  ON JOB_GRADES
  FOR EACH ROW
   
BEGIN
    
	DBMS_OUTPUT.PUT_LINE('Action prohibited!');
	RAISE_APPLICATION_ERROR(-20243,'jakistekst');   
    
END;





-- e)
-- Stworzyć wyzwalacz, który przy próbie zmiany max i min salary
-- w tabeli jobs zostawia stare wartości.


CREATE OR REPLACE TRIGGER remain_old_values
  BEFORE INSERT OR UPDATE 
  ON JOBS
  FOR EACH ROW
   DECLARE
    maxi NUMBER; mini NUMBER;
BEGIN
    SELECT max_salary, min_salary INTO maxi, mini from JOBS WHERE job_id = ROWID;
	IF :new.max_salary<>maxi or :new.min_salary <> mini
	 THEN 
	  DBMS_OUTPUT.PUT_LINE('Action prohibited!');
	  RAISE_APPLICATION_ERROR(-20243,'jakistekst');    
    END IF;  
END;

