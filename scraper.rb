require 'nokogiri'
require 'faraday'
require 'byebug'
require 'addressable'
require 'json'

$index_url = 'http://macintoshgarden.org/games/9'
next_url = $index_url
index = Faraday.get($index_url)
doc = Nokogiri::HTML(index.body)

def url_join(relative_path)
    Addressable::URI.join($index_url, relative_path).to_s
end

def get_next_page_url(doc)
    link = doc.css("ul.pager a:contains('next')").first
    return url_join(link['href']) if link
end

def rating_to_f(rating_str)
    rating_str.gsub(/[^0-9\-\+\.]/, '').to_f
end

def votes_to_i(votes_str)
    votes_str.gsub(/[^0-9\-\+]/, '').to_i
end

def parse_entries(doc)
    doc.css("div.game-preview").map do |game|
        title = game.css("h2 > a").first
        table = game.css("div.descr > table > tr")
        {
            "title" => title.text.encode("utf-8", invalid: :replace, undef: :replace),
            "url" => url_join(title["href"]),
            "short_desc" => game.css("div.descr > p").first.text.encode("utf-8", invalid: :replace, undef: :replace),
            "rating" => rating_to_f(table[0].css("span.average-rating").text),
            "rating_votes" => votes_to_i(table[0].css("span.total_votes").text),
            "categories" => table[1].css("a[rel='tag']").map{ |tag| tag.text },
            "perspective" => table[2].css("a[rel='tag']").map{ |tag| tag.text },
            "year_released" => table[3].css("a[rel='tag']").map{ |tag| tag.text }.first.to_i,
            "author" => table[4].css("a[rel='tag']").map{ |tag| tag.text }
        }
    end
end

alphanum = 'a'
archive = []
page = 0
loop do
    entries = parse_entries(doc)
    archive += entries
    
    $stderr.puts "page: #{page}, archive size: #{archive.size}, url: #{next_url}"

    next_url = get_next_page_url(doc)
    if next_url.nil?
        if (alphanum.ord >= 'a'.ord && alphanum.ord < 'z'.ord) || (alphanum.ord >= '0'.ord && alphanum.ord < '9'.ord)
            alphanum = (alphanum.ord + 1).chr
        elsif alphanum.ord == 'z'.ord
            alphanum = '0'
        elsif alphanum.ord == '9'.ord
            alphanum = nil
        end
        if alphanum
            next_url = url_join("/games/" + alphanum) 
        end
    end
    break unless next_url
    break
    response = Faraday.get(next_url)
    doc = Nokogiri::HTML(response.body)
    page += 1
    sleep 1

    generated = JSON.pretty_generate(archive)
    File.open("archive.json", "w") do |file|
        file.write generated
    end
end

# Last write
generated = JSON.pretty_generate(archive)
File.open("archive.json", "w") do |file|
    file.write generated
end
