#! /usr/bin/env ruby
# Based on https://github.com/denten-bin/write-support

require 'yaml'

# Load in data sources & dump them to a new file.
data = {}
Dir.glob('data/*.yml') do |file|
  key = file.sub(/^data\//, "").sub(/\.yml$/, "")
  data[key] = YAML.load_file file
end
data["title"] = data["format"]["title"] # pandoc complains if no "title" is set.
File.open('metadata.yml', 'w') do |file|
  file.puts YAML::dump(data)
  file.puts "date: #{Time.now.strftime "%F"}" # set the date
  file.puts "---" # pandoc needs the trailing marker to understand the yaml is done
end

# Set the templates
if data["format"]["mode"] == "markdown"
  tex_template = "templates/tex.tex"
  html_template = "templates/html.html"
else
  raise "Formatting mode must be 'markdown'."
end

# Make a list of the sections files.
files = data["format"]["cv-sections"].map{ |section| "sections/#{section}.md" }.join " "

# Add templating information
tex_opts = "--template=#{tex_template} "
pdf_opts = "--pdf-engine=xelatex --template=#{tex_template} "
html_opts = "--template=#{html_template}"

tex_cmd = "pandoc -sr markdown+yaml_metadata_block \
  #{tex_opts} \
  'metadata.yml' \
  #{files} \
  -o docs/out.tex"
pdf_cmd = "pandoc -sr markdown+yaml_metadata_block \
  #{pdf_opts} \
  'metadata.yml' \
  #{files} \
  -o docs/#{data["format"]["pdf-options"]["filename"]}.pdf"
html_cmd = "pandoc -sr markdown+yaml_metadata_block \
  #{html_opts} \
  'metadata.yml' \
  #{files} \
  -o docs/index.html"

system tex_cmd
puts "Generated docs/out.tex"
system pdf_cmd
puts "Generated docs/#{data["format"]["pdf-options"]["filename"]}.pdf"
system html_cmd
puts "Generated docs/index.html"




