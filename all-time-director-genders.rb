require 'dotenv/load'
require 'csv'
require 'nokogiri'
require 'open-uri'
require 'http'
require 'json'
require 'date'

diary_file = 'watched.csv'

men = 0
women = 0
unknown = 0
count = 0

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
  unless movie.header_row?
    movie_url = movie[3]

    begin
      director = get_director_info_from_movie_url movie_url
    rescue NoMethodError
      puts "Error finding director info for #{movie[1]}"
      next
    end

    case director['gender']
    when 0
      puts "#{director['name']} (#{director['id']}): unknown"
      unknown += 1
    when 1
      women += 1
    when 2
      men += 1
    end

    count += 1

    puts "#{women} women, #{men} men, #{unknown} unknown, #{count} total"
  end
end

