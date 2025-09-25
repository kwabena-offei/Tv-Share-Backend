class ImportPrimeOriginalsJob < ApplicationJob
  URLS = [
    'https://en.wikipedia.org/wiki/List_of_Amazon_Prime_Video_original_programming'
  ]

  HEADERS = {
    'User-Agent' => 'TvShareBot/1.0 (+https://example.com/contact)'
  }

  ALLOWED_CATEGORIES = Set.new([
    # "Original programming",
    "Drama",
    "Comedy",
    "Animation",
    "Adult animation",
    "Anime",
    "Kids & family",
    # "Non-English language scripted",
    # "German",
    # "Hindi",
    # "Japanese",
    # "Portuguese",
    # "Spanish",
    "Other",
    # "Unscripted",
    # "Docuseries",
    "Reality",
    "Variety",
    "Co-productions",
    "Continuations",
    # "Regional original programming",
    # "Drama",
    # "Original films",
    # "Feature films",
    # "Documentaries",
    # "Specials",
    # "Stand-up comedy specials",
    # "Upcoming original programming",
    # "Ordered",
    # "Continuations",
    # "In development",
    # "Upcoming original films",
    # "Feature films",
    # "Exclusive international distribution",
    # "TV shows",
    # "Drama",
    # "Comedy",
    # "Animation",
    # "Adult animation",
    # "Anime",
    # "Kids and family",
    # "Non-English language scripted",
    # "Continuations",
    # "Films",
    # "Upcoming",
    # "Pilots not picked up to series",
    # "Notes",
    # "References",
  ])

  FALLBACK_SECTION_HEADERS = Set.new([
    'Scripted',
    'Unscripted'
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

    ALLOWED_CATEGORIES.each do |category|
      header = doc.at(".mw-headline:contains('#{category}')")
      next unless header

      section = header.parent
      rows = section.css('~ .wikitable tr')
      rows.each do |tr|
        first_td = tr.at_css('td:first-child')
        next unless first_td

        title_text = first_td.at_css('i a')&.text || first_td.at_css('a')&.text || first_td.at_css('i')&.text || first_td.text
        title_text = (title_text[/^.*?(?=\[)/] || title_text).chomp.strip
        next if title_text.blank?

        id = title_text.parameterize
        next if seen_ids.include?(id)
        seen_ids << id

        import_show({ id: id, title: title_text })
        imported_count += 1
      end
    end

    if imported_count.zero?
      FALLBACK_SECTION_HEADERS.each do |header_text|
        header_node = doc.at(".mw-headline:contains('#{header_text}')")
        next unless header_node

        section = header_node.parent
        rows = section.css('~ .wikitable tr')
        rows.each do |tr|
          first_td = tr.at_css('td:first-child')
          next unless first_td

          title_text = first_td.at_css('i a')&.text || first_td.at_css('a')&.text || first_td.at_css('i')&.text || first_td.text
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

    if imported_count.zero?
      doc.css('.wikitable').each do |table|
        table.css('tr').each do |tr|
          first_td = tr.at_css('td:first-child')
          next unless first_td

          title_text = first_td.at_css('i a')&.text || first_td.at_css('a')&.text || first_td.at_css('i')&.text || first_td.text
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
      original_streaming_network: :prime,
      original_streaming_network_id: program[:id]
    })
    show.title = program[:title]
    show.save if show.tmsId.blank?
  end
end