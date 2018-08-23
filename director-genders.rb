require 'dotenv/load'
require 'csv'
require 'nokogiri'
require 'open-uri'
require 'http'
require 'json'
require 'date'

diary_file = 'diary.csv'

men = 0
women = 0
unknown = 0

def get_tmdb_person_by_id(id)
  tmdb_api_key = ENV['TMDB_API_KEY']
  HTTP.get("https://api.themoviedb.org/3/person/#{id}?api_key=#{tmdb_api_key}")
end

def get_director_info_from_movie_url(movie_url)
  movie_doc = Nokogiri::HTML(HTTP.get(movie_url).to_s)

  director_path = movie_doc.at_xpath('//a[@itemprop="director"]/@href')
  director_url = "https://letterboxd.com#{director_path}"
  director_doc = Nokogiri::HTML(HTTP.get(director_url).to_s)
  director_id = director_doc.at_css('.micro-button')['href'][/[0-9]+/]

  JSON.parse(get_tmdb_person_by_id(director_id))
end

CSV.foreach(diary_file, headers: true) do |movie|
  watched_over_a_year_ago = Date.parse(movie[6]) < Date.today.prev_year

  unless movie.header_row? || watched_over_a_year_ago
    movie_url = movie[3]
    movie_url.slice! "#{ENV['LETTERBOXD_USERNAME']}/"

    director = get_director_info_from_movie_url movie_url

    case director['gender']
    when 0
      puts "#{director['name']} (#{director['id']}): unknown"
      unknown += 1
    when 1
      women += 1
    when 2
      men += 1
    end
  end
end

puts "#{women} women, #{men} men, #{unknown} unknown"
