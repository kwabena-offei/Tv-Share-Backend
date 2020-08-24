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
    {
      type: :image,
      image_url: @show.preferred_image_uri,
      alt_text: @show.title
    },
  },
  {type: :divider},

]

json.blocks title_blocks
