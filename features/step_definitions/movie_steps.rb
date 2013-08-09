# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.

    Movie.create(:title => movie[:title], :rating => movie[:rating], :release_date => movie[:release_date])

  end
  #flunk "Unimplemented"
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  e1.should <= e2
  #  ensure that that e1 occurs before e2.
  #  page.body is the entire content of the page as a string.
  #flunk "Unimplemented"
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  @rating_list = rating_list.split(", ")
  @rating_list.each do |rating|
    if uncheck
      step ("I uncheck \"ratings_#{rating}\"")
    else
      step ("I check \"ratings_#{rating}\"")
    end
  end
  #assert_equal uncheck, "un"
end

When /^(?:|I )press the "([^"]*)" button$/ do |button|
  step %Q(I press "ratings_#{button.downcase}")
end

Then /^I should (not )?see movies with the following ratings: (.*)$/ do |not_expected, rating_list|
  @rating_list = rating_list.split(", ")
  @movies = Movie.find_all_by_rating(@rating_list)
  if not_expected
    @movies.each do |movie|
      step %Q(I should not see "#{movie.title}")
    end
  else
    @movies.each do |movie|
      step %Q(I should see "#{movie.title}")
    end
  end
end

Then /^I should see all of the movies$/ do
  @num_movies_in_db = Movie.all.length
  @num_movies_on_page = page.body.split("<tr>").length - 2 # need to remove the head <tr> tag and subtract 1 for the extra split
  assert_equal @num_movies_in_db, @num_movies_on_page
end

Then /^I should see the movies sorted alphabetically$/ do
  @movie_table_rows = page.body.split("<tr>")[2..-1]       #returns an array of table rows (without the leading <tr> tag)
  @ordered_movie_titles = @movie_table_rows.map do |row|
    row[/[^>]*>([^<]*)/, 1]                              #isolates the movie title (by looking between the <td> and </td> tags)
  end
  @ordered_movie_titles.each do |movie|
    if @previous_movie
      step %Q(Then I should see "#{@previous_movie}" before "#{movie}")
      @previous_movie = movie
    else
      @previous_movie = movie
    end
  end
end

Then /^I should see the movies sorted by release date$/ do
  @movie_table_rows = page.body.split("<tr>")[2..-1]       #returns an array of table rows (without the leading <tr> tag)
  @ordered_release_dates = @movie_table_rows.map do |row|
    row[/(.*\n.*){2}\n[^>]*>([^<]*)/, 2]                   #isolates the release_date (strips first two lines, then looks for
  end                                                      #the content between the <td> and </td> tags)
  @ordered_release_dates.each do |date|
    if @previous_date
      step %Q(Then I should see "#{@previous_date}" before "#{date}")
      @previous_date = date
    else
      @previous_date = date
    end
  end
end
