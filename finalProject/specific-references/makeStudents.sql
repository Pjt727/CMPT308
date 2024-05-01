DELETE FROM Messages;
DELETE FROM PreferredEnrollments;
DELETE FROM Students;

INSERT INTO Students (id, firstName) 
VALUES (1, 'Patrick');
 
INSERT INTO Students (id, firstName) 
VALUES (2, 'Daisy');
  
INSERT INTO Students (id, firstName) 
VALUES (3, 'Alan Jr');

-- a student with no classes
INSERT INTO Students (id, firstName) 
VALUES (4, 'Jimmy');

INSERT INTO PreferredEnrollments (courseNumber, subjectCode, sectionNumber, term, studentId)
VALUES
-- my actual schedule next fall
('333N', 'CMPT', '111', 'Fall 2024', 1),
('422N', 'CMPT', '111', 'Fall 2024', 1),
('440L', 'CMPT', '111', 'Fall 2024', 1),
('475N', 'CMPT', '113', 'Fall 2024', 1),
('476N', 'CMPT', '721', 'Fall 2024', 1),

('477L', 'ENG', '111', 'Fall 2024', 2),
('101L', 'FREN', '111', 'Fall 2024', 2),
('120L', 'MDIA', '111', 'Fall 2024', 2),
('101L', 'ART', '113', 'Fall 2024', 2),

('150L', 'ENG', '115', 'Fall 2024', 3),
('402L', 'BUS', '200', 'Fall 2024', 3),
('132N', 'PHED', '111', 'Fall 2024', 3),
('324L', 'COM', '200', 'Fall 2024', 3);
