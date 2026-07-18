/* CREATE DATABASE SIMS_DB;
GO */
/* USE SIMS_DB;
GO */

/* DROP TABLE Enrolment;
DROP TABLE Courses;
DROP TABLE Faculty;
DROP TABLE Students; */
 
CREATE TABLE Students (
    StudentID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(15),
    DateOfBirth DATE NOT NULL,
    Gender VARCHAR(10)
        CHECK (Gender IN ('Male','Female','Other')),
    EnrollmentDate DATE DEFAULT GETDATE(),
    Address VARCHAR(150)
);

CREATE TABLE Faculty (
    FacultyID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Department VARCHAR(100) NOT NULL,
    Phone VARCHAR(15)
);

CREATE TABLE Courses (
    CourseID INT IDENTITY(1,1) PRIMARY KEY,
    CourseCode VARCHAR(10) NOT NULL UNIQUE,
    CourseName VARCHAR(100) NOT NULL,
    Credits INT NOT NULL CHECK (Credits BETWEEN 1 AND 6),
    FacultyID INT NOT NULL,
    CONSTRAINT FK_Courses_Faculty
        FOREIGN KEY (FacultyID)
        REFERENCES Faculty(FacultyID)
);

CREATE TABLE Enrolment (
    EnrolmentID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT NOT NULL,
    CourseID INT NOT NULL,
    EnrollDate DATE NOT NULL DEFAULT GETDATE(),
    Grade DECIMAL(5,2) NULL CHECK (Grade BETWEEN 0 AND 100),
    CONSTRAINT FK_Enrolment_Student
        FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID),
    CONSTRAINT FK_Enrolment_Course
        FOREIGN KEY (CourseID)
        REFERENCES Courses(CourseID),
    CONSTRAINT UQ_Student_Course
        UNIQUE (StudentID, CourseID)
);

CREATE TABLE Feedback (
    FeedbackID INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentID INT NOT NULL,
    FacultyID INT NOT NULL,
    Comments VARCHAR(255),
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    FeedbackDate DATE DEFAULT GETDATE(),

    CONSTRAINT FK_Feedback_Enrolment
        FOREIGN KEY (EnrolmentID)
        REFERENCES Enrolment(EnrolmentID),

    CONSTRAINT FK_Feedback_Faculty
        FOREIGN KEY (FacultyID)
        REFERENCES Faculty(FacultyID)
);


INSERT INTO Students (FirstName, LastName, Email, Phone, DateOfBirth, Gender, Address)
VALUES ('Prakash', 'Adhikari', 'prakash.a@student.edu.np', '9800000006', '2004-03-18', 'Male', 'Kathmandu');
 

UPDATE Students SET Phone = '9811111111' WHERE Email = 'prakash.a@student.edu.np';
 

DELETE FROM Students WHERE Email = 'prakash.a@student.edu.np';

INSERT INTO Faculty (FirstName, LastName, Email, Department, Phone)
VALUES
('Ram', 'Sharma', 'ram.sharma@college.edu.np', 'Computer Science', '9800000001'),
('Sita', 'Thapa', 'sita.thapa@college.edu.np', 'Information Technology', '9800000002'),
('Hari', 'Karki', 'hari.karki@college.edu.np', 'Cyber Security', '9800000003');

INSERT INTO Students
(FirstName, LastName, Email, Phone, DateOfBirth, Gender, Address)
VALUES
('Prakash', 'Adhikari', 'prakash.adhikari@student.edu.np', '9800000006', '2004-03-18', 'Male', 'Kathmandu'),
('Anjali', 'Shrestha', 'anjali.shrestha@student.edu.np', '9800000007', '2003-11-25', 'Female', 'Lalitpur'),
('Rohit', 'Gurung', 'rohit.gurung@student.edu.np', '9800000008', '2004-07-10', 'Male', 'Bhaktapur');

INSERT INTO Courses
(CourseCode, CourseName, Credits, FacultyID)
VALUES
('DMS-236', 'Database Management Systems', 3, 1),
('SEC-220', 'Cyber Security Fundamentals', 3, 3),
('WEB-210', 'Web Development', 4, 2);

INSERT INTO Enrolment (StudentID, CourseID, Grade)
VALUES
(4,1,88),
(4,2,91),
(5,1,84),
(5,3,79),
(6,2,93),
(6,3,87);

INSERT INTO Feedback
(EnrolmentID, FacultyID, Comments, Rating)
VALUES
(1, 1, 'Excellent understanding of SQL.', 5),
(2, 3, 'Strong security concepts demonstrated.', 5),
(3, 1, 'Good progress throughout the semester.', 4),
(4, 2, 'Needs improvement in frontend design.', 3),
(5, 3, 'Very active during practical sessions.', 5),
(6, 2, 'Consistent work and timely submissions.', 4);

SELECT * FROM Students
SELECT s.StudentID, s.FirstName, s.LastName, c.CourseName, e.Grade
FROM Students s
INNER JOIN Enrolment e ON s.StudentID = e.StudentID
INNER JOIN Courses c ON e.CourseID = c.CourseID
ORDER BY s.StudentID;


-- LIKE
SELECT * FROM Students WHERE FirstName LIKE 'P%';
 
-- BETWEEN
SELECT StudentID, FirstName, LastName, DateOfBirth FROM Students
WHERE DateOfBirth BETWEEN '2004-01-01' AND '2004-12-31';
 
-- IN
SELECT * FROM Courses WHERE CourseCode IN ('DMS-236', 'SEC-220');

SELECT EnrolmentID, Grade
FROM Enrolment
WHERE EnrolmentID = 3;

SELECT *
FROM Feedback
WHERE EnrolmentID = 3;

-- Test Case 1: Successful transaction
BEGIN TRANSACTION;
    UPDATE Enrolment
    SET Grade = 90
    WHERE EnrolmentID = 3;

INSERT INTO Feedback (EnrolmentID, FacultyID, Comments, Rating)
    VALUES (3, 1, 'Grade revised after re-evaluation.', 4);

COMMIT TRANSACTION;
-- Test Case 2: Failed transaction (rolled back)
BEGIN TRANSACTION;

    UPDATE Students
    SET Email = 'anjali.shrestha@student.edu.np'
    WHERE StudentID = 4;

IF @@ERROR <> 0
    ROLLBACK TRANSACTION;
ELSE
    COMMIT TRANSACTION;

SELECT *
FROM Feedback
WHERE EnrolmentID = 3;

SELECT StudentID, FirstName, Email
FROM Students;

/* DELETE FROM Feedback
WHERE FeedbackID IN (3,4,5); */

-- INNER JOIN
SELECT s.StudentID, s.FirstName, c.CourseName
FROM Students s
INNER JOIN Enrolment e ON s.StudentID = e.StudentID
INNER JOIN Courses c ON e.CourseID = c.CourseID;
 
-- LEFT JOIN: students not enrolled in any course
SELECT s.StudentID, s.FirstName, s.LastName
FROM Students s
LEFT JOIN Enrolment e ON s.StudentID = e.StudentID
WHERE e.EnrolmentID IS NULL;
 
-- SELF JOIN: compare grades of students in the same course
SELECT e1.CourseID, s1.FirstName AS Student1, e1.Grade AS Grade1,
       s2.FirstName AS Student2, e2.Grade AS Grade2
FROM Enrolment e1
JOIN Enrolment e2 ON e1.CourseID = e2.CourseID AND e1.StudentID < e2.StudentID
JOIN Students s1 ON e1.StudentID = s1.StudentID
JOIN Students s2 ON e2.StudentID = s2.StudentID;


-- COUNT: students enrolled per course
SELECT c.CourseName, COUNT(e.StudentID) AS TotalStudents
FROM Courses c LEFT JOIN Enrolment e ON c.CourseID = e.CourseID
GROUP BY c.CourseName;
 
-- AVG: average grade per course
SELECT c.CourseName, AVG(e.Grade) AS AverageGrade
FROM Courses c JOIN Enrolment e ON c.CourseID = e.CourseID
GROUP BY c.CourseName;
 
-- HAVING: courses with average grade below 80
SELECT c.CourseName, AVG(e.Grade) AS AverageGrade
FROM Courses c JOIN Enrolment e ON c.CourseID = e.CourseID
GROUP BY c.CourseName
HAVING AVG(e.Grade) < 80;
