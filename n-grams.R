# n-grams.R

# This script loads all three data files, samples @ 10%,
# concatentates, and cleans the data.

# Then it generates 1-5 n-grams and saves to files for loading into the 
# shiny app.

# libraries

library(R.utils)
library(tm)
library(rJava)
library(RWeka)

set.seed(2)


# load and sample

if(!file.exists('samp_blogs.txt')) {
  con_blogs<-file('final/en_US/en_US.blogs.txt')
  blogs<- readLines(con_blogs)
  close(con_blogs)
  
  samp_size <- length(blogs)*.0025
  samp_blogs<-sample(blogs,samp_size)
  rm(blogs)
  
  writeLines(samp_blogs,'samp_blogs.txt')
} else {
  samp_blogs<-readLines('samp_blogs.txt')
}

if(!file.exists('samp_news.txt')) {
  con_news<-file('final/en_US/en_US.news.txt')
  news<- readLines(con_news)
  close(con_news)
  
  samp_size <- length(news)*.02
  samp_news<-sample(news,samp_size)
  rm(news)
  
  writeLines(samp_news,'samp_news.txt')
} else {
  samp_news<-readLines('samp_news.txt')
}

if(!file.exists('samp_twitter.txt')) {
  con_twitter<-file ('final/en_US/en_US.twitter.txt')
  twitter<- readLines(con_twitter)
  close(con_twitter)
  
  samp_size <- length(twitter)*.0025
  samp_twitter<-sample(twitter,samp_size)
  rm(twitter)
  writeLines(samp_twitter,'samp_twitter.txt')
} else {
  samp_twitter<-readLines('samp_twitter.txt')
}


# Merge & Cleanse

merged <- c(samp_blogs,samp_news,samp_twitter)
merged_corpus <- Corpus(VectorSource(merged))

merged_corpus<-tm_map( merged_corpus,tolower)

# Some entries have odd characters, this is the only way I've come up with
# to eliminate them, along with any non-letter/space

merged_corpus<-tm_map(merged_corpus, 
  function (txt) gsub("[^a-z///' ]", " ", txt))

#merged_corpus<-tm_map(merged_corpus, 
#  function (txt) sub("[^[a-z ] ]", "\\1", txt[grepl("[^[a-z ] ]", txt)]))

merged_corpus<-tm_map(merged_corpus, removeNumbers)
merged_corpus<-tm_map(merged_corpus, removePunctuation)
merged_corpus<-tm_map(merged_corpus,stripWhitespace)

# Remove profanity

profane_list<-read.table('swearWords.txt',sep='\n')
merged_corpus<-tm_map(merged_corpus, removeWords, profane_list$V1)

# Build n-grams (1-5)

mc1 <- NGramTokenizer(merged_corpus, Weka_control(min = 1, max = 1))
mc1_data <- data.frame(table(mc1))
mc1_data <- mc1_data[order(mc1_data$Freq,decreasing = TRUE),]

write.table(mc1_data, 'mc1.txt', sep='\t',col.names=FALSE)
zip('mc1.zip','mc1.txt')

mc2 <- NGramTokenizer(merged_corpus, Weka_control(min = 2, max = 2))
mc2_data <- data.frame(table(mc2))
mc2_data <- mc2_data[order(mc2_data$Freq,decreasing = TRUE),]

write.table(mc2_data, 'mc2.txt', sep='\t',col.names=FALSE)
zip('mc2.zip','mc2.txt')

mc3 <- NGramTokenizer(merged_corpus, Weka_control(min = 3, max = 3))
mc3_data <- data.frame(table(mc3))
mc3_data <- mc3_data[order(mc3_data$Freq,decreasing = TRUE),]

write.table(mc3_data, 'mc3.txt', sep='\t',col.names=FALSE)
zip('mc3.zip','mc3.txt')


mc4 <- NGramTokenizer(merged_corpus, Weka_control(min = 4, max = 4))
mc4_data <- data.frame(table(mc4))
mc4_data <- mc4_data[order(mc4_data$Freq,decreasing = TRUE),]

write.table(mc4_data, 'mc4.txt', sep='\t',col.names=FALSE)
zip('mc4.zip','mc4.txt')

mc5 <- NGramTokenizer(merged_corpus, Weka_control(min = 5, max = 5))
mc5_data <- data.frame(table(mc5))
mc5_data <- mc5_data[order(mc5_data$Freq,decreasing = TRUE),]

write.table(mc5_data, 'mc5.txt', sep='\t',col.names=FALSE)
zip('mc5.zip','mc5.txt')


