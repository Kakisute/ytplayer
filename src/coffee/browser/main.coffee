request = require "superagent"
require('superagent-retry')(request)

key = 'AIzaSyAMo9pXJfO4aClAGbN0rOuO7QBvB435hdA'
part = 'snippet'

req =
    channelId: (username, callback) ->
        request
            .get 'https://www.googleapis.com/youtube/v3/channels'
            .retry 2
            .query 'part': part
            .query 'forUsername': username
            .query 'key': key
            .end callback

    playlists: (channelId, callback) ->
        request
            .get 'https://www.googleapis.com/youtube/v3/playlists'
            .query 'part': part
            .query 'channelId': channelId
            .query 'key': key
            .query 'maxResults': 50
            .end callback
            #.end (err, res) ->
                #console.log res.body.items.map (x, i) -> x.id

    playlistItems: (playlistId, callback) ->
        request
            .get 'https://www.googleapis.com/youtube/v3/playlistItems'
            .query 'part': part
            .query 'playlistId': playlistId
            .query 'key': key
            .query 'maxResults': 50
            .end callback

module.exports = req
