# QUICK AVERT YOUR EYES ITS PYTHON !!!
#
# Sorry for including this in the repository... I work on multiple devices 
#    and this is the best place for this code to go
#
# Objective of this code is to directly produce the sample information which is used
#    for the project **INFORMATION IS POWER** and using all of this information 
#    is the good and real data is the best test for the database 
import json
import os
from pathlib import Path

def generate_course_sql():
    INSERT_STATEMENT = "INSERT INTO Courses (number, subjectCode, bannerId, description, name) VALUES\n"
    sample_courses_path = Path(os.path.join("sample-data", "courses.json"))
    output_courses_path = Path("makeCourses.sql")

    with sample_courses_path.open("r") as sample_courses_file:
        sample_courses = json.load(sample_courses_file)

    with open(output_courses_path, "w") as courses_output:
        courses_output.write(INSERT_STATEMENT)
        length = len(sample_courses)
        # sql attacks...
        for i, course in enumerate(sample_courses):
            allowed_chars = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 
                             'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
                             'u', 'v', 'w', 'x', 'y', 'z', '.', ',', ' ']
            og_course_details: str = course.get("course_details", "None")
            course_details = ""
            for letter in og_course_details:
                letter: str
                if letter.lower() in allowed_chars:
                    course_details += letter
            if length - 1 == i:
                ending = ""
            else:
                ending = ","

            full_string = f'''    (\
'{course["courseNumber"]}',\
'{course["subjectCode"]}',\
'{course["id"]}',\
'{course_details}',\
'{course["courseTitle"]}'\
){ending}\n'''
            courses_output.write(full_string)
        courses_output.write(";")

def add_schools_and_subjects():
    SCHOOL_INSERT = "INSERT INTO Schools (code, name) VALUES\n"
    SUBJECT_INSERT = "INSERT INTO Subjects (code, name, schoolCode) VALUES\n"
    output = Path("makeSchoolSubjects.sql")
    code_schools = set()
    subject_code_name_school = set()

    sample_courses_path = Path(os.path.join("sample-data", "courses.json"))
    with open(sample_courses_path) as file:
        sample_courses = json.load(file)
    for course in sample_courses:
        try:
            code_schools.add((course["departmentCode"], course["department"]))
        except KeyError:
            continue
        subject_code_name_school.add((course["subjectCode"], course["subjectDescription"], course["collegeCode"]))

    for code, school in code_schools:
        print(code, school)

    with open(output, "w") as output_f:
        output_f.write(SCHOOL_INSERT)
        len1 = len(code_schools)
        for i, (code, school) in enumerate(code_schools):
            if i == len1 - 1:
                output_f.write(f"('{code}', '{school}')\n")
            else:
                output_f.write(f"('{code}', '{school}'),\n")
        output_f.write(";\n")

        output_f.write(SUBJECT_INSERT)
        len2 = len(subject_code_name_school)
        for i, (code, name, school_code) in enumerate(subject_code_name_school):
            if i == len2 - 1:
                output_f.write(f"('{code}', '{name}', '{school_code}')\n")
            else:
                output_f.write(f"('{code}', '{name}', '{school_code}'),\n")
        output_f.write(";\n")

def add_all_professors():
    sample_data_path = "sample-data"
    file_names = os.listdir(sample_data_path)
    lines: set[str] = set()
    for filename in file_names:
        if filename.startswith("sections"):
            lines.update(add_professors_from(Path(os.path.join(sample_data_path, filename))))
    out_put_professor = Path("makeProfessors.sql")
    with open(out_put_professor, "w") as output:
        output.write("INSERT INTO Professors VALUES (email, firstName, lastName)\n")
        output.writelines(lines)
        output.write("\n;")


def add_professors_from(section_path: Path) -> set[str]:
    # email, firstName, lastName
    professor_tuples = set()
    with section_path.open("r") as sections_f:
        sections = json.load(sections_f)
        for section in sections:
            for professor in section["faculty"]:
                try:
                    last_name, first_name = professor["displayName"].split(", ")
                except:
                    last_name = None
                    first_name = professor["displayName"]
                professor_tuples.add((
                    professor["emailAddress"],
                    first_name,
                    last_name
                    ))
    lines: set[str] = set()
    for email, first_name, last_name in professor_tuples:
        line = "("
        line += f"'{email}', "
        line += f"'{first_name}', "
        line += f"'{last_name}'"
        line += "),\n"
        lines.add(line)

    return lines

def add_all_section_declares():
    pass

def add_sections_declare(sections_path: Path, output_name: str, term: str):
    section_tuples: list[str] = []
    course_numbers = []
    subject_codes = []
    numbers = []
    banner_ids = []
    primary_professors = []
    with sections_path.open("r") as sections_f:
        sections = json.load(sections_f)
        # courseNumber, subjectCode, number, term, bannerId, primaryProfessor
        length = len(sections)
        for i, section in enumerate(sections):
            if i == length - 1:
                ending = ""
            else:
                ending = ","
            course_numbers.append(f"'{section["courseNumber"]}'{ending}")
            subject_codes.append(f"'{section["subject"]}'{ending}")
            numbers.append(f"'{section["sequenceNumber"]}'{ending}")
            banner_ids.append(f"'{section["id"]}'{ending}")
            professor = "NULL"
            for fac in section["faculty"]:
                if fac["primaryIndicator"]:
                    professor = fac["emailAddress"]
            primary_professors.append(f"'{professor}'{ending}")

    with open(output_name, "w") as output:




def prints():
    sample_courses_path = Path(os.path.join("sample-data", "courses.json"))

    codes = set()

    with sample_courses_path.open("r") as file:
        sample_courses = json.load(file)
        for course in sample_courses:
            codes.add(course["collegeCode"])

    for code in codes:
        print(code, )


def main():
    # prints()
    #generate_course_sql()
    #add_schools_and_subjects()
    add_all_professors()

if __name__ == "__main__":
    main()
