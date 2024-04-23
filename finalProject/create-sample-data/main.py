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
    INSERT_STATEMENT = "INSERT INTO Courses (number, subjectCode, bannerId, name) VALUES\n"
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
'{course["courseTitle"]}'\
){ending}\n'''
            courses_output.write(full_string)
        courses_output.write(";")

def add_schools_and_subjects():
    SCHOOL_INSERT = "INSERT INTO Schools (code, name) VALUES\n"
    SUBJECT_INSERT = "INSERT INTO Subjects (code, name, schoolCode) VALUES\n"
    output = Path("makeSchoolSubjects.sql")
    code_schools = {}
    subject_code_name_school = {}

    sample_courses_path = Path(os.path.join("sample-data", "courses.json"))
    with open(sample_courses_path) as file:
        sample_courses = json.load(file)
    for course in sample_courses:
        try:
            code_schools[course["collegeCode"]] = (course["collegeCode"], course["department"])
        except KeyError:
            continue
        subject_code_name_school[course["subjectCode"]] = (course["subjectCode"], course["subjectDescription"], course["collegeCode"])

    with open(output, "w") as output_f:
        output_f.write(SCHOOL_INSERT)
        len1 = len(code_schools)
        for i, (code, school) in enumerate(code_schools.values()):
            if i == len1 - 1:
                output_f.write(f"('{code}', '{school}')\n")
            else:
                output_f.write(f"('{code}', '{school}'),\n")
        output_f.write(";\n")

        output_f.write(SUBJECT_INSERT)
        len2 = len(subject_code_name_school)
        for i, (code, name, school_code) in enumerate(subject_code_name_school.values()):
            if i == len2 - 1:
                output_f.write(f"('{code}', '{name}', '{school_code}')\n")
            else:
                output_f.write(f"('{code}', '{name}', '{school_code}'),\n")
        output_f.write(";\n")

def add_all_professors():
    sample_data_path = "sample-data"
    file_names = os.listdir(sample_data_path)
    lines: dict[str, str] = {}
    for filename in file_names:
        if filename.startswith("sections"):
            lines.update(add_professors_from(Path(os.path.join(sample_data_path, filename))))
    out_put_professor = Path("makeProfessors.sql")
    with open(out_put_professor, "w") as output:
        output.write("INSERT INTO Professors (email, firstName, lastName) VALUES\n")
        output.writelines(lines.values())
        output.write("\n;")


def add_professors_from(section_path: Path) -> dict[str, str]:
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
    lines: dict[str, str] = {}
    for email, first_name, last_name in professor_tuples:
        line = "("
        line += f"'{email}', "
        line += f"'{first_name}', "
        line += f"'{last_name}'"
        line += "),\n"
        lines[email] = line

    return lines

def add_all_section_calls():
    sample_data_path = "sample-data"
    file_names = os.listdir(sample_data_path)
    for filename in file_names:
        if filename.startswith("sections"):
            output = os.path.splitext(filename)[0] + ".sql"
            add_sections_call(Path(os.path.join(sample_data_path, filename)), output, "Fall 2024")

def add_sections_call(sections_path: Path, output_name: str, term: str):
    course_numbers = ""
    subject_codes = ""
    numbers = ""
    banner_ids = ""
    primary_professors = ""
    with sections_path.open("r") as sections_f:
        sections = json.load(sections_f)
        # courseNumber, subjectCode, number, term, bannerId, primaryProfessor
        length = len(sections)
        for i, section in enumerate(sections):
            if i == length - 1:
                ending = ""
            else:
                ending = ","
            course_numbers += f"'{section["courseNumber"]}'{ending}"
            subject_codes += f"'{section["subject"]}'{ending}"
            numbers += f"'{section["sequenceNumber"]}'{ending}"
            banner_ids += f"'{section["id"]}'{ending}"
            professor = "NULL"
            for fac in section["faculty"]:
                if fac["primaryIndicator"]:
                    professor = fac["emailAddress"]
            primary_professors += f"'{professor}'{ending}"

    with open(output_name, "w") as output:
        output.write("DO $$\n")
        output.write("DECLARE\n")
        output.write(f"\tterm text := '{term}';\n")
        output.write(f"\tbanner_ids text[] := ARRAY[{banner_ids}];\n")
        output.write(f"\tcourse_numbers text[] := ARRAY[{course_numbers}];\n")
        output.write(f"\tsubject_codes text[] := ARRAY[{subject_codes}];\n")
        output.write(f"\tnumbers text[] := ARRAY[{numbers}];\n")
        output.write(f"\tprimary_professor_emails text[] := ARRAY[{primary_professors}];\n")
        output.write("BEGIN\n")
        output.write("\tSELECT upsert_sections_in_term(\n")
        output.write("\t\tterm,\n")
        output.write("\t\tbanner_ids,\n")
        output.write("\t\tcourse_numbers,\n")
        output.write("\t\tsubject_codes,\n")
        output.write("\t\tnumbers,\n")
        output.write("\t\tprimary_professor_emails\n")
        output.write("\t);\n")
        output.write("END $$;")


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
    #prints()
    generate_course_sql()
    add_schools_and_subjects()
    add_all_professors()
    add_all_section_calls()

if __name__ == "__main__":
    main()
