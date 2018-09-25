require 'csv'
require './models/beer'
require './models/brewery'
require "prawn"
Prawn::Font::AFM.hide_m17n_warning = true

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
    text_box "Nom:", :at => [0, bounds.height], :size => 10
    line [30, bounds.height - 8], [200, bounds.height - 8]
    text_box "Date: 29 septembre 2018", :at => [210, bounds.height], :size => 10
    stroke
    text_rendering_mode(:fill_stroke) do
      fill_color "ffffff"
      stroke_color "000000"
      text_box "#{index+1}", :at => [bounds.width - 30, bounds.height + 10], :size => 30, :styles => [:bold]
    end
    fill_color "000000"
    move_down 10
    page.each do |beer|
      top_margin = bottom_margin = 5
      left_margin = right_margin = 5
      columns = 3
      bounding_box([0, cursor - top_margin], :width => bounds.width, :height => 110) do
        stroke_color "000000"
        stroke_bounds
        bounding_box([left_margin, cursor - top_margin], :width => bounds.width - left_margin - right_margin, :height => bounds.height) do
          float do
            bounding_box([bounds.width / columns + left_margin, cursor], :width => bounds.width / columns * 2) do
              text_box "#{beer.description}", :height => 60, :size =>8, :overflow => :shrink_to_fit
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
          stroke_color "aaaaaa"
          stroke do
            horizontal_rule
          end
          bounding_box([0, cursor], :width => bounds.width, :height => cursor - left_margin - bottom_margin) do
            text_box "Notes", :at => [0, bounds.height - top_margin], :size => 10
          end
        end
      end
    end
  end
end
