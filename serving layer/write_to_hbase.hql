create 'shahrm_movie', 'movie'

drop table if exists shahrm_movie;

create external table shahrm_movie(
  title string,
  year smallint,
  genre string,
  ratings bigint,
  votes bigint,
  director string,
  writer string)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ('hbase.columns.mapping' = ':key,movie:year,movie:genre,movie:ratings#b,movie:votes#b,movie:director,movie:writer')
TBLPROPERTIES ('hbase.table.name' = 'shahrm_movie');

insert overwrite table shahrm_movie
select primary_title,
  year, genre, total_ratings, num_votes,
  director_name, writer_name
from shahrm_movies_info;


create 'shahrm_movie_recom', 'recom'

drop table if exists shahrm_movie_recom;

create external table shahrm_movie_recom(
  genre string,
  title string,
  year smallint,
  rating float,
  votes bigint,
  director string,
  writer string,
  rank bigint)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ('hbase.columns.mapping' = ':key,recom:title,recom:year,recom:rating,recom:votes,recom:director,recom:writer,recom:rank')
TBLPROPERTIES ('hbase.table.name' = 'shahrm_movie_recom');

insert overwrite table shahrm_movie_recom
select genre, primary_title,
  year, avg_rating, num_votes,
  director_name, writer_name, genre_rank
from shahrm_movies_with_rank_10;

create 'shahrm_movie_recom_rotten', 'rotten'

drop table if exists shahrm_movie_recom_rotten;

create external table shahrm_movie_recom_rotten(
  genre string,
  title string,
  year smallint,
  director string,
  writer string,
  rating smallint,
  rank bigint,
  review string)
STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
WITH SERDEPROPERTIES ('hbase.columns.mapping' = ':key,rotten:title,rotten:year,rotten:director,rotten:writer,rotten:rating,rotten:rank,rotten:review')
TBLPROPERTIES ('hbase.table.name' = 'shahrm_movie_recom_rotten');

insert overwrite table shahrm_movie_recom_rotten
select genre, primary_title,
  year, director_name, writer_name, critic_rating, rotten_rank, critic_review
from shahrm_movies_rotten_rank_10;
