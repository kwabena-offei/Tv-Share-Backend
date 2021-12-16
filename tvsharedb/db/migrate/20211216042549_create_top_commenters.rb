class CreateTopCommenters < ActiveRecord::Migration[6.0]
  def change
    create_view :top_commenters, materialized: true
  end
end
