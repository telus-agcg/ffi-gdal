require 'nokogiri'
require 'open-uri'

abort("Usage: extract_links URL DEST_DIR") if ARGV.size != 2

args = ARGV.dup
url = args[0]
dest_dir = args[1]

doc = Nokogiri::HTML(open(url))

hrefs = doc.css("a").map do |link|
  if (href = link.attr("href")) && !href.empty?
    URI::join(url, href)
  end
end.compact.uniq

Dir.mkdir(dest_dir) unless File.exist?(dest_dir)
Dir.chdir(dest_dir)

hrefs.each_with_index do |href, i|
  filename = href.path.split('/').last
  print "Downloading (#{i + 1}/#{hrefs.size}) #{filename}...\r"

  begin
    File.write(filename, open(href).read)
  rescue OpenURI::HTTPError => ex
    puts "Sonofa!"
    raise
  end
end

puts "\nAll done!"

#  puts(hrefs.join("\n"))
