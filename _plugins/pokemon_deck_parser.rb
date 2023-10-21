# _plugins/pokemon_deck_parser.rb

Jekyll::Hooks.register :site, :post_read do |site|
  # Find deck list files in the _decks directory
  deck_list_files = Dir.glob(File.join(site.source, '_decks', '*.txt'))

  deck_list_files.each do |file|
    # Read the content of each deck list file
    deck_content = File.read(file)

    parsed_deck = parse_deck(deck_content)


    # Create a new page for each deck list file
    file_name_parts = File.basename(file, ".txt").split('_')
    
    year = file_name_parts.first
    title = file_name_parts.map(&:capitalize).join(" ")
    path =  year + "/" + file_name_parts.drop(1).join("-")

    image_name = file_name_parts.drop(1).join("-")

    generate_image(parsed_deck, year, image_name)

    deck_page = Jekyll::PageWithoutAFile.new(site, site.source, 'decks', path + ".html")
    deck_page.content = render_html(parsed_deck, image_name)

    # Specify a layout for the page (optional)
    deck_page.data['layout'] = 'deck_layout'
    deck_page.data['title'] = title

    # Add the new page to the site's pages collection
    site.pages << deck_page
  end
end

def generate_image(parsed_deck, year, filename)
  output = []
  parsed_deck.each do |category, cards|
    for card in cards
      unless card[:set].empty?
        output.append("#{card[:quantity]}%3A#{card[:set].upcase}-#{card[:id]}%211%7Eint*en")
      end
    end
  end
  data = "_token=&data=#{output.join("+")}&game=PTCG"
  cmd = `./download_image.sh "#{data}" "#{year}" "#{filename}"`
end


def render_html(parsed_deck, filename)
  # Generate HTML representation of the parsed deck


      html = "<div class='deck-list'>"

      html << "<img src='img/#{filename}.png'/>"

      parsed_deck.each do |category, cards|

        card_type_count = cards.sum {|h| h[:quantity].to_i }

        html << "<h2>#{category.capitalize} Cards (#{card_type_count})</h2>"
        html << "<ul>\n"

        for card in cards
          html << "<li>#{card[:quantity]} x #{card[:name]} <i style='font-size:12px;color:#cecece;'>(#{card[:set]} #{card[:id]})</i></li>\n"
        end

        html << "</ul>\n"
      end

      html << "</div>"
      html
end

def parse_deck(deck_content)
  parsed_deck = {
    'pokemon' => [],
    'trainer' => [],
    'energy' => []
  }

  current_category = nil

  deck_content.each_line do |line|
    line.chomp!  # Remove trailing newline

    # Check if the line indicates a category change
    if line.match?(/Pokémon \(\d+\)/)
      current_category = 'pokemon'
    elsif line.match?(/Trainer \(\d+\)/)
      current_category = 'trainer'
    elsif line.match?(/Energy \(\d+\)/)
      current_category = 'energy'
    else
      # Extract card name, quantity, set code, and card number
      match = line.match(/^(\d+)\s+(.+?)(?:\s+([A-Z\-]+)(?:\s+(\d+))?)?$/)
      if match
        card_quantity = "#{match[1]}"
        card_name = "#{match[2]}"
        card_set_id = "#{match[3]}"
        card_num = "#{match[4]}"

        parsed_deck[current_category].append({
          name: card_name,
          quantity: card_quantity,
          set: card_set_id,
          id: card_num
        })
      end
    end
  end

  parsed_deck
end