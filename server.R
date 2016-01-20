# server.R

# 2016 Johns Hopkins Data Science Capstone Project
# Joe Fuqua


# Predict next word based on corpus from blogs, news feeds, and twitter

# Required libraries 

library(stringr)
library(dplyr)
library(R.utils)
library(tm)
library(rJava)
library(RWeka)
library(data.table)
library(DescTools)
library(wordcloud)

# Load n-grams starting at highest allowable value of n (max=5), then
# decrease till a match is found
# if no match is found, display most frequent 1-gram

predWord <-function (txt) {
  
  # Text for initialization
  
  V3<-'please'
  V4<- 1
  
  returnWords<-data.frame(V3, V4, stringsAsFactors=FALSE)
  
  returnWords[2,1]<-' '
  returnWords[2,2]<-1
  
  if(txt=='*Your phrase here*') {return(returnWords)}
  
  # Clean up input text
  
  txt<-tolower(txt)
  txt<-gsub("[^a-z// ]", " ", txt)
  returnWords<-vector()
  
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
    zipfileName<-paste('mc',i,'_1.zip',sep='')
    modelData<-read.table(unz(zipfileName, fileName),header=FALSE)
    #    }
    
    # for (i in index:1) {
    
    if(index>1 && i>1) {
      
      # look for matching pattern and return results
      
      filterData<-modelData %>%
        filter(str_detect(word(modelData[,3],1,i-1),
                          paste('\\b',word(txt,-(i-1),-1),'\\b',sep='')))
      
      if(!is.na(filterData[1,3])) {
        
        filterData[,3]<-word(filterData[,3],-1)
        returnWords<-rbind(returnWords, filterData[,3:4])}
    }
    else if(is.na(filterData[1,3])) {
      V3<-as.character(word(modelData[1,3],-1))
      v4<-1
      oneGram<-data.frame(V3,V4)
      returnWords<-rbind(returnWords,oneGram)
    }
  }
  
  #  collapse unique values
  
  retDT <- data.table(returnWords, key="V3")
  retDT<-retDT[, list(V4=sum(V4)), by=V3]  
  
  returnWords<-as.data.frame(retDT)
  returnWords <- returnWords[order(returnWords$V4,decreasing = TRUE),]
  
  
  if(nrow(returnWords)<2) {
    V3<-as.character('*No more Identified*')
    v4<-1
    noGuess<-data.frame(V3,V4)
    returnWords<-rbind(returnWords,noGuess)}
  
  return(returnWords)
}

shinyServer(
  function(input, output) {
      answer<-reactive({as.data.frame(predWord(input$txt))})

      output$prediction<-renderText(answer()[1,1])

#      output$df_data<-renderTable(answer())
      
       
       output$others<-renderText(paste(
        answer()[2:min(nrow(answer()),5),1],collapse=', '))
      
      wdCloud <- repeatable(wordcloud)
      
      output$cloud <- renderPlot({
        wdCloud(answer()[,1], answer()[,2], scale=c(5,0.5),
                      min.freq = 0, max.words=20,
                      colors=brewer.pal(9, "Set1"))
  })
  }
)