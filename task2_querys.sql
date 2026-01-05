----------------- QUERY 1 --------------------------
-- Calculate total planned workload per course instance (budget level)
-- Uses PLANNED hours, not allocated hours

SELECT 
    ci.course_code,
    ci.instance_id AS "Course Instance ID",
    cl.hp AS "HP",
    ci.study_period AS "Period",
    ci.num_students AS "# Students",
    
    -- Teaching activities: based on PLANNED_HOURS multiplied by activity factor
    ROUND(SUM(CASE WHEN ta.activity_name = 'Lecture'
        THEN pa.planned_hours * ta.factor ELSE 0 END)) AS "Lecture Hours",

    ROUND(SUM(CASE WHEN ta.activity_name = 'Tutorial'
        THEN pa.planned_hours * ta.factor ELSE 0 END)) AS "Tutorial Hours",

    ROUND(SUM(CASE WHEN ta.activity_name = 'Lab'
        THEN pa.planned_hours * ta.factor ELSE 0 END)) AS "Lab Hours",

    ROUND(SUM(CASE WHEN ta.activity_name = 'Seminar'
        THEN pa.planned_hours * ta.factor ELSE 0 END)) AS "Seminar Hours",

    -- Admin hours: full formula value (course budget, not distributed per teacher)
    ROUND(MAX(2 * cl.hp + 28 + 0.2 * ci.num_students)) AS "Admin",

    -- Exam hours: full formula value (course budget)
    ROUND(MAX(32 + 0.725 * ci.num_students)) AS "Exam",

    -- Total planned workload for the course instance
    ROUND(
        SUM(pa.planned_hours * ta.factor) +
        MAX(2 * cl.hp + 28 + 0.2 * ci.num_students) +
        MAX(32 + 0.725 * ci.num_students)
    ) AS "Total Hours"

FROM course_instance ci
JOIN course_layout cl ON ci.course_code = cl.course_code
JOIN planned_activity pa ON cl.course_code = pa.course_code
JOIN teaching_activity ta ON pa.activity_id = ta.activity_id

WHERE ci.study_year = 2025

GROUP BY 
    ci.course_code,
    ci.instance_id,
    cl.hp,
    ci.study_period,
    ci.num_students

ORDER BY 
    ci.course_code;



----------- QUERY 2 --------------------------
-- Calculate actual allocated hours per teacher for a specific course instance
-- Uses ALLOCATED hours and distributes Admin and Exam hours among teachers

WITH AllocationDetails AS (
    SELECT 
        ci.course_code,
        ci.instance_id,
        ci.study_period,
        cl.hp,
        ci.num_students,
        p.first_name,
        p.last_name,
        jt.job_title_name,
        ta.activity_name,
        ta.factor,
        aa.allocated_hours,

        -- Number of teachers sharing the same activity in this course instance
        COUNT(e.employment_id) OVER (
            PARTITION BY ci.instance_id, ta.activity_name
        ) AS teachers_count_sharing

    FROM course_instance ci
    JOIN course_layout cl ON ci.course_code = cl.course_code
    JOIN planned_activity pa ON cl.course_code = pa.course_code
    JOIN activity_allocation aa ON pa.planned_activity_id = aa.planned_activity_id
    JOIN teaching_activity ta ON pa.activity_id = ta.activity_id
    JOIN employee e ON aa.employment_id = e.employment_id
    JOIN person p ON e.personal_number = p.personal_number
    JOIN job_title jt ON e.job_title_id = jt.job_title_id

    -- Filter for the specific course instance being analysed
    WHERE ci.instance_id = '2025-50273'
)

-- Final aggregation per teacher
SELECT 
    course_code,
    instance_id AS "Course Instance ID",
    hp AS "HP",
    first_name || ' ' || last_name AS "Teacher's Name",
    job_title_name AS "Designation",

    -- Allocated teaching hours multiplied by activity factor
    ROUND(SUM(CASE WHEN activity_name = 'Lecture'
        THEN allocated_hours * factor ELSE 0 END)) AS "Lecture Hours",

    ROUND(SUM(CASE WHEN activity_name = 'Tutorial'
        THEN allocated_hours * factor ELSE 0 END)) AS "Tutorial Hours",

    ROUND(SUM(CASE WHEN activity_name = 'Lab'
        THEN allocated_hours * factor ELSE 0 END)) AS "Lab Hours",

    ROUND(SUM(CASE WHEN activity_name = 'Seminar'
        THEN allocated_hours * factor ELSE 0 END)) AS "Seminar Hours",

    -- Admin hours distributed evenly among teachers
    ROUND(SUM(CASE 
        WHEN activity_name = 'Admin'
        THEN (2 * hp + 28 + 0.2 * num_students) / teachers_count_sharing
        ELSE 0
    END)) AS "Admin",

    -- Exam hours distributed evenly among teachers
    ROUND(SUM(CASE 
        WHEN activity_name = 'Exam'
        THEN (32 + 0.725 * num_students) / teachers_count_sharing
        ELSE 0
    END)) AS "Exam",

    -- Total allocated workload per teacher
    ROUND(SUM(CASE 
        WHEN activity_name = 'Admin'
            THEN (2 * hp + 28 + 0.2 * num_students) / teachers_count_sharing
        WHEN activity_name = 'Exam'
            THEN (32 + 0.725 * num_students) / teachers_count_sharing
        ELSE allocated_hours * factor
    END)) AS "Total"

FROM AllocationDetails

GROUP BY 
    course_code,
    instance_id,
    hp,
    first_name,
    last_name,
    job_title_name

ORDER BY 
    "Total" DESC;



-------------------- QUERY 3 -----------------------------
-- Calculate total allocated hours per teacher across all course instances
-- for the current year
EXPLAIN ANALYZE
WITH AllocationDetails AS (
    SELECT 
        ci.course_code,
        ci.instance_id,
        ci.study_period,
        cl.hp,
        ci.num_students,
        p.first_name,
        p.last_name,
        jt.job_title_name,
        ta.activity_name,
        ta.factor,
        aa.allocated_hours,

        -- Number of teachers sharing each activity
        COUNT(e.employment_id) OVER (
            PARTITION BY ci.instance_id, ta.activity_name
        ) AS teachers_count_sharing

    FROM course_instance ci
    JOIN course_layout cl ON ci.course_code = cl.course_code
    JOIN planned_activity pa ON cl.course_code = pa.course_code
    JOIN activity_allocation aa ON pa.planned_activity_id = aa.planned_activity_id
    JOIN teaching_activity ta ON pa.activity_id = ta.activity_id
    JOIN employee e ON aa.employment_id = e.employment_id
    JOIN person p ON e.personal_number = p.personal_number
    JOIN job_title jt ON e.job_title_id = jt.job_title_id

    -- Filter for current year and a specific teacher
    WHERE ci.study_year = 2025
      AND p.first_name = 'Sara'
      AND p.last_name = 'Holm'
)

SELECT 
    course_code,
    instance_id AS "Course Instance ID",
    hp AS "HP",
    study_period AS "Period",
    first_name || ' ' || last_name AS "Teacher's Name",

    ROUND(SUM(CASE WHEN activity_name = 'Lecture'
        THEN allocated_hours * factor ELSE 0 END)) AS "Lecture Hours",

    ROUND(SUM(CASE WHEN activity_name = 'Tutorial'
        THEN allocated_hours * factor ELSE 0 END)) AS "Tutorial Hours",

    ROUND(SUM(CASE WHEN activity_name = 'Lab'
        THEN allocated_hours * factor ELSE 0 END)) AS "Lab Hours",

    ROUND(SUM(CASE WHEN activity_name = 'Seminar'
        THEN allocated_hours * factor ELSE 0 END)) AS "Seminar Hours",

    ROUND(SUM(CASE 
        WHEN activity_name = 'Admin'
        THEN (2 * hp + 28 + 0.2 * num_students) / teachers_count_sharing
        ELSE 0
    END)) AS "Admin",

    ROUND(SUM(CASE 
        WHEN activity_name = 'Exam'
        THEN (32 + 0.725 * num_students) / teachers_count_sharing
        ELSE 0
    END)) AS "Exam",

    -- Total workload per course instance for the selected teacher
    ROUND(SUM(CASE 
        WHEN activity_name = 'Admin'
            THEN (2 * hp + 28 + 0.2 * num_students) / teachers_count_sharing
        WHEN activity_name = 'Exam'
            THEN (32 + 0.725 * num_students) / teachers_count_sharing
        ELSE allocated_hours * factor
    END)) AS "Total"

FROM AllocationDetails

GROUP BY 
    course_code,
    instance_id,
    hp,
    study_period,
    first_name,
    last_name

ORDER BY 
    study_period, "Total" DESC;



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
