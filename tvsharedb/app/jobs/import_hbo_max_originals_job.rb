class ImportHboMaxOriginalsJob < ApplicationJob
  URLS = [
    'https://en.wikipedia.org/wiki/List_of_Max_original_programming',
    'https://en.wikipedia.org/wiki/List_of_HBO_Max_original_programming',
    'https://en.wikipedia.org/wiki/List_of_HBO_original_programming'
  ]
  HEADERS = {
    'User-Agent' => 'TvShareBot/1.0 (+https://example.com/contact)'
  }
  HBOMAX_COLLECTIONS_URL = 'https://www.hbomax.com/collections/originals'

  ALLOWED_CATEGORIES = Set.new([
    'Drama',
    'Drama series',
    'Comedy',
    'Comedy series',
    'Animation',
    'Adult animation',
    'Anime',
    'Kids & family',
    'Kids & family series',
    'Kids & family programming',
    'Docuseries',
    'Reality',
    'Variety',
    'Co-productions',
    'Continuations',
    'Original films',
    'Feature films',
    'Documentaries',
    'Specials',
    'Stand-up comedy specials'
  ])

  # Broader section headers that sometimes group categories
  FALLBACK_SECTION_HEADERS = Set.new([
    'Scripted',
    'Unscripted'
  ])

  queue_as :default

  def perform(*args)
    total_imported = 0
    global_seen_ids = Set.new

    URLS.each do |url|
      response = HTTParty.get(url, headers: HEADERS)
      body = response&.body.to_s
      next if body.empty?
      doc = Nokogiri::HTML(body)
      imported = import_from_wikipedia_doc(doc, global_seen_ids)
      total_imported += imported
    end

    # Supplement with HBO Max Originals collections page (server-rendered HTML)
    response = HTTParty.get(HBOMAX_COLLECTIONS_URL, headers: HEADERS)
    body = response&.body.to_s
    unless body.empty?
      doc = Nokogiri::HTML(body)
      total_imported += import_from_hbomax_collections(doc, global_seen_ids)
    end

    total_imported
  end

  def import_from_wikipedia_doc(doc, seen_ids)
    imported_count = 0

    ALLOWED_CATEGORIES.each do |category|
      originals_header = doc.at(".mw-headline:contains('#{category}')")
      next unless originals_header

      originals_section = originals_header.parent
      # Collect all subsequent wikitables under this category
      originals = originals_section.css('~ .wikitable tr td:first-child')

      originals.each do |node|
        # Removes citations from text. EX: [23]
        raw_text = node.text
        title = (raw_text[/^.*?(?=\[)/] || raw_text).chomp.strip
        next if title.blank?

        id = title.parameterize
        next if seen_ids.include?(id)
        seen_ids << id

        import_show({
          id: id,
          title: title
        })

        imported_count += 1
      end
    end

    # Try broader section headers if nothing imported yet
    if imported_count.zero?
      FALLBACK_SECTION_HEADERS.each do |header|
        header_node = doc.at(".mw-headline:contains('#{header}')")
        next unless header_node

        section = header_node.parent
        rows = section.css('~ .wikitable tr')
        rows.each do |tr|
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

    # Final fallback: scan all wikitables if still zero
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

  def import_from_hbomax_collections(doc, seen_ids)
    imported_count = 0

    # Prefer category sections near the main heading
    heading = doc.at('h1:contains("Original Shows"), h2:contains("Original Shows")')
    search_root = heading ? heading.parent : doc

    # Collect titles from lists following any h2/h3 under the search_root
    search_root.css('h2, h3').each do |hdr|
      node = hdr.next_element
      while node && !%w[h1 h2 h3].include?(node.name)
        if node.name == 'ul'
          node.css('li').each do |li|
            text = li.at('a')&.text || li.text
            next unless text
            title = text.gsub(/\s*\(HBO\)\s*/i, '').gsub(/\s*\(with ASL\)\s*/i, '').strip
            title = (title[/^.*?(?=\[)/] || title).chomp.strip
            next if title.blank?

            id = title.parameterize
            next if seen_ids.include?(id)
            seen_ids << id

            import_show({ id: id, title: title })
            imported_count += 1
          end
        end
        node = node.next_element
      end
    end

    imported_count
  end

  def import_show(program)
    show = Show.find_or_initialize_by({
      original_streaming_network: :hbo_max,
      original_streaming_network_id: program[:id]
    })

    show.title = program[:title]
    show.save if show.tmsId.blank? # if it's already been matched, don't update
  end
end
