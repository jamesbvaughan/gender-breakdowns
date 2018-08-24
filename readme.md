Gender Breakdowns
===

This repo is a companion to my project where I am analyzing the gender
breakdown in the movies I watch, the music I listen to, and the books I read.

So far, I have looked at the genders of the directors of the movies I've been
watching. I also wrote [a blog post about it](https://jamesbvaughan.com/movie-director-genders). That post goes over the basics of how I used data that I have
been entering in to letterboxd to find the gender breakdown.

If you use Letterboxd and would like to try the same thing,
you are free to use the ruby script that I wrote for it!

1. [Export your Letterboxd data.](https://letterboxd.com/settings/data/)
2. Run `ruby director-genders.rb` in a directory containing:
   - [director-genders.rb](https://github.com/jamesbvaughan/gender-breakdowns/blob/master/director-genders.rb)
   - a `.env` file containing a `TMDB_API_KEY`
   - the `watched.csv` file that you got from your Letterboxd export
   The script may take a long time to run if you have a lot of movies,
   since it is making two HTTP requests per movie.
3. If you got any unknown results, go add genders to those directors on TMDB
and re-run the script.

Let me know if you have any issues and I'll try to help out!

Todo
---

- [x] support multiple directors per movie
