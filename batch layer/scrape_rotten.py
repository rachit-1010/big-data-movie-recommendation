import pandas as pd
import regex as re
import requests
from bs4 import BeautifulSoup

def scrape_rotten(movies):
    rotten_toma = []
    for idx, value in enumerate(movies):
        movie = value[0]
        year = value[1]
        movie_cleaned = re.sub('[^A-Za-z0-9]+', '_', movie)
        headers = { "User-Agent" : "web scraper for classroom purposes shahrm@uchicago.edu" }
        # scrape rating
        base_movie_url = "https://www.rottentomatoes.com/m/" + movie_cleaned + "_" + year
        results = requests.get(base_movie_url, headers=headers)
        if results.status_code == 404:
            base_movie_url = "https://www.rottentomatoes.com/m/" + movie_cleaned
        responses = requests.get(base_movie_url)
        if responses.status_code == 200:
            soup = BeautifulSoup(results.text, "html")
            for element in soup.find_all("div", {"class": "col mob col-center-right col-full-xs mop-main-column"}):
                critic_rating = element.find("score-board").get("tomatometerscore")
                # make sure it has a rating
                if critic_rating != '':
                # scrape critic review
                    review_link = base_movie_url + "/reviews"
                    responses = requests.get(review_link, headers=headers)
                    sp = BeautifulSoup(responses.text, "html")
                    if sp.find("div", {"class": "the_review"}) is not None:
                        critic_review_latest = sp.find("div", {"class": "the_review"}).text
                    else:
                        critic_review_latest = 'NA'
                    rotten_toma.append((movie, year, critic_rating, critic_review_latest))

    # save as dataframe and clean the text
    rotten_toma_df = pd.DataFrame(rotten_toma)
    rotten_toma_df = rotten_toma_df.replace(r'\n',' ', regex=True) 
    rotten_toma_df = rotten_toma_df.replace(r'\r',' ', regex=True)
    rotten_toma_df = rotten_toma_df.set_axis(['primaryTitle', 'startYear', 'critic_rating', 'critic_review'], axis=1, inplace=False)

    return rotten_toma_df

if __name__ == "__main__":
    # we use movies in IMDb dataset to look for matched ratings in rotten tomatoes because the IMDb database contains 627251 movies
    # download data from https://datasets.imdbws.com/
    path = './title.basics.tsv'
    movie_df = pd.read_csv(path, sep='\t')
    # only movies are needed
    movie_df = movie_df[movie_df['titleType']=='movie']
    # use year and title to search in rotten tomatoes
    movie_year = list(zip(movie_df.primaryTitle, movie_df.startYear))
    # run scraper, the 627251 movie dataset is too large that it takes me several days to finish the scraping
    # the connection may be broken sometimes because too many requests are made, to better track the progress, you could add a tracker
    # I have posted the jupyter notebook I use to scrape the ratings for a better understanding of how the tracker works
    scrape_rotten(movie_year).to_csv('./rotten_tomato_data.csv')