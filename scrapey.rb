# Require the following
require "optparse"
require "fileutils"

# Globals
OUTPUT = 'files'

# Methods
def scrape_page(url)
  `cd #{OUTPUT} && wget -E -H -k -K -p -e robots=off #{url}`
end

def read_file(filename)
  buffer = File.read filename if File.exist? filename
end

def get_links(filename)
  read_file(filename).gsub(/<a href="(.+?)"/) if File.exist? filename
end

def find_files(directory)
  files = []
  Dir["#{OUTPUT}/#{directory}/**/*.html"].each{|s| files << s }
  files
end

def get_all_links(files)
  all_links = []
  files.each do |file|
    get_links(file).each do |link|
      all_links << link[9..-2]
    end
  end
  all_links.uniq!
end

class Array
  def get_all_sublinks(match)
    all_links_cleansed = []
    self.each do |link|
      all_links_cleansed << link if link.include? match
    end
    all_links_cleansed
  end
end

# Pull in options passed from the command line
options = {}
OptionParser.new do |opts|

  opts.banner = "Usage: ruby scrapey.rb [options]"

  opts.on('-u', '--url [NAME]',  'Scrape a specific URL')     { |v| options[:url] = v }
  opts.on('-t', '--tree [NAME]',  'Scrape any pages in subdirctories of a URL')     { |v| options[:tree] = v }

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
  end

end.parse!

# Option handling
if options[:url]
  # scrape_page(options[:url])
  # get_links("#{OUTPUT}/web.archive.org/web/20130126055416/http//jenniewalker.com/index.html").each do |link|
  #   puts link
  # end

  files = find_files("web.archive.org")

  all_links = get_all_links(files).get_all_sublinks options[:url]
  
  all_links.each do |link|
    scrape_page link
  end

end