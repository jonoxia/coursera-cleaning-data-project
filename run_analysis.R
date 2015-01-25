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

# Mean and STD-dev for each measurement are:
# 1, 2, 3 = tBodyAcc-mean()   x, y z
# 4, 5, 6 = tBodyAcc - std()   x, y, z
# 41, 42, 43 = tGravityAcc-mean() x, y, z
# 44, 45, 46 = tGravityAcc-std() x, y, z
# 81, 82, 83 = tBodyAccJerk-mean() x, y, z
# 84, 85, 86 = tBodyAccJerk-std() x, y, z
# 121-126 = tBodyGyro mean x, y, y and std x, y, z
# 161 - 166 = tBodyGyroJerk mean x, y, z and std x, y, z
# 201 = tBodyAccMag - mean()
# 202 = tBodyAccMag - std()
# 214 = tGravityAccMag - mean()
# 215 = tGravityAccMag - std()
# 227-228 = tBodyAccJerkMag - mean and std
# 240 - 241 = tBodyGyroMag - mean and std
# 253-255 = tBodyGyroJerkMag - mean and std
# 266 - 268 fBodyAcc - mean, x, y, z
# 269 - 271 fBodyAcc - std, x, y, z
# 345 - 350 fBodyAccJerk - mean x, y, z, std x, y, z
# 424 - 429 fBodyGyro - mean x, y, z, std x, y, z
# 503, 504 = fbodyAccMag - mean and std
# 516, 517 = fBodyBodyAccJerkMag - mean and std
# 529, 530 - fBodyBodyGyroMag - mean and std
# 542, 543 - fBodyBodyGyroJerkMag - mean and std

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

# rawdata <- read.table(filename, sep  = ",", header = TRUE) 
# Appear to be space-delimited

label.activity <- function(code) {
  c("Walking", "Walking Upstairs", "Walking Downstairs", "Sitting", "Standing", "Laying")[[code]]
}

# The column numbers we want to extract and the names we want to give them:
col.names <- c("t.body.acc.mean.x", "t.body.acc.mean.y", "t.body.acc.mean.z",
               "t.body.acc.std.x", "t.body.acc.std.y", "t.body.acc.std.z",
               "t.gravity.acc.mean.x", "t.gravity.acc.mean.y", "t.gravity.acc.mean.z",
               "t.gravity.acc.std.x", "t.gravity.acc.std.y", "t.gravity.acc.std.z")
col.numbers <- c(1, 2, 3, 4, 5, 6, 41, 42, 43, 44, 45, 46)


read.one.data.set <- function(directory) {
     filename <- paste(directory, "/y_", directory, ".txt", sep="")
     activities.table <- read.table(filename, header=FALSE)
     filename <- paste(directory, "/subject_", directory, ".txt", sep="")
     subjects.table <- read.table(filename, header=FALSE)
     filename <- paste(directory, "/X_", directory, ".txt", sep="")
     raw.data <- read.table(filename, header=FALSE, blank.lines.skip=TRUE)
     # Default behavior, for no separator or column names supplied, is to split columns on
     # 'any whitespace' and label columns V1.... V561  (yes there are 561 columns)


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

    # The column indices of the columns of full.data that contain numeric
    # data to be averaged:
    numeric.cols <- 3:14

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
    # Read both data sets and append the rows into a single data frame:
    full.data.set <- rbind (read.one.data.set("train"), read.one.data.set("test"))

    # Computes averages:
    avg.frame <- create.frame.of.averages(full.data.set)
    # save the averages to a CSV file:
    write.csv(avg.frame, "jono.avgs.csv")
}
