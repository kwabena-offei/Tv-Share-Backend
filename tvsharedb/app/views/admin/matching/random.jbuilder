title_blocks = [
  {
    type: :header,
    text: {
      type: :plain_text,
      text: [
        ":#{@show.original_streaming_network.downcase}: #{@show.title}",
        "(#{@show.entityType})"
      ].compact.join(' '),
      emoji: true
    },
  },
  {type: :divider}
]

other_blocks = @matches.first(5).flat_map do |match|
  [
    {
      type: :section,
      fields: [
        "*Title*: #{match.dig('program', 'title')}",
        "*Type*: #{match.dig('program', 'entityType')}",
        "*Year*: #{match.dig('program', 'releaseYear')}",
        "*Genres*: #{match.dig('program', 'genres')&.join(', ')}" || '',
        "*Description*: #{match.dig('program', 'shortDescription')}" || ''
      ].map do |content|
        {
          type: :mrkdwn,
          text: content
        }
      end,
      accessory: {
        type: :image,
        image_url: match.dig('program', 'preferredImage', 'uri'),
        alt_text: match.dig('program', 'title')
      }
    },
    {
      type: :actions,
      elements: [{
        type: :button,
        text: {
          type: :plain_text,
          text: "Create Match",
        },
        value: "#{@show.id}.#{match.dig('program', 'tmsId')}",
        style: :primary
        }]
      },
      type: :divider
    ]
  end

  json.blocks title_blocks + other_blocks
