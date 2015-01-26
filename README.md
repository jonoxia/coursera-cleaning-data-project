My submission for the class project for the "Getting and Cleaning Data" Coursera course.

To run the script, please:

1. Download the data set from 
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip and unzip it into a directory within the git checkout directory.
2. Start R and do: `source("run_analysis.R")`
3. run the main function like so: `run.assignment()`. This will output a text file to the current working directory called "tidy_averages.txt".
4. If you want to read the text file back into R, use the following command: `tidy.avgs <- read.table("tidy_averages.txt", header=TRUE)`


Please see CodeBook.md for an explanation of output file format, the variables in it, and the transformations done to those variables.

Note that the run_analysis.R script assumes the data will be found in a directory called "UCI HAR Dataset". If this is not the name of your data directory, you can alter the constant DATA.DIR defined in run_analysis.R to point at the correct directory.