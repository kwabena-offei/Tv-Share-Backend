SELECT id,
  COALESCE(likes_count, 0) +
  COALESCE(sub_comments_count, 0) +
  COALESCE(shares_count, 0) AS score
FROM "comments"
WHERE (likes_count > 0 OR sub_comments_count > 0 OR shares_count > 0)
  AND status = 0
ORDER BY score DESC
