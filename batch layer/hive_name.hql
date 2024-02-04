drop table if exists shahrm_name_tsv;
create external table shahrm_name_tsv(
    nameid STRING,
    primaryname STRING,
    birthyear SMALLINT,
    deathyear STRING,
    primaryprofession STRING,
    knownfortitles STRING)
    row format serde 'org.apache.hadoop.hive.serde2.OpenCSVSerde'

WITH SERDEPROPERTIES(
   "separatorChar" = "\t",
   "quoteChar"     = "\""
)
STORED AS TEXTFILE
    location '/tmp/shahrm/movie/data/name'
TBLPROPERTIES("skip.header.line.count"="1");


create table shahrm_name(
    nameid STRING,
    primaryname STRING,
    birthyear SMALLINT,
    deathyear STRING,
    primaryprofession STRING,
    knownfortitles STRING)
    stored as orc;


insert overwrite table shahrm_name
select *
from shahrm_name_tsv
where nameid is not null and primaryname is not null;
