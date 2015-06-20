#Getting and Cleaning Data Readme 
####By Sergio D'Argenio

##Introduction
The following instructions will let you reproduce the Getting and Cleaning Data Course Project from start to finish.


##Code Description
1. The first thing I do in the script, is to set the Working directory. Then, as I need to access three different directories to read all the files needed for the projects, I create a character vector with the paths to the other directories.
```
setwd("C:/Users/dargenios/Desktop/COURSES/Statistics And Data Analysis/Getting And Cleaning Data/R Project_Getting Data/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset")
```
2. Path to the train dataset directory
```
train_path <- "C:/Users/dargenios/Desktop/COURSES/Statistics And Data Analysis/Getting And Cleaning Data/R Project_Getting Data/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/train/"
```
3. Path to the test dataset directory
```
test_path <- "C:/Users/dargenios/Desktop/COURSES/Statistics And Data Analysis/Getting And Cleaning Data/R Project_Getting Data/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/test/"
```
4. We then load the necessary libraries. Maybe, one of the two between the reshape and reshape 2 
is not necessary, however, I was not familiar with the two packages and later in the code I used cast from reshape. 
```
library(dplyr)
library(data.table)
library(reshape2)
library(reshape)
```
5. In order to accomplish the first step, we need to read the two datasets (train, test). I create a tbl data frame (from dplyr) with the training and set tests. 
```
Training_Set <- tbl_df(read.table(paste(train_path ,"x_train.txt", sep = "")))
Test_Set <- tbl_df(read.table(paste(test_path ,"x_test.txt", sep = "")))
```

6.I then merge the two datasets using the rbind function. This Accomplishes STEP 1 of the project description:
Merges the training and the test sets to create one data set.
```
merged_dataset <- rbind(Training_Set, Test_Set)
```
7. For the next step we need to extract only the measurements on the mean and standard deviation for each measurement. At the moment the data frame we have created has undefined variable names, as the variable names are included in the file "features.txt". We can read this file, name the columns (I use setnames of the data.table package), and by using a regular expression we can create an index to the variables that only contain the mean and standard deviation measurement.Note: as the number of columns is not clearly stated, and various mean categories are available I simply included all the measurements captured by the regular expression grep("mean",features,value=F).
```  
features <- read.table("features.txt")
features <- as.character(features[[2]])
setnames(merged_dataset,names(merged_dataset), features)
index1 <- grep("std",features,value=F)
index2 <- grep("mean",features,value=F)
complete_index <- append(index1,index2)
```
8. We then use this index to subset the data frame. This Accomplishes step 2.  
```
filtered_dataset <- merged_dataset[complete_index]
```
9. Before proceeding to the next two steps, we need to add the subject column. As the dataset is already merged, I append the two files "subject_train.txt", "subject_test.txt" in the merged_subjects vector. I will add the column to the dataframe in a second Moment, as I still need to add the activity column as well.
```
training_subjects <- tbl_df(read.table(paste(train_path ,"subject_train.txt", sep = "")))
training_subjects <- as.integer(training_subjects[[1]])
test_subjects <- tbl_df(read.table(paste(test_path ,"subject_test.txt", sep = "")))
test_subjects <- as.integer(test_subjects[[1]])
merged_subjects <- append(training_subjects, test_subjects)
```
10. We also need to create the activity ID column, and that can be done in the same way as we did for the subjects.
```
training_activity_ids <- tbl_df(read.table(paste(train_path ,"y_train.txt", sep = "")))
test_activity_ids <- tbl_df(read.table(paste(test_path ,"y_test.txt", sep = "")))
training_activity_ids <- as.integer(training_activity_ids[[1]])
test_activity_ids <- as.integer(test_activity_ids[[1]])
merged_activity_ids <- append(training_activity_ids, test_activity_ids)
```
11. I then use the mutate function from dplyr to add activity Ids and subjects to the dataset (filtered_dataset) that was created at step 8.
```
complete_merged_dataset <- mutate(filtered_dataset, subjects = merged_subjects, activity_ids = merged_activity_ids)
```
12. Now we can proceed to step 3. To label the values we need to read the activity_labels.txt file and map its values to the activity ids.  I will use the merge function to map or "join" (to use the sql terminology) the data by using the activity ids columns, in order to do this I need to rename the column of the file we just read, so that its name matches the name of the column (activity_ids) of the dataset that we have been preparing. This will accomplish Step 3:
Uses descriptive activity names to name the activities in the data set
Note: As for the naming convention, I chose Camel case as I find it more easily readable, despite not being suggested by the lectures. As you can see in this article - The State of Naming Conventions in R, by Rasmus Baath - also the mentioned sources do not unanimously agree on the conventions to be used.
```
activity_labels <- read.table("C:/Users/dargenios/Desktop/COURSES/Statistics And Data Analysis/Getting And Cleaning Data/R Project_Getting Data/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/activity_labels.txt")
setnames(activity_labels, names(activity_labels[1]), "activity_ids")
setnames(activity_labels, names(activity_labels[2]), "activity_labels")
complete_merged_dataset_labeled <- merge(x=complete_merged_dataset, y=activity_labels, by = "activity_ids")
```
13. Here I briefly reorder the dataset to move the categorical variables in front, and to remove the activity_ids column as its content is basically a duplicate of the activity_labels.
```
reordered_merged_dataset_labeled <- complete_merged_dataset_labeled[c(81,82,2:80)]
```

14. Now, by using regular expressions, we can create decriptive variable names by substituting acronyms with full words, and thus accomplish step 4. I am not sure if there's a quicker way, but I reckon so. I tried with the stringr package but it did not work as I wanted.
```
names(reordered_merged_dataset_labeled ) <- gsub("^t","Time",names(reordered_merged_dataset_labeled )) 
names(reordered_merged_dataset_labeled ) <- gsub("^f","Frequency",names(reordered_merged_dataset_labeled )) 
names(reordered_merged_dataset_labeled ) <- gsub("Acc","Acceleration",names(reordered_merged_dataset_labeled )) 
names(reordered_merged_dataset_labeled ) <- gsub("Gyro","Gyroscope",names(reordered_merged_dataset_labeled )) 
names(reordered_merged_dataset_labeled ) <- gsub("Mag","Magnitude",names(reordered_merged_dataset_labeled )) 
names(reordered_merged_dataset_labeled ) <- gsub("std","StandardDeviation",names(reordered_merged_dataset_labeled )) 
names(reordered_merged_dataset_labeled ) <- gsub("mad","MedianAbsoluteDeviation",names(reordered_merged_dataset_labeled ))
names(reordered_merged_dataset_labeled ) <- gsub("sma","SignalMagnitudeArea",names(reordered_merged_dataset_labeled ))
names(reordered_merged_dataset_labeled ) <- gsub("iqr","InterquartileRange",names(reordered_merged_dataset_labeled ))
names(reordered_merged_dataset_labeled ) <- gsub("arCoeff","AutorRegresionCoefficients",names(reordered_merged_dataset_labeled ))
names(reordered_merged_dataset_labeled ) <- gsub("maxInds","MaxFrequencyIndex",names(reordered_merged_dataset_labeled ))
names(reordered_merged_dataset_labeled ) <- gsub("meanFreq","MeanFrequency",names(reordered_merged_dataset_labeled ))
names(reordered_merged_dataset_labeled ) <- gsub("mean","Mean",names(reordered_merged_dataset_labeled ))
names(reordered_merged_dataset_labeled ) <- gsub("\\(","",names(reordered_merged_dataset_labeled ))
names(reordered_merged_dataset_labeled ) <- gsub("\\)","",names(reordered_merged_dataset_labeled ))
names(reordered_merged_dataset_labeled ) <- gsub("-","",names(reordered_merged_dataset_labeled ))
```
15. It is time now to create the final tidy dataset with the average of each variable for each activity and each subject. By using the reshape package we can pivot the actual dataset to a long format (using the melt function) and then cast it in the wide format and at the same time we apply the average function. This accomplishes step 5 and closes the project, however please read the last note on the tidy format.
```
MeltedDataset <- melt(reordered_merged_dataset_labeled,id=c("subjects","activity_labels"))
CastDataset <- cast(MeltedDataset, subjects~activity_labels,mean)
write.table(CastDataset, "GettingAndCleaningData_SergioDargenio",row.name=FALSE)
```
16. From what I understand both the wide and long format should be good. In this case the tidy data principles should be respected as each variable is in a column and each observation is in a row (in this case an individual observation is constituted by the measurement taken for the quantitativa variables on one activity for one subject), and the dataframe can be easily tranformed. However, by reusing the melt function on the cast dataframe, the long format can be obtained.To read the table use this command: test <- read.table("GettingAndCleaningData_SergioDargenio.txt",header=T).
