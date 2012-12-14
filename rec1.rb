require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'active_record'

$arr1 = Array.new
$arr2 = Array.new

doc = Nokogiri::HTML(open('http://www.simplyrecipes.com/index/'))

doc.xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "entry-content", " " ))]//p/a/@href').each_with_index do |node, i|
   $arr2 << node.text
 end

doc.xpath('//*[contains(concat( " ", @class, " " ), concat( " ", "entry-content", " " ))]//p/a').each_with_index do |node, i|
   $arr1 << node.text
 end


$arr1.each do |a1|
puts a1
end


$arr2.each do |a2|
puts a2
end

ActiveRecord::Base.establish_connection(  
:adapter => "mysql",  
:host => "localhost",  
:database => "ruby",
:password => "admin" 
)

class Recipes < ActiveRecord::Base  
end 

while $j<200 do
$value_one=$arr1.at($j)
$value_two=$arr2.at($j)
Recipes.create(:recipe_name => $value_one,:recipe_link => $value_two)
$j +=1
end

