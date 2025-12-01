-- Query 1: Calculates all hours for each course instance
SELECT
    ci.course_code,
    ci.instance_id AS course_instance_id,
    cl.hp,
    ci.study_period,
    ci.num_students,

    -- Sum hours for each activity type
    SUM(CASE WHEN ta.activity_name = 'Lecture'
        THEN pa.planned_hours * ta.factor ELSE 0 END) AS lecture_hours,

    SUM(CASE WHEN ta.activity_name = 'Tutorial'
        THEN pa.planned_hours * ta.factor ELSE 0 END) AS tutorial_hours,

    SUM(CASE WHEN ta.activity_name = 'Lab'
        THEN pa.planned_hours * ta.factor ELSE 0 END) AS lab_hours,

    SUM(CASE WHEN ta.activity_name = 'Seminar'
        THEN pa.planned_hours * ta.factor ELSE 0 END) AS seminar_hours,

    SUM(CASE WHEN ta.activity_name = 'Other Overhead'
        THEN pa.planned_hours * ta.factor ELSE 0 END) AS other_overhead_hours,

    -- Admin and exam hours based on the formula
    (2 * cl.hp + 28 + 0.2 * ci.num_students) AS admin_hours,
    (32 * 0.725 + 0.725 * ci.num_students)   AS exam_hours,

    -- Total hours for the course instance
    SUM(pa.planned_hours * ta.factor)
        + (2 * cl.hp + 28 + 0.2 * ci.num_students)
        + (32 * 0.725 + 0.725 * ci.num_students) AS total_hours

FROM course_instance ci
JOIN course_layout cl ON cl.course_code = ci.course_code
LEFT JOIN planned_activity pa ON pa.course_code = ci.course_code
LEFT JOIN teaching_activity ta ON ta.activity_id = pa.activity_id

GROUP BY
    ci.course_code, ci.instance_id, cl.hp, ci.study_period, ci.num_students
ORDER BY
    ci.study_period, ci.course_code;



-- Query 2: Shows all teachers who work on one specific course instance
SELECT
    ci.course_code,
    ci.instance_id AS course_instance_id,
    cl.hp,
    CONCAT(p.first_name, ' ', p.last_name) AS teacher_name,
    jt.job_title_name AS designation,

    -- Activity hours per teacher
    SUM(CASE WHEN ta.activity_name = 'Lecture'
        THEN pa.planned_hours * ta.factor ELSE 0 END) AS lecture_hours,

    SUM(CASE WHEN ta.activity_name = 'Tutorial'
        THEN pa.planned_hours * ta.factor ELSE 0 END) AS tutorial_hours,

    SUM(CASE WHEN ta.activity_name = 'Lab'
        THEN pa.planned_hours * ta.factor ELSE 0 END) AS lab_hours,

    SUM(CASE WHEN ta.activity_name = 'Seminar'
        THEN pa.planned_hours * ta.factor ELSE 0 END) AS seminar_hours,

    -- Admin and exam hours for each teacher on this instance
    (2 * cl.hp + 28 + 0.2 * ci.num_students) AS admin_hours,
    (32 + 0.725 * ci.num_students) AS exam_hours,

    -- Total hours per teacher
    SUM(pa.planned_hours * ta.factor)
        + (2 * cl.hp + 28 + 0.2 * ci.num_students)
        + (32 + 0.725 * ci.num_students) AS total_hours

FROM activity_allocation aa
JOIN planned_activity pa ON pa.planned_activity_id = aa.planned_activity_id
JOIN teaching_activity ta ON ta.activity_id = pa.activity_id
JOIN course_instance ci ON ci.course_code = pa.course_code
JOIN course_layout cl ON cl.course_code = pa.course_code
JOIN employee e ON e.employment_id = aa.employment_id
JOIN person p ON p.personal_number = e.personal_number
JOIN job_title jt ON jt.job_title_id = e.job_title_id

WHERE ci.instance_id = '2025-50273'   -- the course instance we want to inspect
GROUP BY
    ci.course_code, ci.instance_id, cl.hp, ci.num_students,
    CONCAT(p.first_name, ' ', p.last_name), jt.job_title_name
ORDER BY
    teacher_name;



-- Query 3: Shows all course instances a teacher works in during the year
SELECT
    ci.course_code,
    ci.instance_id AS course_instance_id,
    cl.hp,
    ci.study_period AS period,
    CONCAT(p.first_name, ' ', p.last_name) AS teacher_name,

    -- Activity hours for this teacher
    SUM(CASE WHEN ta.activity_name = 'Lecture'
        THEN pa.planned_hours * ta.factor ELSE 0 END) AS lecture_hours,

    SUM(CASE WHEN ta.activity_name = 'Tutorial'
        THEN pa.planned_hours * ta.factor ELSE 0 END) AS tutorial_hours,

    SUM(CASE WHEN ta.activity_name = 'Lab'
        THEN pa.planned_hours * ta.factor ELSE 0 END) AS lab_hours,

    SUM(CASE WHEN ta.activity_name = 'Seminar'
        THEN pa.planned_hours * ta.factor ELSE 0 END) AS seminar_hours,

    -- Admin and exam hours
    (2 * cl.hp + 28 + 0.2 * ci.num_students) AS admin_hours,
    (32 + 0.725 * ci.num_students) AS exam_hours,

    -- Total hours that the teacher spends on the course
    SUM(pa.planned_hours * ta.factor)
        + (2 * cl.hp + 28 + 0.2 * ci.num_students)
        + (32 + 0.725 * ci.num_students) AS total_hours

FROM activity_allocation aa
JOIN planned_activity pa ON pa.planned_activity_id = aa.planned_activity_id
JOIN teaching_activity ta ON ta.activity_id = pa.activity_id
JOIN course_instance ci ON ci.course_code = pa.course_code
JOIN course_layout cl ON cl.course_code = pa.course_code
JOIN employee e ON e.employment_id = aa.employment_id
JOIN person p ON p.personal_number = e.personal_number

WHERE aa.employment_id = 'E01'   -- choose which teacher to check
  AND LEFT(ci.instance_id, 4) = '2025'   -- limit to one year
GROUP BY
    ci.course_code, ci.instance_id, cl.hp,
    ci.study_period, ci.num_students,
    CONCAT(p.first_name, ' ', p.last_name)
ORDER BY
    ci.study_period, ci.course_code;



-- Query 4: Counts how many courses each teacher has in a specific study period
SELECT
    e.employment_id,
    CONCAT(p.first_name, ' ', p.last_name) AS teacher_name,
    ci.study_period AS period,
    COUNT(DISTINCT ci.instance_id) AS no_of_courses
FROM activity_allocation aa
JOIN planned_activity pa
    ON pa.planned_activity_id = aa.planned_activity_id
JOIN course_instance ci
    ON ci.course_code = pa.course_code
JOIN employee e
    ON e.employment_id = aa.employment_id
JOIN person p
    ON p.personal_number = e.personal_number
WHERE ci.study_period = 'P1'    -- choose the study period to check
GROUP BY
    e.employment_id, teacher_name, ci.study_period
ORDER BY
    e.employment_id, ci.study_period;
