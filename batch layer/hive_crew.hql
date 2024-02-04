drop table if exists shahrm_crew_tsv;
create external table shahrm_crew_tsv(
    titleid STRING,
    directors STRING,
    writers STRING)
    row format serde 'org.apache.hadoop.hive.serde2.OpenCSVSerde'

WITH SERDEPROPERTIES(
   "separatorChar" = "\t",
   "quoteChar"     = "\""
)
STORED AS TEXTFILE
    location '/tmp/shahrm/movie/data/crew'
TBLPROPERTIES("skip.header.line.count"="1");

create table shahrm_crew(
    titleid STRING,
    directors STRING,
    writers STRING)
    stored as orc;

insert overwrite table shahrm_crew
select *
from shahrm_crew_tsv
where directors is not null and writers is not null;
