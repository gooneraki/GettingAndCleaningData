library(RCurl)

if(!file.exists("./project")){
  dir.create("./project")
  fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileUrl,destfile="./project/Dataset.zip",method="curl")}

unzip(zipfile="./project/Dataset.zip",exdir="./project")

path_rf <- file.path("./project" , "UCI HAR Dataset")

#Merge the training and the test sets to create one data set.
x.train <- read.table(file.path(path_rf, "train" , "X_train.txt" ),header = FALSE)
x.test <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
x <- rbind(x.train, x.test)

y.train <- read.table(file.path(path_rf, "train" , "y_train.txt" ),header = FALSE)
y.test <- read.table(file.path(path_rf, "test" , "y_test.txt" ),header = FALSE)
y <- rbind(y.train, y.test)

subj.train <- read.table(file.path(path_rf, "train" , "subject_train.txt" ),header = FALSE)
subj.test <- read.table(file.path(path_rf, "test" , "subject_test.txt" ),header = FALSE)
subj <- rbind(subj.train, subj.test)

#Extract only the measurements on the mean and standard deviation for each measurement. 
features <- read.table(file.path(path_rf,  "features.txt" ),header = FALSE)
mean.sd <- grep("-mean\\(\\)|-std\\(\\)", features[, 2])
x.mean.sd <- x[, mean.sd]

#Use descriptive activity names to name the activities in the data set
names(x.mean.sd) <- features[mean.sd, 2]
names(x.mean.sd) <- tolower(names(x.mean.sd)) 
names(x.mean.sd) <- gsub("\\(|\\)", "", names(x.mean.sd))

activities <- read.table(file.path(path_rf,  "activity_labels.txt" ),header = FALSE)
activities[, 2] <- tolower(as.character(activities[, 2]))
activities[, 2] <- gsub("_", "", activities[, 2])

y[, 1] = activities[y[, 1], 2]
colnames(y) <- 'activity'
colnames(subj) <- 'subject'

# Appropriately label the data set with descriptive activity names.
data <- cbind(subj, x.mean.sd, y)
str(data)
write.table(data, './Project/merged.txt', row.names = F)

#Create a second, independent tidy data set with the average of each variable for each activity and each subject. 
average.df <- aggregate(x=data, by=list(activities=data$activity, subj=data$subject), FUN=mean)
average.df <- average.df[, !(colnames(average.df) %in% c("subj", "activity"))]
str(average.df)
write.table(average.df, './Project/average.txt', row.names = F)
