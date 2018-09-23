require 'csv'
require './models/beer'
require './models/brewery'
require "prawn"

rows = CSV.table("beers.csv")

breweries = rows.reduce({}) do |b, row|
  name = row[:brewery]
  b[name] = b[name] || Brewery.new(name)
  b
end

beers = rows.map do |row|
  Beer.new(row[:name], breweries[row[:brewery]], row[:type], row[:abv], row[:ibu], row[:description])
end

beers.each do |beer|
  print "#{beer.name}\t#{beer.brewery.name}\n"
end

Prawn::Document.generate("out.pdf") do
  beers.each_slice(6).each_with_index do |page, index|
    if (index != 0) then
      start_new_page
    end
    page.each do |beer|
      top_margin = bottom_margin = 5
      left_margin = right_margin = 5
      columns = 3
      bounding_box([0, cursor - top_margin], :width => bounds.width, :height => 110) do
        #stroke_bounds
        bounding_box([left_margin, cursor - top_margin], :width => bounds.width - left_margin - right_margin, :height => bounds.height) do
          float do
            bounding_box([bounds.width / columns, cursor - top_margin], :width => bounds.width / columns * 2) do
              text "#{beer.description}"
            end
          end
          font("Helvetica", :style => :bold, :size => 15) do
            text_box beer.name, :width => bounds.width / columns, :height => 20, :overflow => :shrink_to_fit
          end
          move_down 18
          bounding_box([0, cursor], :width => bounds.width / columns) do
            font("Helvetica", :style => :bold, :size => 12) do
              text_box beer.brewery.name, :width => bounds.width, :height => 20, :overflow => :shrink_to_fit
            end
          end
          move_down 14
          bounding_box([0, cursor], :width => bounds.width / columns) do
            formatted_text [{ :text => "#{beer.type}", :styles => []}]
          end
          bounding_box([0, cursor], :width => bounds.width / columns) do
            text "#{beer.abv || 'N/A'}%  #{beer.ibu || 'N/A'} IBU"
          end
          bounding_box([0, cursor], :width => bounds.width, :height => cursor - left_margin - bottom_margin) do
            text_box "Notes", :at => [left_margin, bounds.height - top_margin], :size => 10
            stroke_color "aaaaaa"
            stroke_bounds
          end
        end
      end
    end
  end
end
