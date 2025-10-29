create database PROJECTS;
use PROJECTS;

#roject Submission Phase-4
#(20-20 Queries per table: Views, Stored Procedures, Window Functions, DCL/TCL, Triggers)


#queries:----------------------------------------------------------------------------------------------------
#countries

-- View to show country name, continent, and GDP per capita above 10000
CREATE VIEW high_gdp_countries AS
SELECT country_name, continent, gdp_per_capita
FROM countries
WHERE gdp_per_capita > 10000;

-- View to calculate average GDP by continent
CREATE VIEW avg_gdp_by_continent AS
SELECT continent, ROUND(AVG(gdp_per_capita),2) AS avg_gdp
FROM countries
GROUP BY continent;

-- Stored Procedure to get countries by continent name
DELIMITER //
CREATE PROCEDURE getCountriesByContinent(IN cont_name VARCHAR(50))
BEGIN
  SELECT country_name, capital_city, gdp_per_capita
  FROM countries
  WHERE continent = cont_name;
END //
DELIMITER ;

-- Stored Procedure to update GDP of a country
DELIMITER //
CREATE PROCEDURE updateGDP(IN cid INT, IN new_gdp DECIMAL(12,2))
BEGIN
  UPDATE countries SET gdp_per_capita = new_gdp WHERE country_id = cid;
END //
DELIMITER ;

-- Stored Procedure to display top 3 richest countries
DELIMITER //
CREATE PROCEDURE topRichestCountries()
BEGIN
  SELECT country_name, gdp_per_capita
  FROM countries
  ORDER BY gdp_per_capita DESC
  LIMIT 3;
END //
DELIMITER ;

-- Window Function: Rank countries by GDP
SELECT country_name, continent, gdp_per_capita,
RANK() OVER (ORDER BY gdp_per_capita DESC) AS gdp_rank
FROM countries;

-- Window Function: Find average literacy rate per continent
SELECT country_name, continent, literacy_rate,
AVG(literacy_rate) OVER (PARTITION BY continent) AS avg_lit_by_continent
FROM countries;

-- Window Function: Running total of health budgets
SELECT country_name, SUM(health_budget) OVER (ORDER BY health_budget) AS running_total_budget
FROM countries;

-- DCL: Grant SELECT and UPDATE privileges on countries to user 'country_user'
GRANT SELECT, UPDATE ON countries TO 'country_user'@'localhost';

-- DCL: Revoke UPDATE privilege from user 'country_user'
REVOKE UPDATE ON countries FROM 'country_user'@'localhost';

-- TCL: Start a transaction for GDP update
START TRANSACTION;
UPDATE countries SET gdp_per_capita = gdp_per_capita + 1000 WHERE continent = 'Asia';
SAVEPOINT after_asia_update;
UPDATE countries SET gdp_per_capita = gdp_per_capita + 500 WHERE continent = 'Europe';
ROLLBACK TO after_asia_update;
COMMIT;

-- Trigger: Automatically update literacy rate if GDP increases significantly
DELIMITER //
CREATE TRIGGER update_literacy_after_gdp
AFTER UPDATE ON countries
FOR EACH ROW
BEGIN
  IF NEW.gdp_per_capita > OLD.gdp_per_capita + 10000 THEN
    UPDATE countries SET literacy_rate = literacy_rate + 0.5 WHERE country_id = NEW.country_id;
  END IF;
END //
DELIMITER ;

-- Trigger: Log deleted countries into a backup table
CREATE TABLE deleted_countries_log (
  log_id INT AUTO_INCREMENT PRIMARY KEY,
  country_id INT,
  country_name VARCHAR(100),
  deleted_on DATETIME
);

DELIMITER //
CREATE TRIGGER log_deleted_countries
BEFORE DELETE ON countries
FOR EACH ROW
BEGIN
  INSERT INTO deleted_countries_log(country_id, country_name, deleted_on)
  VALUES (OLD.country_id, OLD.country_name, NOW());
END //
DELIMITER ;

-- View to show countries with life expectancy greater than the average
CREATE VIEW above_avg_life AS
SELECT country_name, life_expectancy
FROM countries
WHERE life_expectancy > (SELECT AVG(life_expectancy) FROM countries);

-- View combining GDP and health budget in ratio form
CREATE VIEW gdp_health_ratio AS
SELECT country_name, ROUND(gdp_per_capita / (health_budget / 1000000000), 2) AS gdp_to_health_ratio
FROM countries;

-- Window Function: Dense rank of countries by literacy rate
SELECT country_name, literacy_rate,
DENSE_RANK() OVER (ORDER BY literacy_rate DESC) AS literacy_rank
FROM countries;

-- Stored Procedure to calculate total health budget by continent
DELIMITER //
CREATE PROCEDURE totalHealthBudget()
BEGIN
  SELECT continent, SUM(health_budget) AS total_health_budget
  FROM countries
  GROUP BY continent;
END //
DELIMITER ;

-- Trigger: Prevent inserting a country with GDP < 1000
DELIMITER //
CREATE TRIGGER prevent_low_gdp
BEFORE INSERT ON countries
FOR EACH ROW
BEGIN
  IF NEW.gdp_per_capita < 1000 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'GDP per capita cannot be less than 1000';
  END IF;
END //
DELIMITER ;

-- TCL: Rollback example on update failure
START TRANSACTION;
UPDATE countries SET population = population - 50000 WHERE country_name = 'India';
ROLLBACK;

-- View showing top 5 countries by life expectancy
CREATE VIEW top_life_exp AS
SELECT country_name, life_expectancy
FROM countries
ORDER BY life_expectancy DESC
LIMIT 5;

-- Stored Procedure to delete a country by ID
DELIMITER //
CREATE PROCEDURE deleteCountry(IN cid INT)
BEGIN
  DELETE FROM countries WHERE country_id = cid;
END //
DELIMITER ;
#====================================================================================================
#hospitals
CREATE VIEW hospital_view AS SELECT hospital_name, city, capacity, rating FROM hospitals;

CREATE VIEW top_hospitals AS SELECT hospital_name, rating FROM hospitals WHERE rating > 4.5;

CREATE VIEW city_hospitals AS SELECT city, COUNT(*) AS total FROM hospitals GROUP BY city;

CREATE VIEW general_hospitals AS SELECT * FROM hospitals WHERE specialization = 'General';

CREATE VIEW old_hospitals AS SELECT hospital_name, established_year FROM hospitals WHERE established_year < 1900;
delimiter //
CREATE PROCEDURE show_hospitals() 
BEGIN 
SELECT * FROM hospital
END ;
delimiter ;

delimiter //
CREATE PROCEDURE hospital_by_city(IN cityName VARCHAR(50)) BEGIN SELECT * FROM hospitals WHERE city = cityName; END;
delimiter //
CREATE PROCEDURE update_capacity(IN id INT, IN addCap INT) BEGIN UPDATE hospitals SET capacity = capacity + addCap WHERE hospital_id = id; END;
delimiter //
CREATE PROCEDURE top_rated_hospitals() BEGIN SELECT hospital_name, rating FROM hospitals ORDER BY rating DESC LIMIT 3; END;
delimiter //
CREATE PROCEDURE hospitals_by_specialization(IN spec VARCHAR(50)) BEGIN SELECT * FROM hospitals WHERE specialization = spec; END;

CREATE TRIGGER before_hospital_insert BEFORE INSERT ON hospitals FOR EACH ROW SET NEW.director_name = UPPER(NEW.director_name);

CREATE TRIGGER after_hospital_update AFTER UPDATE ON hospitals FOR EACH ROW INSERT INTO log_table VALUES (NOW(), 'Hospital updated');

CREATE TRIGGER before_hospital_delete BEFORE DELETE ON hospitals FOR EACH ROW INSERT INTO deleted_hospitals VALUES (OLD.hospital_id, OLD.hospital_name, NOW());

CREATE TRIGGER hospital_capacity_check BEFORE INSERT ON hospitals FOR EACH ROW IF NEW.capacity < 500 THEN SET NEW.capacity = 500; END IF;

CREATE TRIGGER set_default_rating BEFORE INSERT ON hospitals FOR EACH ROW IF NEW.rating IS NULL THEN SET NEW.rating = 3.5; END IF;

SELECT hospital_name, rating, RANK() OVER (ORDER BY rating DESC) AS rank_rating FROM hospitals;

SELECT city, capacity, DENSE_RANK() OVER (PARTITION BY city ORDER BY capacity DESC) AS city_rank FROM hospitals;

SELECT hospital_name, rating, ROW_NUMBER() OVER (ORDER BY rating DESC) AS row_num FROM hospitals;

SELECT hospital_name, AVG(capacity) OVER (PARTITION BY city) AS avg_city_capacity FROM hospitals;

GRANT SELECT, UPDATE ON hospitals TO 'staff1'@'localhost';
#============================================================================================================
#doctors
CREATE VIEW doctor_view AS SELECT first_name, last_name, specialty, salary FROM doctors;

CREATE VIEW high_salary_doctors AS SELECT * FROM doctors WHERE salary > 140000;

CREATE VIEW doctor_specialization_count AS SELECT specialty, COUNT(*) AS total FROM doctors GROUP BY specialty;

CREATE VIEW female_doctors AS SELECT * FROM doctors WHERE gender = 'F';

CREATE VIEW experienced_doctors AS SELECT * FROM doctors WHERE experience_years > 10;

CREATE PROCEDURE show_doctors() BEGIN SELECT * FROM doctors; END;

CREATE PROCEDURE doctor_by_specialty(IN spec VARCHAR(50)) BEGIN SELECT * FROM doctors WHERE specialty = spec; END;

CREATE PROCEDURE increase_salary(IN percent DECIMAL(5,2)) BEGIN UPDATE doctors SET salary = salary + (salary * percent / 100); END;

CREATE PROCEDURE top_paid_doctors() BEGIN SELECT first_name, salary FROM doctors ORDER BY salary DESC LIMIT 5; END;

CREATE PROCEDURE doctors_by_hospital(IN hid INT) BEGIN SELECT * FROM doctors WHERE hospital_id = hid; END;

CREATE TRIGGER before_doctor_insert BEFORE INSERT ON doctors FOR EACH ROW SET NEW.first_name = UPPER(NEW.first_name);

CREATE TRIGGER after_doctor_update AFTER UPDATE ON doctors FOR EACH ROW INSERT INTO log_table VALUES (NOW(), 'Doctor updated');

CREATE TRIGGER before_doctor_delete BEFORE DELETE ON doctors FOR EACH ROW INSERT INTO deleted_doctors VALUES (OLD.doctor_id, OLD.first_name, NOW());

CREATE TRIGGER salary_check BEFORE INSERT ON doctors FOR EACH ROW IF NEW.salary < 50000 THEN SET NEW.salary = 50000; END IF;

CREATE TRIGGER default_email BEFORE INSERT ON doctors FOR EACH ROW IF NEW.email IS NULL THEN SET NEW.email = CONCAT(NEW.first_name, '@hospital.com'); END IF;

SELECT first_name, salary, RANK() OVER (ORDER BY salary DESC) AS salary_rank FROM doctors;

SELECT hospital_id, salary, DENSE_RANK() OVER (PARTITION BY hospital_id ORDER BY salary DESC) AS hospital_rank FROM doctors;

SELECT first_name, ROW_NUMBER() OVER (ORDER BY experience_years DESC) AS exp_order FROM doctors;

SELECT specialty, AVG(salary) OVER (PARTITION BY specialty) AS avg_salary FROM doctors;

GRANT SELECT, INSERT ON doctors TO 'doctor1'@'localhost';

#=================================================================================================================
#patients
CREATE VIEW patient_view AS SELECT first_name, last_name, status FROM patients;

CREATE VIEW recovered_patients AS SELECT * FROM patients WHERE status = 'Recovered';

CREATE VIEW under_treatment_patients AS SELECT * FROM patients WHERE discharge_date IS NULL;

CREATE VIEW patients_by_country AS SELECT country_id, COUNT(*) AS total FROM patients GROUP BY country_id;

CREATE VIEW female_patients AS SELECT * FROM patients WHERE gender = 'F';

CREATE PROCEDURE show_patients() BEGIN SELECT * FROM patients; END;

CREATE PROCEDURE patient_by_status(IN stat VARCHAR(50)) BEGIN SELECT * FROM patients WHERE status = stat; END;

CREATE PROCEDURE update_status(IN id INT, IN newStatus VARCHAR(50)) BEGIN UPDATE patients SET status = newStatus WHERE patient_id = id; END;

CREATE PROCEDURE count_recovered() BEGIN SELECT COUNT(*) AS total_recovered FROM patients WHERE status='Recovered'; END;

CREATE PROCEDURE delete_recovered() BEGIN DELETE FROM patients WHERE status='Recovered'; END;

CREATE TRIGGER before_patient_insert BEFORE INSERT ON patients FOR EACH ROW SET NEW.first_name = UPPER(NEW.first_name);

CREATE TRIGGER after_patient_update AFTER UPDATE ON patients FOR EACH ROW INSERT INTO log_table VALUES (NOW(), 'Patient updated');

CREATE TRIGGER before_patient_delete BEFORE DELETE ON patients FOR EACH ROW INSERT INTO deleted_patients VALUES (OLD.patient_id, OLD.first_name, NOW());

CREATE TRIGGER default_status BEFORE INSERT ON patients FOR EACH ROW IF NEW.status IS NULL THEN SET NEW.status = 'Under Observation'; END IF;

CREATE TRIGGER admission_date_check BEFORE INSERT ON patients FOR EACH ROW IF NEW.admission_date > NOW() THEN SET NEW.admission_date = NOW(); END IF;

SELECT first_name, status, ROW_NUMBER() OVER (ORDER BY admission_date ASC) AS patient_order FROM patients;

SELECT country_id, COUNT(*) OVER (PARTITION BY country_id) AS total_country_patients FROM patients;

SELECT first_name, DENSE_RANK() OVER (ORDER BY dob ASC) AS age_rank FROM patients;

SELECT disease_id, RANK() OVER (ORDER BY disease_id ASC) AS disease_order FROM patients;

GRANT SELECT, UPDATE ON patients TO 'nurse1'@'localhost';

#=============================================================================================================
#diseases
CREATE VIEW disease_view AS SELECT disease_name, category, mortality_rate FROM diseases;

CREATE VIEW viral_diseases AS SELECT * FROM diseases WHERE category='Viral';

CREATE VIEW vaccine_available AS SELECT disease_name FROM diseases WHERE vaccine_available=TRUE;

CREATE VIEW high_mortality_diseases AS SELECT * FROM diseases WHERE mortality_rate>10;

CREATE VIEW recent_diseases AS SELECT disease_name, discovered_year FROM diseases WHERE discovered_year>2000;

CREATE PROCEDURE show_diseases() BEGIN SELECT * FROM diseases; END;

CREATE PROCEDURE disease_by_category(IN cat VARCHAR(50)) BEGIN SELECT * FROM diseases WHERE category = cat; END;

CREATE PROCEDURE update_notes(IN id INT, IN note TEXT) BEGIN UPDATE diseases SET notes = note WHERE disease_id = id; END;

CREATE PROCEDURE avg_mortality() BEGIN SELECT AVG(mortality_rate) AS avg_rate FROM diseases; END;

CREATE PROCEDURE diseases_with_vaccine() BEGIN SELECT * FROM diseases WHERE vaccine_available=TRUE; END;

CREATE TRIGGER before_disease_insert BEFORE INSERT ON diseases FOR EACH ROW SET NEW.disease_name = UPPER(NEW.disease_name);

CREATE TRIGGER after_disease_update AFTER UPDATE ON diseases FOR EACH ROW INSERT INTO log_table VALUES (NOW(), 'Disease updated');

CREATE TRIGGER before_disease_delete BEFORE DELETE ON diseases FOR EACH ROW INSERT INTO deleted_diseases VALUES (OLD.disease_id, OLD.disease_name, NOW());

CREATE TRIGGER check_mortality BEFORE INSERT ON diseases FOR EACH ROW IF NEW.mortality_rate < 0 THEN SET NEW.mortality_rate = 0; END IF;

CREATE TRIGGER default_vaccine BEFORE INSERT ON diseases FOR EACH ROW IF NEW.vaccine_available IS NULL THEN SET NEW.vaccine_available = FALSE; END IF;

SELECT disease_name, mortality_rate, RANK() OVER (ORDER BY mortality_rate DESC) AS death_rank FROM diseases;

SELECT category, AVG(mortality_rate) OVER (PARTITION BY category) AS avg_mortality FROM diseases;

SELECT disease_name, ROW_NUMBER() OVER (ORDER BY discovered_year ASC) AS discovery_order FROM diseases;

SELECT disease_name, DENSE_RANK() OVER (ORDER BY discovered_year DESC) AS recent_rank FROM diseases;

GRANT SELECT, UPDATE ON diseases TO 'researcher1'@'localhost';

#============================================================================================================
#vaccines
-- ======= VIEWS (4) =======
CREATE OR REPLACE VIEW v_vaccine_basic AS
SELECT vaccine_id, vaccine_name, manufacturer, disease_id, approval_year FROM vaccines;

CREATE OR REPLACE VIEW v_vaccine_storage AS
SELECT vaccine_id, vaccine_name, storage_temp, expiry_period FROM vaccines;

CREATE OR REPLACE VIEW v_vaccine_efficacy_high AS
SELECT vaccine_id, vaccine_name, efficacy_rate FROM vaccines WHERE efficacy_rate >= 90;

CREATE OR REPLACE VIEW v_vaccine_summary AS
SELECT vaccine_id, vaccine_name, manufacturer, efficacy_rate, expiry_period FROM vaccines;

-- ======= STORED PROCEDURES (4) =======
DELIMITER //
CREATE PROCEDURE sp_GetVaccineByDisease(IN in_disease_id INT)
BEGIN
  SELECT * FROM vaccines WHERE disease_id = in_disease_id;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_ListVaccinesByManufacturer(IN in_man VARCHAR(100))
BEGIN
  SELECT vaccine_id, vaccine_name, approval_year FROM vaccines WHERE manufacturer = in_man;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_UpdateEfficacy(IN in_vaccine_id INT, IN in_new_eff DECIMAL(5,2))
BEGIN
  UPDATE vaccines SET efficacy_rate = in_new_eff WHERE vaccine_id = in_vaccine_id;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_GetVaccineExpiry(IN in_months INT)
BEGIN
  SELECT vaccine_id, vaccine_name, expiry_period FROM vaccines WHERE expiry_period <= in_months;
END //
DELIMITER ;

-- ======= WINDOW / ANALYTIC QUERIES (4) =======
-- row number partitioned by manufacturer ordered by efficacy desc
SELECT vaccine_id, vaccine_name, manufacturer, efficacy_rate,
       ROW_NUMBER() OVER (PARTITION BY manufacturer ORDER BY efficacy_rate DESC) AS rn_by_man
FROM vaccines;

-- lead/lag to compare efficacy with next vaccine by manufacturer
SELECT vaccine_id, vaccine_name, manufacturer, efficacy_rate,
       LAG(efficacy_rate) OVER (PARTITION BY manufacturer ORDER BY efficacy_rate DESC) AS prev_eff,
       LEAD(efficacy_rate) OVER (PARTITION BY manufacturer ORDER BY efficacy_rate DESC) AS next_eff
FROM vaccines;

-- rank by efficacy overall
SELECT vaccine_id, vaccine_name, efficacy_rate,
       RANK() OVER (ORDER BY efficacy_rate DESC) AS eff_rank
FROM vaccines;

-- running count of vaccines per manufacturer
SELECT vaccine_id, vaccine_name, manufacturer,
       COUNT(*) OVER (PARTITION BY manufacturer) AS vaccines_per_manufacturer
FROM vaccines;

-- ======= DCL / TCL (4) =======
-- create user and grant limited read to vaccines
CREATE USER IF NOT EXISTS 'vreader'@'localhost' IDENTIFIED BY 'vreader_pass';
GRANT SELECT ON `your_database_name`.`vaccines` TO 'vreader'@'localhost';
FLUSH PRIVILEGES;

-- grant update for admin role (example)
GRANT UPDATE ON `your_database_name`.`vaccines` TO 'admin_user'@'localhost';

-- transaction example (TCL)
START TRANSACTION;
-- (example) UPDATE vaccines SET efficacy_rate = efficacy_rate WHERE vaccine_id = vaccine_id;
COMMIT;

-- rollback example
START TRANSACTION;
-- (example) UPDATE vaccines SET expiry_period = expiry_period WHERE vaccine_id = -1;
ROLLBACK;

-- ======= TRIGGERS (4) =======
DELIMITER //
CREATE TRIGGER trg_vaccine_before_update
BEFORE UPDATE ON vaccines
FOR EACH ROW
BEGIN
  -- keep efficacy_rate between 0 and 100
  IF NEW.efficacy_rate < 0 THEN SET NEW.efficacy_rate = 0; END IF;
  IF NEW.efficacy_rate > 100 THEN SET NEW.efficacy_rate = 100; END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_vaccine_after_insert
AFTER INSERT ON vaccines
FOR EACH ROW
BEGIN
  -- example: write to a logging table (assumes vaccine_audit exists)
  -- INSERT INTO vaccine_audit(vaccine_id, action, action_time) VALUES (NEW.vaccine_id, 'INSERT', NOW());
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_vaccine_before_delete
BEFORE DELETE ON vaccines
FOR EACH ROW
BEGIN
  -- prevent deletion of high-efficacy vaccines (example rule)
  IF OLD.efficacy_rate >= 90 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete vaccine with high efficacy';
  END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_vaccine_after_update
AFTER UPDATE ON vaccines
FOR EACH ROW
BEGIN
  -- example: if expiry_period decreased, log (assumes vaccine_audit)
  -- IF NEW.expiry_period < OLD.expiry_period THEN INSERT INTO vaccine_audit(vaccine_id, action, action_time) VALUES (NEW.vaccine_id, 'EXPIRY_DECREASE', NOW()); END IF;
END //
DELIMITER ;
#==================================================================================================
#vaccination center
-- ======= VIEWS (4) =======
CREATE OR REPLACE VIEW v_centers_basic AS
SELECT center_id, center_name, city, capacity_per_day FROM vaccination_centers;

CREATE OR REPLACE VIEW v_centers_by_country AS
SELECT center_id, center_name, country_id, city FROM vaccination_centers;

CREATE OR REPLACE VIEW v_centers_high_capacity AS
SELECT center_id, center_name, capacity_per_day FROM vaccination_centers WHERE capacity_per_day >= 500;

CREATE OR REPLACE VIEW v_center_hours AS
SELECT center_id, center_name, opening_time, closing_time FROM vaccination_centers;

-- ======= STORED PROCEDURES (4) =======
DELIMITER //
CREATE PROCEDURE sp_GetCentersByCity(IN in_city VARCHAR(100))
BEGIN
  SELECT * FROM vaccination_centers WHERE city = in_city;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_UpdateCenterCapacity(IN in_center INT, IN add_cap INT)
BEGIN
  UPDATE vaccination_centers SET capacity_per_day = capacity_per_day + add_cap WHERE center_id = in_center;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_GetCentersByCountry(IN in_country INT)
BEGIN
  SELECT center_id, center_name, city, capacity_per_day FROM vaccination_centers WHERE country_id = in_country;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_GetOpenCentersAtTime(IN in_time TIME)
BEGIN
  SELECT center_id, center_name, opening_time, closing_time
  FROM vaccination_centers
  WHERE opening_time <= in_time AND closing_time >= in_time;
END //
DELIMITER ;

-- ======= WINDOW / ANALYTIC QUERIES (4) =======
-- rank centers within country by capacity
SELECT center_id, center_name, country_id, capacity_per_day,
       RANK() OVER (PARTITION BY country_id ORDER BY capacity_per_day DESC) AS rank_in_country
FROM vaccination_centers;

-- row_number ordered by capacity
SELECT center_id, center_name, city, capacity_per_day,
       ROW_NUMBER() OVER (ORDER BY capacity_per_day DESC) AS rn_overall
FROM vaccination_centers;

-- lead/lag to compare capacities
SELECT center_id, center_name, capacity_per_day,
       LAG(capacity_per_day) OVER (ORDER BY capacity_per_day) AS prev_cap,
       LEAD(capacity_per_day) OVER (ORDER BY capacity_per_day) AS next_cap
FROM vaccination_centers;

-- cumulative count of centers by country
SELECT center_id, country_id,
       COUNT(*) OVER (PARTITION BY country_id) AS centers_in_country
FROM vaccination_centers;

-- ======= DCL / TCL (4) =======
-- create viewer role & grant select
CREATE USER IF NOT EXISTS 'center_view'@'localhost' IDENTIFIED BY 'center_view_pass';
GRANT SELECT ON `your_database_name`.`vaccination_centers` TO 'center_view'@'localhost';
FLUSH PRIVILEGES;

-- grant update for operations staff
GRANT UPDATE ON `your_database_name`.`vaccination_centers` TO 'ops_user'@'localhost';

-- transaction example for capacity update
START TRANSACTION;
UPDATE vaccination_centers SET capacity_per_day = capacity_per_day + 10 WHERE center_id = 1;
COMMIT;

-- rollback example
START TRANSACTION;
UPDATE vaccination_centers SET capacity_per_day = capacity_per_day - 5 WHERE center_id = -1;
ROLLBACK;

-- ======= TRIGGERS (4) =======
DELIMITER //
CREATE TRIGGER trg_center_before_update
BEFORE UPDATE ON vaccination_centers
FOR EACH ROW
BEGIN
  -- ensure capacity never negative
  IF NEW.capacity_per_day < 0 THEN SET NEW.capacity_per_day = 0; END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_center_after_insert
AFTER INSERT ON vaccination_centers
FOR EACH ROW
BEGIN
  -- example logging: INSERT INTO center_audit(center_id, action_time, action) VALUES (NEW.center_id, NOW(), 'INSERT');
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_center_before_delete
BEFORE DELETE ON vaccination_centers
FOR EACH ROW
BEGIN
  -- prevent deleting centers with capacity > 800 (example policy)
  IF OLD.capacity_per_day > 800 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete high-capacity center';
  END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_center_after_update
AFTER UPDATE ON vaccination_centers
FOR EACH ROW
BEGIN
  -- if opening time changed, example notification (pseudocode)
  -- IF NEW.opening_time <> OLD.opening_time THEN INSERT INTO notifications(...) END IF;
END //
DELIMITER ;
#=======================================================================================================
#vaccination_records
-- ======= VIEWS (4) =======
CREATE OR REPLACE VIEW v_vacc_records_basic AS
SELECT record_id, patient_id, vaccine_id, center_id, dose_number, vaccination_date FROM vaccination_records;

CREATE OR REPLACE VIEW v_vacc_sideeffects AS
SELECT record_id, patient_id, vaccine_id, side_effects FROM vaccination_records WHERE side_effects <> 'None';

CREATE OR REPLACE VIEW v_vacc_by_center AS
SELECT center_id, COUNT(*) AS records_count FROM vaccination_records GROUP BY center_id;

CREATE OR REPLACE VIEW v_vacc_recent AS
SELECT * FROM vaccination_records WHERE vaccination_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

-- ======= STORED PROCEDURES (4) =======
DELIMITER //
CREATE PROCEDURE sp_GetRecordsByPatient(IN in_patient INT)
BEGIN
  SELECT * FROM vaccination_records WHERE patient_id = in_patient ORDER BY vaccination_date;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_GetRecordsByVaccine(IN in_vaccine INT)
BEGIN
  SELECT * FROM vaccination_records WHERE vaccine_id = in_vaccine;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_MarkRecordVerified(IN in_record INT)
BEGIN
  UPDATE vaccination_records SET remarks = CONCAT(IFNULL(remarks,''),' | Verified: ',CURDATE()) WHERE record_id = in_record;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_GetCenterVaccCount(IN in_center INT)
BEGIN
  SELECT center_id, COUNT(*) AS total_vaccinations FROM vaccination_records WHERE center_id = in_center GROUP BY center_id;
END //
DELIMITER ;

-- ======= WINDOW / ANALYTIC QUERIES (4) =======
-- rank patients by number of doses received
SELECT patient_id, vaccine_id, dose_number,
       DENSE_RANK() OVER (PARTITION BY vaccine_id ORDER BY dose_number DESC) AS dose_rank
FROM vaccination_records;

-- lead to see next dose date per patient/vaccine
SELECT record_id, patient_id, vaccine_id, vaccination_date,
       LEAD(vaccination_date) OVER (PARTITION BY patient_id, vaccine_id ORDER BY vaccination_date) AS next_dose_date
FROM vaccination_records;

-- row_number per patient to get sequence of doses
SELECT record_id, patient_id, vaccination_date,
       ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY vaccination_date) AS dose_seq
FROM vaccination_records;

-- count of doses per vaccine (window)
SELECT record_id, vaccine_id,
       COUNT(*) OVER (PARTITION BY vaccine_id) AS doses_per_vaccine
FROM vaccination_records;

-- ======= DCL / TCL (4) =======
-- create a reporting user
CREATE USER IF NOT EXISTS 'vacc_report'@'localhost' IDENTIFIED BY 'report_pass';
GRANT SELECT ON `your_database_name`.`vaccination_records` TO 'vacc_report'@'localhost';
FLUSH PRIVILEGES;

-- grant insert only for data entry operator
GRANT INSERT ON `your_database_name`.`vaccination_records` TO 'data_entry'@'localhost';

-- transaction example: insert simulated record then commit
START TRANSACTION;
-- INSERT INTO vaccination_records(record_id, patient_id, vaccine_id, center_id, dose_number, vaccination_date, batch_number, administered_by) VALUES (...);
COMMIT;

-- rollback example
START TRANSACTION;
-- INSERT INTO vaccination_records(...) VALUES (...);
ROLLBACK;

-- ======= TRIGGERS (4) =======
DELIMITER //
CREATE TRIGGER trg_vrec_before_insert
BEFORE INSERT ON vaccination_records
FOR EACH ROW
BEGIN
  -- ensure dose_number >=1
  IF NEW.dose_number < 1 THEN SET NEW.dose_number = 1; END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_vrec_after_insert
AFTER INSERT ON vaccination_records
FOR EACH ROW
BEGIN
  -- example: increment counter in center_stats (assumes exists)
  -- INSERT INTO center_stats(center_id, day, count) VALUES (NEW.center_id, DATE(NEW.vaccination_date), 1) ON DUPLICATE KEY UPDATE count = count + 1;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_vrec_before_update
BEFORE UPDATE ON vaccination_records
FOR EACH ROW
BEGIN
  -- prevent changing administered_by to empty
  IF NEW.administered_by IS NULL OR NEW.administered_by = '' THEN
    SET NEW.administered_by = OLD.administered_by;
  END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_vrec_after_delete
AFTER DELETE ON vaccination_records
FOR EACH ROW
BEGIN
  -- example: log deletion (assumes vacc_log exists)
  -- INSERT INTO vacc_log(record_id, deleted_on) VALUES (OLD.record_id, NOW());
END //
DELIMITER ;
#=========================================================================================================
#research_projects
-- ======= VIEWS (4) =======
CREATE OR REPLACE VIEW v_projects_basic AS
SELECT project_id, project_name, disease_id, start_date, end_date FROM research_projects;

CREATE OR REPLACE VIEW v_projects_ongoing AS
SELECT project_id, project_name, lead_scientist FROM research_projects WHERE status = 'Ongoing';

CREATE OR REPLACE VIEW v_projects_budget AS
SELECT project_id, project_name, budget, funding_source FROM research_projects;

CREATE OR REPLACE VIEW v_projects_timeline AS
SELECT project_id, project_name, start_date, end_date, status FROM research_projects;

-- ======= STORED PROCEDURES (4) =======
DELIMITER //
CREATE PROCEDURE sp_GetProjectsByScientist(IN in_scientist VARCHAR(100))
BEGIN
  SELECT project_id, project_name, status FROM research_projects WHERE lead_scientist = in_scientist;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_ExtendProject(IN in_project INT, IN new_end DATE)
BEGIN
  UPDATE research_projects SET end_date = new_end, status = 'Extended' WHERE project_id = in_project;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_GetProjectsByDisease(IN in_disease INT)
BEGIN
  SELECT project_id, project_name FROM research_projects WHERE disease_id = in_disease;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_MarkProjectComplete(IN in_project INT)
BEGIN
  UPDATE research_projects SET status = 'Completed' WHERE project_id = in_project;
END //
DELIMITER ;

-- ======= WINDOW / ANALYTIC QUERIES (4) =======
-- rank projects by budget per disease
SELECT project_id, project_name, disease_id, budget,
       RANK() OVER (PARTITION BY disease_id ORDER BY budget DESC) AS budget_rank_in_disease
FROM research_projects;

-- lead/lag to see adjacent project end dates per disease
SELECT project_id, disease_id, start_date, end_date,
       LAG(end_date) OVER (PARTITION BY disease_id ORDER BY end_date) AS prev_end,
       LEAD(end_date) OVER (PARTITION BY disease_id ORDER BY end_date) AS next_end
FROM research_projects;

-- row_number of projects per lead scientist
SELECT project_id, lead_scientist,
       ROW_NUMBER() OVER (PARTITION BY lead_scientist ORDER BY start_date) AS proj_seq
FROM research_projects;

-- cumulative count of ongoing projects
SELECT project_id, status,
       COUNT(*) OVER (PARTITION BY status) AS count_by_status
FROM research_projects;

-- ======= DCL / TCL (4) =======
-- create user for research viewer
CREATE USER IF NOT EXISTS 'research_view'@'localhost' IDENTIFIED BY 'rview_pass';
GRANT SELECT ON `your_database_name`.`research_projects` TO 'research_view'@'localhost';
FLUSH PRIVILEGES;

-- grant update for project managers
GRANT UPDATE ON `your_database_name`.`research_projects` TO 'proj_manager'@'localhost';

-- transaction example: extend project then commit
START TRANSACTION;
UPDATE research_projects SET end_date = DATE_ADD(end_date, INTERVAL 6 MONTH) WHERE project_id = 1;
COMMIT;

-- rollback example for safe testing
START TRANSACTION;
UPDATE research_projects SET status = status WHERE project_id = -1;
ROLLBACK;

-- ======= TRIGGERS (4) =======
DELIMITER //
CREATE TRIGGER trg_projects_before_update
BEFORE UPDATE ON research_projects
FOR EACH ROW
BEGIN
  -- ensure budget not negative
  IF NEW.budget < 0 THEN SET NEW.budget = OLD.budget; END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_projects_after_insert
AFTER INSERT ON research_projects
FOR EACH ROW
BEGIN
  -- example: notify funding team (pseudocode)
  -- INSERT INTO notifications(project_id, msg, created_on) VALUES (NEW.project_id, 'New project added', NOW());
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_projects_before_delete
BEFORE DELETE ON research_projects
FOR EACH ROW
BEGIN
  -- prevent deleting projects with status 'Ongoing'
  IF OLD.status = 'Ongoing' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete ongoing project';
  END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_projects_after_update
AFTER UPDATE ON research_projects
FOR EACH ROW
BEGIN
  -- log status changes (assumes project_audit)
  -- IF NEW.status <> OLD.status THEN INSERT INTO project_audit(project_id, old_status, new_status, changed_on) VALUES (NEW.project_id, OLD.status, NEW.status, NOW()); END IF;
END //
DELIMITER ;
#==========================================================================================================
#funding
-- ======= VIEWS (4) =======
CREATE OR REPLACE VIEW v_funding_basic AS
SELECT funding_id, project_id, donor_name, amount, funding_date FROM funding;

CREATE OR REPLACE VIEW v_funding_by_project AS
SELECT project_id, donor_name, amount FROM funding;

CREATE OR REPLACE VIEW v_large_funding AS
SELECT funding_id, donor_name, amount FROM funding WHERE amount >= 800000;

CREATE OR REPLACE VIEW v_funding_recent AS
SELECT * FROM funding WHERE funding_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

-- ======= STORED PROCEDURES (4) =======
DELIMITER //
CREATE PROCEDURE sp_GetFundingByDonor(IN in_donor VARCHAR(100))
BEGIN
  SELECT funding_id, project_id, amount FROM funding WHERE donor_name = in_donor;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_AddRemark(IN in_funding INT, IN in_remark TEXT)
BEGIN
  UPDATE funding SET remarks = CONCAT(IFNULL(remarks,''), ' | ', in_remark) WHERE funding_id = in_funding;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_GetFundingByProject(IN in_project INT)
BEGIN
  SELECT funding_id, donor_name, amount FROM funding WHERE project_id = in_project;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_UpdateFundingAmount(IN in_funding INT, IN in_amount DECIMAL(15,2))
BEGIN
  UPDATE funding SET amount = in_amount WHERE funding_id = in_funding;
END //
DELIMITER ;

-- ======= WINDOW / ANALYTIC QUERIES (4) =======
-- rank donors by amount for each project
SELECT funding_id, project_id, donor_name, amount,
       RANK() OVER (PARTITION BY project_id ORDER BY amount DESC) AS donor_rank_in_project
FROM funding;

-- lead/lag of funding_date to see previous funding per project
SELECT funding_id, project_id, funding_date,
       LAG(funding_date) OVER (PARTITION BY project_id ORDER BY funding_date) AS prev_funding_date,
       LEAD(funding_date) OVER (PARTITION BY project_id ORDER BY funding_date) AS next_funding_date
FROM funding;

-- row_number per donor by amount
SELECT funding_id, donor_name, amount,
       ROW_NUMBER() OVER (PARTITION BY donor_name ORDER BY amount DESC) AS rn_by_donor
FROM funding;

-- count of fundings per project (window)
SELECT funding_id, project_id,
       COUNT(*) OVER (PARTITION BY project_id) AS fundings_per_project
FROM funding;

-- ======= DCL / TCL (4) =======
-- grant select to financial analyst
CREATE USER IF NOT EXISTS 'fin_analyst'@'localhost' IDENTIFIED BY 'fan_pass';
GRANT SELECT ON `your_database_name`.`funding` TO 'fin_analyst'@'localhost';
FLUSH PRIVILEGES;

-- grant update for finance_manager
GRANT UPDATE ON `your_database_name`.`funding` TO 'finance_manager'@'localhost';

-- transaction: adjust funding then commit
START TRANSACTION;
UPDATE funding SET amount = amount + 50000 WHERE funding_id = 1;
COMMIT;

-- rollback example
START TRANSACTION;
UPDATE funding SET amount = amount WHERE funding_id = -1;
ROLLBACK;

-- ======= TRIGGERS (4) =======
DELIMITER //
CREATE TRIGGER trg_funding_before_insert
BEFORE INSERT ON funding
FOR EACH ROW
BEGIN
  -- ensure amount positive
  IF NEW.amount < 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Funding amount must be positive'; END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_funding_after_insert
AFTER INSERT ON funding
FOR EACH ROW
BEGIN
  -- example: notify project lead (pseudocode)
  -- INSERT INTO notifications(project_id, msg, created_on) VALUES (NEW.project_id, CONCAT('New funding from ', NEW.donor_name), NOW());
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_funding_before_update
BEFORE UPDATE ON funding
FOR EACH ROW
BEGIN
  -- prevent large sudden decreases (example business rule)
  IF NEW.amount < OLD.amount * 0.5 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Funding amount cannot drop by more than 50%';
  END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_funding_after_delete
AFTER DELETE ON funding
FOR EACH ROW
BEGIN
  -- example: log deletion (assumes funding_log table exists)
  -- INSERT INTO funding_log(funding_id, deleted_on) VALUES (OLD.funding_id, NOW());
END //
DELIMITER ;
#========================================================================================================
#awarness_campaigns
-- ======= VIEWS =======
CREATE OR REPLACE VIEW v_campaigns_basic AS
SELECT campaign_id, campaign_name, country_id, start_date, end_date FROM awareness_campaigns;

CREATE OR REPLACE VIEW v_campaigns_budget AS
SELECT campaign_id, campaign_name, budget, organizer FROM awareness_campaigns;

CREATE OR REPLACE VIEW v_campaigns_active AS
SELECT campaign_id, campaign_name, start_date, end_date
FROM awareness_campaigns
WHERE CURDATE() BETWEEN start_date AND end_date;

CREATE OR REPLACE VIEW v_campaigns_outcome AS
SELECT campaign_id, campaign_name, outcome FROM awareness_campaigns WHERE outcome IS NOT NULL;

-- ======= STORED PROCEDURES =======
DELIMITER //
CREATE PROCEDURE sp_GetCampaignsByCountry(IN in_country INT)
BEGIN
  SELECT campaign_id, campaign_name, start_date, end_date FROM awareness_campaigns WHERE country_id = in_country;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_UpdateCampaignOutcome(IN in_campaign INT, IN in_outcome TEXT)
BEGIN
  UPDATE awareness_campaigns SET outcome = in_outcome WHERE campaign_id = in_campaign;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_GetCampaignsByOrganizer(IN in_org VARCHAR(100))
BEGIN
  SELECT campaign_id, campaign_name, budget FROM awareness_campaigns WHERE organizer = in_org;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_ExtendCampaign(IN in_campaign INT, IN new_end DATE)
BEGIN
  UPDATE awareness_campaigns SET end_date = new_end WHERE campaign_id = in_campaign;
END //
DELIMITER ;

-- ======= WINDOW / ANALYTIC QUERIES =======
-- For each country show campaigns and rank by budget
SELECT campaign_id, campaign_name, country_id, budget,
       RANK() OVER (PARTITION BY country_id ORDER BY budget DESC) AS budget_rank
FROM awareness_campaigns;

-- Row number by organizer to get sequence of campaigns
SELECT campaign_id, campaign_name, organizer,
       ROW_NUMBER() OVER (PARTITION BY organizer ORDER BY start_date) AS org_campaign_seq
FROM awareness_campaigns;

-- Lead/Lag to compare campaign end_dates in the same country
SELECT campaign_id, country_id, start_date, end_date,
       LAG(end_date) OVER (PARTITION BY country_id ORDER BY end_date) AS prev_end,
       LEAD(end_date) OVER (PARTITION BY country_id ORDER BY end_date) AS next_end
FROM awareness_campaigns;

-- Count campaigns per country using window
SELECT campaign_id, country_id,
       COUNT(*) OVER (PARTITION BY country_id) AS campaigns_in_country
FROM awareness_campaigns;

-- ======= DCL / TCL =======
-- create read-only user for campaign reports
CREATE USER IF NOT EXISTS 'camp_report'@'localhost' IDENTIFIED BY 'camp_pass';
GRANT SELECT ON `your_database_name`.`awareness_campaigns` TO 'camp_report'@'localhost';
FLUSH PRIVILEGES;

-- give update to evaluation team
GRANT UPDATE ON `your_database_name`.`awareness_campaigns` TO 'eval_team'@'localhost';

-- sample transaction: update outcome and commit
START TRANSACTION;
UPDATE awareness_campaigns SET outcome = 'Reviewed' WHERE campaign_id = 1;
COMMIT;

-- sample rollback: test run then rollback
START TRANSACTION;
UPDATE awareness_campaigns SET budget = budget WHERE campaign_id = -1;
ROLLBACK;

-- ======= TRIGGERS =======
DELIMITER //
CREATE TRIGGER trg_campaign_before_update
BEFORE UPDATE ON awareness_campaigns
FOR EACH ROW
BEGIN
  -- ensure budget not negative
  IF NEW.budget IS NOT NULL AND NEW.budget < 0 THEN
    SET NEW.budget = OLD.budget;
  END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_campaign_after_insert
AFTER INSERT ON awareness_campaigns
FOR EACH ROW
BEGIN
  -- example log (requires campaign_audit table). Commented to avoid errors.
  -- INSERT INTO campaign_audit(campaign_id, action, action_time) VALUES (NEW.campaign_id, 'INSERT', NOW());
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_campaign_before_delete
BEFORE DELETE ON awareness_campaigns
FOR EACH ROW
BEGIN
  -- prevent deleting campaigns with outcome = 'Successful'
  IF OLD.outcome = 'Successful' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete a successful campaign';
  END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_campaign_after_update
AFTER UPDATE ON awareness_campaigns
FOR EACH ROW
BEGIN
  -- optional audit step (commented)
  -- IF NEW.outcome <> OLD.outcome THEN INSERT INTO campaign_audit(campaign_id, old_outcome, new_outcome, changed_on) VALUES (NEW.campaign_id, OLD.outcome, NEW.outcome, NOW()); END IF;
END //
DELIMITER ;
#===========================================================================================================
#laboratiors
-- ======= VIEWS =======
CREATE OR REPLACE VIEW v_labs_basic AS
SELECT lab_id, lab_name, country_id, city FROM laboratories;

CREATE OR REPLACE VIEW v_labs_research AS
SELECT lab_id, lab_name, research_focus FROM laboratories WHERE research_focus IS NOT NULL;

CREATE OR REPLACE VIEW v_labs_by_country AS
SELECT country_id, lab_id, lab_name FROM laboratories;

CREATE OR REPLACE VIEW v_labs_contact AS
SELECT lab_id, lab_name, phone, email FROM laboratories;

-- ======= STORED PROCEDURES =======
DELIMITER //
CREATE PROCEDURE sp_GetLabsByCity(IN in_city VARCHAR(100))
BEGIN
  SELECT lab_id, lab_name, accreditation FROM laboratories WHERE city = in_city;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_UpdateLabEmail(IN in_lab INT, IN in_email VARCHAR(100))
BEGIN
  UPDATE laboratories SET email = in_email WHERE lab_id = in_lab;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_GetLabsByResearch(IN in_focus TEXT)
BEGIN
  SELECT lab_id, lab_name, research_focus FROM laboratories WHERE research_focus LIKE CONCAT('%', in_focus, '%');
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_AddLabCapacity(IN in_lab INT, IN add_cap INT)
BEGIN
  UPDATE laboratories SET capacity = COALESCE(capacity, 0) + add_cap WHERE lab_id = in_lab;
END //
DELIMITER ;

-- ======= WINDOW / ANALYTIC QUERIES =======
-- rank labs by established_year per country
SELECT lab_id, lab_name, country_id, established_year,
       RANK() OVER (PARTITION BY country_id ORDER BY established_year) AS rank_by_age
FROM laboratories;

-- row_number of labs ordered by capacity
SELECT lab_id, lab_name, capacity,
       ROW_NUMBER() OVER (ORDER BY capacity DESC) AS rn_capacity
FROM laboratories;

-- lead/lag to compare established_year
SELECT lab_id, lab_name, established_year,
       LAG(established_year) OVER (ORDER BY established_year) AS prev_year,
       LEAD(established_year) OVER (ORDER BY established_year) AS next_year
FROM laboratories;

-- count of labs per city window
SELECT lab_id, city,
       COUNT(*) OVER (PARTITION BY city) AS labs_in_city
FROM laboratories;

-- ======= DCL / TCL =======
-- grant select to lab_viewer
CREATE USER IF NOT EXISTS 'lab_view'@'localhost' IDENTIFIED BY 'lab_view_pass';
GRANT SELECT ON `your_database_name`.`laboratories` TO 'lab_view'@'localhost';
FLUSH PRIVILEGES;

-- grant update to lab_admin
GRANT UPDATE ON `your_database_name`.`laboratories` TO 'lab_admin'@'localhost';

-- transaction example: update multiple labs then commit
START TRANSACTION;
UPDATE laboratories SET email = email WHERE lab_id IN (1,2);
COMMIT;

-- rollback example
START TRANSACTION;
UPDATE laboratories SET phone = phone WHERE lab_id = -1;
ROLLBACK;

-- ======= TRIGGERS =======
DELIMITER //
CREATE TRIGGER trg_lab_before_insert
BEFORE INSERT ON laboratories
FOR EACH ROW
BEGIN
  -- ensure phone is not null (small example)
  IF NEW.phone IS NULL THEN SET NEW.phone = 'Not Provided'; END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_lab_after_insert
AFTER INSERT ON laboratories
FOR EACH ROW
BEGIN
  -- optional insert into lab_audit (commented)
  -- INSERT INTO lab_audit(lab_id, action_time, action) VALUES (NEW.lab_id, NOW(), 'INSERT');
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_lab_before_delete
BEFORE DELETE ON laboratories
FOR EACH ROW
BEGIN
  -- prevent deleting labs with accreditation = 'Critical'
  IF OLD.accreditation = 'Critical' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete a critical lab';
  END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_lab_after_update
AFTER UPDATE ON laboratories
FOR EACH ROW
BEGIN
  -- example audit on email change (commented)
  -- IF NEW.email <> OLD.email THEN INSERT INTO lab_audit(lab_id, old_email, new_email, changed_on) VALUES (NEW.lab_id, OLD.email, NEW.email, NOW()); END IF;
END //
DELIMITER ;
#===================================================================================================
#lab_tests
-- ======= VIEWS =======
CREATE OR REPLACE VIEW v_tests_basic AS
SELECT test_id, test_name, patient_id, lab_id, test_date FROM lab_tests;

CREATE OR REPLACE VIEW v_tests_costly AS
SELECT test_id, test_name, cost FROM lab_tests WHERE cost > 1000;

CREATE OR REPLACE VIEW v_tests_by_lab AS
SELECT lab_id, test_name, cost FROM lab_tests;

CREATE OR REPLACE VIEW v_tests_recent AS
SELECT * FROM lab_tests WHERE test_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

-- ======= STORED PROCEDURES =======
DELIMITER //
CREATE PROCEDURE sp_GetTestsByPatient(IN in_patient INT)
BEGIN
  SELECT test_id, test_name, result, test_date FROM lab_tests WHERE patient_id = in_patient ORDER BY test_date;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_UpdateTestRemark(IN in_test INT, IN in_remark TEXT)
BEGIN
  UPDATE lab_tests SET remarks = CONCAT(IFNULL(remarks,''), ' | ', in_remark) WHERE test_id = in_test;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_GetTestsByLab(IN in_lab INT)
BEGIN
  SELECT test_id, test_name, cost FROM lab_tests WHERE lab_id = in_lab;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_SetTestVerified(IN in_test INT)
BEGIN
  UPDATE lab_tests SET verified = 'Yes' WHERE test_id = in_test;
END //
DELIMITER ;

-- ======= WINDOW / ANALYTIC QUERIES =======
-- rank tests by cost per lab
SELECT test_id, test_name, lab_id, cost,
       RANK() OVER (PARTITION BY lab_id ORDER BY cost DESC) AS cost_rank_in_lab
FROM lab_tests;

-- row number per patient for test sequence
SELECT test_id, patient_id, test_date,
       ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY test_date) AS test_seq
FROM lab_tests;

-- lead/lag to compare sequential test dates for a patient
SELECT test_id, patient_id, test_date,
       LAG(test_date) OVER (PARTITION BY patient_id ORDER BY test_date) AS prev_test,
       LEAD(test_date) OVER (PARTITION BY patient_id ORDER BY test_date) AS next_test
FROM lab_tests;

-- count tests per test_name using window
SELECT test_id, test_name,
       COUNT(*) OVER (PARTITION BY test_name) AS tests_per_type
FROM lab_tests;

-- ======= DCL / TCL =======
-- reporting user
CREATE USER IF NOT EXISTS 'lab_report'@'localhost' IDENTIFIED BY 'lab_report_pass';
GRANT SELECT ON `your_database_name`.`lab_tests` TO 'lab_report'@'localhost';
FLUSH PRIVILEGES;

-- give insert to lab_tech
GRANT INSERT ON `your_database_name`.`lab_tests` TO 'lab_tech'@'localhost';

-- transaction example: add test then commit (example lines commented)
START TRANSACTION;
-- INSERT INTO lab_tests(test_id, patient_id, lab_id, test_name, test_date, result, cost) VALUES (...);
COMMIT;

-- rollback example
START TRANSACTION;
-- INSERT INTO lab_tests(...) VALUES (...);
ROLLBACK;

-- ======= TRIGGERS =======
DELIMITER //
CREATE TRIGGER trg_test_before_insert
BEFORE INSERT ON lab_tests
FOR EACH ROW
BEGIN
  -- ensure cost not negative
  IF NEW.cost < 0 THEN SET NEW.cost = 0; END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_test_after_insert
AFTER INSERT ON lab_tests
FOR EACH ROW
BEGIN
  -- example: increment lab daily counter (commented)
  -- INSERT INTO lab_daily_count(lab_id, day, count) VALUES (NEW.lab_id, DATE(NEW.test_date), 1) ON DUPLICATE KEY UPDATE count = count + 1;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_test_before_update
BEFORE UPDATE ON lab_tests
FOR EACH ROW
BEGIN
  -- preserve 'tested_by' if attempted to set empty
  IF NEW.tested_by IS NULL OR NEW.tested_by = '' THEN SET NEW.tested_by = OLD.tested_by; END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_test_after_delete
AFTER DELETE ON lab_tests
FOR EACH ROW
BEGIN
  -- optional delete log (commented)
  -- INSERT INTO lab_test_log(test_id, deleted_on) VALUES (OLD.test_id, NOW());
END //
DELIMITER ;
#===========================================================================================================
#health_programs
-- ======= VIEWS =======
CREATE OR REPLACE VIEW v_programs_basic AS
SELECT program_id, program_name, start_date, end_date, target_region FROM health_programs;

CREATE OR REPLACE VIEW v_programs_budget AS
SELECT program_id, program_name, budget, funded_by FROM health_programs;

CREATE OR REPLACE VIEW v_programs_active AS
SELECT program_id, program_name FROM health_programs WHERE CURDATE() BETWEEN start_date AND end_date;

CREATE OR REPLACE VIEW v_programs_outcome AS
SELECT program_id, program_name, outcome FROM health_programs WHERE outcome IS NOT NULL;

-- ======= STORED PROCEDURES =======
DELIMITER //
CREATE PROCEDURE sp_GetProgramsByRegion(IN in_region VARCHAR(100))
BEGIN
  SELECT program_id, program_name, start_date FROM health_programs WHERE target_region = in_region;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_UpdateProgramOutcome(IN in_prog INT, IN in_outcome TEXT)
BEGIN
  UPDATE health_programs SET outcome = in_outcome WHERE program_id = in_prog;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_AddProgramParticipants(IN in_prog INT, IN add_p INT)
BEGIN
  UPDATE health_programs SET participants = COALESCE(participants,0) + add_p WHERE program_id = in_prog;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_GetProgramsByFunder(IN in_funder VARCHAR(100))
BEGIN
  SELECT program_id, program_name, budget FROM health_programs WHERE funded_by = in_funder;
END //
DELIMITER ;

-- ======= WINDOW / ANALYTIC QUERIES =======
-- rank programs by budget per region
SELECT program_id, program_name, target_region, budget,
       RANK() OVER (PARTITION BY target_region ORDER BY budget DESC) AS budget_rank
FROM health_programs;

-- row_number by start_date to sequence programs
SELECT program_id, program_name,
       ROW_NUMBER() OVER (ORDER BY start_date) AS seq_by_start
FROM health_programs;

-- lead/lag to check program timelines in region
SELECT program_id, target_region, start_date, end_date,
       LAG(end_date) OVER (PARTITION BY target_region ORDER BY end_date) AS prev_end,
       LEAD(end_date) OVER (PARTITION BY target_region ORDER BY end_date) AS next_end
FROM health_programs;

-- count programs per funder using window
SELECT program_id, funded_by,
       COUNT(*) OVER (PARTITION BY funded_by) AS programs_per_funder
FROM health_programs;

-- ======= DCL / TCL =======
-- reporting user
CREATE USER IF NOT EXISTS 'prog_report'@'localhost' IDENTIFIED BY 'prog_report_pass';
GRANT SELECT ON `your_database_name`.`health_programs` TO 'prog_report'@'localhost';
FLUSH PRIVILEGES;

-- grant update to program_manager
GRANT UPDATE ON `your_database_name`.`health_programs` TO 'program_manager'@'localhost';

-- transaction: update budget and commit
START TRANSACTION;
UPDATE health_programs SET budget = budget WHERE program_id = 1;
COMMIT;

-- rollback example
START TRANSACTION;
UPDATE health_programs SET participants = participants WHERE program_id = -1;
ROLLBACK;

-- ======= TRIGGERS =======
DELIMITER //
CREATE TRIGGER trg_program_before_insert
BEFORE INSERT ON health_programs
FOR EACH ROW
BEGIN
  IF NEW.budget < 0 THEN SET NEW.budget = 0; END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_program_after_insert
AFTER INSERT ON health_programs
FOR EACH ROW
BEGIN
  -- optional notification (commented)
  -- INSERT INTO notifications(program_id, msg, created_on) VALUES (NEW.program_id, 'New program created', NOW());
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_program_before_delete
BEFORE DELETE ON health_programs
FOR EACH ROW
BEGIN
  IF OLD.outcome = 'Ongoing' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete an ongoing program';
  END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_program_after_update
AFTER UPDATE ON health_programs
FOR EACH ROW
BEGIN
  -- log significant budget changes (commented)
  -- IF NEW.budget <> OLD.budget THEN INSERT INTO program_audit(program_id, old_budget, new_budget, changed_on) VALUES (NEW.program_id, OLD.budget, NEW.budget, NOW()); END IF;
END //
DELIMITER ;
#==============================================================================================================
#program_beneficiaries

CREATE OR REPLACE VIEW v_beneficiaries_basic AS
SELECT beneficiary_id, program_id, name, age, gender, country_id FROM program_beneficiaries;

CREATE OR REPLACE VIEW v_benefits_by_program AS
SELECT program_id, name, benefit_type, received_date FROM program_beneficiaries;

CREATE OR REPLACE VIEW v_beneficiaries_status AS
SELECT beneficiary_id, program_id, status FROM program_beneficiaries WHERE status IS NOT NULL;

CREATE OR REPLACE VIEW v_beneficiaries_recent AS
SELECT * FROM program_beneficiaries WHERE received_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

-- ======= STORED PROCEDURES =======
DELIMITER //
CREATE PROCEDURE sp_GetBeneficiariesByProgram(IN in_prog INT)
BEGIN
  SELECT beneficiary_id, name, age, status FROM program_beneficiaries WHERE program_id = in_prog;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_UpdateBeneficiaryStatus(IN in_beneficiary INT, IN in_status VARCHAR(50))
BEGIN
  UPDATE program_beneficiaries SET status = in_status WHERE beneficiary_id = in_beneficiary;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_GetBeneficiariesByCountry(IN in_country INT)
BEGIN
  SELECT beneficiary_id, name, program_id FROM program_beneficiaries WHERE country_id = in_country;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_AddBeneficiaryRemark(IN in_beneficiary INT, IN in_remark TEXT)
BEGIN
  UPDATE program_beneficiaries SET remarks = CONCAT(IFNULL(remarks,''), ' | ', in_remark) WHERE beneficiary_id = in_beneficiary;
END //
DELIMITER ;

-- ======= WINDOW / ANALYTIC QUERIES =======
-- rank beneficiaries by age within program
SELECT beneficiary_id, program_id, name, age,
       RANK() OVER (PARTITION BY program_id ORDER BY age DESC) AS age_rank_in_program
FROM program_beneficiaries;

-- row_number per country to sequence beneficiaries
SELECT beneficiary_id, country_id,
       ROW_NUMBER() OVER (PARTITION BY country_id ORDER BY received_date) AS seq_by_country
FROM program_beneficiaries;

-- lead/lag to examine previous beneficiary received_date in same program
SELECT beneficiary_id, program_id, received_date,
       LAG(received_date) OVER (PARTITION BY program_id ORDER BY received_date) AS prev_received,
       LEAD(received_date) OVER (PARTITION BY program_id ORDER BY received_date) AS next_received
FROM program_beneficiaries;

-- count beneficiaries per program using window
SELECT beneficiary_id, program_id,
       COUNT(*) OVER (PARTITION BY program_id) AS beneficiaries_per_program
FROM program_beneficiaries;

-- ======= DCL / TCL =======
-- report user
CREATE USER IF NOT EXISTS 'ben_report'@'localhost' IDENTIFIED BY 'ben_report_pass';
GRANT SELECT ON `your_database_name`.`program_beneficiaries` TO 'ben_report'@'localhost';
FLUSH PRIVILEGES;

-- grant update to field_officer
GRANT UPDATE ON `your_database_name`.`program_beneficiaries` TO 'field_officer'@'localhost';

-- transaction example: update status then commit
START TRANSACTION;
UPDATE program_beneficiaries SET status = 'Verified' WHERE beneficiary_id = 1;
COMMIT;

-- rollback example
START TRANSACTION;
UPDATE program_beneficiaries SET remarks = remarks WHERE beneficiary_id = -1;
ROLLBACK;

-- ======= TRIGGERS =======
DELIMITER //
CREATE TRIGGER trg_benef_before_insert
BEFORE INSERT ON program_beneficiaries
FOR EACH ROW
BEGIN
  -- ensure age non-negative
  IF NEW.age < 0 THEN SET NEW.age = 0; END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_benef_after_insert
AFTER INSERT ON program_beneficiaries
FOR EACH ROW
BEGIN
  -- optional log (commented)
  -- INSERT INTO beneficiary_audit(beneficiary_id, action, created_on) VALUES (NEW.beneficiary_id, 'INSERT', NOW());
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_benef_before_update
BEFORE UPDATE ON program_beneficiaries
FOR EACH ROW
BEGIN
  -- preserve status if new status is empty
  IF NEW.status IS NULL OR NEW.status = '' THEN SET NEW.status = OLD.status; END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_benef_after_delete
AFTER DELETE ON program_beneficiaries
FOR EACH ROW
BEGIN
  -- optional cleanup (commented)
  -- DELETE FROM program_assets WHERE beneficiary_id = OLD.beneficiary_id;
END //
DELIMITER ;
#=============================================================================================================
#health_worker

-- view: basic listing
CREATE VIEW vw_health_workers_basic AS
SELECT worker_id, first_name, last_name, job_role, salary FROM health_workers;

-- view: salary rank using window function
CREATE VIEW vw_health_workers_salary_rank AS
SELECT worker_id, first_name, last_name, job_role, salary,
       RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM health_workers;

-- view: experience percentile
CREATE VIEW vw_health_workers_experience_pct AS
SELECT worker_id, first_name, experience_years,
       NTILE(4) OVER (ORDER BY experience_years DESC) AS experience_quartile
FROM health_workers;

-- stored procedure: get worker by id (OUT params)
DELIMITER //
CREATE PROCEDURE sp_get_worker(IN p_id INT, OUT p_name VARCHAR(101), OUT p_role VARCHAR(100))
BEGIN
  SELECT CONCAT(first_name, ' ', last_name), job_role INTO p_name, p_role
  FROM health_workers WHERE worker_id = p_id;
END //
DELIMITER ;

-- stored procedure: show top N by salary (uses prepared stmt)
DELIMITER //
CREATE PROCEDURE sp_top_workers_by_salary(IN p_limit INT)
BEGIN
  SELECT worker_id, first_name, last_name, salary
  FROM health_workers
  ORDER BY salary DESC
  LIMIT p_limit;
END //
DELIMITER ;

-- stored procedure: compute hypothetical raise (no update)
DELIMITER //
CREATE PROCEDURE sp_compute_raise(IN p_id INT, IN p_pct DECIMAL(5,2), OUT new_salary DECIMAL(12,2))
BEGIN
  SELECT salary * (1 + p_pct/100) INTO new_salary FROM health_workers WHERE worker_id = p_id;
END //
DELIMITER ;

-- view: email contact with country id (useful join if countries exist)
CREATE VIEW vw_health_workers_contact AS
SELECT worker_id, CONCAT(first_name, ' ', last_name) AS full_name, phone, email, country_id
FROM health_workers;

-- window function select as view: experience lag/lead
CREATE VIEW vw_health_workers_experience_trend AS
SELECT worker_id, first_name, experience_years,
       LAG(experience_years) OVER (ORDER BY experience_years) AS prev_experience,
       LEAD(experience_years) OVER (ORDER BY experience_years) AS next_experience
FROM health_workers;

-- DCL: grant select on health_workers to a user
GRANT SELECT ON Electricity_Department.health_workers TO 'clerk'@'localhost';

-- DCL: revoke update (example)
REVOKE UPDATE ON Electricity_Department.health_workers FROM 'clerk'@'localhost';

-- TCL: start a transaction example (you can paste when needed)
START TRANSACTION;
SAVEPOINT sp_before_proc;
ROLLBACK TO SAVEPOINT sp_before_proc;
COMMIT;

-- trigger: set default hire_date if not provided (before insert)
DELIMITER //
CREATE TRIGGER trg_hw_before_insert
BEFORE INSERT ON health_workers
FOR EACH ROW
BEGIN
  IF NEW.hire_date IS NULL THEN
    SET NEW.hire_date = CURDATE();
  END IF;
END //
DELIMITER ;

-- trigger: prevent negative salary
DELIMITER //
CREATE TRIGGER trg_hw_before_update_salary
BEFORE UPDATE ON health_workers
FOR EACH ROW
BEGIN
  IF NEW.salary < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salary cannot be negative';
  END IF;
END //
DELIMITER ;

-- view: workers with experience window avg (3-row moving avg)
CREATE VIEW vw_hw_experience_mavg AS
SELECT worker_id, first_name, experience_years,
       ROUND(AVG(experience_years) OVER (ORDER BY worker_id ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING),2) AS moving_avg_exp
FROM health_workers;

-- stored procedure: list workers by country (parameterized)
DELIMITER //
CREATE PROCEDURE sp_workers_by_country(IN p_country INT)
BEGIN
  SELECT worker_id, first_name, last_name, job_role FROM health_workers WHERE country_id = p_country;
END //
DELIMITER ;

-- view: flag experienced workers
CREATE VIEW vw_hw_flag_experienced AS
SELECT worker_id, first_name, experience_years,
       CASE WHEN experience_years >= 10 THEN 'Senior' ELSE 'Junior' END AS level
FROM health_workers;

-- DCL: grant select on view to reporting user
GRANT SELECT ON Electricity_Department.vw_health_workers_salary_rank TO 'report'@'localhost';

-- TCL: example savepoint usage inside session (paste when executing logic)
START TRANSACTION;
SAVEPOINT before_raise;
-- (some operations)
ROLLBACK TO SAVEPOINT before_raise;
COMMIT;

-- procedure: return count by role (OUT)
DELIMITER //
CREATE PROCEDURE sp_count_by_role(IN p_role VARCHAR(100), OUT cnt INT)
BEGIN
  SELECT COUNT(*) INTO cnt FROM health_workers WHERE job_role = p_role;
END //
DELIMITER ;
#===========================================================================================================
#disease_outbreaks

-- view: outbreak summary
CREATE VIEW vw_outbreaks_summary AS
SELECT outbreak_id, disease_id, country_id, start_date, end_date, cases_reported, deaths, recovery_rate
FROM disease_outbreaks;

-- view: duration using window (end_date - start_date)
CREATE VIEW vw_outbreaks_duration AS
SELECT outbreak_id, disease_id, start_date, end_date,
       DATEDIFF(end_date, start_date) AS duration_days
FROM disease_outbreaks;

-- view: rolling sum of cases by disease (window)
CREATE VIEW vw_outbreaks_cases_rolling AS
SELECT outbreak_id, disease_id, cases_reported,
       SUM(cases_reported) OVER (PARTITION BY disease_id ORDER BY start_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_cases
FROM disease_outbreaks;

-- stored procedure: get outbreak by id
DELIMITER //
CREATE PROCEDURE sp_get_outbreak(IN p_id INT)
BEGIN
  SELECT * FROM disease_outbreaks WHERE outbreak_id = p_id;
END //
DELIMITER ;

-- stored procedure: list outbreaks in date range
DELIMITER //
CREATE PROCEDURE sp_outbreaks_in_range(IN s_date DATE, IN e_date DATE)
BEGIN
  SELECT * FROM disease_outbreaks WHERE start_date BETWEEN s_date AND e_date;
END //
DELIMITER ;

-- stored procedure: compute CFR (case fatality rate) safely
DELIMITER //
CREATE PROCEDURE sp_compute_cfr(IN p_id INT, OUT cfr DECIMAL(6,2))
BEGIN
  SELECT CASE WHEN cases_reported > 0 THEN (deaths * 100.0 / cases_reported) ELSE 0 END
  INTO cfr FROM disease_outbreaks WHERE outbreak_id = p_id;
END //
DELIMITER ;

-- view: outbreaks with recovery rank per country
CREATE VIEW vw_outbreaks_recovery_rank AS
SELECT outbreak_id, country_id, recovery_rate,
       RANK() OVER (PARTITION BY country_id ORDER BY recovery_rate DESC) AS recovery_rank
FROM disease_outbreaks;

-- trigger: ensure end_date >= start_date
DELIMITER //
CREATE TRIGGER trg_outbreak_dates
BEFORE INSERT ON disease_outbreaks
FOR EACH ROW
BEGIN
  IF NEW.end_date < NEW.start_date THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'end_date must be >= start_date';
  END IF;
END //
DELIMITER ;

-- trigger: block inserting huge cases without note
DELIMITER //
CREATE TRIGGER trg_outbreak_cases_check
BEFORE INSERT ON disease_outbreaks
FOR EACH ROW
BEGIN
  IF NEW.cases_reported > 1000000 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'cases_reported too large; add justification';
  END IF;
END //
DELIMITER ;

-- view: ranks of outbreaks by severity (cases+deaths)
CREATE VIEW vw_outbreaks_severity AS
SELECT outbreak_id, cases_reported, deaths,
       DENSE_RANK() OVER (ORDER BY (cases_reported + deaths) DESC) AS severity_rank
FROM disease_outbreaks;

-- stored procedure: outbreaks for disease (window example inside proc)
DELIMITER //
CREATE PROCEDURE sp_outbreaks_for_disease(IN p_disease INT)
BEGIN
  SELECT outbreak_id, start_date, end_date, cases_reported,
         SUM(cases_reported) OVER (PARTITION BY disease_id ORDER BY start_date) AS cumulative_cases
  FROM disease_outbreaks
  WHERE disease_id = p_disease;
END //
DELIMITER ;

-- DCL: grant select on view to analyst
GRANT SELECT ON Electricity_Department.vw_outbreaks_cases_rolling TO 'analyst'@'localhost';

-- DCL: revoke select from a user
REVOKE SELECT ON Electricity_Department.vw_outbreaks_cases_rolling FROM 'analyst'@'localhost';

-- TCL: example transaction block for reporting tasks
START TRANSACTION;
SAVEPOINT sp_outbreak_report;
-- (reporting selects)
ROLLBACK TO SAVEPOINT sp_outbreak_report;
COMMIT;

-- view: outbreak start ordering with lag
CREATE VIEW vw_outbreaks_start_lag AS
SELECT outbreak_id, start_date,
       LAG(start_date) OVER (ORDER BY start_date) AS prev_start
FROM disease_outbreaks;

-- stored procedure: mark reported_by (returns rows, no update)
DELIMITER //
CREATE PROCEDURE sp_outbreak_reporters()
BEGIN
  SELECT outbreak_id, reported_by FROM disease_outbreaks;
END //
DELIMITER ;

-- trigger: on update ensure recovery_rate between 0 and 100
DELIMITER //
CREATE TRIGGER trg_outbreak_recovery_check
BEFORE UPDATE ON disease_outbreaks
FOR EACH ROW
BEGIN
  IF NEW.recovery_rate < 0 OR NEW.recovery_rate > 100 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'recovery_rate must be 0..100';
  END IF;
END //
DELIMITER ;
#===========================================================================================================
#medical_supplies

-- view: supplies basic
CREATE VIEW vw_medical_supplies_basic AS
SELECT supply_id, supply_name, category, quantity, unit_price, expiry_date FROM medical_supplies;

-- view: supplies low stock flag using window (compare to avg by category)
CREATE VIEW vw_medical_supplies_lowstock AS
SELECT supply_id, supply_name, category, quantity,
       AVG(quantity) OVER (PARTITION BY category) AS avg_qty_by_cat,
       CASE WHEN quantity < AVG(quantity) OVER (PARTITION BY category) THEN 'LOW' ELSE 'OK' END AS stock_status
FROM medical_supplies;

-- view: shelf life days
CREATE VIEW vw_medical_supplies_shelf_life AS
SELECT supply_id, supply_name, manufacture_date, expiry_date,
       DATEDIFF(expiry_date, manufacture_date) AS shelf_days
FROM medical_supplies;

-- stored procedure: get supply by id
DELIMITER //
CREATE PROCEDURE sp_get_supply(IN p_id INT)
BEGIN
  SELECT * FROM medical_supplies WHERE supply_id = p_id;
END //
DELIMITER ;

-- stored procedure: compute total value (quantity * unit_price) in result (no update)
DELIMITER //
CREATE PROCEDURE sp_get_supply_value(IN p_id INT, OUT total_value DECIMAL(20,2))
BEGIN
  SELECT quantity * unit_price INTO total_value FROM medical_supplies WHERE supply_id = p_id;
END //
DELIMITER ;

-- stored procedure: list supplies expiring before date
DELIMITER //
CREATE PROCEDURE sp_supplies_expiring_before(IN cutoff DATE)
BEGIN
  SELECT supply_id, supply_name, expiry_date FROM medical_supplies WHERE expiry_date < cutoff;
END //
DELIMITER ;

-- view: expensive equipment (window rank by unit_price)
CREATE VIEW vw_medical_supplies_price_rank AS
SELECT supply_id, supply_name, category, unit_price,
       ROW_NUMBER() OVER (PARTITION BY category ORDER BY unit_price DESC) AS price_rank_in_category
FROM medical_supplies;

-- trigger: prevent negative quantity
DELIMITER //
CREATE TRIGGER trg_supply_quantity_check
BEFORE INSERT ON medical_supplies
FOR EACH ROW
BEGIN
  IF NEW.quantity < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'quantity cannot be negative';
  END IF;
END //
DELIMITER ;

-- trigger: ensure expiry date after manufacture date
DELIMITER //
CREATE TRIGGER trg_supply_dates
BEFORE INSERT ON medical_supplies
FOR EACH ROW
BEGIN
  IF NEW.expiry_date <= NEW.manufacture_date THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'expiry_date must be after manufacture_date';
  END IF;
END //
DELIMITER ;

-- DCL: grant select on views to procurement user
GRANT SELECT ON Electricity_Department.vw_medical_supplies_basic TO 'procure'@'localhost';

-- TCL: transaction example for inventory check
START TRANSACTION;
SAVEPOINT sp_inventory_check;
ROLLBACK TO SAVEPOINT sp_inventory_check;
COMMIT;

-- view: supplier aggregated window (shows supplier_id and moving sum of quantities)
CREATE VIEW vw_supplies_supplier_moving AS
SELECT supply_id, supplier_id, quantity,
       SUM(quantity) OVER (PARTITION BY supplier_id ORDER BY supply_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_by_supplier
FROM medical_supplies;

-- stored procedure: check_batch (return boolean via OUT)
DELIMITER //
CREATE PROCEDURE sp_check_batch(IN p_batch VARCHAR(50), OUT has_batch TINYINT)
BEGIN
  SELECT CASE WHEN EXISTS(SELECT 1 FROM medical_supplies WHERE batch_no = p_batch) THEN 1 ELSE 0 END INTO has_batch;
END //
DELIMITER ;

-- view: items nearing expiry (useful when joined to current_date)
CREATE VIEW vw_supplies_near_expiry AS
SELECT supply_id, supply_name, expiry_date,
       DATEDIFF(expiry_date, CURDATE()) AS days_to_expiry
FROM medical_supplies;

-- trigger: on update prevent lowering unit_price below zero
DELIMITER //
CREATE TRIGGER trg_supply_before_update_price
BEFORE UPDATE ON medical_supplies
FOR EACH ROW
BEGIN
  IF NEW.unit_price < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'unit_price cannot be negative';
  END IF;
END //
DELIMITER ;

-- stored procedure: list supplies by category (with rank)
DELIMITER //
CREATE PROCEDURE sp_supplies_by_category(IN p_cat VARCHAR(50))
BEGIN
  SELECT supply_id, supply_name, quantity,
         RANK() OVER (ORDER BY quantity DESC) AS qty_rank
  FROM medical_supplies
  WHERE category = p_cat;
END //
DELIMITER ;

-- DCL: revoke select example
REVOKE SELECT ON Electricity_Department.vw_medical_supplies_lowstock FROM 'procure'@'localhost';
#========================================================================================================
#suppliers


-- view: basic supplier contact
CREATE VIEW vw_suppliers_basic AS
SELECT supplier_id, supplier_name, contact_name, phone, email, city FROM suppliers;

-- view: supplier address and domain extracted (example window: row_number)
CREATE VIEW vw_suppliers_with_rownum AS
SELECT supplier_id, supplier_name, city, ROW_NUMBER() OVER (ORDER BY supplier_id) AS rownum
FROM suppliers;

-- stored procedure: get supplier by id
DELIMITER //
CREATE PROCEDURE sp_get_supplier(IN p_id INT)
BEGIN
  SELECT * FROM suppliers WHERE supplier_id = p_id;
END //
DELIMITER ;

-- stored procedure: suppliers in country (returns rows)
DELIMITER //
CREATE PROCEDURE sp_suppliers_in_country(IN p_country INT)
BEGIN
  SELECT supplier_id, supplier_name, city FROM suppliers WHERE country_id = p_country;
END //
DELIMITER ;

-- trigger: ensure phone not null
DELIMITER //
CREATE TRIGGER trg_suppliers_phone
BEFORE INSERT ON suppliers
FOR EACH ROW
BEGIN
  IF NEW.phone IS NULL OR NEW.phone = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'phone is required';
  END IF;
END //
DELIMITER ;

-- DCL: grant select on vw_suppliers_basic
GRANT SELECT ON Electricity_Department.vw_suppliers_basic TO 'buyer'@'localhost';

-- DCL: revoke select
REVOKE SELECT ON Electricity_Department.vw_suppliers_basic FROM 'buyer'@'localhost';

-- view: supplier email domain (uses substring_index)
CREATE VIEW vw_suppliers_email_domain AS
SELECT supplier_id, supplier_name, SUBSTRING_INDEX(email, '@', -1) AS email_domain FROM suppliers;

-- stored procedure: check supplier existence (OUT)
DELIMITER //
CREATE PROCEDURE sp_supplier_exists(IN p_id INT, OUT exists_flag TINYINT)
BEGIN
  SELECT CASE WHEN EXISTS (SELECT 1 FROM suppliers WHERE supplier_id = p_id) THEN 1 ELSE 0 END INTO exists_flag;
END //
DELIMITER ;

-- TCL: transaction template for supplier onboarding
START TRANSACTION;
SAVEPOINT sp_supplier_onboard;
ROLLBACK TO SAVEPOINT sp_supplier_onboard;
COMMIT;

-- view: suppliers by state with window count
CREATE VIEW vw_suppliers_state_counts AS
SELECT supplier_id, state,
       COUNT(supplier_id) OVER (PARTITION BY state) AS suppliers_in_state
FROM suppliers;

-- trigger: prevent duplicate email (simple check)
DELIMITER //
CREATE TRIGGER trg_suppliers_unique_email
BEFORE INSERT ON suppliers
FOR EACH ROW
BEGIN
  IF (SELECT COUNT(*) FROM suppliers WHERE email = NEW.email) > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'email must be unique';
  END IF;
END //
DELIMITER ;

-- stored procedure: suppliers contact list (returns small result)
DELIMITER //
CREATE PROCEDURE sp_supplier_contacts()
BEGIN
  SELECT supplier_name, contact_name, phone, email FROM suppliers;
END //
DELIMITER ;

-- view: latest supplier id with window
CREATE VIEW vw_suppliers_latest AS
SELECT supplier_id, supplier_name,
       RANK() OVER (ORDER BY supplier_id DESC) AS id_rank
FROM suppliers;

-- DCL: grant select on suppliers table to read_only user
GRANT SELECT ON Electricity_Department.suppliers TO 'read_only'@'localhost';

-- DCL: revoke select example
REVOKE SELECT ON Electricity_Department.suppliers FROM 'read_only'@'localhost';

-- stored procedure: get suppliers with common domain (input domain)
DELIMITER //
CREATE PROCEDURE sp_suppliers_by_domain(IN p_domain VARCHAR(100))
BEGIN
  SELECT supplier_id, supplier_name, email FROM suppliers WHERE email LIKE CONCAT('%', p_domain);
END //
DELIMITER ;
#===========================================================================================================
#training_programs


-- view: training basic
CREATE VIEW vw_training_basic AS
SELECT training_id, training_name, start_date, end_date, topic, instructor FROM training_programs;

-- view: duration (days) for each training
CREATE VIEW vw_training_duration AS
SELECT training_id, training_name, DATEDIFF(end_date, start_date) AS duration_days FROM training_programs;

-- view: participants window (use participants table later via join if needed)
CREATE VIEW vw_training_by_country_window AS
SELECT training_id, country_id,
       COUNT(training_id) OVER (PARTITION BY country_id) AS trainings_per_country
FROM training_programs;

-- stored procedure: get training details
DELIMITER //
CREATE PROCEDURE sp_get_training(IN p_id INT)
BEGIN
  SELECT * FROM training_programs WHERE training_id = p_id;
END //
DELIMITER ;

-- stored procedure: list current/upcoming trainings after today
DELIMITER //
CREATE PROCEDURE sp_upcoming_trainings()
BEGIN
  SELECT training_id, training_name, start_date FROM training_programs WHERE start_date >= CURDATE();
END //
DELIMITER ;

-- trigger: ensure end_date >= start_date
DELIMITER //
CREATE TRIGGER trg_training_dates
BEFORE INSERT ON training_programs
FOR EACH ROW
BEGIN
  IF NEW.end_date < NEW.start_date THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'end_date must be >= start_date';
  END IF;
END //
DELIMITER ;

-- view: training budget rank by country
CREATE VIEW vw_training_budget_rank AS
SELECT training_id, country_id, budget,
       RANK() OVER (PARTITION BY country_id ORDER BY budget DESC) AS budget_rank
FROM training_programs;

-- stored procedure: participants count placeholder (returns training and participants column)
DELIMITER //
CREATE PROCEDURE sp_training_participants_count()
BEGIN
  SELECT training_id, participants FROM training_programs;
END //
DELIMITER ;

-- DCL: grant select on training view
GRANT SELECT ON Electricity_Department.vw_training_duration TO 'trainer'@'localhost';

-- TCL: example transaction for scheduling
START TRANSACTION;
SAVEPOINT sp_training_schedule;
ROLLBACK TO SAVEPOINT sp_training_schedule;
COMMIT;

-- trigger: set default outcome if null
DELIMITER //
CREATE TRIGGER trg_training_default_outcome
BEFORE INSERT ON training_programs
FOR EACH ROW
BEGIN
  IF NEW.outcome IS NULL THEN
    SET NEW.outcome = 'Pending';
  END IF;
END //
DELIMITER ;

-- view: training with running total of participants by country
CREATE VIEW vw_training_participants_running AS
SELECT training_id, country_id, participants,
       SUM(participants) OVER (PARTITION BY country_id ORDER BY start_date) AS cumulative_participants
FROM training_programs;

-- stored procedure: get trainings by topic
DELIMITER //
CREATE PROCEDURE sp_trainings_by_topic(IN p_topic VARCHAR(100))
BEGIN
  SELECT training_id, training_name, start_date FROM training_programs WHERE topic = p_topic;
END //
DELIMITER ;

-- DCL: revoke example
REVOKE SELECT ON Electricity_Department.vw_training_duration FROM 'trainer'@'localhost';

-- view: latest trainings (row_number)
CREATE VIEW vw_training_latest AS
SELECT training_id, training_name, start_date,
       ROW_NUMBER() OVER (ORDER BY start_date DESC) AS rn
FROM training_programs;

-- stored procedure: compute budget per participant (returns results)
DELIMITER //
CREATE PROCEDURE sp_budget_per_participant(IN p_id INT, OUT bpp DECIMAL(12,2))
BEGIN
  SELECT CASE WHEN participants>0 THEN budget/participants ELSE 0 END INTO bpp FROM training_programs WHERE training_id = p_id;
END //
DELIMITER ;
#============================================================================================================
#participants

-- view: participants basic
CREATE VIEW vw_participants_basic AS
SELECT participant_id, training_id, name, role, country_id FROM participants;

-- view: participants age rank within training
CREATE VIEW vw_participants_age_rank AS
SELECT participant_id, training_id, name, age,
       RANK() OVER (PARTITION BY training_id ORDER BY age DESC) AS age_rank
FROM participants;

-- stored procedure: get participant by id
DELIMITER //
CREATE PROCEDURE sp_get_participant(IN p_id INT)
BEGIN
  SELECT * FROM participants WHERE participant_id = p_id;
END //
DELIMITER ;

-- stored procedure: list participants for training (returns rows)
DELIMITER //
CREATE PROCEDURE sp_participants_for_training(IN p_training INT)
BEGIN
  SELECT participant_id, name, role FROM participants WHERE training_id = p_training;
END //
DELIMITER ;

-- trigger: ensure age > 18 for a participant (example rule)
DELIMITER //
CREATE TRIGGER trg_participants_age_check
BEFORE INSERT ON participants
FOR EACH ROW
BEGIN
  IF NEW.age < 18 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'participant must be 18 or older';
  END IF;
END //
DELIMITER ;

-- view: participants count by training using window
CREATE VIEW vw_participants_count_window AS
SELECT participant_id, training_id,
       COUNT(*) OVER (PARTITION BY training_id) AS participants_in_training
FROM participants;

-- DCL: grant select on participant views to training_coordinator
GRANT SELECT ON Electricity_Department.vw_participants_basic TO 'training_coordinator'@'localhost';

-- TCL: sample transaction block for attendance marking
START TRANSACTION;
SAVEPOINT sp_attendance;
ROLLBACK TO SAVEPOINT sp_attendance;
COMMIT;

-- stored procedure: check participant email (OUT)
DELIMITER //
CREATE PROCEDURE sp_participant_has_email(IN p_id INT, OUT has_email TINYINT)
BEGIN
  SELECT CASE WHEN email IS NOT NULL AND email<>'' THEN 1 ELSE 0 END INTO has_email FROM participants WHERE participant_id = p_id;
END //
DELIMITER ;

-- view: participants by country with row_number
CREATE VIEW vw_participants_by_country_rn AS
SELECT participant_id, name, country_id,
       ROW_NUMBER() OVER (PARTITION BY country_id ORDER BY participant_id) AS rn
FROM participants;

-- trigger: default remarks if null
DELIMITER //
CREATE TRIGGER trg_participants_default_remarks
BEFORE INSERT ON participants
FOR EACH ROW
BEGIN
  IF NEW.remarks IS NULL THEN
    SET NEW.remarks = 'None';
  END IF;
END //
DELIMITER ;

-- stored procedure: list participants with role filter
DELIMITER //
CREATE PROCEDURE sp_participants_by_role(IN p_role VARCHAR(50))
BEGIN
  SELECT participant_id, name, role FROM participants WHERE role = p_role;
END //
DELIMITER ;

-- DCL: revoke example
REVOKE SELECT ON Electricity_Department.vw_participants_basic FROM 'training_coordinator'@'localhost';

-- view: oldest participant per training (window with first_value)
CREATE VIEW vw_oldest_participant AS
SELECT training_id,
       FIRST_VALUE(name) OVER (PARTITION BY training_id ORDER BY age DESC) AS oldest_participant
FROM participants;

-- stored procedure: return counts by gender (OUT params)
DELIMITER //
CREATE PROCEDURE sp_count_by_gender(OUT male_cnt INT, OUT female_cnt INT)
BEGIN
  SELECT COUNT(*) INTO male_cnt FROM participants WHERE gender='M';
  SELECT COUNT(*) INTO female_cnt FROM participants WHERE gender='F';
END //
DELIMITER ;
#============================================================================================================
#emergency_responses

-- view: emergency summary
CREATE VIEW vw_emergency_basic AS
SELECT response_id, disaster_type, country_id, start_date, end_date, affected_population, relief_funds FROM emergency_responses;

-- view: relief funds rank by disaster_type
CREATE VIEW vw_emergency_funds_rank AS
SELECT response_id, disaster_type, relief_funds,
       RANK() OVER (PARTITION BY disaster_type ORDER BY relief_funds DESC) AS funds_rank
FROM emergency_responses;

-- stored procedure: get response by id
DELIMITER //
CREATE PROCEDURE sp_get_response(IN p_id INT)
BEGIN
  SELECT * FROM emergency_responses WHERE response_id = p_id;
END //
DELIMITER ;

-- stored procedure: summary for country (returns rows)
DELIMITER //
CREATE PROCEDURE sp_responses_for_country(IN p_country INT)
BEGIN
  SELECT response_id, disaster_type, affected_population FROM emergency_responses WHERE country_id = p_country;
END //
DELIMITER ;

-- trigger: ensure relief_funds non-negative
DELIMITER //
CREATE TRIGGER trg_emergency_funds_check
BEFORE INSERT ON emergency_responses
FOR EACH ROW
BEGIN
  IF NEW.relief_funds < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'relief_funds cannot be negative';
  END IF;
END //
DELIMITER ;

-- view: outcome timeline lag
CREATE VIEW vw_emergency_outcome_lag AS
SELECT response_id, disaster_type, start_date,
       LAG(start_date) OVER (ORDER BY start_date) AS prev_start
FROM emergency_responses;

-- DCL: grant select on emergency view to coordinator
GRANT SELECT ON Electricity_Department.vw_emergency_basic TO 'coordinator'@'localhost';

-- TCL: sample transaction for allocations
START TRANSACTION;
SAVEPOINT sp_allocate;
ROLLBACK TO SAVEPOINT sp_allocate;
COMMIT;

-- stored procedure: list high impact responses (based on affected_population param)
DELIMITER //
CREATE PROCEDURE sp_high_impact_responses(IN min_pop INT)
BEGIN
  SELECT response_id, disaster_type, affected_population FROM emergency_responses WHERE affected_population >= min_pop;
END //
DELIMITER ;

-- view: funds cumulative by country (window)
CREATE VIEW vw_emergency_funds_cumulative AS
SELECT response_id, country_id, relief_funds,
       SUM(relief_funds) OVER (PARTITION BY country_id ORDER BY start_date) AS cumulative_funds
FROM emergency_responses;

-- trigger: default response_team if null
DELIMITER //
CREATE TRIGGER trg_emergency_default_team
BEFORE INSERT ON emergency_responses
FOR EACH ROW
BEGIN
  IF NEW.response_team IS NULL THEN
    SET NEW.response_team = 'TBD';
  END IF;
END //
DELIMITER ;

-- stored procedure: coordinator list
DELIMITER //
CREATE PROCEDURE sp_coordinators()
BEGIN
  SELECT DISTINCT coordinator FROM emergency_responses;
END //
DELIMITER ;

-- DCL: revoke example
REVOKE SELECT ON Electricity_Department.vw_emergency_basic FROM 'coordinator'@'localhost';

-- view: duration and intensity rank
CREATE VIEW vw_emergency_duration_intensity AS
SELECT response_id, DATEDIFF(end_date, start_date) AS duration_days, affected_population,
       RANK() OVER (ORDER BY affected_population DESC) AS intensity_rank
FROM emergency_responses;

-- stored procedure: returns count of disasters per type (OUT)
DELIMITER //
CREATE PROCEDURE sp_count_by_disaster(IN p_type VARCHAR(100), OUT cnt INT)
BEGIN
  SELECT COUNT(*) INTO cnt FROM emergency_responses WHERE disaster_type = p_type;
END //
DELIMITER ;
#===========================================================================================================
#who_staff

-- view: staff basic info
CREATE VIEW vw_who_staff_basic AS
SELECT staff_id, CONCAT(first_name, ' ', last_name) AS full_name, job_title, department, salary FROM who_staff;

-- view: salary percentile using NTILE
CREATE VIEW vw_who_staff_salary_ntile AS
SELECT staff_id, first_name, salary,
       NTILE(4) OVER (ORDER BY salary DESC) AS salary_quartile
FROM who_staff;

-- stored procedure: get staff contact
DELIMITER //
CREATE PROCEDURE sp_get_who_staff(IN p_id INT)
BEGIN
  SELECT staff_id, first_name, last_name, phone, email FROM who_staff WHERE staff_id = p_id;
END //
DELIMITER ;

-- stored procedure: list staff by department
DELIMITER //
CREATE PROCEDURE sp_staff_by_department(IN p_dept VARCHAR(100))
BEGIN
  SELECT staff_id, first_name, last_name, job_title FROM who_staff WHERE department = p_dept;
END //
DELIMITER ;

-- trigger: prevent negative salary
DELIMITER //
CREATE TRIGGER trg_who_salary_check
BEFORE INSERT ON who_staff
FOR EACH ROW
BEGIN
  IF NEW.salary < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'salary cannot be negative';
  END IF;
END //
DELIMITER ;

-- view: top earners per department (row_number)
CREATE VIEW vw_who_top_earners AS
SELECT staff_id, department, salary,
       ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn
FROM who_staff;

-- DCL: grant select on who view to hr_user
GRANT SELECT ON Electricity_Department.vw_who_staff_basic TO 'hr_user'@'localhost';

-- TCL: template transaction for payroll processing
START TRANSACTION;
SAVEPOINT sp_payroll;
ROLLBACK TO SAVEPOINT sp_payroll;
COMMIT;

-- stored procedure: list managers (job_title filter)
DELIMITER //
CREATE PROCEDURE sp_list_managers()
BEGIN
  SELECT staff_id, first_name, last_name FROM who_staff WHERE job_title LIKE '%Manager%';
END //
DELIMITER ;

-- view: staff join-ready with country (if countries table exists)
CREATE VIEW vw_who_staff_country AS
SELECT staff_id, first_name, last_name, country_id FROM who_staff;

-- trigger: default hire_date
DELIMITER //
CREATE TRIGGER trg_who_default_hiredate
BEFORE INSERT ON who_staff
FOR EACH ROW
BEGIN
  IF NEW.hire_date IS NULL THEN
    SET NEW.hire_date = CURDATE();
  END IF;
END //
DELIMITER ;

-- stored procedure: return departments (distinct)
DELIMITER //
CREATE PROCEDURE sp_list_departments()
BEGIN
  SELECT DISTINCT department FROM who_staff;
END //
DELIMITER ;

-- DCL: revoke select example
REVOKE SELECT ON Electricity_Department.vw_who_staff_basic FROM 'hr_user'@'localhost';

-- view: staff count per department (window)
CREATE VIEW vw_who_staff_count AS
SELECT staff_id, department,
       COUNT(staff_id) OVER (PARTITION BY department) AS staff_count
FROM who_staff;

-- stored procedure: get salary stats per job (returns windowed rows)
DELIMITER //
CREATE PROCEDURE sp_salary_stats_job(IN p_job VARCHAR(100))
BEGIN
  SELECT staff_id, job_title, salary,
         RANK() OVER (ORDER BY salary DESC) AS salary_rank
  FROM who_staff
  WHERE job_title = p_job;
END //
DELIMITER ;
#===========================================================================================================
# reports

-- view: reports basic
CREATE VIEW vw_reports_basic AS
SELECT report_id, title, author, publish_date, category FROM reports;

-- view: recent reports by language using row_number
CREATE VIEW vw_reports_recent_rn AS
SELECT report_id, title, publish_date, language,
       ROW_NUMBER() OVER (PARTITION BY language ORDER BY publish_date DESC) AS rn
FROM reports;

-- stored procedure: get report file url
DELIMITER //
CREATE PROCEDURE sp_get_report_url(IN p_id INT, OUT url VARCHAR(200))
BEGIN
  SELECT file_url INTO url FROM reports WHERE report_id = p_id;
END //
DELIMITER ;

-- stored procedure: list reports by category
DELIMITER //
CREATE PROCEDURE sp_reports_by_category(IN p_cat VARCHAR(50))
BEGIN
  SELECT report_id, title, publish_date FROM reports WHERE category = p_cat;
END //
DELIMITER ;

-- trigger: ensure pages positive
DELIMITER //
CREATE TRIGGER trg_reports_pages_check
BEFORE INSERT ON reports
FOR EACH ROW
BEGIN
  IF NEW.pages <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'pages must be positive';
  END IF;
END //
DELIMITER ;

-- view: language distribution using window count
CREATE VIEW vw_reports_language_count AS
SELECT report_id, language,
       COUNT(report_id) OVER (PARTITION BY language) AS reports_in_language
FROM reports;

-- DCL: grant select on reports view to researcher
GRANT SELECT ON Electricity_Department.vw_reports_basic TO 'researcher'@'localhost';

-- stored procedure: recent reports (last N days)
DELIMITER //
CREATE PROCEDURE sp_recent_reports(IN days_back INT)
BEGIN
  SELECT report_id, title, publish_date FROM reports WHERE publish_date >= DATE_SUB(CURDATE(), INTERVAL days_back DAY);
END //
DELIMITER ;

-- TCL: transaction example for report publishing
START TRANSACTION;
SAVEPOINT sp_publish;
ROLLBACK TO SAVEPOINT sp_publish;
COMMIT;

-- view: longest reports by pages rank per category
CREATE VIEW vw_reports_pages_rank AS
SELECT report_id, category, pages,
       RANK() OVER (PARTITION BY category ORDER BY pages DESC) AS pages_rank
FROM reports;

-- stored procedure: return authors list
DELIMITER //
CREATE PROCEDURE sp_list_authors()
BEGIN
  SELECT DISTINCT author FROM reports;
END //
DELIMITER ;

-- DCL: revoke select example
REVOKE SELECT ON Electricity_Department.vw_reports_basic FROM 'researcher'@'localhost';

-- view: reports timeline lag/lead
CREATE VIEW vw_reports_timeline AS
SELECT report_id, publish_date,
       LAG(publish_date) OVER (ORDER BY publish_date) AS prev_pub,
       LEAD(publish_date) OVER (ORDER BY publish_date) AS next_pub
FROM reports;

-- stored procedure: get report summary
DELIMITER //
CREATE PROCEDURE sp_report_summary(IN p_id INT)
BEGIN
  SELECT title, summary FROM reports WHERE report_id = p_id;
END //
DELIMITER ;
#====================================================================================================
#global_statistics

-- view: global statistics basic
CREATE VIEW vw_global_stats_basic AS
SELECT stat_id, year, global_population, global_life_expectancy FROM global_statistics;

-- view: life expectancy trend using window (lag)
CREATE VIEW vw_global_life_trend AS
SELECT year, global_life_expectancy,
       LAG(global_life_expectancy) OVER (ORDER BY year) AS prev_life_expectancy
FROM global_statistics;

-- stored procedure: stats for year
DELIMITER //
CREATE PROCEDURE sp_stats_for_year(IN p_year INT)
BEGIN
  SELECT * FROM global_statistics WHERE year = p_year;
END //
DELIMITER ;

-- stored procedure: years range
DELIMITER //
CREATE PROCEDURE sp_stats_range(IN start_year INT, IN end_year INT)
BEGIN
  SELECT year, total_disease_cases, total_vaccinations FROM global_statistics WHERE year BETWEEN start_year AND end_year;
END //
DELIMITER ;

-- trigger: ensure year reasonable
DELIMITER //
CREATE TRIGGER trg_global_stats_year_check
BEFORE INSERT ON global_statistics
FOR EACH ROW
BEGIN
  IF NEW.year < 1900 OR NEW.year > 2100 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'year must be between 1900 and 2100';
  END IF;
END //
DELIMITER ;

-- view: vaccination progress running total (window)
CREATE VIEW vw_vaccination_running AS
SELECT year, total_vaccinations,
       SUM(total_vaccinations) OVER (ORDER BY year) AS cumulative_vaccinations
FROM global_statistics;

-- DCL: grant select on stats view to policy user
GRANT SELECT ON Electricity_Department.vw_global_stats_basic TO 'policy_user'@'localhost';

-- stored procedure: get top disease info (returns text fields)
DELIMITER //
CREATE PROCEDURE sp_top_disease(IN p_year INT, OUT topd VARCHAR(100))
BEGIN
  SELECT top_disease INTO topd FROM global_statistics WHERE year = p_year;
END //
DELIMITER ;

-- TCL: transaction example for publishing annual stats
START TRANSACTION;
SAVEPOINT sp_stats_publish;
ROLLBACK TO SAVEPOINT sp_stats_publish;
COMMIT;

-- view: death rate trend with lead (forecast helper)
CREATE VIEW vw_death_rate_lead AS
SELECT year, global_death_rate,
       LEAD(global_death_rate) OVER (ORDER BY year) AS next_year_death_rate
FROM global_statistics;

-- trigger: prevent negative totals
DELIMITER //
CREATE TRIGGER trg_global_totals_check
BEFORE INSERT ON global_statistics
FOR EACH ROW
BEGIN
  IF NEW.total_disease_cases < 0 OR NEW.total_vaccinations < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'totals must be non-negative';
  END IF;
END //
DELIMITER ;

-- stored procedure: cumulative vaccinations up to year
DELIMITER //
CREATE PROCEDURE sp_cumulative_vaccinations(IN p_year INT, OUT cumulative BIGINT)
BEGIN
  SELECT SUM(total_vaccinations) INTO cumulative FROM global_statistics WHERE year <= p_year;
END //
DELIMITER ;

-- DCL: revoke select example
REVOKE SELECT ON Electricity_Department.vw_global_stats_basic FROM 'policy_user'@'localhost';

-- view: stats with population per million helper
CREATE VIEW vw_stats_population_millions AS
SELECT year, global_population, (global_population / 1000000) AS population_millions FROM global_statistics;

-- stored procedure: return range of years available (distinct)
DELIMITER //
CREATE PROCEDURE sp_years_range()
BEGIN
  SELECT MIN(year) AS first_year, MAX(year) AS last_year FROM global_statistics;
END //
DELIMITER ;
