-- Users
CREATE TABLE IF NOT EXISTS users (
    id       SERIAL PRIMARY KEY,
    username VARCHAR(50)  UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role     VARCHAR(20)  NOT NULL
);

-- Classes
CREATE TABLE IF NOT EXISTS classes (
    id          SERIAL PRIMARY KEY,
    code        VARCHAR(20)  NOT NULL,
    name        VARCHAR(100) NOT NULL,
    description TEXT
);

-- Which lecturers teach which classes
CREATE TABLE IF NOT EXISTS teaches (
    lecturer_id INT REFERENCES users(id),
    class_id    INT REFERENCES classes(id),
    PRIMARY KEY (lecturer_id, class_id)
);

-- Which students are enrolled in which classes
CREATE TABLE IF NOT EXISTS enrollments (
    student_id INT REFERENCES users(id),
    class_id   INT REFERENCES classes(id),
    PRIMARY KEY (student_id, class_id)
);

-- Assignments belong to a class
CREATE TABLE IF NOT EXISTS assignments (
    id            SERIAL PRIMARY KEY,
    class_id      INT REFERENCES classes(id),
    title         VARCHAR(200) NOT NULL,
    description   TEXT,
    accepts_files BOOLEAN DEFAULT FALSE
);

-- Submissions scoped to an assignment
CREATE TABLE IF NOT EXISTS submissions (
    id            SERIAL PRIMARY KEY,
    student_id    INT REFERENCES users(id),
    assignment_id INT REFERENCES assignments(id),
    filename      VARCHAR(255),
    file_path     VARCHAR(500),
    submitted_at  TIMESTAMP DEFAULT NOW()
);

-- Grades
CREATE TABLE IF NOT EXISTS grades (
    id            SERIAL PRIMARY KEY,
    submission_id INT REFERENCES submissions(id),
    score         INT,
    comments      TEXT,
    exec_output   TEXT,
    graded_at     TIMESTAMP DEFAULT NOW()
);

-- ----------------------------------------------------------------
-- Seed data
-- ----------------------------------------------------------------

-- Staff accounts
INSERT INTO users (username, password, role)
    VALUES ('lecturer', '$2b$12$b7Jz0ZmXKvVVol2KLgqDOOtCnDH.HHkJXpMYj2neC4F52EQnMh.Fa', 'lecturer')
    ON CONFLICT (username) DO NOTHING;

INSERT INTO users (username, password, role)
    VALUES ('admin', '$2b$12$8eHicq2Wijf0mJ2umpX54OWMd5TLNCdAnZLcsJ4DFY1LCnzrcvQUK', 'admin')
    ON CONFLICT (username) DO NOTHING;

-- Student test account (provided to testers)
INSERT INTO users (username, password, role)
    VALUES ('student-user', '$2b$12$8eHicq2Wijf0mJ2umpX54OWMd5TLNCdAnZLcsJ4DFY1LCnzrcvQUK', 'student')
    ON CONFLICT (username) DO NOTHING;

-- Classes
INSERT INTO classes (code, name, description)
    VALUES
        ('CS101', 'Introduction to Programming',
         'Fundamentals of programming using Python. Covers variables, control flow, functions and file I/O.'),
        ('CS201', 'Data Structures & Algorithms',
         'Theory and analysis of core data structures. Assessments are written and do not require code submission.'),
        ('CS304', 'Web Application Security',
         'Hands-on study of common web vulnerabilities and mitigation strategies.')
    ON CONFLICT DO NOTHING;

-- Lecturer teaches CS101 and CS304 only
INSERT INTO teaches (lecturer_id, class_id)
    SELECT u.id, c.id
    FROM users u, classes c
    WHERE u.username = 'lecturer'
      AND c.code IN ('CS101', 'CS304')
    ON CONFLICT DO NOTHING;

-- Enroll student-user in all three classes
INSERT INTO enrollments (student_id, class_id)
    SELECT u.id, c.id
    FROM users u, classes c
    WHERE u.username = 'student-user'
    ON CONFLICT DO NOTHING;

-- Assignments
INSERT INTO assignments (class_id, title, description, accepts_files)
    SELECT id,
           'Assignment 1: Python Basics',
           'Write a Python script that accepts a number as input and prints the Fibonacci sequence up to that number.',
           TRUE
    FROM classes WHERE code = 'CS101';

INSERT INTO assignments (class_id, title, description, accepts_files)
    SELECT id,
           'Problem Set 1: Sorting Algorithms',
           'Written analysis of bubble sort, merge sort, and quicksort. Submit via the course LMS — no code upload required.',
           FALSE
    FROM classes WHERE code = 'CS201';

INSERT INTO assignments (class_id, title, description, accepts_files)
    SELECT id,
           'Lab 1: Vulnerable App Testing',
           'Upload a Python script that demonstrates an automated test against the target application. Your script will be executed on the grading server.',
           TRUE
    FROM classes WHERE code = 'CS304';

-- Ensure default enrolment records are populated
INSERT INTO users (username, password, role)
    VALUES ('student', '$2b$12$zwS9jeYkT.wkWU9rGpR3jut71T4Ir0EeCtEGXnG8KFyp8UOXZurYi', 'student')
    ON CONFLICT (username) DO NOTHING;

INSERT INTO enrollments (student_id, class_id)
    SELECT u.id, c.id
    FROM users u, classes c
    WHERE u.username = 'student'
    ON CONFLICT DO NOTHING;