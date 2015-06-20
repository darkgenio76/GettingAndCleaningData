setwd("C:/Users/dargenios/Desktop/COURSES/Statistics And Data Analysis/Getting And Cleaning Data/R Project_Getting Data/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset")
train_path <- "C:/Users/dargenios/Desktop/COURSES/Statistics And Data Analysis/Getting And Cleaning Data/R Project_Getting Data/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/train/"
test_path <- "C:/Users/dargenios/Desktop/COURSES/Statistics And Data Analysis/Getting And Cleaning Data/R Project_Getting Data/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/test/"

#Load necessary libraries
library(dplyr)
library(data.table)
library(reshape2)
library(reshape)

#Create a data frame tbl with the training and set tests 
Training_Set <- tbl_df(read.table(paste(train_path ,"x_train.txt", sep = "")))
Test_Set <- tbl_df(read.table(paste(test_path ,"x_test.txt", sep = "")))

#Merge the two datasets (Accomplishes STEP 1)
merged_dataset <- rbind(Training_Set, Test_Set)

#Read the features file to name the 561 variables  
features <- read.table("features.txt")
features <- as.character(features[[2]])
setnames(merged_dataset,names(merged_dataset), features)

#Filter Only STD AND Mean Variables 
index1 <- grep("std",features,value=F)
index2 <- grep("mean",features,value=F)

#Create an Index to filter the dataset with only mean and STD variables
complete_index <- append(index1,index2)
filtered_dataset <- merged_dataset[complete_index]

#Read Subjects file and transform it in a vector
training_subjects <- tbl_df(read.table(paste(train_path ,"subject_train.txt", sep = "")))
training_subjects <- as.integer(training_subjects[[1]])
test_subjects <- tbl_df(read.table(paste(test_path ,"subject_test.txt", sep = "")))
test_subjects <- as.integer(test_subjects[[1]])

#Create merged_subjects variable
merged_subjects <- append(training_subjects, test_subjects)


#Read Activity IDs files 
training_activity_ids <- tbl_df(read.table(paste(train_path ,"y_train.txt", sep = "")))
test_activity_ids <- tbl_df(read.table(paste(test_path ,"y_test.txt", sep = "")))
training_activity_ids <- as.integer(training_activity_ids[[1]])
test_activity_ids <- as.integer(test_activity_ids[[1]])

#Create merged_activity variable
merged_activity_ids <- append(training_activity_ids, test_activity_ids)

#Add Subject and activity Ids Column to the Test and Train DFs
complete_merged_dataset <- mutate(filtered_dataset, subjects = merged_subjects, activity_ids = merged_activity_ids)

#Create Activity Labels Column, and merge it with the dataset (TO CHECK: MERGE REORDERS THE DATASET)
activity_labels <- read.table("C:/Users/dargenios/Desktop/COURSES/Statistics And Data Analysis/Getting And Cleaning Data/R Project_Getting Data/getdata-projectfiles-UCI HAR Dataset/UCI HAR Dataset/activity_labels.txt")
setnames(activity_labels, names(activity_labels[1]), "activity_ids")
setnames(activity_labels, names(activity_labels[2]), "ActivityLabels")
complete_merged_dataset_labeled <- merge(x=complete_merged_dataset, y=activity_labels, by = "activity_ids")

#Reorder the labeled dataset and remove the activity id column
reordered_merged_dataset_labeled <- complete_merged_dataset_labeled[c(81,82,2:80)]

#Create decriptive variable names by substituting acronyms with full words and removing other characters
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
#Melt the dataset for Analysis
#Create two id variables with the two categorical variables, and transform the measured variable names 
#into a categorical variable. 
MeltedDataset <- melt(reordered_merged_dataset_labeled,id=c("subjects","ActivityLabels"))
CastDataset <- cast(MeltedDataset, subjects + ActivityLabels~variable,mean)
write.table(CastDataset, "GettingAndCleaningData_SergioDargenio.txt",row.name=FALSE)





