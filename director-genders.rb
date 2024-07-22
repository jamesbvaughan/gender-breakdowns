require 'dotenv/load'
require 'csv'
require 'nokogiri'
require 'http'

men = 0
women = 0

CSV.foreach('watched.csv', headers: true) do |movie|
  next if movie.header_row?

  movie_doc = Nokogiri::HTML(HTTP.follow.get(movie[3]).to_s)

  tmdb_id = movie_doc.at_xpath('/html/body/@data-tmdb-id')

  tmdb_movie_credits_url = "https://api.themoviedb.org/3/movie/#{tmdb_id}"\
                           "/credits?api_key=#{ENV['TMDB_API_KEY']}"

  movie_credits = JSON.parse HTTP.get(tmdb_movie_credits_url)

  if movie_credits['crew'].nil?
    puts "error getting director info for #{movie[1]}"
    next
  end

  movie_credits['crew'].each do |credit|
    next unless credit['job'] == 'Director'

    case credit['gender']
    when 1
      women += 1
    when 2
      men += 1
    else
      tmdb_person_url =
        "https://www.themoviedb.org/person/#{credit['id']}"
      puts "Unknown gender: #{credit['name']}, edit here: #{tmdb_person_url}"
    end
  end
end

puts "#{women} women, #{men} men"
