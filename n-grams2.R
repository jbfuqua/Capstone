# n-grams.R

# This script loads all three data files, samples @ 10%,
# concatentates, and cleans the data.

# Then it generates 1-5 n-grams and saves to files for loading into the 
# shiny app.

# This is a second attempt using the quanteda package

# libraries

library(R.utils)
library(quanteda) # using both quanteda (ngrams) and tm (cleaning)
library(tm) # more comfortable with tm data cleaning
library(rJava)
library(RWeka)
library(data.table)

set.seed(2)


# load and sample

if(!file.exists('samp_blogs.txt')) {
  con_blogs<-file('final/en_US/en_US.blogs.txt')
  blogs<- readLines(con_blogs)
  close(con_blogs)
  
  samp_size <- length(blogs)*.10
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
  
  samp_size <- length(news)*.10
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
  
  samp_size <- length(twitter)*.10
  samp_twitter<-sample(twitter,samp_size)
  rm(twitter)
  writeLines(samp_twitter,'samp_twitter.txt')
} else {
  samp_twitter<-readLines('samp_twitter.txt')
}


# Merge & Cleanse

merged <- c(samp_blogs,samp_news,samp_twitter)
merged_corpus <- Corpus(VectorSource(merged))
merged_corpus<-tm_map( merged_corpus,content_transformer(tolower))

# Some entries have odd characters, this is the only way I've come up with
# to eliminate them, along with any non-letter/space

merged_corpus<-tm_map(merged_corpus, 
                 content_transformer(function (txt) gsub("[^a-z///' ]", " ", txt)))

# Everything but letters and spaces should be gone, but just to be safe...

merged_corpus<-tm_map(merged_corpus, removeNumbers)
merged_corpus<-tm_map(merged_corpus, removePunctuation)
merged_corpus<-tm_map(merged_corpus,stripWhitespace)

# Remove profanity

profane_list<-read.table('swearWords.txt',sep='\n')
merged_corpus<-tm_map(merged_corpus, removeWords, profane_list$V1)

merged_corpus<-corpus(as.VCorpus(merged_corpus))

# Build n-grams (1-5)

for (i in 1:5) {
  merged_token <-tokenize(merged_corpus, what='sentence', concatenator=' ')
  merged_ngram <- sapply(merged_token, 
                         function(mdfm) quanteda::tokenize(mdfm, ngrams=i, 
                                              concatenator=" "))
  merged_ngram <- table(unlist(merged_ngram))
  merged_ngram<-data.table(words=names(merged_ngram),Freq=as.integer(merged_ngram))
  merged_ngram <- merged_ngram[order(merged_ngram$Freq,decreasing = TRUE),]
  
  fileName<-paste('mc',i,'.txt',sep='')
  zipfileName<-paste('mc',i,'.zip',sep='')
  write.table(merged_ngram, fileName, sep='\t',col.names=FALSE)
  zip(zipfileName,fileName)
}
