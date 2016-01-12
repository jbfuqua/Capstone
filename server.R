# server.R

# 2016 Johns Hopkins Data Science Capstone Project
# Joe Fuqua


# Predict next word based on corpus from blogs, news feeds, and twitter

# Required libraries 

library(stringr)
library(R.utils)
library(tm)
library(rJava)
library(RWeka)
library(data.table)
library(DescTools)

# Load n-grams starting at highest allowable value of n (max=5), then
# decrease till a match is found
# if no match is found, display most frequent 1-gram

predWord <-function (txt) {

  if(txt=='*Your phrase here*') {return('please')}
# clean up
  
  txt<-tolower(txt)
  txt<-gsub("[^a-z///' ]", " ", txt)


# determine number of words in entered text
      
  numWords<-StrCountW(txt)
  if (numWords >= 4) {
    index<-5
    txt<-word(txt,-4,-1)}
  else {index<-numWords+1}

# cycle through n-grams and return prediction
  
  for (i in index:1) {

# build filenames and load data
    
    fileName<-paste('mc',i,'.txt',sep='')
    zipfileName<-paste('mc',i,'.zip',sep='')
    modelData<-read.table(unz(zipfileName, fileName),header=FALSE)
#    modelData<-as.data.table(modelData)
    
    if(index>1) {

# look for matching pattern and return results
      
      matchRows<-chmatch(word(txt,-(i-1),-1), 
                                 word(modelData[,2],1,i-1))
      
      if(!is.na(matchRows[1])) {return(word(modelData[matchRows[1],2],i))}
    }  
    else {return(as.character(modelData[1,2]))}
  }
}

shinyServer(
  function(input, output) {
      answer<-reactive({as.character(predWord(input$txt))})
      output$prediction<-renderText(answer())
  }
)