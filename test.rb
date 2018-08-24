require 'dotenv/load'
require 'csv'
require 'nokogiri'
require 'http'
require 'json'

diary_file = 'watched.csv'
tmdb_api_key = ENV['TMDB_API_KEY']

men = 0
women = 0
unknown = 0
count = 0

CSV.foreach(diary_file, headers: true) do |movie|
  next if movie.header_row?

  movie_url = movie[3]

  movie_doc = Nokogiri::HTML(HTTP.get(movie_url).to_s)

  movie_tmdb_id = movie_doc.at_xpath('/html/body/@data-tmdb-id')

  tmdb_url = "https://api.themoviedb.org/3/movie/#{movie_tmdb_id}/credits"

  movie_credits = JSON.parse HTTP.get("#{tmdb_url}?api_key=#{tmdb_api_key}")

  if movie_credits.nil?
    puts "error getting director info for #{movie[1]}"
    next
  end

  movie_credits['crew'].each do |credit|
    next unless credit['job'] == 'Director'

    case credit['gender']
    when 0
      puts "#{credit['name']} (#{credit['id']}): unknown"
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
