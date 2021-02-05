CREATE TABLE Regions (
    region_id int NOT NULL,
    region_name varchar(255),    
);

ALTER TABLE Regions
ADD CONSTRAINT PK_Regions PRIMARY KEY (region_id);

CREATE TABLE Countries (
    country_id int NOT NULL,
    country_name varchar(255),
	region_id int,
    PRIMARY KEY (country_id),
    FOREIGN KEY (region_id) REFERENCES Regions(region_id)	
);

CREATE TABLE Locations (
    location_id int NOT NULL,
	country_id int,
    street_address varchar(255),
	postal_code varchar(255),
	city varchar(255),
	state_province varchar(255),
    PRIMARY KEY (location_id),
    FOREIGN KEY (country_id) REFERENCES Countries(country_id)	
);

CREATE TABLE Departments (
    department_id int NOT NULL,
	location_id int,
	manager_id int,
    department_name varchar(255),
	PRIMARY KEY (department_id),
    FOREIGN KEY (location_id) REFERENCES Locations(location_id)	
);

CREATE TABLE Employees (
    employee_id int NOT NULL,
	department_id int,
	manager_id int,
    first_name varchar(255),
	last_name varchar(255),
	email varchar(255),
	phone_number varchar(255),
	hire_date date,
	salary float,
	commission_pct float,    	
	PRIMARY KEY (employee_id),
    CONSTRAINT fk FOREIGN KEY (department_id) REFERENCES Departments(department_id),
    CONSTRAINT fk1 FOREIGN KEY (manager_id) REFERENCES Employees(employee_id)	
);

ALTER TABLE Departments
ADD FOREIGN KEY (manager_id) REFERENCES Employees(employee_id);

CREATE TABLE Job_History (
    employee_id int,
	department_id int,
	job_id int,
	manager_id int,
	start_date date,
	end_date date,    
	PRIMARY KEY (employee_id, start_date),
	FOREIGN KEY (employee_id)REFERENCES Employees(employee_id),
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)	
);

CREATE TABLE Jobs (
    job_id int NOT NULL,
	job_title varchar(255),
	max_salary float,
    min_salary	float,
	CHECK(max_salary-min_salary>=2000),
	
	PRIMARY KEY (job_id)    	
);


ALTER TABLE Job_History
ADD FOREIGN KEY (job_id) REFERENCES Jobs(job_id); 