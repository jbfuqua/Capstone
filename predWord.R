#predWord.R

# Predict the next word in a sentance

library(stringr)
library(R.utils)
library(tm)
library(rJava)
library(RWeka)
library(data.table)
library(DescTools)

# Load n-grams


predWord <-function (txt) {
  
  txt<-tolower(txt)
  txt<-gsub("[^a-z///' ]", " ", txt)
  
  numWords<-StrCountW(txt)
  if (numWords >= 4) {index<-5}
  else {index<-numWords+1}

  for (i in index:1) {
    
    fileName<-paste('mc',i,'.txt',sep='')
    zipfileName<-paste('mc',i,'.zip',sep='')

    modelData<-read.table(unz(zipfileName, fileName),header=FALSE)

    if(index>1) {
      
      matchRows<-modelData[grep (word(txt,-(i-1),-1), 
                               word(modelData[,2],1,i-1)),]
    
    if(!is.na(matchRows[1,2])) {return(word(matchRows[1,2],i))}
    }  
    else {return(as.character(modelData[1,2]))}
  }
}

testTxt<-'going'
print(predWord(testTxt))
