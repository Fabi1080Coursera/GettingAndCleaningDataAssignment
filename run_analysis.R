# This is a script to convert the data of the assignment of the Coursera Course "Getting an cleaning data" to a tidy dataset.
# Please refere to the Codebook.md file for further information.

###### What this script does
# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each measurement.
# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive variable names.
# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Edit this variable if needed
pathtodata = "../UCI HAR Dataset"

# Load tables
x_train <- read.table(file.path(pathtodata, "train", "X_train.txt")) 
y_train <- read.table(file.path(pathtodata, "train", "y_train.txt")) 
subject_train <- read.table(file.path(pathtodata, "train", "subject_train.txt")) 

x_test <- read.table(file.path(pathtodata, "test", "X_test.txt")) 
y_test <- read.table(file.path(pathtodata, "test", "y_test.txt")) 
subject_test <- read.table(file.path(pathtodata, "test", "subject_test.txt")) 

activity_labels <- read.table(file.path(pathtodata, "activity_labels.txt"))
features <-  read.table(file.path(pathtodata, "features.txt"))

# merge test and train in their tables
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
subject_data <- rbind(subject_train, subject_test)

rm(x_train,y_train, subject_train, x_test, y_test, subject_test)

# better colnames
colnames(activity_labels) = c("activityid", "activity")
colnames(features) = c("featureid", "feature")

colnames(subject_data) <- c("subjectid")
colnames(y_data) <- c("activityid")
colnames(x_data) <- features$feature



# set activity names in lower case instead of ids
y_data <- merge(y_data, activity_labels, by="activityid")
y_data$activityid <- NULL
y_data$activity <- tolower(y_data$activity)

# merge to one table
data <- cbind(subject_data, y_data, x_data)

rm(activity_labels, subject_data, x_data, y_data)

# only keep the measurements on the mean and standard deviation
features_avg_mean <- features[grep(".(mean\\(\\)|std\\(\\)).", features$feature),]

data <- data[,c("subjectid", "activity", as.character(features_avg_mean$feature))]

# edit colnames to only contain plain letters
features_avg_mean$feature <- gsub("-", "", as.character(features_avg_mean$feature))
features_avg_mean$feature <- gsub("\\(", "", as.character(features_avg_mean$feature))
features_avg_mean$feature <- gsub(")", "", as.character(features_avg_mean$feature))

colnames(data)[3:50] <- features_avg_mean$feature


# create an extra tidy dataset to only contain the averages per subject and activity
library(dplyr)
data_averages <- data %>%
  group_by(subjectid, activity) %>%
  summarise_each(funs(mean))


write.table(data_averages, "data_averages.txt", row.names = FALSE) 
