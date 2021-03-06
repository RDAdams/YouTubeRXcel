#' Search YouTube
#' 
#' Search for videos, channels and playlists. (By default, the function searches for videos.)
#' 
#' @param term Character. Search term; required; no default
#' @param max_results Maximum number of items that should be returned. Integer. Optional. Can be between 0 and 50. Default is 50.
#' Search results are constrained to a maximum of 500 videos if type is video and we have a value of \code{channel_id}.
#' @param channel_id Character. Only return search results from this channel; Optional.
#' @param channel_type Character. Optional. Takes one of two values: 'any' or 'show'. Default is 'any'
#' @param event_type Character. Optional. Takes one of three values: `completed', 'live' or 'upcoming'
#' @param location  Character.  Optional. Latitude and Longitude within parentheses, e.g. "(37.42307,-122.08427)"
#' @param location_radius Character.  Optional. e.g. "1500m", "5km", "10000ft", "0.75mi"
#' @param published_after Character. Optional. RFC 339 Format. For instance, "1970-01-01T00:00:00Z"
#' @param published_before Character. Optional. RFC 339 Format. For instance, "1970-01-01T00:00:00Z"
#' @param type Character. Optional. Takes one of three values: 'video', 'channel', or 'playlist'. Default is 'video'.
#' @param video_caption Character. Optional. Takes one of three values: 'any' (return all videos; Default), 'closedCaption', 'none'. Type must be set to video.
#' @param video_type Character. Optional. Takes one of three values: 'any' (return all videos; Default), 'episode' (return episode of shows), 'movie' (return movies)
#' @param video_syndicated Character. Optional. Takes one of two values: 'any' (return all videos; Default), 'true' (return only syndicated videos)
#' @param video_definition Character. Optional. Takes one of three values: 'any' (return all videos; Default), 'high' and 'standard'
#' @param video_license Character. Optional. Takes one of three values: 'any' (return all videos; Default), 'creativeCommon' (return videos with Creative Commons 
#' license), 'youtube' (return videos with standard YouTube license).
#' @param simplify Boolean. Return a data.frame if TRUE. Default is TRUE. If FALSE, it returns a list that carries additional information. 
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return data.frame with 7 elements: publishedAt, channelId, title, description, thumbnails, channelTitle, liveBroadcastContent
#' 
#' @export
#' 
#' @references \url{https://developers.google.com/youtube/v3/docs/search/list}
#' 
#' @examples
#' \dontrun{
#' yt_search(term="Barack Obama")
#' }

yt_search <- function (term=NULL, max_results=50, channel_id= NULL, channel_type=NULL, type="video", event_type=NULL, location= NULL, location_radius=NULL, 
	published_after=NULL, published_before=NULL, video_definition = "any", video_caption="any", video_license="any", video_syndicated="any", video_type="any", 
	simplify=TRUE,...) {

	if (is.null(term)) stop("Must specify a search term")
	if (max_results < 0 | max_results > 50) stop("max_results only takes a value between 0 and 50")
	if (!(video_license %in% c("any", "creativeCommon", "youtube"))) stop("video_license can only take values: any, creativeCommon, or youtube")
	if (!(video_syndicated %in% c("any", "true"))) stop("video_syndicated can only take values: any or true")
	if (!(video_type %in% c("any", "episode", "movie"))) stop("video_type can only take values: any, episode, or movie")
	if (!is.null(published_after))  if (is.na(as.POSIXct(published_after, format="%Y-%m-%dT%H:%M:%SZ"))) stop("The date is not properly formatted in RFC 339 Format")
	if (!is.null(published_before)) if (is.na(as.POSIXct(published_before, format="%Y-%m-%dT%H:%M:%SZ"))) stop("The date is not properly formatted in RFC 339 Format")

	if (type!="video") video_caption = video_license = video_definition = video_type = video_syndicated= NULL

	yt_check_token()

	# For queries with spaces
	term = paste0(unlist(strsplit(term, " ")), collapse="%20")

	querylist <- list(part="snippet", q = term, maxResults=max_results, channelId=channel_id, type=type, channelType=channel_type, eventType= event_type, 
		location= location, publishedAfter=published_after, publishedBefore=published_before, videoDefinition = video_definition, videoCaption= video_caption, 
		videoType=video_type, videoSyndicated=video_syndicated, videoLicense= video_license)

	res <- tuber_GET("search", querylist, ...)


	resdf <- NA

	if (identical(simplify, TRUE)) {

		if (res$pageInfo$totalResults != 0) {
			simple_res  <- lapply(res$items, function(x) x$snippet)
			resdf       <- as.data.frame(do.call(rbind, simple_res))
		} else {
			resdf <- 0
		}

		return(resdf)
	}

	# Cat total results
	cat("Total Results", res$pageInfo$totalResults, "\n")

	return(res)
}
