class ImportNetflixOriginalsJob < ApplicationJob
  URLS = [
    'https://en.wikipedia.org/wiki/List_of_Netflix_original_programming'
  ]
  HEADERS = {
    'User-Agent' => 'TvShareBot/1.0 (+https://example.com/contact)'
  }

  ALLOWED_CATEGORIES = Set.new([
    'Drama',
    'Comedy',
    'Kids & family',
    'Animation',
    'Adult animation',
    'Anime',
    'Non-English language scripted',
    'Docuseries',
    'Reality',
    'Variety',
    'Continuations',
    'Specials',
    'One-time',
    'Episodic',
    'Co-productions'
  ])

  FALLBACK_SECTION_HEADERS = Set.new([
    'Scripted',
    'Unscripted',
    'Current programming',
    'Upcoming original programming',
    'Ended programming',
    'Regional original programming',
    'In development'
  ])

  queue_as :default

  def perform(*args)
    total_imported = 0
    seen_ids = Set.new

    URLS.each do |url|
      response = HTTParty.get(url, headers: HEADERS)
      body = response&.body.to_s
      next if body.empty?

      doc = Nokogiri::HTML(body)
      total_imported += import_from_wikipedia_doc(doc, seen_ids)
    end

    total_imported
  end

  def import_from_wikipedia_doc(doc, seen_ids)
    imported_count = 0

    # 1) Prefer specific category sections first
    ALLOWED_CATEGORIES.each do |category|
      header = doc.at(".mw-headline:contains('#{category}')")
      next unless header

      section = header.parent
      rows = section.css('~ .wikitable tr td:first-child')

      rows.each do |node|
        raw_text = node.text
        title = (raw_text[/^.*?(?=\[)/] || raw_text).chomp.strip
        next if title.blank?

        id = title.parameterize
        next if seen_ids.include?(id)
        seen_ids << id

        import_show({ id: id, title: title })
        imported_count += 1
      end
    end

    # 2) If nothing imported, scan broader section headers for lists/tables
    if imported_count.zero?
      FALLBACK_SECTION_HEADERS.each do |header_text|
        header_node = doc.at(".mw-headline:contains('#{header_text}')")
        next unless header_node

        node = header_node.parent.next_element
        while node && !%w[h1 h2].include?(node.name)
          if node.name == 'ul'
            node.css('li').each do |li|
              text = li.at('i a')&.text || li.at('a')&.text || li.at('i')&.text || li.text
              text = (text[/^.*?(?=\[)/] || text).chomp.strip
              next if text.blank?

              id = text.parameterize
              next if seen_ids.include?(id)
              seen_ids << id

              import_show({ id: id, title: text })
              imported_count += 1
            end
          elsif node['class'].to_s.include?('wikitable') || node.name == 'table'
            node.css('tr').each do |tr|
              first_td = tr.at_css('td:first-child')
              next unless first_td

              title_text = first_td.at_css('i a')&.text || first_td.at_css('i')&.text || first_td.at_css('a')&.text || first_td.text
              title_text = (title_text[/^.*?(?=\[)/] || title_text).chomp.strip
              next if title_text.blank?

              id = title_text.parameterize
              next if seen_ids.include?(id)
              seen_ids << id

              import_show({ id: id, title: title_text })
              imported_count += 1
            end
          end
          node = node.next_element
        end
      end
    end

    # 3) Final fallback: scan every wikitable on the page
    if imported_count.zero?
      doc.css('.wikitable').each do |table|
        table.css('tr').each do |tr|
          first_td = tr.at_css('td:first-child')
          next unless first_td

          title_text = first_td.at_css('i a')&.text || first_td.at_css('i')&.text || first_td.at_css('a')&.text || first_td.text
          title_text = (title_text[/^.*?(?=\[)/] || title_text).chomp.strip
          next if title_text.blank?

          id = title_text.parameterize
          next if seen_ids.include?(id)
          seen_ids << id

          import_show({ id: id, title: title_text })
          imported_count += 1
        end
      end
    end

    imported_count
  end

  def import_show(program)
    show = Show.find_or_initialize_by({
      original_streaming_network: :netflix,
      original_streaming_network_id: program[:id]
    })

    show.title = program[:title]
    show.save if show.tmsId.blank? # if it's already been matched, don't update
  end
end
