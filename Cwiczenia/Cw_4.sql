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






