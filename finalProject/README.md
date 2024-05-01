The .sql file in this directory 'bannerTracker.sql' contains all initial data...

However, messages will not populate until diffs between sections are made so therefore you will
also need to run the .sql files for the section in the 'create-sample-data' directory 
(just one of the later files will work i.e. sectionsFall2024-13.sql) some errors are to be expected / ignored
so do not run it and an 'all or nothing script'

I do sort of regret the direction I took with the project I think it would have been more interesting if I
did something with timing rather than the complicated diffing procedures. I really think that diffing would
be much better to do in whatever programming language is doing the scraping as you can easily have the last
json in memory anyway so it'll be really fast compared to the atrocities I did in the procedure language.
