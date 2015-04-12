## Hardcoded variables
online_zip_data = "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
local_zip_data = "~/assignment_data_01.zip"
csv_data = "household_power_consumption.txt"

startDate = as.Date("01/02/2007", format="%d/%m/%Y")
endDate = as.Date("02/02/2007", format="%d/%m/%Y")

####################### Fetches zip file and unzips if it isn't available #########################################
### If either download or unzip fails exit program ###
if (!(file.exists(csv_data))) {
	print ("File doesn't exist. Attempting download.")
	download_status = download.file( online_zip_data, local_zip_data,method = "curl")
	if (download_status != 0) {
 		stop("Error: File did not download. Download manually")
	}
	unzip_status = try(system(paste("unzip ",local_zip_data,"")))
	if (unzipstatus != 0) {
		stop("File did not unzip. Unzip manually")
	}
}

#######################  Extract relevant lines from .txt to a dataframe #########################################
### Using options to reduce the memory footprint and time taken to read file and write to a data frame ####
## I could also only read the lines from the database into the dataframe that meet the criteria but I am using subset here
initial = read.table(csv_data, header = T, sep=";",stringsAsFactors=F,na.strings="?",nrows = 100)
classes = sapply(initial, class)
power_dataframe = read.csv(csv_data, header=T, sep=";", na.strings="?", colClasses = classes, nrows = 2000000, comment.char = "")

### Convert dates to Date class instances so date comparisons becomes easy###
power_dataframe$Date = as.Date(power_dataframe$Date, format="%d/%m/%Y")

### Extract/subset required data based on date comparisons###
power_dataframe = power_dataframe[power_dataframe$Date >= startDate & power_dataframe$Date <= endDate, ]

## An extra data+time column in needed for these plots.
## But I do the data subset by date as earlier. Using the time of day for this uses up unnecessary memory and cycle time 
## I then convert the date and day and to POSIXct so plotting works as it should
## I could also use strptime() but I wanted to play with this
power_dataframe$timestamp = as.POSIXct(paste(as.character(power_dataframe$Date), power_dataframe$Time), format="%Y-%m-%d %H:%M:%S")

######################## Creating the plot ########################################################################
png(filename="plot3.png", width=480, height=480)
plot(power_dataframe$timestamp, power_dataframe$Sub_metering_1, type="l", xlab="", ylab="Energy sub metering")
lines(power_dataframe$timestamp, power_dataframe$Sub_metering_2, col="red")
lines(power_dataframe$timestamp, power_dataframe$Sub_metering_3, col="blue")
legend("topright", legend=c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), col=c("black", "red", "blue"), lwd=par("lwd"))
dev.off()
