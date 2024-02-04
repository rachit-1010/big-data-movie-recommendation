'use strict';
const http = require('http');
var assert = require('assert');
const express= require('express');
const app = express();
const mustache = require('mustache');
const filesystem = require('fs');
const url = require('url');
const port = Number(process.argv[2]);

const hbase = require('hbase')
var hclient = hbase({ host: process.argv[3], port: Number(process.argv[4]), encoding: 'latin1'})

function rowToMap(row) {
	var stats = {}
	row.forEach(function (item) {
		stats[item['column']] = item['$']
	});
	return stats;
}

function counterToNumber(c) {
	return Number(Buffer.from(c, 'latin1').readBigInt64BE());
}

app.use(express.static('public'));

app.get('/movies.html',function (req, res) {
	const title = req.query['title'];
	console.log(title);

	hclient.table('shahrm_movie').row(title).get(function (err, cells) {
		const movieInfo = rowToMap(cells);
		let movie_year = movieInfo['movie:year'];
		const movie_genre = movieInfo['movie:genre'];
		let movie_ratings = counterToNumber(cells[2]['$']);
		let movie_votes = counterToNumber(cells[3]['$']);
		let movie_director = movieInfo['movie:director'];
		let movie_writer = movieInfo['movie:writer'];
		function average_rating(cells) {
			if(movie_votes == 0)
				return 0;
			return (movie_ratings/movie_votes).toFixed(1); /* One decimal place */
		}

		hclient.table('shahrm_movie_recom').row(movie_genre).get(function (err, cells) {
			const movieRec = rowToMap(cells);
			let rec_title = movieRec['recom:title'];
			let rec_year = movieRec['recom:year'];
			let rec_rating = movieRec['recom:rating'];
			let rec_votes = movieRec['recom:votes'];
			let rec_rank = movieRec['recom:rank'];
			let rec_director = movieRec['recom:director'];
			let rec_writer = movieRec['recom:writer'];

		hclient.table('shahrm_movie_recom_rotten').row(movie_genre).get(function (err, cells) {
			const rottenRec = rowToMap(cells);
			let rot_title = rottenRec['rotten:title'];
			let rot_year = rottenRec['rotten:year'];
			let rot_rating = rottenRec['rotten:rating'];
			let rot_rank = rottenRec['rotten:rank'];
			let rot_director = rottenRec['rotten:director'];
			let rot_writer = rottenRec['rotten:writer'];
			let rot_review = rottenRec['rotten:review'];


				let template = filesystem.readFileSync("result.mustache").toString();
				let html = mustache.render(template, {
					title: req.query['title'],
					year: movie_year,
					genre: movie_genre,
					avg_rating: average_rating(movieInfo),
					votes: movie_votes,
					director: movie_director,
					writer: movie_writer,
					recom_title: rec_title,
					recom_year: rec_year,
					recom_rating: rec_rating,
					recom_votes: rec_votes,
					recom_rank: rec_rank,
					recom_director: rec_director,
					recom_writer: rec_writer,
					rotten_title: rot_title,
					rotten_year: rot_year,
					rotten_rating: rot_rating,
					rotten_rank: rot_rank,
					rotten_director: rot_director,
					rotten_writer: rot_writer,
					rotten_review: rot_review
				});
				res.send(html);
			});
		});
	});
});

/* Send simulated weather to kafka */
var kafka = require('kafka-node');
var Producer = kafka.Producer;
var KeyedMessage = kafka.KeyedMessage;
var kafkaClient = new kafka.KafkaClient({kafkaHost: process.argv[5]});
var kafkaProducer = new Producer(kafkaClient);

app.get('/rating.html',function (req, res) {
	var title_val = req.query['title'];
	var rating_val = req.query['rating'];

	var report = {
		title : title_val,
		rating : rating_val
	};

	console.log(report)

	kafkaProducer.send([{ topic: 'shahrm-public-rating', messages: JSON.stringify(report)}],
		function (err, data) {
			console.log(err);
			console.log(report);
			res.redirect('submit-rating.html');
		});
});

app.listen(port);
