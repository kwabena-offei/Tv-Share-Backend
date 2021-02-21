## Profile Endpoints

> The following endpoints are paginated via the param: `?page=1`

### `GET` `/profile/reactions`

Returns comments that the logged in user has made

```json
{
	"pagination": {
		"current_page": 1,
		"total_pages": 4,
		"prev_page": null,
		"next_page": 2,
		"total_count": 96,
		"current_per_page": 25
	},
	"results": [{
		"id": 158,
		"text": "Comment text",
		"hashtag": null,
		"user_id": 2,
		"created_at": "2021-02-21T17:13:04.792Z",
		"updated_at": "2021-02-21T17:13:04.792Z",
		"show_id": 297458,
		"images": ["https://cdn.filestackcontent.com/2yl0RIYEQYuXaOG5MFCj"],
		"likes_count": 1,
		"sub_comments_count": 1,
		"videos": [],
		"shares_count": 0
	}]
}
```

### `GET` `/profile/favorites`

Returns shows the logged in user has favorited

```json
{
	"pagination": {
		"current_page": 1,
		"total_pages": 3,
		"prev_page": null,
		"next_page": 2,
		"total_count": 69,
		"current_per_page": 25
	},
	"results": [{
		"id": 6059,
		"tmsId": "SH003781390000",
		"title": "Big Brother",
		"seasonNum": 1,
		"episodeNum": 1,
		"shares_count": 0,
		"likes_count": 1,
		"comments_count": 2,
		"stories_count": 0,
		"activity_count": 3,
		"popularity_score": 0,
		"shortDescription": "Strangers, cut off from the outside world, coexist in an isolated house.",
		"seriesId": "188043",
		"rootId": 188043,
		"preferred_image_uri": "http://wewe.tmsimg.com/assets/p18592610_b_v5_aa.jpg",
		"episodeTitle": null
	}]
}
```

### `GET` `/profile/followers`

Returns users that follow the current user

```json
{
	"pagination": {
		"current_page": 1,
		"total_pages": 1,
		"prev_page": null,
		"next_page": null,
		"total_count": 1,
		"current_per_page": 25
	},
	"results": [{
		"id": 5,
		"username": "The Rock",
		"image": "https://m.media-amazon.com/images/M/MV5BMTkyNDQ3NzAxM15BMl5BanBnXkFtZTgwODIwMTQ0NTE@._V1_UX214_CR0,0,214,317_AL_.jpg",
		"bio": "Dwayne Douglas Johnson, also known as The Rock"
	}]
}
```

### `GET` `/profile/following`

Returns users that current user is following

```json
{
	"pagination": {
		"current_page": 1,
		"total_pages": 1,
		"prev_page": null,
		"next_page": null,
		"total_count": 1,
		"current_per_page": 25
	},
	"results": [{
		"id": 5,
		"username": "The Rock",
		"image": "https://m.media-amazon.com/images/M/MV5BMTkyNDQ3NzAxM15BMl5BanBnXkFtZTgwODIwMTQ0NTE@._V1_UX214_CR0,0,214,317_AL_.jpg",
		"bio": "Dwayne Douglas Johnson, also known as The Rock"
	}]
}
```

---

### `GET` `/likes`

This endpoint returns IDs (or TMS IDs) of records that the logged in user has liked.

A client could cache these values and refer to them when determining if the logged in user has liked a certain record.

> The "shows" array contains TMS IDs and series IDs.
```json
{
	"shows": ["SH001887100000", "184382", "SH027410230000", "14370517"],
	"comments": [7, 9, 11, 14, 5, 100],
	"sub_comments": [1, 35, 36],
	"stories": [577, 574, 546]
}
```
