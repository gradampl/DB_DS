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
WHERE location_id IN 
 (SELECT l.location_id 
  FROM locations l 
  WHERE l.country_id IN 
   (SELECT country_id 
    FROM Countries 
    WHERE country_name = select_country
   )
  );

SELECT COUNT(*) AS num_of_empls INTO empl_num
FROM employees 
WHERE department_id IN 
 (SELECT department_id
  FROM departments 
  WHERE location_id IN 
   (SELECT l.location_id 
    FROM locations l 
	WHERE l.country_id IN 
     (SELECT country_id 
      FROM Countries 
      WHERE country_name = select_country
     )
    )
  );
  
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



--===================================================================================
--===================================================================================


-- Zadanie 3 (paczki)

-- a)
-- Składającą się ze stworzonych procedur i funkcji


-- PACKAGE SPECIFICATION:

CREATE OR REPLACE PACKAGE zad_3a AS 

   -- PROCEDURES:

   -- Adds a row to the JOBS table      
   PROCEDURE addRow(j_id IN VARCHAR, j_title IN VARCHAR); 
   
   -- Removes a row from the JOBS table   
   PROCEDURE delRow(j_id IN VARCHAR); 
   
   
   -- FUNCTIONS:
   
   -- Takes the area code into braces
   FUNCTION area_number(phonenumber VARCHAR)
   RETURN VARCHAR;
   
   -- Extracts the birth date from PESEL
   FUNCTION get_date(pesel VARCHAR)
   RETURN VARCHAR;   
  
END zad_3a; 



-- PACKAGE BODY:


CREATE OR REPLACE PACKAGE BODY zad_3a AS 

   PROCEDURE addRow(j_id IN VARCHAR, j_title IN VARCHAR) 
   IS
    ex EXCEPTION;
   BEGIN 
      INSERT INTO jobs (job_id,job_title,min_salary,max_salary) 
         VALUES(j_id, j_title, NULL, NULL);
		 DBMS_OUTPUT.put_line(j_id || ' ' || j_title || ' added to Jobs');
	  EXCEPTION
	    WHEN DUP_VAL_ON_INDEX THEN
		 DBMS_OUTPUT.put_line('Job with this id already exists');
		WHEN OTHERS THEN
		 DBMS_OUTPUT.put_line('Error!');
   END addRow; 
   
   
   PROCEDURE delRow(j_id IN VARCHAR) 
   IS
    wiersz jobs%ROWTYPE;
    ex EXCEPTION;
   BEGIN
      SELECT * INTO wiersz FROM jobs WHERE job_id = j_id;
      DELETE FROM jobs WHERE job_id = j_id;
	  
	  EXCEPTION
	    WHEN NO_DATA_FOUND THEN
          dbms_output.put_line('There is nothing to delete!');
        WHEN OTHERS THEN
          DBMS_OUTPUT.put_line('Error!');
   END delRow;

 
   FUNCTION area_number(phonenumber VARCHAR) 
     RETURN VARCHAR IS 
	  BEGIN
  	   RETURN '(' || SUBSTR(phonenumber, 1, 2) || ')' || SUBSTR(phonenumber, 3);
   END area_number;
   
   FUNCTION get_date(pesel VARCHAR)
     RETURN VARCHAR IS
	  BEGIN
        RETURN '19' || SUBSTR(pesel, 1, 2) || '-' || SUBSTR(pesel, 3, 2) || '-' || SUBSTR(pesel, 5, 2);
   END get_date;
   
END zad_3a;


---------------------------------------------------------------------------





-- Zadanie 3 (paczki)

-- b)
-- Stworzyć paczkę z procedurami i funkcjami do obsługi tabeli REGIONS (CRUD),
-- gdzie odczyt z różnymi parametrami


-- PACKAGE SPECIFICATION:

CREATE OR REPLACE PACKAGE zad_3b AS 

   -- PROCEDURES:

   -- Create   
   PROCEDURE addRegion(r_id  REGIONS.region_id%type, 
      r_name REGIONS.region_name%type); 
   
   -- Read   
   PROCEDURE listRegion;
   
   -- Update   
   PROCEDURE changeRegion (r_id REGIONS.region_id%type, nowa_nazwa IN VARCHAR );
   
   -- Delete   
   PROCEDURE delRegion(r_name REGIONS.region_name%type);   
  
END zad_3b; 



------------------------------------------------------------------



-- PACKAGE BODY:


CREATE OR REPLACE PACKAGE BODY zad_3b AS

   -- Create
   
   PROCEDURE addRegion(r_id  REGIONS.region_id%type, 
      r_name REGIONS.region_name%type) 
   IS 
   BEGIN 
      INSERT INTO REGIONS(region_id,region_name) 
         VALUES(r_id, r_name); 
   END addRegion;     
   
   
   
   -- Read
   
   PROCEDURE listRegion IS 
   CURSOR r_regions is 
      SELECT region_name FROM REGIONS; 
   TYPE r_list is TABLE OF REGIONS.region_name%type; 
   name_list r_list := r_list(); 
   counter integer :=0; 
   BEGIN 
      FOR n IN r_regions LOOP 
      counter := counter +1; 
      name_list.extend; 
      name_list(counter) := n.region_name; 
      dbms_output.put_line('Region(' ||counter|| ')'||name_list(counter)); 
      END LOOP; 
   END listRegion;
   
   
  
  
   --Update
   
  PROCEDURE changeRegion (r_id REGIONS.region_id%type, nowa_nazwa IN VARCHAR )
AS
  counter NUMBER;  

BEGIN
  SELECT count(*) into counter
    FROM REGIONS
   WHERE region_id = r_id; 

  IF counter = 1 THEN
    update REGIONS
       set region_name = nowa_nazwa
     where region_id = r_id;
    dbms_output.put_line('Region name has been changed.');
  ELSE
    dbms_output.put_line('Region does not exist.');
  END IF;
END;
   
   
   
   -- Delete
   
   PROCEDURE delRegion(r_name REGIONS.region_name%type) 
   IS 
   BEGIN 
      DELETE FROM REGIONS 
      WHERE region_name = r_name; 
   END delRegion;
   
END zad_3b;
