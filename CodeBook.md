= Variables in the Tidy Data File (tidy_averages.txt) =

The tidy data file contains one row for each unique combination of test subject and activity. The first two columns (out of 68) specify the test subject and the activity. All of the feature variables for a single activity for a single test subject are in the same row, comprising columns 3 through 68.

== Column 1 ("subject") ==

Identifies the study participant. It's a character type column containing a number from 1 to 30 uniquely but anonymously specifying the participant.

== Column 2 ("activity") ==

The second column ("activity") identifies which activity the subject was performing. This is a character type column. There are six possible values: "Standing", "Sitting", "Laying", "Walking", "Walking Downstairs", "Walking Upstairs".

== Columns 3 through 68 ==

These are all numeric type columns. Each one holds the average (mean) of a single feature variable. They are named as follows:

* "t" prefix means time domain while "f" prefix means frequency domain
* "Body" indicates acceleration due to motion of the human body while "Gravity" indicates accelertion due to gravity.
* "Gyro" indicates a measurement of the phone gyroscope while "Acc" indicates a measurement of the phone accelerometer.
* "mean" indicates the mean of observations over the time period while "std" indicates the standard deviation of those observations.
* "X", "Y", or "Z" indicates movement of the accelerometer in the x, y, or z direction, or rotation of the gyroscope about the x, y, or z axis.

So for example, the column "tGravityAcc.mean.X" means the mean of acceleration on the X axis due to gravity in the time domain.

All of the numbers in these feature columns are normalized. Therefore they're unitless and range from -1.0 to 1.0.

Each one of the feature variables in these columns was calculated by averaging together all of the raw values for that feature (that matched the given subject and activity). That means that, yes, the "mean" columns are average of an average, and the "std" columns are average of a standard deviation.