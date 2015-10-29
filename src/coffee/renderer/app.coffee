React = require "react"
ReactDOM = require "react-dom"
remote = window.require "remote"
req = remote.require "./dest/js/browser/main"


App = React.createClass
    getInitialState: ->
        username: "AnimeSongCollabo"
        channelId: ""
        playlistId: ""
        playlists: []

    componentDidMount: ->
        req.channelId this.state.username, ((err, res) ->
            this.setState channelId: res.body.items[0].id

            req.playlists this.state.channelId, ((err, res) ->
                this.setState playlists: res.body.items.map (x, i) ->
                    id: x.id
                    title: x.snippet.title
                    thumbnail: x.snippet.thumbnails.default.url
                    playlistItems: []

                this.state.playlists.map ((x, i) ->
                    req.playlistItems x.id, ((err, res) ->
                        playlistItems = res.body.items.map (x, j) ->
                            id: x.id
                            title: x.snippet.title
                            description: x.snippet.description
                            thumbnail: x.snippet.thumbnails.default.url
                        playlists = this.state.playlists
                        playlists[i].playlistItems = playlistItems
                        this.setState playlists: playlists
                    ).bind this
                ).bind this
            ).bind this
        ).bind this
        return

    _onPlaylistItemClick: (index) ->
        console.log this.state.playlists[index[0]].playlistItems[index[1]]
        return

    render: ->
        <div>
            <div>
                <ul>
                {this.state.playlists.map ((x, i) ->
                    playlistItems = x.playlistItems.map ((x, j) ->
                        onPlaylistItemClick = this._onPlaylistItemClick.bind(this, [i, j])
                        return <li key={j} onClick={onPlaylistItemClick}><img src={x.thumbnail}></img>{x.title}</li>
                    ).bind this
                    return <li key={i}><img src={x.thumbnail}></img>{x.title}<ul>{playlistItems}</ul></li>
                ).bind(this)}
                </ul>
            </div>
        </div>

ReactDOM.render <App/>, document.getElementById "main"
