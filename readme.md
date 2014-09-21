

**Getting and Cleaning Data Course Project**

**How the run\_analysis.R program works.**

Initially I load the dplyr library. Dplyr is a powerful library for analysing data.

Next I search for Training and Test files. This drills down through all the subdirectories and finds files which end in test.txt or train.txt and adds the filenames to the testFiles or trainFiles variables respectively. 

The MergeFiles function is than called to read all these files. The files XXXtest.txt and XXXtrain.txt are read in and merged into a global data.frame called XXX\_df.

( I have read in all files here but it subsequently became apparent that the files in the "Inertial Signals" were not being used. However it wasn't causing any problems so I left the code as is.)

The next phase I read in the features.txt and activity\_labels.txt files into global data frames called features\_df and activity\_labels\_df

**Tidying Data**

I now need to start looking at the names of the variables in the original data.

Initially I define a function called "_substrRight_" to find the last n characters of each element of a character vector.

The names of the variables are in the function\_df data.frame.

The first thing I do is to change all occurences of BodyBody to Body as this seems to be an error in the original data.

I then search for variables containing "mean()" or "std()" and store these positions in TargetMeanVars and TargetSTDVars.

I now create a data.frame called MeanVars\_df.

I am going to use this to parse out the variable names into components so that I can clean up the names into tidier names.

I create a field BaseName which has the the –X, -Y and –Z and mean() stripped out.

I create a field Stat with "Mean"

I create a field Axis with the –X, -Y or –Z component of the original name if present.

I then create a data.frame called STDVars where I preform the same tasks with the Standard Deviation fields.

I then create merge MeanVars and StdVars to create NewVarNames\_df which has the naming date for the columns I wish to use in the tidy dataset.

**Step 2 Create a dataset data\_df with only the mean and Standard Deviation Variables**

I now extract the targeted columns from X\_df to create a dataset data\_df with the columns specified in NewVarNames\_df$V1

I now do step 4 and step 3 in reverse order as it's slightly more convenient to label the column headings in the new data.frame before adding extra columns.

**Step 4 Appropriately label the data set with descriptive variable names.**

I concatenate the (BaseName, Axis,"\_" and Stat) fields from NewVarNames to gives the new name for each of the columns in data\_df.

**Step 3 Uses descriptive activity names to name the activities in the data set**

I create a column data\_df$Activity which and populate the rows with the activity\_name associtated with the activity\_number for the row in the y\_df data frame.

I then add a column data\_df$Subject and populate it with the Subject number data for each row from the subject\_df data frame

**Step 5 create a second, independent tidy data set with the average of each variable for each activity and each subject.**

I now create a data frame called TidyData\_df with the mean of each variable in data\_df calculated grouped by Activity and Subject using the dplyr library.

Finally I write the resulting data.frame with one record for each Activity and Subject combination to "TidyData.txt"

