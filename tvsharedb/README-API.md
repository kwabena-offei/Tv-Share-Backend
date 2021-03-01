## Profile Endpoints

These endpoints can be accessed in two ways. If you want information based on the currently logged in user use `/profile/reactions`. If you want information for a particular user use `/users/:username/reactions`.

> Paginated endpoints are paginated via the param: `?page=1`

### `GET` `/profile/reactions`
### `GET` `/users/:username/reactions`

Returns comments the user has made

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
### `GET` `/users/:username/favorites`

Returns shows the user has favorited

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
### `GET` `/users/:username/followers`

Returns users that follow the user

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
### `GET` `/users/:username/following`

Returns users that user is following

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

### `GET` `/comments`
Comments can be returned for a program (via ID or TMS ID) or a news story. One of the following parameters is required:  
> - `GET` `/comments?tms_id=abc` (Program comments)
> - `GET` `/comments?show_id=123` (Program comments)
> - `GET` `/comments?story_id=456` (Story comments)

```json
{
	"pagination": {
		"current_page": 1,
		"total_pages": 1,
		"prev_page": null,
		"next_page": null,
		"total_count": 1,
		"current_per_page": 50
	},
	"results": [{
		"id": 123,
		"text": "Comment",
		"show_id": null,
		"story_id": 3049,
		"images": [],
		"videos": [],
		"created_at": "2021-02-22T04:02:49.802Z",
		"likes_count": 0,
		"sub_comments_count": 1,
		"shares_count": 0,
		"created_at_formatted": "about 19 hours",
		"current_user_liked": false,
		"current_user_replied": false,
		"likes_count_by_followed_users": 0,
		"user": {
			"id": 5,
			"username": "The Rock",
			"image": "https://m.media-amazon.com/images/M/MV5BMTkyNDQ3NzAxM15BMl5BanBnXkFtZTgwODIwMTQ0NTE@._V1_UX214_CR0,0,214,317_AL_.jpg"
		}
	}]
}
```

### `GET` `/comments/123`
Returns a single comment
> Note: The "replies" section is deprecated. To get sub_comments use the following endpoint: `/sub_comments?comment_id=123`


```json
{
	"id": 123,
	"text": "hio",
	"show_id": null,
	"story_id": 3049,
	"images": [],
	"videos": [],
	"created_at": "2021-02-22T04:02:49.802Z",
	"likes_count": 1,
	"sub_comments_count": 1,
	"shares_count": 1,
	"created_at_formatted": "about 19 hours",
	"current_user_liked": false,
	"current_user_replied": false,
	"likes_count_by_followed_users": 0,
	"user": {
		"id": 5,
		"username": "The Rock",
		"image": "https://m.media-amazon.com/images/M/MV5BMTkyNDQ3NzAxM15BMl5BanBnXkFtZTgwODIwMTQ0NTE@._V1_UX214_CR0,0,214,317_AL_.jpg"
	},
	"shares": [{
		"created_at_formatted": "5 months",
		"username": "funkparliament",
		"user_image": "https://cdn.filestackcontent.com/p3xfiY8GSTCAQqrQkSSB"
	}],
	"likes": [{
		"created_at_formatted": "about 20 hours",
		"username": "funkparliament",
		"user_image": "https://cdn.filestackcontent.com/p3xfiY8GSTCAQqrQkSSB"
	}],
	"replies": [{
		"id": 30,
		"text": "Hi",
		"images": [],
		"videos": [],
		"created_at_formatted": "about 19 hours",
		"username": "The Rock",
		"user_image": "https://m.media-amazon.com/images/M/MV5BMTkyNDQ3NzAxM15BMl5BanBnXkFtZTgwODIwMTQ0NTE@._V1_UX214_CR0,0,214,317_AL_.jpg"
	}]
}
```

### `POST` `/comments`
Creates a comment from the logged in user.
> A `show_id` or `story_id` parameter is required.

##### Request:

```json
{
  "comment": {
    "text": "comment",
    "show_id": "123",
    "story_id": null,
    "images": ["http://media.com/image.jpg"],
    "videos": ["http://media.com/video.mov"]
  }
}
```

##### Response:
```json
{
	"id": 1234,
	"text": "comment",
	"show_id": 123,
	"story_id": null,
  "images": ["http://media.com/image.jpg"],
  "videos": ["http://media.com/video.mov"],
	"created_at": "2021-02-22T23:45:59.324Z",
	"likes_count": 0,
	"sub_comments_count": 0,
	"shares_count": 0,
	"created_at_formatted": "less than a minute",
	"current_user_liked": false,
	"current_user_replied": false,
	"likes_count_by_followed_users": 0,
	"user": {
		"id": 123,
		"username": "user",
		"image": null
	},
	"shares": [],
	"likes": [],
}
```


### Sub Comments
### `GET` `/sub_comments`
Comments can be returned for a comment or a sub_comment. One of the following parameters is required:  
> - `GET` `/sub_comments?comment_id=123`
> - `GET` `/sub_comments?sub_comment_id=456`

```json
{
	"pagination": {
		"current_page": 1,
		"total_pages": 1,
		"prev_page": null,
		"next_page": null,
		"total_count": 2,
		"current_per_page": 50
	},
	"results": [{
		"id": 123,
		"text": "Comment",
		"images": [],
		"videos": [],
		"created_at": "2021-02-23T00:16:52.005Z",
		"likes_count": 0,
		"sub_comments_count": 0,
		"shares_count": 0,
		"created_at_formatted": "less than a minute",
		"user": {
			"id": 123,
			"username": "user",
			"image": null
		}
	}]
}

```

### `GET` `/sub_comments/123`

```json
{
	"id": 123,
	"text": "Comment",
	"images": [],
	"videos": [],
	"created_at": "2021-02-23T00:16:52.005Z",
	"likes_count": 0,
	"sub_comments_count": 0,
	"shares_count": 0,
	"created_at_formatted": "less than a minute",
	"user": {
		"id": 123,
		"username": "user",
		"image": null
	}
}

```

### `POST` `/sub_comments`
Creates a sub_comment from the logged in user.
> A `comment_id` or `sub_comment_id` parameter is required.

##### Request:

```json
{
	"sub_comment": {
		"text": "Sub comment",
		"comment_id": 123,
		"sub_comment_id": null,
		"images": ["http://media.com/image.jpg"],
		"videos": ["http://media.com/video.mov"]
	}
}
```

##### Response:
```json
{
	"id": 123,
	"text": "Sub comment",
	"comment_id": 123,
	"user_id": 123,
	"created_at": "2021-02-23T00:29:43.484Z",
	"updated_at": "2021-02-23T00:29:43.484Z",
	"shares_count": 0,
	"sub_comment_id": null,
	"likes_count": 0,
	"sub_comments_count": 0,
  "images": ["http://media.com/image.jpg"],
  "videos": ["http://media.com/video.mov"]
}
```



---

## Reset Password Endpoints

### `GET` `/password_reset/exists?email=test@example.com`

Returns `status 200` if account exists or `status 404` if it does not.


### `POST` `/password_reset/generate`

Generates a password reset token that is valid for 3 days and sends an email to the user with a link to the password reset page.

The user is directed to this link: `https://gotvchat.com/reset_password/:password_reset_token`

Returns `status 200` if the request was successful or `status 404` if the account could not be found.

##### Request:

```json
{
  "email": "test@example.com"
}
```

### `POST` `/password_reset/save`

Updates the password for the user account.

Returns `status 200` if the request was successful or `status 404` if the token was invalid or expired.

##### Request:

```json
{
  "token": "123",
	"password": "new_password",
	"password_confiramtion": "new_password"
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

---

### `GET` `/users/:username`

This endpoint returns information about a user. It uses the `username` (not ID) for lookups.

> The "shows" array contains TMS IDs and series IDs.
```json
{
	"username":"funkparliament",
	"image":"https://cdn.filestackcontent.com/p3xfiY8GSTCAQqrQkSSB"}
}
```
