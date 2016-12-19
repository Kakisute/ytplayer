React = require "react"
ReactDOM = require "react-dom"
req = require "../browser/main"

color =
    d0: "#CCCCCC"
    d1: "#8987FE"
    d2: "#5755B2"
    d3: "#363377"
    d4: "#18173C"
    d5: "#000001"

styles =
    flexbox:
        display: "flex"
        flexDirection: "row"
        justifyContent: "space-between"
        height: "560px"
    flexitem:
        flex: 1
    thumbnail:
        display: "inline-block"
        verticalAlign: "middle"
        width: "40px"
        height: "30px"
    thumbnailTitle:
        display: "inline-block"
        verticalAlign: "middle"
        paddingLeft: "5px"
    ul:
        listStyle: "none"
        backgroundColor: "#555"
    playlist:
        listStyle: "none"
        overflowY: "scroll"
        height: "560px"
        backgroundColor: "#555"
    myplaylist:
        listStyle: "none"
        overflowY: "scroll"
        height: "150px"
        backgroundColor: "#555"
    item:
        backgroundColor: color.d4
        color: color.d0
        height: "30px"
        fontSize: "10px"
        marginBottom: "1px"
        cursor: "pointer"
    itemHeader:
        backgroundColor: color.d5
        color: color.d0
        height: "30px"
        marginBottom: "1px"
        cursor: "pointer"
    description:
        backgroundColor: color.d5
        color: color.d0
        fontSize: "11px"
        overflowY: "scroll"
        height: "140px"
        padding: "10px"
    btnGroup:
        height: "50px"
    btn:
        backgroundColor: color.d4
        color: color.d0
        border: "2px #{color.d4} solid"
        fontSize: "16px"
        width: "133.3px"
        height: "50px"

App = React.createClass
    getInitialState: ->
        username: "AnimeSongCollabo"
        playlistId: ""
        playlists: []
        player: null
        mylist: []
        selected: null

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
                            description: x.snippet.description.split("\n").map (l) -> l
                            thumbnail: x.snippet.thumbnails.default.url
                        playlists = this.state.playlists
                        playlists[i].playlistItems = playlistItems
                        this.setState playlists: playlists
                        if i == playlists.length-1
                            this.setState player: new YT.Player 'player',
                                height: '200'
                                width: '400'

                    ).bind this
                ).bind this
            ).bind this
        ).bind this
        return

    _onPlaylistItemClick: (index) ->
        selected = this.state.playlists[index[0]].playlistItems[index[1]]
        mylist = this.state.mylist
        if (mylist.filter (x, i) -> x.id == selected.id).length != 0
            mylist = mylist.filter (x, i) -> x.id != selected.id
            this.setState mylist: mylist, selected: null
        else
            mylist.unshift selected
            this.setState mylist: mylist, selected: selected.description.map (l,i) -> <p key={i}>{l}</p>

    _onPlaylistClick: (index) ->
        playlistItems = this.state.playlists[index].playlistItems
        player = this.state.player
        player.cuePlaylist(playlistItems.map (x, i) -> x.id)
        player.setLoop true
        player.setVolume 5
        this.setState player: player, mylist: playlistItems

    _onAllPlay: ->
        mylist = this.state.mylist
        idList = []
        for i in [0..mylist.length-1]
            idList.push mylist[i].id
        console.log idList.length
        player = this.state.player
        player.cuePlaylist(idList)
        player.setLoop true
        player.setVolume 5
        this.setState player: player

    _onMylistItemClick: (index) ->
        mylist = this.state.mylist
        clicked = mylist[index]
        mylist = mylist.filter (x, i) -> x.id != clicked.id
        this.setState mylist: mylist

    _onShuffle: ->
        player = this.state.player
        player.setShuffle true

    _onClearMyList: ->
        this.setState mylist: []

    render: ->
        <div style={styles.flexbox}>
            <div style={styles.flexitem}>
                <div>
                    <ul style={styles.playlist}>
                    {this.state.playlists.map ((x, i) ->
                        playlistItems = x.playlistItems.map ((x, j) ->
                            onPlaylistItemClick = this._onPlaylistItemClick.bind(this, [i, j])
                            return (
                                <li key={j} onClick={onPlaylistItemClick}>
                                    <div style={styles.item}>
                                        <img style={styles.thumbnail} src={x.thumbnail}></img>
                                        <p style={styles.thumbnailTitle}>{x.description[0].replace(/を演奏してみました。/g, "")}</p>
                                    </div>
                                </li>
                            )
                        ).bind this
                        onPlaylistClick = this._onPlaylistClick.bind(this, i)
                        return (
                            <li key={i}>
                                <div style={styles.itemHeader} onClick={onPlaylistClick}>
                                    <img style={styles.thumbnail} src={x.thumbnail}></img>
                                    <p style={styles.thumbnailTitle}>{x.title}</p>
                                </div>
                                <ul style={styles.ul}>{playlistItems}</ul>
                            </li>
                        )
                    ).bind this}
                    </ul>
                </div>
            </div>
            <div style={styles.flexitem}>
                <div id="player"></div>
                <div style={styles.btnGroup}>
                    <button style={styles.btn} onClick={this._onAllPlay}>ALLPlay</button>
                    <button style={styles.btn} onClick={this._onShuffle}>Shuffle</button>
                    <button style={styles.btn} onClick={this._onClearMyList}>Clear</button>
                </div>
                <div style={styles.description}>
                    {this.state.selected}
                </div>
                <div>
                    <ul style={styles.myplaylist}> 
                    {this.state.mylist.map ((x, i) -> (
                        <li key={i} onClick={this._onMylistItemClick.bind(this, i)}>
                            <div style={styles.item}>
                                <img style={styles.thumbnail} src={x.thumbnail}></img>
                                <p style={styles.thumbnailTitle}>{x.description[0].replace(/を演奏してみました。/g, "")}</p>
                            </div>
                        </li>
                    )).bind this}
                    </ul>
                </div>
            </div>
        </div>

ReactDOM.render <App/>, document.getElementById "main"
