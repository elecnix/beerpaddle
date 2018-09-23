require 'csv'
require './models/beer'
require './models/brewery'

rows = CSV.table("beers.csv")

breweries = rows.reduce({}) do |b, row|
  name = row[:brewery]
  b[name] = b[name] || Brewery.new(name)
  b
end

beers = rows.map do |row|
  Beer.new(row[:name], breweries[row[:brewery]])
end

beers.each do |beer|
  print "#{beer.name}\t#{beer.brewery.name}\n"
end
