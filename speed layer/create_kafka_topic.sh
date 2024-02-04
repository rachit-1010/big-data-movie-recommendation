$ cd kafka_2.12-2.6.2/bin

# create a topic
$ kafka-topics.sh --create --zookeeper z-2.mpcs530142022.7vr20l.c19.kafka.us-east-1.amazonaws.com:2181,z-1.mpcs530142022.7vr20l.c19.kafka.us-east-1.amazonaws.com:2181,z-3.mpcs530142022.7vr20l.c19.kafka.us-east-1.amazonaws.com:2181 --replication-factor 1 --partitions 1 --topic shahrm-public-rating

