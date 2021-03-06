include Nanoc::Helpers::Rendering

def categories
    $categories ||= calculate_categories
end

def calculate_categories
    c = {}

    c["Software"] = with_tag("project")
    c["Documents"] = newest_first((with_tag("document") + with_tag("talk") + with_tag("paper")).uniq) - c.values.flatten
    c["Design"] = with_tag("art") - c.values.flatten
    c["Blog"] = things - c.values.flatten

    c
end

def things
    $things ||= calculate_things
end

def favs
    things.select{|i| i[:fav]}.sort_by{|i| i[:fav]}
end

def calculate_things
    newest_first(@items['/'].children.select{|i| i[:published]})
end

def link_to item, text=nil
    text = item[:title] if text.nil?
    "<a href=\"#{link_for(item)}\">#{text}</a>"
end

def tags
    things.select{|i| i[:tags]}.map{|i| i[:tags]}.flatten.uniq
end

def link_for item
    if item[:url]
        item[:url]
    else
        item.path
    end
end

def tags_for item, link=true
    item[:tags].map do |tag|
        if tag == "german"
            text = "<img class=\"flag\" src=\"/assets/images/de.svg\" alt=\"german\" />"
        else
            text = tag
        end
        if link
            "<a href=\"/tag/#{tag}/\">#{text}</a>"
        else
            text
        end
    end.join(", ")
end

def lang_for item
    if item[:tags] and item[:tags].include? "german"
        "de"
    else
        "en"
    end
end

def abstract_for item
    abstract = item.raw_content.split("\n").find{|line| not line.empty?}
    if abstract
        max_len = 30*2
        if abstract.size > max_len
            abstract[0..max_len-1]+"…"
        else
            abstract
        end
    else
        ""
    end
end

def thumbnail_for item
    if item[:thumbnail]
        item.path+item[:thumbnail]
    else
        candidates = item.children

        images = candidates.select{|c| c.path =~ Regexp.new("\.(png|jpg|svg|gif)$")}
        thumbnail = images.find{|i| i.path =~ Regexp.new("/thumbnail\....$")}
        return thumbnail.path if thumbnail

        pdfs = candidates.select{|c| c.path =~ Regexp.new("\.pdf$")}
        thumbnail = pdfs.find{|p| p.path =~ Regexp.new("talk")}
        return thumbnail.rep_named(:titlepage).path if thumbnail

        return images.first.path unless images.empty?

        return pdfs.first.rep_named(:titlepage).path unless pdfs.empty?

        return ""
    end
end

def with_tag tag
    things.select do |item|
        item[:tags] and item[:tags].include? tag
    end
end

def subtitle
    "morr.cc"
end

def domain
    "http://morr.cc/"
end

def box(items)
    ret = "<div class=\"boxes\">"
    items.each do |item|
        ret << render("box", {:item => item})
    end
    ret << "</div>"
    ret
end

def newest_first(items)
    items.sort_by{|i| i[:updated] || i[:published]}.reverse
end

def titlepage file, title, url=nil
    file = file.split(".").first
    link = url || "#{file}.pdf"
    "[![#{title}](#{file}-titlepage.svg)](#{link}){:.titlepage title=\"#{title}\"}"
end
