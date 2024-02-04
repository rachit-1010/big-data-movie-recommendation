#!/bin/bash

curl https://datasets.imdbws.com/title.basics.tsv.gz | hdfs dfs -put - /tmp/shahrm/movie/data/title.tsv.gz

curl https://datasets.imdbws.com/title.crew.tsv.gz | hdfs dfs -put - /tmp/shahrm/movie/data/crew.tsv.gz

curl https://datasets.imdbws.com/title.ratings.tsv.gz | hdfs dfs -put - /tmp/shahrm/movie/data/rating.tsv.gz

curl https://datasets.imdbws.com/name.basics.tsv.gz | hdfs dfs -put - /tmp/shahrm/movie/data/name.tsv.gz

#unzip file
hdfs dfs -cat /tmp/shahrm/movie/data/title.tsv.gz | gunzip | hdfs dfs -put - /tmp/shahrm/movie/data/title/title.tsv

hdfs dfs -cat /tmp/shahrm/movie/data/crew.tsv.gz | gunzip | hdfs dfs -put - /tmp/shahrm/movie/data/crew/crew.tsv

hdfs dfs -cat /tmp/shahrm/movie/data/rating.tsv.gz | gunzip | hdfs dfs -put - /tmp/shahrm/movie/data/rating/rating.tsv

hdfs dfs -cat /tmp/shahrm/movie/data/name.tsv.gz | gunzip | hdfs dfs -put - /tmp/shahrm/movie/data/name/name.tsv
