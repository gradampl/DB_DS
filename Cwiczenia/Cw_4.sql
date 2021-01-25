-- Zadanie 1

--Stworzyć blok anonimowy wypisujący zmienną numer_max
-- równą maksymalnemu numerowi Departamentu i dodaj 
--do tabeli departamenty – departament z numerem 
--o 10 wiekszym, typ pola dla zmiennej z nazwą 
--nowego departamentu (zainicjować na EDUCATION)
-- ustawić taki jak dla pola department_name 
--w tabeli (%TYPE)

DECLARE 
   numer_max departments.department_id%type;
   EDUCATION departments.department_name%type;

BEGIN

  SELECT a.department_id INTO numer_max FROM departments a
  WHERE a.department_id = (SELECT MAX(department_id) FROM departments);
  
  DBMS_OUTPUT.put_line('Departament o najwyższym identyfkatorze: ' || numer_max);
  
  INSERT INTO departments VALUES (numer_max+10, 'EDUCATION',NULL, NULL);
END;
 
--===========================================================================

-- Zadanie 2

-- Do poprzedniego skryptu dodaj instrukcje zmieniającą
-- location_id (3000) dla dodanego departamentu 

DECLARE 
   numer_max departments.department_id%type;
   EDUCATION departments.department_name%type;

BEGIN

  SELECT a.department_id INTO numer_max FROM departments a
  WHERE a.department_id = (SELECT MAX(department_id) FROM departments);
  
  DBMS_OUTPUT.put_line('Departament o najwyższym identyfkatorze: ' || numer_max);
  
  INSERT INTO departments VALUES (numer_max+10, 'EDUCATION',NULL, NULL);
  
  UPDATE departments SET location_id = 3000 
  WHERE department_id = (SELECT MAX(department_id) FROM departments);
  
END;

--========================================================================

--Zadanie 3

-- Stwórz tabelę nowa z jednym polem typu varchar a następnie wpisz
-- do niej za pomocą pętli liczby od 1 do 10 bez liczb 4 i 6



CREATE TABLE nowa (liczby varchar(10));

DECLARE 
   i number(1);
   
BEGIN 
    
   FOR i IN 1..10 
   LOOP 
      IF NOT (i = 4 OR i = 6)
	  THEN INSERT INTO nowa VALUES(i);
      END IF;
   END loop; 
END;


--====================================================================

--Zadanie 4


--Wyciągnąć informacje z tabeli countries do jednej zmiennej
-- (%ROWTYPE) dla kraju o identyfikatorze ‘CA’. 
--Wypisać nazwę i region_id na ekran


DECLARE

   one_variable countries%ROWTYPE;
   
BEGIN

   SELECT * into one_variable FROM countries WHERE country_id = 'CA';
   
   DBMS_OUTPUT.put_line(one_variable.country_name);
   DBMS_OUTPUT.put_line(one_variable.region_id);
   
END;


--=======================================================================

--Zadanie 5

-- Za pomocą tabeli INDEX BY wyciągnąć informacje o nazwach departamentów
-- i wypisać na ekran 10 (numery 10,20,…,100)


DECLARE

   TYPE zad_5 IS TABLE OF departments.department_name%TYPE INDEX BY PLS_INTEGER;    
   
   department_list zad_5; 
   
   id_numbers NUMBER:=10;   
   
BEGIN 
   
     FOR i IN 1..10
     LOOP
       SELECT department_name INTO department_list(i) FROM departments 
       WHERE department_id = id_numbers;
       id_numbers := id_numbers + 10;
       DBMS_OUTPUT.put_line(department_list(i));       
     END LOOP;
       
END;  



--=======================================================================


--Zadanie 6

--Zmienić skrypt z 5 tak aby pojawiały się wszystkie informacje
-- na ekranie (wstawić %ROWTYPE do tabeli)


DECLARE

   TYPE zad_5 IS TABLE OF departments%ROWTYPE INDEX BY PLS_INTEGER;
   
   department_list zad_5; 
   
   id_numbers NUMBER:=10;
   
BEGIN

     FOR i IN 1..10
     LOOP
       SELECT * INTO department_list(i) FROM departments 
       WHERE department_id = id_numbers;
       id_numbers := id_numbers + 10;
       DBMS_OUTPUT.put_line(department_list(i).department_name || ' ' || department_list(i).department_id);
     END LOOP;
   
END;


--============================================================================

-- Zadanie 7

-- Zadeklaruj kursor jako wynagrodzenie, nazwisko dla departamentu
-- o numerze 50. Dla elementów kursora wypisać na ekran, 
--jeśli wynagrodzenie jest wyższe niż 3100: nazwisko osoby i tekst
-- ‘nie dawać podwyżki’ w przeciwnym przypadku: nazwisko + ‘dać podwyżkę’

DECLARE 
CURSOR zad_7 IS
    SELECT salary, last_name
    FROM employees
    WHERE department_id = 50;
BEGIN
    FOR wiersz IN zad_7
    LOOP
    IF wiersz.salary > 3100 THEN
        DBMS_OUTPUT.put_line(wiersz.last_name || ' nie dawac podwyzki');
    ELSE
        DBMS_OUTPUT.put_line(wiersz.last_name || ' dac podwyzke');
    END IF;
    END LOOP;
END;



-- Zadanie 8
   
-- Zadeklarować kursor zwracający zarobki imię i nazwisko pracownika
-- z parametrami, gdzie pierwsze dwa parametry określają widełki zarobków
-- a trzeci część imienia pracownika. Wypisać na ekran pracowników:
--      a. z widełkami 1000- 5000 z częścią imienia a (może być również A)
--      b. z widełkami 5000-20000 z częścią imienia u (może być również U)


DECLARE 
    CURSOR zad_8 (min_sal NUMBER, max_sal NUMBER, first_name_char VARCHAR) IS
    SELECT salary, first_name, last_name
    FROM employees
    WHERE salary > min_sal AND salary < max_sal AND (first_name LIKE LOWER('%' || first_name_char || '%')
    OR first_name LIKE UPPER('%' || first_name_char || '%'));
BEGIN
    DBMS_OUTPUT.put_line('Z litera a/A w imieniu');
    FOR wiersz IN zad_8(1000, 5000, 'a')
    LOOP
    DBMS_OUTPUT.put_line(wiersz.first_name || ' ' || wiersz.last_name || ' ' || wiersz.salary);
    END LOOP;
    DBMS_OUTPUT.put_line('Z litera u/U w imieniu');
    FOR wiersz IN zad_8(5000, 20000, 'u')
    LOOP
    DBMS_OUTPUT.put_line(wiersz.first_name || ' ' || wiersz.last_name || ' ' || wiersz.salary);
    END LOOP;
END;





-- Zadanie 9

-- Stwórz procedury:

-- a)
-- dodającą wiersz do tabeli Jobs – z dwoma parametrami wejściowymi określającymi Job_id,
-- Job_title, przetestuj działanie wrzuć wyjątki – co najmniej when others


CREATE OR REPLACE PROCEDURE zad_9a(new_job_id IN VARCHAR, new_job_title IN VARCHAR) IS
ex EXCEPTION;
BEGIN
    INSERT INTO jobs VALUES(new_job_id, new_job_title, NULL, NULL);
    DBMS_OUTPUT.put_line(new_job_id || ' ' || new_job_title || ' added to Jobs');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
    DBMS_OUTPUT.put_line('Job with this id already exists');
    WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('Error!');
END;



-- b)
-- modyfikującą title w  tabeli Jobs – z dwoma parametrami id dla którego ma być 
-- modyfikacja oraz nową wartość dla Job_title – przetestować działanie, dodać
-- swój wyjątek dla no Jobs updated – najpierw sprawdzić numer błędu


CREATE OR REPLACE PROCEDURE zad_9b(edit_job_id IN VARCHAR, edit_job_title IN VARCHAR) IS
wiersz jobs%ROWTYPE;
ex EXCEPTION;
BEGIN
    SELECT * INTO wiersz FROM jobs WHERE job_id=edit_job_id;
    UPDATE jobs SET job_title = edit_job_title
    WHERE job_id = edit_job_id;
    DBMS_OUTPUT.put_line('Job updated.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('There is nothing to update!');
    WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('Error!');
END;


-- c)
-- usuwającą wiersz z tabeli Jobs  o podanym Job_id– przetestować działanie,
-- dodaj wyjątek dla no Jobs deleted


CREATE OR REPLACE PROCEDURE zad_9c(delete_job_id IN VARCHAR) IS
wiersz jobs%ROWTYPE;
ex EXCEPTION;
BEGIN
    SELECT * INTO wiersz FROM jobs WHERE job_id=delete_job_id;
    DELETE FROM jobs WHERE job_id = delete_job_id;
    DBMS_OUTPUT.put_line('Job deleted');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('There is nothing to delete!');
    WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('Error!');
END;



-- d)
-- Wyciągającą zarobki i nazwisko (parametry zwracane przez procedurę) z tabeli employees
-- dla pracownika o przekazanym jako parametr id


CREATE OR REPLACE PROCEDURE zad_9d(find_employee_id IN VARCHAR, wages OUT NUMBER, surname OUT VARCHAR) IS
ex EXCEPTION;
BEGIN
    SELECT salary, last_name INTO wages, surname
    FROM employees WHERE employee_id=find_employee_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.put_line('No data found!');
    WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('Error!');
END;


-- e)
-- dodającą do tabeli employees wiersz – większość parametrów ustawić na domyślne
-- (id poprzez sekwencję), stworzyć wyjątek jeśli wynagrodzenie dodawanego pracownika
-- jest wyższe niż 20000


CREATE SEQUENCE employee_id_seq
INCREMENT BY 1
    START WITH 1
    MINVALUE 1
    MAXVALUE 100000
    CYCLE
    CACHE 2;


CREATE OR REPLACE PROCEDURE zad_9e(
emp_id IN NUMBER DEFAULT employee_id_seq.nextval,
emp_first_name IN VARCHAR DEFAULT 'Donald',
emp_last_name IN VARCHAR DEFAULT 'Trump',
emp_mail IN VARCHAR DEFAULT 'donnie@gmail.com',
emp_empl_date IN DATE DEFAULT SYSDATE,
emp_job_id IN VARCHAR DEFAULT 'MR_PRESIDENT',
emp_salary IN NUMBER DEFAULT 3000,
emp_commission IN NUMBER DEFAULT 2,
emp_manager_id IN NUMBER DEFAULT 124,
emp_depart_id IN NUMBER DEFAULT 50
) IS
ex EXCEPTION;
BEGIN
    IF emp_salary>20000 THEN
	RAISE ex;
    END IF;
    INSERT INTO employees VALUES(emp_id, emp_first_name, emp_last_name, emp_mail, emp_mail, emp_empl_date, emp_job_id, emp_salary, emp_commission, emp_manager_id, emp_depart_id);
    DBMS_OUTPUT.put_line('New employee created');
EXCEPTION
    WHEN ex THEN
    dbms_output.put_line('Salary beyond the limit!');
    WHEN DUP_VAL_ON_INDEX THEN
    DBMS_OUTPUT.put_line('Employee with this id number already exists');
    WHEN OTHERS THEN
    dbms_output.put_line('Error!');
END;