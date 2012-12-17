require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'active_record'

# For database connection
ActiveRecord::Base.establish_connection(
                                        :adapter => "mysql2",
                                        :host => "localhost",
                                        :database => "ruby",
                                        :username => "root",
                                        :password => "admin"
                                       )

class Recipe < ActiveRecord::Base
end

limit = 5 # Limit value for the loop. Specify "nil" for getting all the records.

$array_one = [] # Array to get the entry urls

$data_hash = { } # Hash to get recipe details

# Saved URL in variables
base_url = 'http://www.simplyrecipes.com'
sub_url_word = "/recipes/ingredient/"

# Open outer page of indexes 
index_page = Nokogiri::HTML(open(base_url + "/index"))

# Fetch the URLs
index_page.xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "entry-content", " " ))]//p/a').each do | node |
  $array_one << node.text
end

# For limit condition
$filtered_data = ( (limit.nil?) ? $array_one : $array_one.first(limit))

$filtered_data.each do | name |
  $content_array = [] 

  puts "Name is : #{name}"

  # This will join the treamed url in sub_url
  sub_url =  base_url + sub_url_word + name.downcase.gsub(' ','_')
  
  # This wil scans the inner page of Recipes
  doc2 = Nokogiri::HTML(open(sub_url))
  doc2.xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "entry-title", " " ))]//a/@href').each do |node|
      $content_array << node.text
  end

  $content_array.each do | sub_sub_url |
    recipe_page= Nokogiri::HTML(open(sub_sub_url)) 
    
    # Fetching all the details from particular recipe
    $data_hash[:recipe_name] = recipe_page.css('h1[itemprop=name]').text
    $data_hash[:description] = recipe_page.css('div[itemprop=description]').text
    $data_hash[:header] = recipe_page.css('div.recipe-callout h2').text
    $data_hash[:prep_time] = recipe_page.css('.preptime').text
    $data_hash[:cook_time] = recipe_page.css('.cooktime').text
    $data_hash[:ingredients] = recipe_page.css('li.ingredient').text
    $data_hash[:instructions] = recipe_page.css('div[itemprop=recipeInstructions]').text
    $data_hash[:yield] = recipe_page.css('.yield').text

    # Inserting the Recipe details in the recipes table
    Recipe.create( :recipe_name => $data_hash[:recipe_name], 
                   :description => $data_hash[:description],
                   :header => $data_hash[:header],
                   :prep_time => $data_hash[:prep_time],
                   :cook_time => $data_hash[:cook_time],
                   :ingredients => $data_hash[:ingredients],
                   :instructions => $data_hash[:instructions] ,
                   :yield => $data_hash[:yield]                  
                   )

    puts "#{$data_hash[:recipe_name]} is added to database."
  end 
end
