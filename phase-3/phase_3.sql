use PROJECTS;
create database PROJECTS;
use PROJECTS;

-- 1. Countries
#queries:
-- Display all countries and details
SELECT * FROM countries;

-- Find countries with GDP per capita greater than 50,000
SELECT country_name, gdp_per_capita FROM countries WHERE gdp_per_capita > 50000;

-- Show countries in Asia with population above 500 million
SELECT country_name, population FROM countries 
WHERE continent = 'Asia' AND population > 500000000;

-- Use ORDER BY to sort countries by GDP descending
SELECT country_name, gdp_per_capita FROM countries ORDER BY gdp_per_capita DESC;

-- Find average life expectancy by continent (Aggregate + GROUP BY)
SELECT continent, AVG(life_expectancy) AS avg_life FROM countries GROUP BY continent;

-- Find countries with literacy rate above average literacy rate (Subquery)
SELECT country_name, literacy_rate 
FROM countries
WHERE literacy_rate > (SELECT AVG(literacy_rate) FROM countries);

-- Find top 3 richest countries by GDP per capita (LIMIT)
SELECT country_name, gdp_per_capita FROM countries ORDER BY gdp_per_capita DESC LIMIT 3;

-- Use built-in string function: display country names in uppercase
SELECT UPPER(country_name) AS upper_country FROM countries;

-- Use CONCAT to create a readable sentence
SELECT CONCAT(country_name, ' is located in ', continent, ' continent.') AS country_info FROM countries;

-- Use date function: add current date to show report generation
SELECT country_name, NOW() AS report_generated_on FROM countries;

--  Create a User Defined Function (UDF) to calculate Total GDP
DELIMITER //
CREATE FUNCTION total_gdp(pop BIGINT, gdp DECIMAL(12,2))
RETURNS DECIMAL(20,2)
DETERMINISTIC
BEGIN
  RETURN pop * gdp;
END //
DELIMITER ;

--  Use the UDF to find total GDP of each country
SELECT country_name, total_gdp(population, gdp_per_capita) AS total_gdp_value FROM countries;

-- Find countries with population less than the average population (Subquery)
SELECT country_name, population FROM countries
WHERE population < (SELECT AVG(population) FROM countries);

-- Show continents and count of countries in each (GROUP BY + COUNT)
SELECT continent, COUNT(*) AS country_count FROM countries GROUP BY continent;

-- Use CASE to categorize countries by GDP per capita
SELECT country_name,
       CASE
           WHEN gdp_per_capita >= 50000 THEN 'High Income'
           WHEN gdp_per_capita BETWEEN 10000 AND 49999 THEN 'Middle Income'
           ELSE 'Low Income'
       END AS income_category
FROM countries;

-- Use SUBSTRING to show first 3 letters of each country name
SELECT SUBSTRING(country_name, 1, 3) AS short_name FROM countries;

-- Find countries with same continent (SELF JOIN)
SELECT c1.country_name AS Country1, c2.country_name AS Country2, c1.continent
FROM countries c1
JOIN countries c2 ON c1.continent = c2.continent AND c1.country_id < c2.country_id
ORDER BY c1.continent;

-- Find country with maximum literacy rate (Aggregate + Subquery)
SELECT country_name, literacy_rate
FROM countries
WHERE literacy_rate = (SELECT MAX(literacy_rate) FROM countries);

-- Find total health budget across all countries (SUM)
SELECT SUM(health_budget) AS total_health_budget FROM countries;

--  Use ROUND() and AVG() together for precise GDP average
SELECT ROUND(AVG(gdp_per_capita), 2) AS avg_gdp_per_capita FROM countries;

#===================================================================================================================================
-- 2. Hospitals
#queies:
-- Display all hospital details
SELECT * FROM hospitals;

-- Show hospitals with capacity greater than 1500
SELECT hospital_name, capacity FROM hospitals WHERE capacity > 1500;

-- Find hospitals established before 1900
SELECT hospital_name, established_year FROM hospitals WHERE established_year < 1900;

-- Sort hospitals by capacity in descending order
SELECT hospital_name, capacity FROM hospitals ORDER BY capacity DESC;

-- Count hospitals by specialization (GROUP BY)
SELECT specialization, COUNT(*) AS total_hospitals FROM hospitals GROUP BY specialization;

-- Find hospitals established after the average established year (Subquery)
SELECT hospital_name, established_year 
FROM hospitals
WHERE established_year > (SELECT AVG(established_year) FROM hospitals);

-- Find top 3 largest hospitals by capacity
SELECT hospital_name, capacity FROM hospitals ORDER BY capacity DESC LIMIT 3;

-- Use string function to show hospital names in uppercase
SELECT UPPER(hospital_name) AS upper_hospital FROM hospitals;

-- Use CONCAT to create readable sentence
SELECT CONCAT(hospital_name, ' located in ', city, ' specializes in ', specialization, '.') AS hospital_info
FROM hospitals;

-- Use date function to add current date as “Data Checked On”
SELECT hospital_name, NOW() AS data_checked_on FROM hospitals;

-- Create User Defined Function (UDF) to calculate age of hospital
DELIMITER //
CREATE FUNCTION hospital_age(est_year INT)
RETURNS INT
DETERMINISTIC
BEGIN
  RETURN YEAR(CURDATE()) - est_year;
END //
DELIMITER ;

-- Use the UDF to display hospital name and its age
SELECT hospital_name, hospital_age(established_year) AS hospital_age_years FROM hospitals;

-- Find hospitals located in cities starting with 'B' (LIKE operator)
SELECT hospital_name, city FROM hospitals WHERE city LIKE 'B%';

-- Join hospitals with countries to display hospital and country name
SELECT h.hospital_name, c.country_name, h.city
FROM hospitals h
JOIN countries c ON h.country_id = c.country_id;

-- Show specialization and total capacity per specialization (GROUP BY + SUM)
SELECT specialization, SUM(capacity) AS total_capacity FROM hospitals GROUP BY specialization;

-- Categorize hospitals based on capacity (CASE)
SELECT hospital_name,
       CASE
           WHEN capacity >= 2000 THEN 'Large'
           WHEN capacity BETWEEN 1000 AND 1999 THEN 'Medium'
           ELSE 'Small'
       END AS hospital_size
FROM hospitals;

-- Use SUBSTRING to extract first 5 characters of hospital name
SELECT SUBSTRING(hospital_name, 1, 5) AS short_name FROM hospitals;

-- Find hospital with maximum capacity (Aggregate + Subquery)
SELECT hospital_name, capacity
FROM hospitals
WHERE capacity = (SELECT MAX(capacity) FROM hospitals);

-- Calculate average capacity across all hospitals
SELECT ROUND(AVG(capacity), 2) AS avg_capacity FROM hospitals;

-- Count total hospitals established before 1950
SELECT COUNT(*) AS old_hospitals FROM hospitals WHERE established_year < 1950;

#=========================================================================================================================================
-- 3. Doctors
#queries:
-- Display all doctors and their details
SELECT * FROM doctors;

-- Find doctors earning more than 140000
SELECT first_name, last_name, salary FROM doctors WHERE salary > 140000;

-- Show female doctors with more than 10 years of experience
SELECT first_name, last_name, experience_years FROM doctors 
WHERE gender = 'F' AND experience_years > 10;

-- Use ORDER BY to sort doctors by salary descending
SELECT first_name, last_name, salary FROM doctors ORDER BY salary DESC;

-- Find average salary per specialty (Aggregate + GROUP BY)
SELECT specialty, AVG(salary) AS avg_salary FROM doctors GROUP BY specialty;

-- Find doctors earning above the average salary (Subquery)
SELECT first_name, last_name, salary 
FROM doctors
WHERE salary > (SELECT AVG(salary) FROM doctors);

-- Find top 3 highest-paid doctors (LIMIT)
SELECT first_name, last_name, salary FROM doctors ORDER BY salary DESC LIMIT 3;

-- Use built-in string function: show doctor names in uppercase
SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS doctor_name_upper FROM doctors;

-- Use CONCAT to create readable info about each doctor
SELECT CONCAT(first_name, ' ', last_name, ' specializes in ', specialty) AS doctor_info FROM doctors;

-- Add current date to show report generation
SELECT first_name, last_name, NOW() AS report_generated_on FROM doctors;

-- Create a User Defined Function (UDF) to calculate yearly income with bonus
DELIMITER //
CREATE FUNCTION yearly_income(base_salary DECIMAL(12,2))
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
  RETURN base_salary * 1.10; -- 10% annual bonus
END //
DELIMITER ;

-- Use the UDF to show yearly income of all doctors
SELECT first_name, last_name, yearly_income(salary) AS yearly_income FROM doctors;

-- Find doctors with experience less than average (Subquery)
SELECT first_name, last_name, experience_years FROM doctors
WHERE experience_years < (SELECT AVG(experience_years) FROM doctors);

-- Show each specialty and count of doctors (GROUP BY + COUNT)
SELECT specialty, COUNT(*) AS total_doctors FROM doctors GROUP BY specialty;

-- Use CASE to categorize doctors by experience
SELECT first_name, last_name,
       CASE
           WHEN experience_years >= 15 THEN 'Highly Experienced'
           WHEN experience_years BETWEEN 8 AND 14 THEN 'Moderately Experienced'
           ELSE 'Junior Doctor'
       END AS experience_level
FROM doctors;

-- Use SUBSTRING to show first 3 letters of each doctor’s specialty
SELECT SUBSTRING(specialty, 1, 3) AS short_specialty FROM doctors;

-- Find doctors working in same hospital (SELF JOIN)
SELECT d1.first_name AS Doctor1, d2.first_name AS Doctor2, d1.hospital_id
FROM doctors d1
JOIN doctors d2 ON d1.hospital_id = d2.hospital_id AND d1.doctor_id < d2.doctor_id
ORDER BY d1.hospital_id;

-- Find doctor with maximum salary (Aggregate + Subquery)
SELECT first_name, last_name, salary
FROM doctors
WHERE salary = (SELECT MAX(salary) FROM doctors);

-- Find total salary expense of all doctors (SUM)
SELECT SUM(salary) AS total_salary_expense FROM doctors;

-- Use ROUND() and AVG() together for precise average salary
SELECT ROUND(AVG(salary), 2) AS avg_salary FROM doctors;

#========================================================================================================================================
-- 4. Patients
#queries:
-- 1. List all patients with full name and status
SELECT patient_id, CONCAT(first_name, ' ', last_name) AS full_name, status FROM patients;

-- 2. Find recovered patients (basic WHERE)
SELECT first_name, last_name, discharge_date FROM patients WHERE status = 'Recovered';

-- 3. Count patients by gender
SELECT gender, COUNT(*) AS total_patients FROM patients GROUP BY gender;

-- 4. Patients per country
SELECT c.country_name, COUNT(p.patient_id) AS patients_count
FROM patients p
JOIN countries c ON p.country_id = c.country_id
GROUP BY c.country_name;

-- 5. Patients currently admitted (discharge_date IS NULL)
SELECT patient_id, first_name, last_name, admission_date FROM patients WHERE discharge_date IS NULL;

-- 6. Patients older than 60 (using DOB)
SELECT patient_id, first_name, last_name, dob
FROM patients
WHERE TIMESTAMPDIFF(YEAR, dob, CURDATE()) > 60;

-- 7. Recent admissions in last 30 days
SELECT patient_id, first_name, last_name, admission_date
FROM patients
WHERE admission_date >= CURDATE() - INTERVAL 30 DAY;

-- 8. Top 5 countries by patient count (ORDER BY + LIMIT)
SELECT country_id, COUNT(*) AS total_patients
FROM patients
GROUP BY country_id
ORDER BY total_patients DESC
LIMIT 5;

-- 9. Number of patients per disease with at least 2 cases (HAVING)
SELECT d.disease_name, COUNT(p.patient_id) AS cases
FROM patients p
JOIN diseases d ON p.disease_id = d.disease_id
GROUP BY d.disease_name
HAVING COUNT(p.patient_id) >= 2;

-- 10. Update: mark a patient as discharged and set discharge_date
UPDATE patients
SET discharge_date = '2025-08-20', status = 'Recovered'
WHERE patient_id = 3;

-- 11. Delete test or placeholder patients (example)
DELETE FROM patients WHERE patient_id > 1000;

-- 12. Add blood_group column (if not already present)
ALTER TABLE patients ADD COLUMN IF NOT EXISTS blood_group VARCHAR(5);

-- 13. Create index on admission_date to speed queries
CREATE INDEX idx_admission_date ON patients(admission_date);

-- 14. Count patients by status
SELECT status, COUNT(*) AS count_status FROM patients GROUP BY status;

-- 15. Find average length of stay for discharged patients (discharge_date - admission_date)
SELECT AVG(DATEDIFF(discharge_date, admission_date)) AS avg_length_of_stay
FROM patients
WHERE discharge_date IS NOT NULL;

-- 16. Patients with duplicate first and last names (self-join)
SELECT p1.patient_id AS id1, p2.patient_id AS id2, p1.first_name, p1.last_name
FROM patients p1
JOIN patients p2 ON p1.first_name = p2.first_name AND p1.last_name = p2.last_name AND p1.patient_id < p2.patient_id;

-- 17. Create a view for active inpatients
CREATE VIEW v_inpatients AS
SELECT patient_id, first_name, last_name, admission_date, status
FROM patients
WHERE discharge_date IS NULL;

-- 18. Use CASE to categorize age groups
SELECT patient_id, first_name, last_name,
CASE
  WHEN TIMESTAMPDIFF(YEAR, dob, CURDATE()) < 18 THEN 'Child'
  WHEN TIMESTAMPDIFF(YEAR, dob, CURDATE()) BETWEEN 18 AND 59 THEN 'Adult'
  ELSE 'Senior'
END AS age_group
FROM patients;

-- 19. Subquery: patients from countries with population > average population
SELECT p.patient_id, p.first_name, p.last_name, p.country_id
FROM patients p
WHERE p.country_id IN (SELECT country_id FROM countries WHERE population > (SELECT AVG(population) FROM countries));

-- 20. Create a stored routine to mark multiple patients as "Archived" by country_id
DELIMITER $$
CREATE PROCEDURE archive_patients_by_country(IN cid INT)
BEGIN
  UPDATE patients SET status = 'Archived' WHERE country_id = cid;
END $$
DELIMITER ;

#============================================================================================================================
-- 5. Diseases
#queries:
-- 1. List all diseases and core details
SELECT disease_id, disease_name, category, transmission_mode, mortality_rate FROM diseases;

-- 2. Top 5 deadliest diseases (highest mortality_rate)
SELECT disease_name, mortality_rate FROM diseases ORDER BY mortality_rate DESC LIMIT 5;

-- 3. Count diseases by category
SELECT category, COUNT(*) AS total_in_category FROM diseases GROUP BY category;

-- 4. Diseases discovered before 1900
SELECT disease_name, discovered_year FROM diseases WHERE discovered_year < 1900;

-- 5. Diseases with vaccines available
SELECT disease_name FROM diseases WHERE vaccine_available = TRUE;

-- 6. Mark a disease as vaccine available (UPDATE)
UPDATE diseases SET vaccine_available = TRUE WHERE disease_name = 'Dengue';

-- 7. Delete low-risk record example
DELETE FROM diseases WHERE disease_name = 'Cholera' AND mortality_rate < 2.0;

-- 8. Add a column for WHO priority (ALTER)
ALTER TABLE diseases ADD COLUMN priority_level VARCHAR(20) DEFAULT 'Normal';

-- 9. Group by transmission mode and count
SELECT transmission_mode, COUNT(*) AS count_by_mode FROM diseases GROUP BY transmission_mode;

-- 10. Diseases with mortality_rate > average mortality (subquery)
SELECT disease_name, mortality_rate FROM diseases WHERE mortality_rate > (SELECT AVG(mortality_rate) FROM diseases);

-- 11. Use LIKE to find diseases with 'virus' or 'viral' in notes
SELECT disease_name, notes FROM diseases WHERE LOWER(notes) LIKE '%viral%' OR LOWER(category) LIKE '%viral%';

-- 12. Rename table (if you want a world_ prefix)
ALTER TABLE diseases RENAME TO world_diseases;

-- 13. Aggregate: average mortality by category
SELECT category, ROUND(AVG(mortality_rate),2) AS avg_mortality FROM diseases GROUP BY category;

-- 14. Index common lookup column
CREATE INDEX idx_disease_name ON diseases(disease_name);

-- 15. Show diseases without vaccine and list their transmission modes
SELECT disease_name, transmission_mode FROM diseases WHERE vaccine_available = FALSE;

-- 16. Limit & offset — paginated list (page 2, 5 rows per page)
SELECT * FROM diseases ORDER BY disease_name LIMIT 5 OFFSET 5;

-- 17. Update mortality rate (example correction)
UPDATE diseases SET mortality_rate = 3.00 WHERE disease_name = 'COVID-19';

-- 18. CASE to categorize mortality risk
SELECT disease_name,
CASE
  WHEN mortality_rate >= 50 THEN 'Very High'
  WHEN mortality_rate BETWEEN 10 AND 49.99 THEN 'High'
  WHEN mortality_rate BETWEEN 1 AND 9.99 THEN 'Moderate'
  ELSE 'Low'
END AS mortality_risk
FROM diseases;

-- 19. Find diseases that share the same category (self join)
SELECT d1.disease_name AS Disease1, d2.disease_name AS Disease2, d1.category
FROM diseases d1
JOIN diseases d2 ON d1.category = d2.category AND d1.disease_id < d2.disease_id
ORDER BY d1.category;

-- 20. Create a view of vaccine-less dangerous diseases (mortality > 10 and no vaccine)
CREATE VIEW v_high_risk_no_vaccine AS
SELECT disease_id, disease_name, mortality_rate FROM diseases
WHERE mortality_rate > 10 AND vaccine_available = FALSE;

#=================================================================================================================================

-- 6. Vaccines
#queries:
-- 1. List all vaccines and basic attributes
SELECT vaccine_id, vaccine_name, manufacturer, disease_id, approval_year, efficacy_rate FROM vaccines;

-- 2. Vaccines ordered by efficacy
SELECT vaccine_name, efficacy_rate FROM vaccines ORDER BY efficacy_rate DESC;

-- 3. Count vaccines per manufacturer
SELECT manufacturer, COUNT(*) AS total_vaccines FROM vaccines GROUP BY manufacturer;

-- 4. Vaccines approved before 2000
SELECT vaccine_name, approval_year FROM vaccines WHERE approval_year < 2000;

-- 5. Update efficacy for an entry
UPDATE vaccines SET efficacy_rate = 92.00 WHERE vaccine_name = 'AstraZeneca COVID-19';

-- 6. Delete low-efficacy vaccines (example)
DELETE FROM vaccines WHERE efficacy_rate < 50.00;

-- 7. Add price column (if not exists)
ALTER TABLE vaccines ADD COLUMN IF NOT EXISTS price DECIMAL(10,2) DEFAULT 0.00;

-- 8. Average efficacy per disease
SELECT v.disease_id, d.disease_name, ROUND(AVG(v.efficacy_rate),2) AS avg_efficacy
FROM vaccines v
LEFT JOIN diseases d ON v.disease_id = d.disease_id
GROUP BY v.disease_id, d.disease_name;

-- 9. Vaccines requiring >1 dose
SELECT vaccine_name, doses_required FROM vaccines WHERE doses_required > 1;

-- 10. Vaccines with long expiry periods (>=24 months)
SELECT vaccine_name, expiry_period FROM vaccines WHERE expiry_period >= 24;

-- 11. Create an index on disease_id for faster joins
CREATE INDEX idx_vaccine_disease ON vaccines(disease_id);

-- 12. Find vaccines for diseases currently in research projects (JOIN)
SELECT DISTINCT v.vaccine_name, d.disease_name
FROM vaccines v
JOIN research_projects rp ON v.disease_id = rp.disease_id
JOIN diseases d ON v.disease_id = d.disease_id
WHERE rp.status = 'Ongoing';

-- 13. Use a subquery to show vaccines for diseases with mortality > 5%
SELECT vaccine_name FROM vaccines WHERE disease_id IN (SELECT disease_id FROM diseases WHERE mortality_rate > 5);

-- 14. Price update example: set price for a vaccine
UPDATE vaccines SET price = 49.99 WHERE vaccine_name = 'Influenza Vaccine';

-- 15. Create a view showing vaccine + disease information
CREATE VIEW v_vaccine_info AS
SELECT v.vaccine_id, v.vaccine_name, v.manufacturer, d.disease_name, v.efficacy_rate
FROM vaccines v
LEFT JOIN diseases d ON v.disease_id = d.disease_id;

-- 16. Use CONCAT to format a human-readable label
SELECT vaccine_id, CONCAT(vaccine_name, ' by ', manufacturer, ' (', approval_year, ')') AS label FROM vaccines;

-- 17. Find vaccines with efficacy above avg efficacy
SELECT vaccine_name, efficacy_rate FROM vaccines WHERE efficacy_rate > (SELECT AVG(efficacy_rate) FROM vaccines);

-- 18. Count vaccines per approval decade (GROUP BY expression)
SELECT CONCAT(FLOOR(approval_year/10)*10, 's') AS decade, COUNT(*) AS num_vaccines
FROM vaccines
GROUP BY decade
ORDER BY decade;

-- 19. Ensure no duplicate vaccine_name (example constraint simulation)
SELECT vaccine_name, COUNT(*) AS cnt FROM vaccines GROUP BY vaccine_name HAVING cnt > 1;

-- 20. Stored procedure to increase price for a manufacturer by percent
DELIMITER $$
CREATE PROCEDURE increase_price_manufacturer(IN mfg VARCHAR(100), IN pct DECIMAL(5,2))
BEGIN
  UPDATE vaccines SET price = price * (1 + pct/100) WHERE manufacturer = mfg;
END $$
DELIMITER ;


#============================================================================================================================
-- 7. Vaccination_Centers
#queries:
-- 1. List centers and capacity
SELECT center_id, center_name, city, capacity_per_day FROM vaccination_centers;

-- 2. Centers ordered by capacity descending
SELECT center_name, capacity_per_day FROM vaccination_centers ORDER BY capacity_per_day DESC;

-- 3. Count centers per country
SELECT country_id, COUNT(*) AS total_centers FROM vaccination_centers GROUP BY country_id;

-- 4. Centers established before 2010
SELECT center_id, center_name, established_year FROM vaccination_centers WHERE established_year < 2010;

-- 5. Increase capacity for a city (UPDATE)
UPDATE vaccination_centers SET capacity_per_day = capacity_per_day + 200 WHERE city = 'Delhi';

-- 6. Delete tiny centers with capacity < 50
DELETE FROM vaccination_centers WHERE capacity_per_day < 50;

-- 7. Add email column if not present
ALTER TABLE vaccination_centers ADD COLUMN IF NOT EXISTS email VARCHAR(100);

-- 8. Average capacity calculation
SELECT ROUND(AVG(capacity_per_day),2) AS avg_capacity FROM vaccination_centers;

-- 9. Cities with more than one center (HAVING)
SELECT city, COUNT(*) AS center_count FROM vaccination_centers GROUP BY city HAVING COUNT(*) > 1;

-- 10. Centers opening before 08:00 (TIME comparison)
SELECT center_name, opening_time FROM vaccination_centers WHERE opening_time < '08:00:00';

-- 11. Join with countries to show names
SELECT vc.center_name, c.country_name, vc.city FROM vaccination_centers vc JOIN countries c ON vc.country_id = c.country_id;

-- 12. Create index on city for faster lookups
CREATE INDEX idx_center_city ON vaccination_centers(city);

-- 13. Find center(s) with max capacity
SELECT * FROM vaccination_centers WHERE capacity_per_day = (SELECT MAX(capacity_per_day) FROM vaccination_centers);

-- 14. Update contact number format example
UPDATE vaccination_centers SET contact_number = CONCAT('+', TRIM(LEADING '+' FROM contact_number)) WHERE contact_number NOT LIKE '+%';

-- 15. Create view for centers in a given country (example: country_id = 2)
CREATE VIEW v_centers_in_country2 AS SELECT * FROM vaccination_centers WHERE country_id = 2;

-- 16. Calculate total daily capacity across all centers
SELECT SUM(capacity_per_day) AS total_daily_capacity FROM vaccination_centers;

-- 17. Use CASE to label size of center by capacity
SELECT center_id, center_name,
CASE
  WHEN capacity_per_day >= 800 THEN 'Large'
  WHEN capacity_per_day BETWEEN 400 AND 799 THEN 'Medium'
  ELSE 'Small'
END AS center_size
FROM vaccination_centers;

-- 18. Find centers with no email (null or empty)
SELECT center_id, center_name FROM vaccination_centers WHERE email IS NULL OR email = '';

-- 19. Delete centers established before a cutoff (example)
DELETE FROM vaccination_centers WHERE established_year < 1990;

-- 20. Add a unique constraint on (center_name, city) to avoid duplicates (syntax may vary by DB)
ALTER TABLE vaccination_centers ADD CONSTRAINT unique_center_city UNIQUE (center_name, city);


#===========================================================================================================================

-- 8. Vaccination_Records
#queries:
-- 1. Show all vaccination records
SELECT record_id, patient_id, vaccine_id, dose_number, vaccination_date FROM vaccination_records;

-- 2. Count first doses administered
SELECT COUNT(*) AS first_doses FROM vaccination_records WHERE dose_number = 1;

-- 3. Records grouped by center
SELECT center_id, COUNT(*) AS records_count FROM vaccination_records GROUP BY center_id;

-- 4. Average dose number per vaccine (to see how many doses on average)
SELECT vaccine_id, ROUND(AVG(dose_number),2) AS avg_doses FROM vaccination_records GROUP BY vaccine_id;

-- 5. Update: mark records with side effects to have a follow-up remark
UPDATE vaccination_records SET remarks = 'Follow up needed' WHERE side_effects IS NOT NULL AND side_effects <> '' AND remarks = '';

-- 6. Delete a record by id
DELETE FROM vaccination_records WHERE record_id = 10;

-- 7. Count records per vaccinator (administered_by)
SELECT administered_by, COUNT(*) AS given FROM vaccination_records GROUP BY administered_by;

-- 8. Vaccines with more than 2 records (HAVING)
SELECT vaccine_id, COUNT(*) AS times_administered FROM vaccination_records GROUP BY vaccine_id HAVING COUNT(*) > 2;

-- 9. Add verified column if missing
ALTER TABLE vaccination_records ADD COLUMN IF NOT EXISTS verified BOOLEAN DEFAULT FALSE;

-- 10. Records after a given date
SELECT patient_id, batch_number FROM vaccination_records WHERE vaccination_date > '2024-06-01';

-- 11. Join to get patient names and vaccine names for a record
SELECT vr.record_id, CONCAT(p.first_name, ' ', p.last_name) AS patient_name, v.vaccine_name, vr.vaccination_date
FROM vaccination_records vr
JOIN patients p ON vr.patient_id = p.patient_id
JOIN vaccines v ON vr.vaccine_id = v.vaccine_id;

-- 12. Find patients who completed full required doses (requires knowing required doses in vaccines)
SELECT p.patient_id, CONCAT(p.first_name,' ',p.last_name) AS patient_name, COUNT(vr.record_id) AS doses_taken, v.doses_required
FROM vaccination_records vr
JOIN patients p ON vr.patient_id = p.patient_id
JOIN vaccines v ON vr.vaccine_id = v.vaccine_id
GROUP BY p.patient_id, v.doses_required
HAVING COUNT(vr.record_id) >= v.doses_required;

-- 13. Recent adverse events (side_effects not NULL)
SELECT record_id, patient_id, side_effects, vaccination_date FROM vaccination_records WHERE side_effects IS NOT NULL AND side_effects <> '';

-- 14. Create index on vaccine_id for analytics
CREATE INDEX idx_vr_vaccine_id ON vaccination_records(vaccine_id);

-- 15. Monthly vaccinations count (GROUP BY YEAR+MONTH)
SELECT YEAR(vaccination_date) AS yr, MONTH(vaccination_date) AS mon, COUNT(*) AS total
FROM vaccination_records
GROUP BY yr, mon
ORDER BY yr, mon;

-- 16. Subquery: records for vaccines with efficacy > 90% (join via vaccines)
SELECT vr.record_id, vr.patient_id, vr.vaccine_id
FROM vaccination_records vr
WHERE vr.vaccine_id IN (SELECT vaccine_id FROM vaccines WHERE efficacy_rate > 90);

-- 17. Mark verified records for a specific batch
UPDATE vaccination_records SET verified = TRUE WHERE batch_number = 'BATCH007';

-- 18. Create a view of adverse events summary
CREATE VIEW v_adverse_summary AS
SELECT vaccine_id, COUNT(*) AS adverse_count
FROM vaccination_records
WHERE side_effects IS NOT NULL AND side_effects <> ''
GROUP BY vaccine_id;

-- 19. Delete duplicate records (example pattern) — keep earliest by vaccination_date
DELETE vr1 FROM vaccination_records vr1
JOIN vaccination_records vr2
  ON vr1.patient_id = vr2.patient_id
 AND vr1.vaccine_id = vr2.vaccine_id
 AND vr1.record_id > vr2.record_id
 AND vr1.vaccination_date = vr2.vaccination_date;

-- 20. Find centers with highest average side effects reports per 1000 vaccinations
SELECT center_id,
  (SUM(CASE WHEN side_effects IS NOT NULL AND side_effects <> '' THEN 1 ELSE 0 END) / COUNT(*)) * 1000 AS side_effects_per_1000
FROM vaccination_records
GROUP BY center_id
ORDER BY side_effects_per_1000 DESC;


#============================================================================================================================


-- 9. Research_Projects
#queries:
-- 1. List all projects and their status
SELECT project_id, project_name, disease_id, status, budget FROM research_projects;

-- 2. Ongoing projects and their budgets
SELECT project_name, budget FROM research_projects WHERE status = 'Ongoing';

-- 3. Count projects per disease
SELECT disease_id, COUNT(*) AS projects_count FROM research_projects GROUP BY disease_id;

-- 4. Average project budget
SELECT ROUND(AVG(budget),2) AS avg_budget FROM research_projects;

-- 5. Extend status for long-running projects (update example)
UPDATE research_projects SET status = 'Extended' WHERE end_date > '2025-12-31';

-- 6. Delete a completed/obsolete project
DELETE FROM research_projects WHERE project_id = 5;

-- 7. Sum budgets by funding source
SELECT funding_source, SUM(budget) AS total_budget FROM research_projects GROUP BY funding_source;

-- 8. Lead scientist project counts
SELECT lead_scientist, COUNT(*) AS num_projects FROM research_projects GROUP BY lead_scientist;

-- 9. Add collaborators column (ALTER)
ALTER TABLE research_projects ADD COLUMN IF NOT EXISTS collaborators INT DEFAULT 0;

-- 10. Order projects by end_date (nearest ending first)
SELECT project_name, end_date FROM research_projects ORDER BY end_date ASC;

-- 11. Completed projects and findings
SELECT project_name, findings FROM research_projects WHERE status = 'Completed';

-- 12. Projects with budget above average (subquery)
SELECT project_name, budget FROM research_projects WHERE budget > (SELECT AVG(budget) FROM research_projects);

-- 13. Projects overlapping a date range (e.g., active on 2024-06-01)
SELECT project_id, project_name FROM research_projects WHERE start_date <= '2024-06-01' AND end_date >= '2024-06-01';

-- 14. Create index on disease_id for research lookups
CREATE INDEX idx_proj_disease ON research_projects(disease_id);

-- 15. Join projects with diseases to get disease name
SELECT rp.project_name, d.disease_name, rp.status FROM research_projects rp JOIN diseases d ON rp.disease_id = d.disease_id;

-- 16. Projects with funding gaps (example: budget > 1,000,000 and no funding entry)
SELECT rp.project_id, rp.project_name
FROM research_projects rp
WHERE rp.budget > 1000000 AND rp.project_id NOT IN (SELECT project_id FROM funding);

-- 17. Monthly expenditure estimate: average yearly budget divided by 12
SELECT project_id, project_name, ROUND(budget/12,2) AS approx_monthly_budget FROM research_projects;

-- 18. Identify long-running projects (>3 years)
SELECT project_id, project_name, DATEDIFF(end_date, start_date)/365 AS duration_years
FROM research_projects
WHERE DATEDIFF(end_date, start_date)/365 > 3;

-- 19. Update collaborators number based on an external decision (example)
UPDATE research_projects SET collaborators = collaborators + 2 WHERE project_id IN (1,2);

-- 20. Create a summary view of project funding needs (budget - sum of funding)
CREATE VIEW v_project_funding_needs AS
SELECT rp.project_id, rp.project_name, rp.budget,
       COALESCE(SUM(f.amount),0) AS funding_received,
       rp.budget - COALESCE(SUM(f.amount),0) AS funding_gap
FROM research_projects rp
LEFT JOIN funding f ON rp.project_id = f.project_id
GROUP BY rp.project_id, rp.project_name, rp.budget;

#=============================================================================================================================
-- 10. Funding
#queries:
-- 1. Show all funding records
SELECT funding_id, project_id, donor_name, amount, funding_date FROM funding;

-- 2. Total funding amount overall
SELECT SUM(amount) AS total_funding FROM funding;

-- 3. Funding per project (GROUP BY)
SELECT project_id, SUM(amount) AS total_by_project FROM funding GROUP BY project_id;

-- 4. Funding per donor (GROUP BY)
SELECT donor_name, SUM(amount) AS total_by_donor FROM funding GROUP BY donor_name;

-- 5. Funding by country (JOIN countries)
SELECT c.country_name, SUM(f.amount) AS total_funding
FROM funding f
JOIN countries c ON f.country_id = c.country_id
GROUP BY c.country_name;

-- 6. Recent funding entries in 2023
SELECT * FROM funding WHERE YEAR(funding_date) = 2023;

-- 7. Delete small test donations (< 100)
DELETE FROM funding WHERE amount < 100;

-- 8. Add currency conversion example column (ALTER; store preferred currency)
ALTER TABLE funding ADD COLUMN  amount_usd DECIMAL(15,2);

-- 9. Update amount_usd using a fixed rate (example rate 1.0 for USD)
UPDATE funding SET amount_usd = amount WHERE currency = 'USD';

-- 10. Donors who funded more than once (HAVING)
SELECT donor_name, COUNT(*) AS donations FROM funding GROUP BY donor_name HAVING COUNT(*) > 1;

-- 11. Top donors by total amount (ORDER BY + LIMIT)
SELECT donor_name, SUM(amount) AS total_given FROM funding GROUP BY donor_name ORDER BY total_given DESC LIMIT 10;

-- 12. Funding per year (GROUP BY YEAR)
SELECT YEAR(funding_date) AS yr, SUM(amount) AS total_amount FROM funding GROUP BY yr ORDER BY yr;

-- 13. Attach contact_email if missing (update example)
UPDATE funding SET contact_email = 'unknown@example.com' WHERE contact_email IS NULL OR contact_email = '';

-- 14. Find projects that received no funding
SELECT project_id, project_name FROM research_projects WHERE project_id NOT IN (SELECT DISTINCT project_id FROM funding);

-- 15. Index country_id for faster joins
CREATE INDEX idx_funding_country ON funding(country_id);

-- 16. Average donation size
SELECT ROUND(AVG(amount),2) AS avg_donation FROM funding;

-- 17. Show funding breakdown for a project (example project_id=1)
SELECT f.donor_name, f.amount, f.funding_date FROM funding f WHERE f.project_id = 1 ORDER BY f.funding_date;

-- 18. Sum funding by currency
SELECT currency, SUM(amount) AS total_by_currency FROM funding GROUP BY currency;

-- 19. Insert example funding record (template)
INSERT INTO funding (funding_id, project_id, donor_name, country_id, amount, funding_date, currency, purpose, contact_email, remarks)
VALUES (11, 2, 'New Donor Org', 2, 50000.00, '2025-08-01', 'USD', 'Additional support', 'donor@org.com', 'One-time grant');

-- 20. Create a view summarizing funding status per project
CREATE VIEW v_project_funding_summary AS
SELECT rp.project_id, rp.project_name, rp.budget,
       COALESCE(SUM(f.amount),0) AS funding_received,
       rp.budget - COALESCE(SUM(f.amount),0) AS funding_gap
FROM research_projects rp
LEFT JOIN funding f ON rp.project_id = f.project_id
GROUP BY rp.project_id, rp.project_name, rp.budget;


#=================================================================================================================================
-- 11. Awareness_Campaigns
#queries:

SELECT * FROM awareness_campaigns;

SELECT campaign_name, budget FROM awareness_campaigns WHERE budget > 600000;

SELECT country_id, COUNT(*) AS campaigns_count FROM awareness_campaigns GROUP BY country_id;

SELECT organizer, SUM(budget) AS total_budget FROM awareness_campaigns GROUP BY organizer;

UPDATE awareness_campaigns SET outcome = 'Successful' WHERE campaign_id = 4;

DELETE FROM awareness_campaigns WHERE campaign_id = 7;

SELECT ROUND(AVG(budget),2) AS avg_budget FROM awareness_campaigns;

SELECT media_channels, COUNT(*) AS occurrences FROM awareness_campaigns GROUP BY media_channels;

ALTER TABLE awareness_campaigns ADD COLUMN evaluation TEXT;

SELECT campaign_name, end_date FROM awareness_campaigns ORDER BY end_date DESC;

SELECT campaign_name, target_audience FROM awareness_campaigns WHERE start_date > '2024-06-01';

SELECT campaign_name, DATEDIFF(end_date, start_date) AS duration_days FROM awareness_campaigns;

SELECT * FROM awareness_campaigns WHERE budget BETWEEN 400000 AND 800000 ORDER BY budget;

SELECT country_id, SUM(budget) AS country_budget FROM awareness_campaigns GROUP BY country_id HAVING SUM(budget) > 1000000;

SELECT campaign_name, LOCATE('Social', media_channels) AS social_pos FROM awareness_campaigns WHERE media_channels LIKE '%Social%';

SELECT campaign_name, CASE WHEN budget >= 1000000 THEN 'Large' WHEN budget >= 500000 THEN 'Medium' ELSE 'Small' END AS size_category FROM awareness_campaigns;

SELECT a.campaign_name, c.country_name FROM awareness_campaigns a JOIN countries c ON a.country_id = c.country_id;

SELECT campaign_name FROM awareness_campaigns WHERE outcome IS NULL OR outcome = '';

SELECT campaign_name FROM awareness_campaigns WHERE end_date < CURDATE();

-- UDF example: total_campaign_days (create once)
 DELIMITER //
 CREATE FUNCTION total_campaign_days(s DATE, e DATE)
 RETURNS INT DETERMINISTIC 
 BEGIN RETURN DATEDIFF(e, s) + 1;
 END // DELIMITER ; 
 


#================================================================================================================================
-- 12. Laboratories
#queries:
SELECT * FROM laboratories;
 SELECT lab_name,city,established_year FROM laboratories WHERE established_year>2005;
 SELECT country_id,COUNT(*) FROM laboratories GROUP BY country_id;
 SELECT head_scientist,COUNT(*) FROM laboratories GROUP BY head_scientist;
 UPDATE laboratories SET email='updated@lab.org' WHERE lab_id=2; DELETE FROM laboratories WHERE lab_id=10;
 SELECT accreditation,COUNT(*) FROM laboratories GROUP BY accreditation; 
 SELECT ROUND(AVG(established_year),0) FROM laboratories; 
 ALTER TABLE laboratories ADD COLUMN capacity INT DEFAULT 100;
 SELECT lab_name,phone FROM laboratories WHERE research_focus LIKE '%Research%';
 SELECT city,COUNT(*) FROM laboratories GROUP BY city HAVING COUNT(*)>1;
SELECT lab_name,CONCAT(head_scientist,' (',accreditation,')') FROM laboratories;
 SELECT * FROM laboratories ORDER BY established_year ASC LIMIT 5;
 SELECT country_id,MAX(capacity) FROM laboratories GROUP BY country_id;
 SELECT lab_id,(YEAR(CURDATE())-established_year) FROM laboratories;
 SELECT lab_name FROM laboratories WHERE email LIKE '%@%.org';
 SELECT lab_name,CASE WHEN capacity>=200 THEN 'Large' WHEN capacity>=100 THEN 'Medium' ELSE 'Small' END FROM laboratories;
 SELECT l.lab_name,c.country_name FROM laboratories l JOIN countries c ON l.country_id=c.country_id ORDER BY c.country_name;
UPDATE laboratories SET phone=REPLACE(phone,'-','') WHERE phone LIKE '%-%';
 CREATE FUNCTION lab_age(est_year INT) RETURNS INT DETERMINISTIC RETURN YEAR(CURDATE())-est_year;


#====================================================================================================================================
-- 13. Lab_Tests
SELECT * FROM lab_tests;
SELECT test_name,cost FROM lab_tests WHERE cost>1000;
SELECT patient_id,COUNT(*) FROM lab_tests GROUP BY patient_id;
SELECT lab_id,ROUND(AVG(cost),2) FROM lab_tests GROUP BY lab_id;
UPDATE lab_tests SET remarks='Recheck needed' WHERE result LIKE '%Slightly High%';
DELETE FROM lab_tests WHERE test_id=8;
SELECT tested_by,COUNT(*) FROM lab_tests GROUP BY tested_by;
SELECT ROUND(AVG(cost),2) FROM lab_tests;
ALTER TABLE lab_tests ADD COLUMN verified VARCHAR(70) DEFAULT 'No';
SELECT test_name,result FROM lab_tests ORDER BY test_date DESC;
SELECT test_name,COUNT(*) FROM lab_tests GROUP BY test_name HAVING COUNT(*)>1;
SELECT * FROM lab_tests WHERE test_date BETWEEN '2025-01-05' AND '2025-01-12';
SELECT lab_id,SUM(cost) FROM lab_tests GROUP BY lab_id;
SELECT patient_id,MAX(test_date) FROM lab_tests GROUP BY patient_id;
SELECT test_name,normal_range FROM lab_tests WHERE result NOT LIKE normal_range;
SELECT lt.test_name,l.lab_name FROM lab_tests lt JOIN laboratories l ON lt.lab_id=l.lab_id;
UPDATE lab_tests SET verified='Yes' WHERE cost>1000;
SELECT test_name,cost,CASE WHEN cost>1000 THEN 'Expensive' ELSE 'Affordable' END FROM lab_tests;
SELECT ROUND(SUM(cost),2) FROM lab_tests WHERE test_date>=DATE_SUB(CURDATE(),INTERVAL 30 DAY);
CREATE FUNCTION is_result_normal(r VARCHAR(255),normal VARCHAR(255)) RETURNS VARCHAR(10) DETERMINISTIC RETURN IF(r LIKE CONCAT('%',normal,'%'),'Normal','Abnormal');


#==================================================================================================================================

-- 14. Health_Programs
#queries:
SELECT * FROM health_programs;
SELECT program_name,budget FROM health_programs WHERE budget>5000000;
SELECT target_region,COUNT(*) FROM health_programs GROUP BY target_region;
SELECT funded_by,SUM(budget) FROM health_programs GROUP BY funded_by;
UPDATE health_programs SET outcome='Extended' WHERE end_date>'2026-01-01';
DELETE FROM health_programs WHERE program_id=4;
SELECT ROUND(AVG(budget),2) FROM health_programs;
SELECT managed_by,COUNT(*) FROM health_programs GROUP BY managed_by;
ALTER TABLE health_programs ADD COLUMN participants INT DEFAULT 0;
SELECT program_name,end_date FROM health_programs ORDER BY end_date;
SELECT program_name,outcome FROM health_programs WHERE outcome='Ongoing';
SELECT program_name,DATEDIFF(end_date,start_date) FROM health_programs;
SELECT * FROM health_programs WHERE start_date>=CURDATE();
SELECT target_region,ROUND(AVG(budget),2) FROM health_programs GROUP BY target_region HAVING AVG(budget)>3000000;
SELECT program_name FROM health_programs WHERE funded_by LIKE '%UNICEF%';
SELECT hp.program_name,p.participants FROM health_programs hp LEFT JOIN training_programs p ON hp.program_id=p.training_id;
SELECT program_name,CASE WHEN budget>=5000000 THEN 'High' WHEN budget>=2000000 THEN 'Medium' ELSE 'Low' END FROM health_programs;
UPDATE health_programs SET participants=participants+10 WHERE program_id IN (1,5,9);
SELECT funded_by,COUNT(*) FROM health_programs GROUP BY funded_by ORDER BY COUNT(*) DESC LIMIT 3;
CREATE FUNCTION program_active_on(d DATE,s DATE,e DATE) RETURNS TINYINT DETERMINISTIC RETURN (d>=s AND d<=e);

#===================================================================================================================================

-- 15. Program_Beneficiaries
#queries:
SELECT * FROM program_beneficiaries;
SELECT name,age,gender FROM program_beneficiaries WHERE country_id=1;
SELECT benefit_type,COUNT(*) FROM program_beneficiaries GROUP BY benefit_type;
SELECT program_id,ROUND(AVG(age),1) FROM program_beneficiaries GROUP BY program_id;
UPDATE program_beneficiaries SET status='Completed' WHERE beneficiary_id=7;
DELETE FROM program_beneficiaries WHERE remarks='Recovering';
SELECT gender,COUNT(*) FROM program_beneficiaries GROUP BY gender;
ALTER TABLE program_beneficiaries ADD COLUMN contact VARCHAR(20);
SELECT name,received_date FROM program_beneficiaries WHERE received_date BETWEEN '2025-02-01' AND '2025-06-30';
SELECT status,COUNT(*) FROM program_beneficiaries GROUP BY status HAVING COUNT(*)>2;
SELECT pb.name,hp.program_name FROM program_beneficiaries pb JOIN health_programs hp ON pb.program_id=hp.program_id;
SELECT country_id,COUNT(*) FROM program_beneficiaries GROUP BY country_id ORDER BY COUNT(*) DESC;
SELECT beneficiary_id FROM program_beneficiaries WHERE age<18 AND benefit_type LIKE '%Vaccin%';
SELECT program_id,COUNT(DISTINCT country_id) FROM program_beneficiaries GROUP BY program_id;
UPDATE program_beneficiaries SET remarks=CONCAT(remarks,' | Follow-up scheduled') WHERE status='Ongoing';
SELECT name,TIMESTAMPDIFF(YEAR,received_date,CURDATE()) FROM program_beneficiaries;
SELECT benefit_type,SUM(CASE WHEN status='Completed' THEN 1 ELSE 0 END) FROM program_beneficiaries GROUP BY benefit_type;
SELECT * FROM program_beneficiaries WHERE name LIKE 'A%';
SELECT program_id,AVG(age) FROM program_beneficiaries WHERE gender='F' GROUP BY program_id;
CREATE FUNCTION age_group_label(a INT) RETURNS VARCHAR(20) DETERMINISTIC RETURN (CASE WHEN a<13 THEN 'Child' WHEN a BETWEEN 13 AND 19 THEN 'Teen' WHEN a BETWEEN 20 AND 59 THEN 'Adult' ELSE 'Senior' END);


#=================================================================================================================================
-- 16. Health_Workers
#queries:
SELECT * FROM health_workers;

SELECT first_name, last_name, job_role FROM health_workers WHERE salary > 60000;

SELECT country_id, AVG(salary) AS avg_salary FROM health_workers GROUP BY country_id;

UPDATE health_workers SET salary = salary * 1.05 WHERE experience_years > 10;

DELETE FROM health_workers WHERE job_role = 'Paramedic';

ALTER TABLE health_workers ADD COLUMN hire_date DATE;

SELECT job_role, COUNT(*) AS role_count FROM health_workers GROUP BY job_role;

SELECT gender, AVG(experience_years) AS avg_experience FROM health_workers GROUP BY gender;

SELECT MAX(salary) AS highest_salary FROM health_workers;

SELECT job_role, AVG(salary) AS avg_role_salary FROM health_workers GROUP BY job_role HAVING AVG(salary) > 50000;

SELECT first_name, salary FROM health_workers WHERE country_id = 1 ORDER BY salary DESC;

SELECT first_name, last_name, salary FROM health_workers WHERE gender = 'F';

SELECT country_id, SUM(salary) AS total_salary FROM health_workers GROUP BY country_id;

SELECT first_name, job_role, salary FROM health_workers WHERE salary BETWEEN 40000 AND 80000;

SELECT first_name, experience_years FROM health_workers WHERE experience_years >= 5;

SELECT job_role, COUNT(*) AS count_per_role FROM health_workers GROUP BY job_role HAVING COUNT(*) > 1;

SELECT first_name, last_name FROM health_workers WHERE first_name LIKE 'A%';

SELECT country_id, MAX(salary) AS max_salary FROM health_workers GROUP BY country_id;

SELECT first_name, salary FROM health_workers ORDER BY experience_years DESC;

SELECT first_name, last_name, salary FROM health_workers WHERE salary = (SELECT MAX(salary) FROM health_workers);

#===================================================================================================================================
-- 17. Disease_Outbreaks
#queries:
SELECT * FROM disease_outbreaks;

SELECT disease_id, country_id, cases_reported FROM disease_outbreaks WHERE cases_reported > 300;

SELECT disease_id, SUM(deaths) AS total_deaths FROM disease_outbreaks GROUP BY disease_id;

UPDATE disease_outbreaks SET response_measures = 'Vaccination and Quarantine' WHERE outbreak_id = 3;

DELETE FROM disease_outbreaks WHERE recovery_rate < 90.00;

ALTER TABLE disease_outbreaks ADD COLUMN reported_by VARCHAR(100);

SELECT country_id, AVG(recovery_rate) AS avg_recovery FROM disease_outbreaks GROUP BY country_id;

SELECT disease_id, MAX(cases_reported) AS max_cases FROM disease_outbreaks GROUP BY disease_id;

SELECT disease_id, AVG(deaths) AS avg_deaths FROM disease_outbreaks GROUP BY disease_id HAVING AVG(deaths) > 20;

SELECT outbreak_id, end_date - start_date AS duration FROM disease_outbreaks;

SELECT disease_id, SUM(cases_reported) AS total_cases FROM disease_outbreaks GROUP BY disease_id;

SELECT country_id, SUM(deaths) AS total_deaths FROM disease_outbreaks GROUP BY country_id;

SELECT * FROM disease_outbreaks WHERE start_date >= '2025-05-01';

SELECT disease_id, recovery_rate FROM disease_outbreaks ORDER BY recovery_rate DESC;

SELECT outbreak_id, disease_id FROM disease_outbreaks WHERE deaths > 25;

SELECT outbreak_id, response_measures FROM disease_outbreaks WHERE response_measures LIKE '%Mask%';

SELECT country_id, COUNT(*) AS outbreak_count FROM disease_outbreaks GROUP BY country_id;

SELECT disease_id, AVG(cases_reported) AS avg_cases FROM disease_outbreaks GROUP BY disease_id;

SELECT outbreak_id, disease_id, recovery_rate FROM disease_outbreaks WHERE recovery_rate = (SELECT MAX(recovery_rate) FROM disease_outbreaks);

SELECT outbreak_id, start_date, end_date FROM disease_outbreaks WHERE end_date <= '2025-08-31';


#====================================================================================================================================
-- 18. Medical_Supplies
#queries:
SELECT * FROM medical_supplies;

SELECT supply_name, quantity, unit_price FROM medical_supplies WHERE category = 'PPE';

SELECT supplier_id, SUM(quantity) AS total_quantity FROM medical_supplies GROUP BY supplier_id;

UPDATE medical_supplies SET quantity = quantity - 100 WHERE supply_name = 'Surgical Masks';

DELETE FROM medical_supplies WHERE expiry_date < '2026-01-01';

ALTER TABLE medical_supplies ADD COLUMN batch_no VARCHAR(50);

SELECT category, AVG(unit_price) AS avg_price FROM medical_supplies GROUP BY category;

SELECT MAX(unit_price) AS max_price FROM medical_supplies;

SELECT category, SUM(quantity) AS total_quantity FROM medical_supplies GROUP BY category HAVING SUM(quantity) > 500;

SELECT supply_name, expiry_date - manufacture_date AS shelf_life FROM medical_supplies;

SELECT supply_name, supplier_id FROM medical_supplies WHERE quantity < 500;

SELECT supply_name, unit_price FROM medical_supplies ORDER BY unit_price DESC;

SELECT supply_name, quantity FROM medical_supplies WHERE category = 'Equipment';

SELECT supplier_id, COUNT(*) AS supply_count FROM medical_supplies GROUP BY supplier_id;

SELECT supply_name FROM medical_supplies WHERE supply_name LIKE 'S%';

SELECT category, MAX(unit_price) AS max_price_per_category FROM medical_supplies GROUP BY category;

SELECT supply_name, quantity FROM medical_supplies WHERE quantity BETWEEN 100 AND 1000;

SELECT category, SUM(quantity * unit_price) AS total_value FROM medical_supplies GROUP BY category;

SELECT supply_name, manufacture_date, expiry_date FROM medical_supplies WHERE expiry_date > '2027-01-01';

SELECT supply_name, notes FROM medical_supplies WHERE notes LIKE '%hospital%';

#==========================================================================================================================
-- 19. Suppliers
#queries:
SELECT * FROM suppliers;

SELECT supplier_name, contact_name, phone FROM suppliers WHERE country_id = 1;

SELECT country_id, COUNT(*) AS supplier_count FROM suppliers GROUP BY country_id;

UPDATE suppliers SET city = 'New Delhi' WHERE supplier_name = 'GlobalMed';

DELETE FROM suppliers WHERE city = 'Rio';

ALTER TABLE suppliers ADD COLUMN website VARCHAR(100);

SELECT state, COUNT(*) AS state_count FROM suppliers GROUP BY state;

SELECT MAX(supplier_id) AS latest_supplier FROM suppliers;

SELECT city, COUNT(*) AS city_count FROM suppliers GROUP BY city HAVING COUNT(*) > 1;

SELECT supplier_name, email FROM suppliers WHERE email LIKE '%.com';

SELECT supplier_name, country_id FROM suppliers ORDER BY supplier_name;

SELECT supplier_name, city FROM suppliers WHERE city LIKE 'N%';

SELECT country_id, SUM(supplier_id) AS total_suppliers FROM suppliers GROUP BY country_id;

SELECT contact_name, COUNT(*) AS contact_count FROM suppliers GROUP BY contact_name;

SELECT supplier_name FROM suppliers WHERE address LIKE '%Health%';

SELECT state, MAX(supplier_id) AS max_supplier_id FROM suppliers GROUP BY state;

SELECT supplier_name, email FROM suppliers WHERE email LIKE '%@medisupply.com';

SELECT city, COUNT(*) AS suppliers_in_city FROM suppliers GROUP BY city;

SELECT supplier_name, phone FROM suppliers WHERE phone LIKE '+91%';

SELECT supplier_name, address FROM suppliers ORDER BY supplier_name;

#==================================================================================================================================
-- 20. Training_Programs
#queries:
SELECT * FROM training_programs;

SELECT training_name, participants FROM training_programs WHERE budget > 6000;

SELECT country_id, AVG(participants) AS avg_participants FROM training_programs GROUP BY country_id;

UPDATE training_programs SET outcome = 'Extended' WHERE training_name = 'Maternal Care';

DELETE FROM training_programs WHERE participants < 20;

ALTER TABLE training_programs ADD COLUMN sponsor VARCHAR(100);

SELECT topic, COUNT(*) AS topic_count FROM training_programs GROUP BY topic;

SELECT MAX(budget) AS max_budget FROM training_programs;

SELECT topic, AVG(budget) AS avg_budget FROM training_programs GROUP BY topic HAVING AVG(budget) > 6000;

SELECT training_name, end_date - start_date AS duration FROM training_programs;

SELECT training_name, participants FROM training_programs WHERE participants >= 40;

SELECT training_name, outcome FROM training_programs WHERE outcome = 'Completed';

SELECT instructor, COUNT(*) AS instructor_count FROM training_programs GROUP BY instructor;

SELECT country_id, SUM(participants) AS total_participants FROM training_programs GROUP BY country_id;

SELECT training_name FROM training_programs WHERE training_name LIKE '%Health%';

SELECT topic, MAX(budget) AS max_topic_budget FROM training_programs GROUP BY topic;

SELECT training_name, budget FROM training_programs ORDER BY budget DESC;

SELECT participants, AVG(budget) AS avg_budget_per_participant FROM training_programs GROUP BY participants;

SELECT training_name, start_date FROM training_programs WHERE start_date BETWEEN '2025-01-01' AND '2025-06-30';

SELECT training_name, instructor, country_id FROM training_programs WHERE outcome = 'Successful';

#================================================================================================================================
-- 21. Participants
#queries:
SELECT * FROM participants;
SELECT name, age, role FROM participants WHERE role='Doctor';
SELECT training_id, COUNT(*) AS total_participants FROM participants GROUP BY training_id;
UPDATE participants SET remarks='Excellent' WHERE participant_id=5;
DELETE FROM participants WHERE role='Technician';
ALTER TABLE participants ADD COLUMN attendance VARCHAR(20);
SELECT gender, COUNT(*) AS gender_count FROM participants GROUP BY gender;
SELECT MAX(age) AS oldest_participant FROM participants;
SELECT role, AVG(age) AS avg_age FROM participants GROUP BY role HAVING AVG(age) > 30;
SELECT name, email FROM participants WHERE email LIKE '%example.com';
SELECT CONCAT(name, ' participates in training ', training_id) AS participant_info FROM participants;
SELECT SUBSTRING(name, 1, 3) AS short_name FROM participants;
SELECT training_id, MIN(age) AS youngest FROM participants GROUP BY training_id;
SELECT name, age FROM participants WHERE age < (SELECT AVG(age) FROM participants);
SELECT name, country_id FROM participants ORDER BY name;
SELECT name, role, CASE WHEN age > 35 THEN 'Senior' ELSE 'Junior' END AS experience_level FROM participants;
SELECT COUNT(DISTINCT country_id) AS total_countries FROM participants;
SELECT name, attendance FROM participants WHERE attendance IS NOT NULL;
SELECT name, training_id FROM participants p1 JOIN participants p2 ON p1.training_id=p2.training_id AND p1.participant_id<>p2.participant_id;
SELECT gender, AVG(age) AS avg_age_by_gender FROM participants GROUP BY gender;



#================================================================================================================================
-- 22. Emergency_Responses
#queries:
SELECT * FROM emergency_responses;
SELECT disaster_type, affected_population FROM emergency_responses WHERE relief_funds > 3000000;
SELECT country_id, SUM(relief_funds) AS total_funds FROM emergency_responses GROUP BY country_id;
UPDATE emergency_responses SET outcome='Ongoing Support' WHERE response_id=9;
DELETE FROM emergency_responses WHERE affected_population < 10000;
ALTER TABLE emergency_responses ADD COLUMN priority_level VARCHAR(20);
SELECT disaster_type, COUNT(*) AS disaster_count FROM emergency_responses GROUP BY disaster_type;
SELECT MAX(affected_population) AS max_affected FROM emergency_responses;
SELECT disaster_type, AVG(relief_funds) AS avg_funds FROM emergency_responses GROUP BY disaster_type HAVING AVG(relief_funds) > 2000000;
SELECT response_id, DATEDIFF(end_date, start_date) AS duration FROM emergency_responses;
SELECT disaster_type, country_id FROM emergency_responses WHERE affected_population > 50000;
SELECT coordinator, COUNT(*) AS responses_handled FROM emergency_responses GROUP BY coordinator;
SELECT disaster_type, MIN(relief_funds) AS min_funds FROM emergency_responses GROUP BY disaster_type;
SELECT disaster_type, CONCAT('Response by ', coordinator) AS response_summary FROM emergency_responses;
SELECT disaster_type, CASE WHEN affected_population > 100000 THEN 'High Impact' ELSE 'Low Impact' END AS impact_level FROM emergency_responses;
SELECT SUM(affected_population) AS total_affected FROM emergency_responses;
SELECT country_id, MAX(relief_funds) AS max_funds_by_country FROM emergency_responses GROUP BY country_id;
SELECT disaster_type, ROUND(AVG(relief_funds), 2) AS avg_funds_rounded FROM emergency_responses GROUP BY disaster_type;
SELECT start_date, end_date FROM emergency_responses ORDER BY start_date;
SELECT disaster_type, priority_level FROM emergency_responses WHERE priority_level IS NOT NULL;

#=====================================================================================================================================

-- 23. WHO_Staff
SELECT * FROM who_staff;
SELECT first_name, last_name, job_title FROM who_staff WHERE gender='F';
SELECT department, AVG(salary) AS avg_salary FROM who_staff GROUP BY department;
SELECT country_id, COUNT(staff_id) AS total_staff FROM who_staff GROUP BY country_id;
SELECT * FROM who_staff ORDER BY salary DESC LIMIT 3;
UPDATE who_staff SET salary = salary + 5000 WHERE job_title='Analyst';
DELETE FROM who_staff WHERE last_name='Howard';
ALTER TABLE who_staff ADD COLUMN hire_date DATE DEFAULT '2020-01-01';
SELECT job_title, MAX(salary) AS max_salary FROM who_staff GROUP BY job_title;
SELECT department, COUNT(staff_id) FROM who_staff GROUP BY department HAVING COUNT(staff_id) > 1;
SELECT CONCAT(first_name, ' ', last_name) AS full_name FROM who_staff;
SELECT salary, ROUND(salary/12, 2) AS monthly_salary FROM who_staff;
SELECT * FROM who_staff WHERE salary > (SELECT AVG(salary) FROM who_staff);
SELECT first_name, last_name, department FROM who_staff ORDER BY department;
SELECT gender, AVG(salary) AS avg_salary_by_gender FROM who_staff GROUP BY gender;
SELECT job_title, COUNT(*) AS job_count FROM who_staff GROUP BY job_title;
SELECT first_name, last_name FROM who_staff WHERE email LIKE '%who.int';
SELECT staff_id, country_id FROM who_staff WHERE department='Technology';
SELECT job_title, CASE WHEN salary>70000 THEN 'High Pay' ELSE 'Moderate Pay' END AS pay_level FROM who_staff;

#=======================================================================================================================================
-- 24. Reports
SELECT * FROM reports;
SELECT title, author, publish_date FROM reports WHERE category='Vaccination';
SELECT category, COUNT(report_id) AS total_reports FROM reports GROUP BY category;
SELECT country_id, AVG(pages) AS avg_pages FROM reports GROUP BY country_id;
SELECT * FROM reports ORDER BY publish_date DESC LIMIT 5;
UPDATE reports SET language='French' WHERE report_id=5;
DELETE FROM reports WHERE category='Nutrition';
ALTER TABLE reports ADD COLUMN reviewed_by VARCHAR(100);
SELECT language, COUNT(report_id) AS total_reports_by_language FROM reports GROUP BY language;
SELECT category, MAX(pages) AS max_pages FROM reports GROUP BY category HAVING MAX(pages)>100;
SELECT CONCAT(title, ' by ', author) AS report_summary FROM reports;
SELECT SUBSTRING(title,1,10) AS short_title FROM reports;
SELECT * FROM reports WHERE pages < (SELECT AVG(pages) FROM reports);
SELECT publish_date, title FROM reports ORDER BY publish_date;
SELECT title, CASE WHEN pages > 100 THEN 'Long Report' ELSE 'Short Report' END AS report_type FROM reports;
SELECT COUNT(DISTINCT category) AS category_count FROM reports;
SELECT title, language FROM reports WHERE language='English';
SELECT author, COUNT(*) AS authored_reports FROM reports GROUP BY author;
SELECT title, country_id FROM reports WHERE country_id IN (SELECT country_id FROM countries WHERE continent='Asia');
SELECT report_id, publish_date FROM reports ORDER BY publish_date ASC;

#================================================================================================================================
-- 25. Global_Statistics
#queries:
SELECT * FROM global_statistics;
SELECT year, global_population, global_life_expectancy FROM global_statistics WHERE year >= 2020;
SELECT AVG(global_life_expectancy) AS avg_life_expectancy FROM global_statistics;
SELECT year, total_vaccinations, total_disease_cases FROM global_statistics ORDER BY year;
SELECT top_disease, COUNT(stat_id) AS disease_count FROM global_statistics GROUP BY top_disease;
UPDATE global_statistics SET remarks='Updated Data' WHERE year=2019;
DELETE FROM global_statistics WHERE year=2015;
ALTER TABLE global_statistics ADD COLUMN data_verified BOOLEAN DEFAULT TRUE;
SELECT year, global_death_rate FROM global_statistics WHERE global_death_rate > 7.5;
SELECT * FROM global_statistics ORDER BY global_life_expectancy DESC LIMIT 1;
SELECT year, global_population, global_life_expectancy FROM global_statistics WHERE global_death_rate > 7;
SELECT top_disease, COUNT(stat_id) AS occurrences FROM global_statistics GROUP BY top_disease;
SELECT year, MAX(global_health_budget) AS max_budget FROM global_statistics GROUP BY year;
SELECT year, total_vaccinations FROM global_statistics ORDER BY total_vaccinations DESC LIMIT 3;
UPDATE global_statistics SET global_death_rate=6.5 WHERE year=2024;
ALTER TABLE global_statistics ADD COLUMN data_source VARCHAR(100) DEFAULT 'WHO';
SELECT year, AVG(global_life_expectancy) AS avg_life_per_year FROM global_statistics GROUP BY year;
SELECT top_disease, MAX(total_disease_cases) AS max_cases FROM global_statistics GROUP BY top_disease;
SELECT year, global_health_budget, global_population FROM global_statistics ORDER BY global_health_budget DESC;
SELECT remarks, year FROM global_statistics WHERE total_vaccinations > 3500000000;
