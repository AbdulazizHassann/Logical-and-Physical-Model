
INSERT INTO job_title (job_title_id, job_title_name) VALUES
('01', 'Ass. ProProfessor'),
('02', 'Lecturer'),
('03', 'TA'),
('04', 'PhD Student');


INSERT INTO person (personal_number, first_name, last_name) VALUES
('198904017654', 'Michael', 'Eriksson'),
('199211239876', 'Sara', 'Holm'),
('197703045432', 'Jonas', 'Berg'),
('200105189912', 'Elin', 'Strand'),
('199812309903', 'David', 'Nguyen');


INSERT INTO employee (employment_id, personal_number, job_title_id, max_courses, supervisor_id) VALUES
('E01', '198904017654', '01', 4, NULL),
('E03', '197703045432', '04', 4, NULL),
('E04', '200105189912', '03', 4, NULL),
('E02', '199211239876', '02', 4, 'E01');


INSERT INTO teaching_activity (activity_id, activity_name, factor) VALUES
('T01', 'Lecture', 3.6),
('T02', 'Lab', 2.4),
('T03', 'Tutorial', 2.4),
('T04', 'Seminar', 1.8);


INSERT INTO course_layout (course_code, course_name, min_students, max_students, hp, version) VALUES
('iv1351', 'Data Storage Parad', 50, 200, 7.5, 1),
('IX1500', 'Discrete Mathemat', 50, 210, 7.5, 1),
('IX1501', 'Statistisc Mathem', 60, 210, 7.5, 1);


INSERT INTO course_instance (instance_id, course_code, study_year, num_students, study_period) VALUES
('2025-50273', 'iv1351', 2025, 200, 'P2'),
('2025-50413', 'IX1500', 2025, 210, 'P1'),
('2025-50414', 'IX1501', 2025, 230, 'P1');


INSERT INTO planned_activity (planned_activity_id, activity_id, course_code, planned_hours) VALUES
('P01', 'T01', 'iv1351', 20),
('P02', 'T02', 'iv1351', 40),
('P03', 'T03', 'iv1351', 50),
('P04', 'T04', 'iv1351', 10),
('P05', 'T01', 'IX1500', 30),
('P06', 'T04', 'IX1500', 10);

------------------------------------------------------------
 ACTIVITY ALLOCATION (allocated_hours optional)
------------------------------------------------------------
INSERT INTO activity_allocation (employment_id, planned_activity_id, allocated_hours) VALUES
('E01', 'P01', NULL),
('E02', 'P05', NULL),
('E04', 'P02', NULL),
('E04', 'P03', NULL),
('E03', 'P06', NULL);


INSERT INTO salary (salary_id, employment_id, salary_amount, currency, valid_from, valid_to) VALUES
(1, 'E01', 38499.95, 'SEK', '2024-03-25', '2025-03-25'),
(2, 'E01', 39499.95, 'SEK', '2025-03-25', NULL);


INSERT INTO contacts (personal_number, phone_nr, email, address) VALUES
('198904017654', '0700000001', 'michael@example.com', 'ElmSt 12'),
('199211239876', '0700000002', 'sara@example.com', 'BirchAve 4'),
('197703045432', '0700000003', 'jonas@example.com', 'PineRd 7'),
('200105189912', '0700000004', 'elin@example.com', 'CedarWay 2'),
('199812309903', '0700000005', 'david@example.com', 'MapleLn 9');


INSERT INTO department (department_id, department_name, manager_employment_id) VALUES
('D01', 'CS Dept', 'E01'),
('D02', 'IT Dept', 'E04');


INSERT INTO skill (skill_id, skill_name) VALUES
('S01', 'C++'),
('S02', 'AI'),
('S03', 'Security'),
('S04', 'Databases');


INSERT INTO skill_set (skill_id, employment_id) VALUES
('S01', 'E01'),
('S02', 'E02'),
('S03', 'E03'),
('S04', 'E04');
y
