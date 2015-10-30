React = require "react"
ReactDOM = require "react-dom"
remote = window.require "remote"
req = remote.require "./dest/js/browser/main"


App = React.createClass
    getInitialState: ->
        username: "AnimeSongCollabo"
        playing: ""
        playlistId: ""
        playlists: []
        player: null
        mode: "list" # 'loop' or 'list' or 'mylist'
        mylist: []

    componentDidMount: ->
        tag = document.createElement('script')
        tag.src = "https://www.youtube.com/iframe_api"
        firstScriptTag = document.getElementsByTagName('script')[0]
        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag)

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
                            id: x.snippet.resourceId.videoId
                            title: x.snippet.title
                            description: x.snippet.description.split("\n").map (l, i) -> <span key={i}>{l}</span>
                            thumbnail: x.snippet.thumbnails.default.url
                        playlists = this.state.playlists
                        playlists[i].playlistItems = playlistItems
                        this.setState playlists: playlists
                        if i == playlists.length-1
                            this.setState player: new YT.Player 'player',
                                height: '100'
                                width: '200'

                    ).bind this
                ).bind this
            ).bind this
        ).bind this
        return

    _onPlaylistItemClick: (index) ->
        mode = this.state.mode
        if mode == "loop"
            playlistItems = this.state.playlists[index[0]].playlistItems
            #this.setState playing: playing
            player = this.state.player
            console.log player
            player.cuePlaylist(playlistItems.map (x, i) -> x.id)
            player.setLoop true
            player.setVolume 10
            this.setState player: player
            return
        else if mode == "list"
            selected = this.state.playlists[index[0]].playlistItems[index[1]]
            mylist = this.state.mylist
            #if selected.description[0].props.children.indexOf "✖"
                #console.log "✖"
            mylist.push selected
            #else
                #console.log selected.description[0]
            this.setState mylist: mylist
            return
        else
            return

    _onAllPlay: ->
        mylist = this.state.mylist
        idList = []
        for i in [0..mylist.length-1]
            idList.push mylist[i].id
        console.log idList.length
        player = this.state.player
        player.cuePlaylist(idList)
        player.setLoop true
        player.setVolume 10
        this.setState player: player

    _onShuffle: ->
        player = this.state.player
        player.setShuffle true
        #player.setShuffle true

    render: ->
        <div>
            <div>
                <p>{this.state.playing.title}</p>
                {this.state.playing.description}
                <button onClick={this._onAllPlay}>ALLPlay</button>
                <button onClick={this._onShuffle}>Shuffle</button>
            </div>
            <div className="box">
                <div className="left">
                    <ul className="list">
                    {this.state.playlists.map ((x, i) ->
                        playlistItems = x.playlistItems.map ((x, j) ->
                            onPlaylistItemClick = this._onPlaylistItemClick.bind(this, [i, j])
                            return <li key={j} onClick={onPlaylistItemClick}><img src={x.thumbnail}></img>{x.description[0]}</li>
                        ).bind this
                        return <li key={i}><img src={x.thumbnail}></img>{x.title}<ul className="items">{playlistItems}</ul></li>
                    ).bind(this)}
                    </ul>
                </div>
                <div className="right">
                    <ul className="items">
                    {this.state.mylist.map (x, i) -> <li key={i}><img src={x.thumbnail}></img>{x.description[0]}</li>}
                    </ul>
                </div>
            </div>
        </div>

ReactDOM.render <App/>, document.getElementById "main"
