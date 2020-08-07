json.results @shows
json.genre @genre

json.pagination do
  json.page_size @shows.limit_value
  json.current_page @shows.current_page
  json.total_pages @shows.total_pages
  json.next_page @shows.next_page
end
