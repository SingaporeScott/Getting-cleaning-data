### Assumes UCI HAR Dataset is set as working directory ###
setwd("~/Desktop/UCI HAR Dataset")

###Loads Libraries to be used###
library(readr)
library(dplyr)
#######
rm(list=ls())

### Sets common labels for both data sets ###
var_names <- as.list(read_lines("~/Desktop/UCI HAR Dataset/features.txt"))
activity_label <- as.list(read_lines("~/Desktop/UCI HAR Dataset/activity_labels.txt"))
######

### Loading train data ###
Train_activities_number <- as.list(read_lines("~/Desktop/UCI HAR Dataset/train/y_train.txt"))
Train_activities_number <-gsub("1",activity_label[1], Train_activities_number) # changing y.train to activity label
Train_activities_number <-gsub("2",activity_label[2], Train_activities_number) # changing y.train to activity label
Train_activities_number <-gsub("3",activity_label[3], Train_activities_number) # changing y.train to activity label
Train_activities_number <-gsub("4",activity_label[4], Train_activities_number) # changing y.train to activity label
Train_activities_number <-gsub("5",activity_label[5], Train_activities_number) # changing y.train to activity label
Train_activities_number <-gsub("6",activity_label[6], Train_activities_number) # changing y.train to activity label

Train_participant_no <- as.list(read_lines("~/Desktop/UCI HAR Dataset/train/subject_train.txt"))
Train_data <- read.table("~/Desktop/UCI HAR Dataset/train/X_train.txt")
names(Train_data) <- var_names

Train_data$Participant_no = Train_participant_no
Train_data$Activities = Train_activities_number
train <- data.frame(Train_data) #train data.frame
######

### Loading test data (Y refers to test Data)###
Test_activities_number <- as.list(read_lines("~/Desktop/UCI HAR Dataset/test/y_test.txt"))
Test_activities_number <-gsub("1",activity_label[1], Test_activities_number) #changing y.test to activity label
Test_activities_number <-gsub("2",activity_label[2], Test_activities_number) #changing y.test to activity label
Test_activities_number <-gsub("3",activity_label[3], Test_activities_number) #changing y.test to activity label
Test_activities_number <-gsub("4",activity_label[4], Test_activities_number) #changing y.test to activity label
Test_activities_number <-gsub("5",activity_label[5], Test_activities_number) #changing y.test to activity label
Test_activities_number <-gsub("6",activity_label[6], Test_activities_number) #changing y.test to activity label

Test_participant_no <- as.list(read_lines("~/Desktop/UCI HAR Dataset/test/subject_test.txt"))
Test_data <- read.table("~/Desktop/UCI HAR Dataset/test/X_test.txt")
names(Test_data) <- var_names

Test_data$Participant_no = Test_participant_no
Test_data$Activities = Test_activities_number

test <- data.frame(Test_data) #test data.frame
######


### Merging test and train data together ###
merged_data <- merge(train, test, all=TRUE)
######

### Subsetting all with mean and std out
var_names <- names(merged_data)
indexer <- grep("mean()|std()|Activities|Participant_no", var_names) #this comes with mean freq
remove_freq <- grep( "meanFreq", var_names) #this gets the index for meanfreq values
clean_indexer <- indexer[!(indexer %in% remove_freq)] #this index only has mean and std without mean freq
######

### Extracts only the measurements on the mean and standard deviation for each measurement###
trimmed_data <- merged_data[,clean_indexer] 
###### 

### Appropriately label names of variables ###
new_vars <- as.list(read_lines("~/Desktop/UCI HAR Dataset/new_vars.txt"))
names(trimmed_data) <- new_vars
trimmed_data <- trimmed_data[,c(67:68,1:66)] #brings participant and activity number to the front
######
final_output <- list()

for (i in 1:30){
  participant_dat <-trimmed_data[(trimmed_data[,1] == i),]
  activity_label <- as.list(read_lines("~/Desktop/UCI HAR Dataset/activity_labels.txt"))
  output_results = list()
  for (j in activity_label){
    activity_dat = participant_dat[(participant_dat[,2] == j),]
    activity_dat =  activity_dat[,3:68] ## Takes away partricipant and activity column to mean data
    output = activity_dat %>% summarise_all(funs(mean))
    output_results[[j]] = output
  }
  ### Combine data and add activity names ###
  activities_by_participant = do.call(rbind, output_results)
  final_output[[i]] <- activities_by_participant
}


tidy_data = do.call(rbind, final_output)
participants <- rep(1:30,6)
tidy_data$Participants = sort(participants) ## adding back participant number after summarizing data
tidy_data$Activities = rep(unlist(activity_label), 30)
tidy_data <- tidy_data[,c(67:68,1:66)]
write.table(tidy_data,"finaltidydata.txt",sep="\t",row.names=FALSE)




