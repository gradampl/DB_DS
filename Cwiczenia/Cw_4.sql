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

   c_salary employees.salary%type; 
   c_name employees.last_name%type; 
    
   CURSOR c_zad_7 is 
      SELECT salary, last_name FROM employees WHERE department_id = 50; 
	  
BEGIN 

   OPEN c_zad_7; 
   LOOP 
   FETCH c_zad_7 into c_salary, c_name; 
      EXIT WHEN c_zad_7%notfound;        
   END LOOP;    
   CLOSE c_zad_7;
   
   OPEN c_zad_7;   
   LOOP
   IF c_zad_7.last_name > 3100 THEN 
      DBMS_OUTPUT.put_line(c_zad_7.last_name || ' - nie dawać podwyżki!'); 
   ELSE  
      DBMS_OUTPUT.put_line(c_zad_7.last_name || ' - dać podwyżkę.'); 
   END IF;
   END LOOP;   
   CLOSE c_zad_7;
   
END; 
