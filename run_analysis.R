#    Merges the training and the test sets to create one data set.
#    Extracts only the measurements on the mean and standard deviation for each measurement. 
#    Uses descriptive activity names to name the activities in the data set
#    Appropriately labels the data set with descriptive variable names. 

#    From the data set in step 4, creates a second, independent tidy
#    data set with the average of each variable for each activity and each subject.


# Activity labels:
# 1 WALKING
# 2 WALKING_UPSTAIRS
# 3 WALKING_DOWNSTAIRS
# 4 SITTING
# 5 STANDING
# 6 LAYING

select.variables <- function() {
    # reads features.txt and chooses only rows where
    # the variable name includes "mean()" or "std()". Converts these
    # to readable variable names, and returns a data frame where the
    # first column is the numbers and the second column is variable names.
    # This will be used to extract and label the numbers from the raw data sets.

    path <- paste(DATA.DIR, "/", "features.txt", sep="")
    vars.table <- read.table(path, header=FALSE)
    
    # Regexp to match only rows that contain "mean()" or "std()".
    # Double-backslash is to escape the backslash in the string literal
    # and then escape the parenthesis in the regexp.
    regexp <- "mean\\(\\)|std\\(\\)"

    # Find rows where the regexp matches the second column:
    matches <- vars.table[grep(regexp, vars.table[[2]]),]

    # Turn these labels into readable (and valid) column names:
    alter.name <- function(name) {
        # Replace hyphen with dot, and strip out parens:
        name <- gsub("-", ".", name)
        name <- gsub("\\(|\\)", "", name)
        name
    }
    matches[2] <- sapply(matches[[2]], alter.name)

    matches
}


# t = time domain, f = frequency domain.
# acc = device accelerometer, gyro = device gyroscope
# vibrations separated using frequency filter into body (freq above 0.3hz) and gravity (freq below)


# Files:
# - 'train/X_train.txt': Training set.
# - 'train/y_train.txt': Training labels.
# - 'test/X_test.txt': Test set.
# - 'test/y_test.txt': Test labels.
# The following files are available for the train and test data. Their descriptions are equivalent. 
# - 'train/subject_train.txt': Each row identifies the subject who performed the activity for each 
# window sample. Its range is from 1 to 30. 


DATA.DIR <- "UCI HAR Dataset"

label.activity <- function(code) {
  c("Walking", "Walking Upstairs", "Walking Downstairs", "Sitting", "Standing", "Laying")[[code]]
}


read.one.data.set <- function(subdir, col.numbers, col.names) {
     # Looks for files within the given subdirectory ("train" or "test")
     # within DATA.DIR.
     # col.numbers and col.names must be vectors of equal length.
     # col.numbers tells which columns of the raw data file we want to keep
     # and col.names gives the label to put on each of those columns.

     path <- paste(DATA.DIR, "/", subdir, "/y_", subdir, ".txt", sep="")
     activities.table <- read.table(path, header=FALSE)
     path <- paste(DATA.DIR, "/", subdir, "/subject_", subdir, ".txt", sep="")
     subjects.table <- read.table(path, header=FALSE)
     path <- paste(DATA.DIR, "/", subdir, "/X_", subdir, ".txt", sep="")
     raw.data <- read.table(path, header=FALSE, blank.lines.skip=TRUE)

     labeled.activities <- sapply(activities.table[[1]], label.activity)

     clean.data <- data.frame(subject = subjects.table[[1]], activity = labeled.activities)

     # helper function to extract a column of training data by number and assign it to a column
     # of newframe by name:
     assign.column <- function(index, colname) { clean.data[[colname]] <<- raw.data[[index]] }

     # do all the column assignments:
     sapply(seq(col.numbers), function(x) { assign.column(col.numbers[[x]], col.names[[x]])})

     clean.data
}


create.frame.of.averages <- function(full.data) {
    #    From the data set in step 4, creates a second, independent tidy
    #    data set with the average of each variable for each activity and each subject.

    # Get the list of unique subjects and the list of unique activities. We'll
    # output a data frame with one row for each unique subject-activity pair.
    subjects <- unique(full.data[["subject"]])
    activities <- unique(full.data[["activity"]])

    # Whih columns of full.data contain numeric data to be averaged 
    # (all except the first two columns):
    numeric.cols <- 3:ncol(full.data)

    # Pre-allocate an empty data frame with the correct number of rows
    # (one row for each activity for each subject):
    num.rows <- length(subjects) * length(activities)

    avg.frame <- data.frame(subject=vector('character', length = num.rows),
                            activity=vector('character', length = num.rows),
                            stringsAsFactors=FALSE)
    # Add empty numeric columns to the data frame:
    for (col.num in numeric.cols) {
       col.name <- colnames(full.data)[col.num]
       avg.frame[col.name] <- vector('numeric', length = num.rows)
    }

    # Loop through each subject and each activity. (For-loops might not be the most
    # idiomatic way to do this in R, but I don't know a better way.)
    rownum <- 1
    for (s in subjects) {
        for (a in activities) {
             # grab all the observations that match this subject and this activity:
             matches <- subset(full.data, subject==s & activity==a)
             # for each numeric column in this subset, calculate the mean:
             averages <- apply(matches[numeric.cols], 2, mean)

             # fill in one row of the output data frame with the subject,       
             # the activity, and the means we just calculated.
             avg.frame[rownum, "subject"] <- as.character(s)
             avg.frame[rownum, "activity"] <- as.character(a)
             avg.frame[rownum, numeric.cols] <- averages
             rownum <- rownum + 1
        }
    }
    # Return the frame of averages:
    avg.frame
}

run.assignment <- function() {
    # Find the column numbers and names for the variables we want to read:
    vars <- select.variables()
    col.numbers <- vars[[1]]
    col.names <- vars[[2]]

    # Read both data sets and append the rows into a single data frame:
    full.data.set <- rbind (read.one.data.set("train", col.numbers, col.names),
                            read.one.data.set("test", col.numbers, col.names))
    # Compute averages:
    avg.frame <- create.frame.of.averages(full.data.set)
    # save the averages to a txt file without row names:
    write.table(avg.frame, file="tidy_averages.txt", row.names=FALSE)
}
