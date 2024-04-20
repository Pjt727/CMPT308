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

def main():
    generate_course_sql()

if __name__ == "__main__":
    main()
