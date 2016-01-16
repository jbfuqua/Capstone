# reProcess.R
# This script loads all three data files sample data files and trims the number
# of n-grams saved, based on frequency and strips the sparser terms

# libraries

#library(R.utils)
#library(tm)
#library(rJava)
#library(RWeka)

library(stringr)
library(dplyr)
library(R.utils)

#set.seed(2)


# load and sample and rewrite

for (i in 1:5) {
  
  # build filenames and load data
  
  fileName<-paste('mc',i,'.txt',sep='')
  zipfileName<-paste('mc',i,'.zip',sep='')
  outfileName<-paste('mc',i,'_1.zip',sep='')
  modelData<-read.table(unz(zipfileName, fileName),header=FALSE)
  if(i==1){
    write.table(modelData[1,], 'mc1.txt', sep='\t',col.names=FALSE)
    zip('mc1_1.zip','mc1.txt')
    
    }
  else {
    
#    separate last words into a separate column to streamline processing
    
    modelData<-modelData[modelData[,3]>2,]
    
#    modelData[,4]<-lapply(modelData[,2],word,start=-1)
    
    write.table(modelData[modelData[,3]>2,], fileName, sep='\t',col.names=FALSE)
    zip(outfileName,fileName)
    
  }
}  
