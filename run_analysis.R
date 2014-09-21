setwd('e:/getting and cleaning data/Course Project')

library(dplyr)

## The MergeFile functions merges a training file and test file

MergeFiles<-function(FileNum) {  
testDat<-read.table(testFiles[FileNum],header=FALSE)
trainDat<-read.table(trainFiles[FileNum],header=FALSE)

## Find the core part of the filename
FName_start<-sapply(gregexpr("/", testFiles[FileNum]), tail, 1)+1
FName_end<-sapply(gregexpr("_test.txt", testFiles[FileNum]), tail, 1)-1
FName<-paste(substr(testFiles[FileNum],FName_start,FName_end),"_df",sep="")
##Now create a data frame in the Global Environment with the Test and
## Training data combined.
assign(FName,rbind(testDat,trainDat),envir = .GlobalEnv)
return(FName)
}

# Find all files in any subsdirectory ending in test.txt and train.txt
testFiles<-list.files( pattern="*test.txt",recursive=TRUE)
trainFiles<-list.files( pattern="*train.txt",recursive=TRUE)

## Go through each file in the list of Training Files
## Read in the Training file and corresponding Test File and create a global data frame
## with the name of the dataset

NumFiles<-length(trainFiles)
datasets<-character(NumFiles)
for (FileNum in 1:NumFiles) {
  datasets[FileNum]<-MergeFiles(FileNum)
}

## Now read in the features and activity labels files into data frames

features_df<-read.table("UCI HAR Dataset/features.txt",stringsAsFactors=FALSE)
activity_labels_df<-read.table("UCI HAR Dataset/activity_labels.txt",stringsAsFactors=FALSE)


## Now start to tidy data
## Need to identify columns containg means and standard deviations of variables
## I have decided to search for the "-mean()" and "-std()" strings
##

## Create a finction to get the last n characters of each element of a character vector

substrRight <- function(CharVector, n){
  sapply(CharVector, function(CharVar)
    substr(CharVar, (nchar(CharVar)-n+1), nchar(CharVar))
  )
}
## Some Desriptions in feature_df use BodyBody rather than Body. Correct This
features_df$V2<-sub("BodyBody","Body",features_df$V2)

## Search for Variables with names containing mean() or df()
TargetMeanVars<-grep("-mean\\(\\)",features_df[,2])
TargetStdVars<-grep("-std\\(\\)",features_df[,2])

## Now Parse out the components of the variables with mean() in them
MeanVars_df<-features_df[TargetMeanVars,]
MeanVars_df$BaseName<-sub("-[XYZ]","",sub("-mean\\(\\)","",MeanVars_df[,2]))
MeanVars_df$Stat<-"Mean"
MeanVars_df$Axis<-""
Axis_Recs<-grep("-[XYZ]",MeanVars_df$V2)

MeanVars_df$Axis[Axis_Recs]<-substrRight(MeanVars_df$V2[Axis_Recs],2)
MeanVars_df

StdVars_df<-features_df[TargetStdVars,]
StdVars_df$BaseName<-sub("-[XYZ]","",sub("-std\\(\\)","",StdVars_df[,2]))
StdVars_df$Stat<-"STD"
StdVars_df$Axis<-""
Axis_Recs<-grep("-[XYZ]",StdVars_df$V2)

StdVars_df$Axis[Axis_Recs]<-substrRight(StdVars_df$V2[Axis_Recs],2)

NewVarNames_df<-rbind(MeanVars_df,StdVars_df)
NewVarNames_df<-NewVarNames_df[order(NewVarNames_df$V1),]
head(NewVarNames_df)


## Step 2 Create a dataset data_df with only the mean and Standard Deviation Variables 
data_df<-X_df[,NewVarNames_df$V1]

## Step 4 Appropriately labels the data set with descriptive variable names. 
colnames(data_df)<-with(NewVarNames_df, {
  paste(BaseName,Axis,"_",Stat,sep="")
})
## Step 3 Uses descriptive activity names to name the activities in the data set
## Add an Activity Column to data_df with the name of the Activity
data_df$Activity<-activity_labels_df[y_df$V1,2]
## Add a Subject column to data_df with the number of the subject 
data_df$Subject<-subject_df$V1


## Step 5  creates a second, independent tidy data set with the average of each 
## variable for each activity and each subject.

TidyData_df<-(data_df %>% 
   group_by(Activity,Subject) %>% 
   summarise_each(funs(mean)))

write.table(TidyData_df,"TidyData.txt",row.names=FALSE,col.name=TRUE)
