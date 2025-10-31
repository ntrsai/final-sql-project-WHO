use zoom;
-- 

-- =========================
-- DDL (data defining language):
-- =========================

-- create an index to speed doctor lookups by specialization
CREATE INDEX idx_doctor_specialization ON Doctors(specialization);

-- add a column to Patients for blood group
ALTER TABLE Patients ADD COLUMN blood_group VARCHAR(5);

-- change Medications.unit_price to allow more precision
ALTER TABLE Medications MODIFY unit_price DECIMAL(12,2);

-- create a junction table for prescriptions (patient uses medication)
CREATE TABLE Prescriptions (
    prescription_id INT PRIMARY KEY,
    patient_id INT,
    med_id INT,
    prescribed_by INT,
    dose VARCHAR(50),
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (med_id) REFERENCES Medications(med_id) ON DELETE RESTRICT,
    FOREIGN KEY (prescribed_by) REFERENCES Doctors(doctor_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- rename Wards column ward_name to ward_label
ALTER TABLE Wards CHANGE ward_name ward_label VARCHAR(80);

-- create table for inventory of medications
CREATE TABLE MedInventory (
    inventory_id INT PRIMARY KEY,
    med_id INT,
    quantity INT,
    last_restock DATE,
    FOREIGN KEY (med_id) REFERENCES Medications(med_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- drop a temp table if exists (cleanup demonstration)
DROP TABLE IF EXISTS TempBackup;

-- add a unique constraint for appointment per patient per datetime
ALTER TABLE Appointments ADD CONSTRAINT uq_patient_appt UNIQUE (patient_id, appt_date);

-- =========================
-- DML (data manipulating language)
-- =========================

-- insert new patient
INSERT INTO Patients VALUES (206, 'Sahil', 'Roy', 'M', '1992-10-10', 'New Street, Pune', '9123456785', 'Pune', '2025-06-01');

-- bulk insert two medications
INSERT INTO Medications VALUES (606,'Vitamin C','NutriLabs','Tablet',0.30),(607,'Cetirizine','AllerSafe','Tablet',0.20);

-- update a patient's phone
UPDATE Patients SET phone='9199999999' WHERE patient_id=201;

-- mark an appointment as completed
UPDATE Appointments SET status='Completed' WHERE appt_id=401;

-- insert a prescription
INSERT INTO Prescriptions VALUES (1001, 201, 601, 101, '500mg twice daily', '2025-06-01', '2025-06-07');

-- delete a test patient (example)
DELETE FROM Patients WHERE patient_id=206;

-- increase salary of doctors in Surgery by 10%
UPDATE Doctors SET salary = salary * 1.10 WHERE dept_id = 3;

-- restock medication inventory
INSERT INTO MedInventory VALUES (4001, 601, 1000, '2025-06-01');

-- =========================
-- DQL - Basic SELECTs (12)
-- =========================

-- list all doctors with department names
SELECT d.doctor_id, d.first_name, d.last_name, dep.dept_name
FROM Doctors d JOIN Departments dep ON d.dept_id = dep.dept_id;

-- show all patients registered after 2025-02-01
SELECT * FROM Patients WHERE registered_date > '2025-02-01';

-- list upcoming appointments (future)
SELECT * FROM Appointments WHERE appt_date >= NOW() ORDER BY appt_date;

-- show unpaid bills
SELECT * FROM Bills WHERE status <> 'Paid';

-- show medical records for a patient
SELECT * FROM MedicalRecords WHERE patient_id = 201 ORDER BY visit_date DESC;

-- show medications ordered by price descending
SELECT med_name, unit_price FROM Medications ORDER BY unit_price DESC;

-- show ward capacities
SELECT ward_label, capacity FROM Wards;

-- count patients per city
SELECT city, COUNT(*) AS patient_count FROM Patients GROUP BY city;

-- list payments made by mode
SELECT mode, SUM(amount_paid) AS total_paid FROM Payments GROUP BY mode;

-- show prescriptions for a patient
SELECT p.prescription_id, m.med_name, p.dose, p.start_date, p.end_date
FROM Prescriptions p JOIN Medications m ON p.med_id = m.med_id
WHERE p.patient_id = 201;

-- show doctors with salary > 95k
SELECT first_name, last_name, salary FROM Doctors WHERE salary > 95000 ORDER BY salary DESC;

-- show bills and patient names
SELECT b.bill_id, CONCAT(pt.first_name,' ',pt.last_name) AS patient_name, b.total_amount, b.status
FROM Bills b JOIN Patients pt ON b.patient_id = pt.patient_id;

-- =========================
-- Clauses & Operators (10)
-- =========================

-- patients with names like 'A%'
SELECT patient_id, first_name, last_name FROM Patients WHERE first_name LIKE 'A%';

-- bills between two dates
SELECT * FROM Bills WHERE bill_date BETWEEN '2025-03-01' AND '2025-06-30';

-- patients in a list of cities
SELECT patient_id, city FROM Patients WHERE city IN ('Mumbai','Pune');

-- doctors not in Surgery
SELECT * FROM Doctors WHERE dept_id <> 3;

-- payments greater than average payment (using scalar subquery)
SELECT * FROM Payments WHERE amount_paid > (SELECT AVG(amount_paid) FROM Payments);

-- appointments with multiple conditions
SELECT * FROM Appointments WHERE status = 'Scheduled' AND appt_date > NOW();

-- use IS NULL to find records without discharge (example)
SELECT * FROM MedicalRecords WHERE notes IS NULL;

-- find bills where total_amount > paid_amount (due)
SELECT * FROM Bills WHERE total_amount > paid_amount;

-- find payments not equal to zero
SELECT * FROM Payments WHERE amount_paid != 0;

-- count appointments per status using CASE
SELECT status, COUNT(*) AS cnt FROM Appointments GROUP BY status;

-- =========================
-- Constraints & Cascades (8)
-- =========================

-- add ON DELETE CASCADE for prescriptions if patient deleted
ALTER TABLE Prescriptions DROP FOREIGN KEY Prescriptions_ibfk_1;
ALTER TABLE Prescriptions ADD CONSTRAINT fk_presc_patient FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE CASCADE;

-- add ON DELETE RESTRICT on MedInventory.med_id
ALTER TABLE MedInventory DROP FOREIGN KEY MedInventory_ibfk_1;
ALTER TABLE MedInventory ADD CONSTRAINT fk_inv_med FOREIGN KEY (med_id) REFERENCES Medications(med_id) ON DELETE RESTRICT;

-- add a check (MySQL 8+) on Bills total >= 0
ALTER TABLE Bills ADD CONSTRAINT chk_bill_total CHECK (total_amount >= 0);

-- add unique constraint on Medications.med_name to avoid duplicates
ALTER TABLE Medications ADD CONSTRAINT uq_med_name UNIQUE (med_name);

-- create composite primary key example table (room assignment)
CREATE TABLE WardAssignments (
    ward_id INT,
    patient_id INT,
    assigned_on DATE,
    PRIMARY KEY (ward_id, patient_id),
    FOREIGN KEY (ward_id) REFERENCES Wards(ward_id),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
) ENGINE=InnoDB;

-- show cascade delete effect: delete a patient will remove their bills (demonstrate)
DELETE FROM Patients WHERE patient_id = 205;

-- revert deletion for continuity (re-insert sample)
INSERT INTO Patients VALUES (205, 'Lina', 'D’souza', 'F', '1998-09-09', 'Street 5, Chennai', '9123456784', 'Chennai', '2025-05-14');

-- add foreign key constraint with ON UPDATE CASCADE (example)
ALTER TABLE Doctors DROP FOREIGN KEY Doctors_ibfk_1;
ALTER TABLE Doctors ADD CONSTRAINT fk_doctor_dept FOREIGN KEY (dept_id) REFERENCES Departments(dept_id) ON UPDATE CASCADE ON DELETE SET NULL;

-- =========================
-- Joins (10)
-- =========================

-- inner join patients with latest medical record (simple join)
SELECT p.patient_id, p.first_name, mr.diagnosis, mr.visit_date
FROM Patients p JOIN MedicalRecords mr ON p.patient_id = mr.patient_id;

-- left join doctors with appointments (doctors without appointments shown too)
SELECT d.doctor_id, d.first_name, a.appt_id, a.appt_date
FROM Doctors d LEFT JOIN Appointments a ON d.doctor_id = a.doctor_id;

-- right join patients with bills (shows patients with bills)
SELECT p.patient_id, p.first_name, b.bill_id, b.total_amount
FROM Patients p RIGHT JOIN Bills b ON p.patient_id = b.patient_id;

-- self join doctors to find pairs with same dept
SELECT a.doctor_id AS d1, b.doctor_id AS d2, a.dept_id
FROM Doctors a JOIN Doctors b ON a.dept_id = b.dept_id AND a.doctor_id < b.doctor_id;

-- join bills and payments to show balance
SELECT b.bill_id, b.total_amount, IFNULL(SUM(p.amount_paid),0) AS paid, b.total_amount - IFNULL(SUM(p.amount_paid),0) AS balance
FROM Bills b LEFT JOIN Payments p ON b.bill_id = p.bill_id
GROUP BY b.bill_id;

-- join prescriptions with medication details
SELECT pr.prescription_id, pr.dose, m.med_name, m.unit_price
FROM Prescriptions pr JOIN Medications m ON pr.med_id = m.med_id;

-- join appointments, patients, doctors for schedule
SELECT a.appt_id, a.appt_date, CONCAT(p.first_name,' ',p.last_name) AS patient, CONCAT(d.first_name,' ',d.last_name) AS doctor
FROM Appointments a JOIN Patients p ON a.patient_id = p.patient_id JOIN Doctors d ON a.doctor_id = d.doctor_id;

-- cross join example (days x doctors) small demonstration
SELECT d.doctor_id, d.first_name, '2025-06-10' AS sample_date FROM Doctors d CROSS JOIN (SELECT 1) tmp;

-- join inventory and medications
SELECT mi.inventory_id, m.med_name, mi.quantity FROM MedInventory mi JOIN Medications m ON mi.med_id = m.med_id;

-- multiple joins: show medical records with doctor and department
SELECT mr.record_id, CONCAT(p.first_name,' ',p.last_name) AS patient, CONCAT(d.first_name,' ',d.last_name) AS doctor, dep.dept_name
FROM MedicalRecords mr
JOIN Patients p ON mr.patient_id = p.patient_id
JOIN Doctors d ON mr.doctor_id = d.doctor_id
JOIN Departments dep ON d.dept_id = dep.dept_id;

-- =========================
-- Subqueries (10)
-- =========================

-- patients who have bills greater than average bill
SELECT patient_id FROM Bills WHERE total_amount > (SELECT AVG(total_amount) FROM Bills);

-- doctors earning more than average salary
SELECT doctor_id, first_name, salary FROM Doctors WHERE salary > (SELECT AVG(salary) FROM Doctors);

-- patients who had more than one appointment
SELECT patient_id FROM Appointments GROUP BY patient_id HAVING COUNT(*) > 1;

-- appointments where patient city is same as doctor's dept floor (demonstration of correlated subquery)
SELECT * FROM Appointments a
WHERE EXISTS (SELECT 1 FROM Patients p WHERE p.patient_id = a.patient_id AND p.city = 'Mumbai');

-- get the latest medical record per patient using subquery
SELECT * FROM MedicalRecords mr
WHERE mr.visit_date = (SELECT MAX(visit_date) FROM MedicalRecords WHERE patient_id = mr.patient_id);

-- bills where paid amount < total and due date past today (overdue)
SELECT * FROM Bills WHERE paid_amount < total_amount AND due_date < CURDATE();

-- patients who were prescribed 'Paracetamol'
SELECT DISTINCT p.patient_id, p.first_name FROM Patients p
WHERE EXISTS (SELECT 1 FROM Prescriptions pr JOIN Medications m ON pr.med_id = m.med_id WHERE pr.patient_id = p.patient_id AND m.med_name = 'Paracetamol');

-- subquery in FROM: average payment per bill
SELECT t.bill_id, t.avg_payment FROM (SELECT bill_id, AVG(amount_paid) AS avg_payment FROM Payments GROUP BY bill_id) t ORDER BY t.avg_payment DESC;

-- find top doctor by number of appointments
SELECT doctor_id FROM (SELECT doctor_id, COUNT(*) AS cnt FROM Appointments GROUP BY doctor_id) tmp ORDER BY cnt DESC LIMIT 1;


-- =========================
-- Functions & UDFs (8)
-- =========================

-- total revenue (aggregate function)
SELECT SUM(total_amount) AS total_revenue FROM Bills;

-- average medication price
SELECT ROUND(AVG(unit_price),2) AS avg_med_price FROM Medications;

-- create a simple UDF to calculate discount on bill (MySQL function)
DELIMITER $$
CREATE FUNCTION calc_discount(amount DECIMAL(12,2)) RETURNS DECIMAL(12,2) DETERMINISTIC
BEGIN
    IF amount > 10000 THEN
        RETURN amount * 0.10;
    ELSE
        RETURN 0;
    END IF;
END $$
$$
DELIMITER ;

-- use the UDF
SELECT bill_id, total_amount, calc_discount(total_amount) AS discount FROM Bills;

-- string functions example
SELECT UPPER(CONCAT(first_name,' ',last_name)) AS patient_fullname FROM Patients;

-- date function example: days since registration
SELECT patient_id, DATEDIFF(CURDATE(), registered_date) AS days_since_registration FROM Patients;

-- numeric function: ceiling medication price
SELECT med_name, CEIL(unit_price) AS price_ceiled FROM Medications;

-- use IFNULL and COALESCE
SELECT b.bill_id, COALESCE(b.paid_amount,0) AS paid, (b.total_amount - COALESCE(b.paid_amount,0)) AS balance FROM Bills b;

-- =========================
-- Views & CTEs (8)
-- =========================

-- create a view for patient summary
CREATE VIEW PatientSummary AS
SELECT p.patient_id, CONCAT(p.first_name,' ',p.last_name) AS name, p.city, COUNT(mr.record_id) AS visits
FROM Patients p LEFT JOIN MedicalRecords mr ON p.patient_id = mr.patient_id
GROUP BY p.patient_id;

-- select from view
SELECT * FROM PatientSummary;

-- view for outstanding bills
CREATE VIEW OutstandingBills AS
SELECT b.bill_id, CONCAT(p.first_name,' ',p.last_name) AS patient_name, b.total_amount - b.paid_amount AS due
FROM Bills b JOIN Patients p ON b.patient_id = p.patient_id WHERE b.total_amount > b.paid_amount;

-- select from outstanding view
SELECT * FROM OutstandingBills ORDER BY due DESC;

-- CTE to compute appointments per doctor
WITH ApptCounts AS (
    SELECT doctor_id, COUNT(*) AS total_appts FROM Appointments GROUP BY doctor_id
)
SELECT a.doctor_id, d.first_name, a.total_appts FROM ApptCounts a JOIN Doctors d ON a.doctor_id = d.doctor_id;

-- recursive CTE to list next 5 days (example)
WITH RECURSIVE days AS (
    SELECT CURDATE() AS dt
    UNION ALL
    SELECT DATE_ADD(dt, INTERVAL 1 DAY) FROM days WHERE dt < DATE_ADD(CURDATE(), INTERVAL 4 DAY)
)
SELECT * FROM days;

-- CTE to find doctors with no appointments (anti-join)
WITH DocAppts AS (SELECT DISTINCT doctor_id FROM Appointments)
SELECT doctor_id, first_name FROM Doctors WHERE doctor_id NOT IN (SELECT doctor_id FROM DocAppts);

-- create a view joining medical records with doctors
CREATE VIEW RecordDoctorView AS
SELECT mr.record_id, CONCAT(p.first_name,' ',p.last_name) AS patient, CONCAT(d.first_name,' ',d.last_name) AS doctor, mr.diagnosis
FROM MedicalRecords mr JOIN Patients p ON mr.patient_id = p.patient_id JOIN Doctors d ON mr.doctor_id = d.doctor_id;

-- =========================
-- Stored Procedures (5)
-- =========================

DELIMITER $$
CREATE PROCEDURE AddPatient(
    IN fname VARCHAR(50), IN lname VARCHAR(50), IN g CHAR(1), IN birth DATE, IN addr VARCHAR(200), IN ph VARCHAR(20), IN cty VARCHAR(50)
)
BEGIN
    DECLARE new_id INT;
    SET new_id = (SELECT IFNULL(MAX(patient_id),200) + 1 FROM Patients);
    INSERT INTO Patients(patient_id, first_name, last_name, gender, dob, address, phone, city, registered_date)
    VALUES (new_id, fname, lname, g, birth, addr, ph, cty, CURDATE());
END $$
$$
DELIMITER ;

-- call example (commented out)
-- CALL AddPatient('Test','User','M','1995-01-01','Somewhere','9191919191','TestCity');

DELIMITER $$
CREATE PROCEDURE PayBill(IN p_bill_id INT, IN amount DECIMAL(12,2), IN pay_mode VARCHAR(30))
BEGIN
    INSERT INTO Payments(payment_id, bill_id, payment_date, amount_paid, mode, reference)
    VALUES ((SELECT IFNULL(MAX(payment_id),800) + 1 FROM Payments), p_bill_id, CURDATE(), amount, pay_mode, CONCAT('REF',p_bill_id));
    UPDATE Bills SET paid_amount = paid_amount + amount, status = IF(paid_amount + amount >= total_amount, 'Paid', 'Partial') WHERE bill_id = p_bill_id;
END $$
$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetPatientRecords(IN pid INT)
BEGIN
    SELECT * FROM MedicalRecords WHERE patient_id = pid;
END $$
$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GetDoctorSchedule(IN did INT)
BEGIN
    SELECT * FROM Appointments WHERE doctor_id = did ORDER BY appt_date;
END $$
$$
DELIMITER ;

-- =========================
-- Window Functions (5)
-- =========================

-- row_number over patients by registration date
SELECT patient_id, first_name, registered_date, ROW_NUMBER() OVER (ORDER BY registered_date DESC) AS rn FROM Patients;

-- rank doctors by salary within their department
SELECT doctor_id, first_name, dept_id, RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS dept_rank FROM Doctors;

-- lead example: show next appointment time per doctor
SELECT appt_id, doctor_id, appt_date, LEAD(appt_date) OVER (PARTITION BY doctor_id ORDER BY appt_date) AS next_appt FROM Appointments;

-- lag example: previous payment per bill (by payment date)
SELECT payment_id, bill_id, payment_date, amount_paid, LAG(amount_paid) OVER (PARTITION BY bill_id ORDER BY payment_date) AS prev_payment FROM Payments;

-- running total of payments per bill
SELECT bill_id, payment_date, amount_paid, SUM(amount_paid) OVER (PARTITION BY bill_id ORDER BY payment_date) AS running_total FROM Payments;

-- =========================
-- Transactions (5)
-- =========================

-- transaction example: create payment and update bill atomically
START TRANSACTION;
CALL PayBill(701, 1500.00, 'Card');
COMMIT;

-- transaction with rollback example (attempt invalid update then rollback)
START TRANSACTION;
UPDATE Bills SET total_amount = total_amount + 100 WHERE bill_id = 702;
ROLLBACK;

-- transaction with savepoint
START TRANSACTION;
UPDATE Doctors SET salary = salary + 500 WHERE doctor_id = 101;
SAVEPOINT sp1;
UPDATE Doctors SET salary = salary + 1000 WHERE doctor_id = 102;
ROLLBACK TO sp1;
COMMIT;

-- transfer inventory example: reduce quantity then log (simulate)
START TRANSACTION;
UPDATE MedInventory SET quantity = quantity - 100 WHERE med_id = 601;
INSERT INTO MedInventory VALUES (4002, 601, 100, CURDATE());
COMMIT;

-- transaction to insert appointment + medical record atomically
START TRANSACTION;
INSERT INTO Appointments(appt_id, patient_id, doctor_id, appt_date, reason, status) VALUES (410, 201, 101, '2025-06-20 10:00:00', 'Follow-up', 'Scheduled');
INSERT INTO MedicalRecords(record_id, patient_id, doctor_id, visit_date, diagnosis, treatment) VALUES (506, 201, 101, '2025-06-20', 'Follow-up check', 'Continue meds');
COMMIT;

-- =========================
-- Triggers (3)
-- =========================

-- after payment insert: update bill status automatically if paid fully
DELIMITER $$
CREATE TRIGGER after_payment_insert
AFTER INSERT ON Payments
FOR EACH ROW
BEGIN
    UPDATE Bills SET paid_amount = paid_amount + NEW.amount_paid, status = IF(paid_amount + NEW.amount_paid >= total_amount, 'Paid', 'Partial') WHERE bill_id = NEW.bill_id;
END $$
$$
DELIMITER ;

-- before insert on Bills: ensure total_amount non-negative
DELIMITER $$
CREATE TRIGGER before_bill_insert
BEFORE INSERT ON Bills
FOR EACH ROW
BEGIN
    IF NEW.total_amount < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bill total cannot be negative';
    END IF;
END $$
$$
DELIMITER ;

-- after insert on Appointments: insert a notification record in a simple log table
CREATE TABLE IF NOT EXISTS Notifications (
    note_id INT PRIMARY KEY,
    appt_id INT,
    note_text VARCHAR(200),
    note_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

DELIMITER $$
CREATE TRIGGER after_appt_insert
AFTER INSERT ON Appointments
FOR EACH ROW
BEGIN
    INSERT INTO Notifications(note_id, appt_id, note_text) VALUES ((SELECT IFNULL(MAX(note_id),9000)+1 FROM Notifications), NEW.appt_id, CONCAT('Appointment scheduled for ', NEW.appt_date));
END $$
$$
DELIMITER ;
