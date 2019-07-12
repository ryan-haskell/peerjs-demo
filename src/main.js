import { Elm } from './Main.elm'

const config = {
  reliable: true
}


const rtc = {
  host: ({ id, onData, onConnect }) =>
    new Promise((resolve, reject) => {
      const peer = new window.Peer(id, config)
      peer.on('open', function (id) {
        const { host, protocol } = window.location
        const url = `${protocol}//${host}?id=${id}`
        resolve(url)
      })
      peer.on('error', function (err) {
        reject(err)
      })
      peer.on('connection', function (conn) {
        conn.on('open', function () {
          onConnect(conn)
          // Receive messages
          conn.on('data', onData)
          // Send messages
          conn.send({ action: 'FRIEND_READY', payload: String(id) })
        })
      })
  }),
  join: ({ id, serverId, onData, onConnect }) => {
    const peer = new window.Peer(id, config)
    const conn = peer.connect(serverId)
    conn.on('open', function () {
      onConnect(conn)
      // Receive messages
      conn.on('data', onData)
      // Send messages
      conn.send({ action: 'FRIEND_READY', payload: String(id) })
    })
  },
  send: ({ conn, msg }) =>
    conn && conn.send(msg)
}


const start = () => {
  const serverId = window.location.search.slice('?id='.length) || null

  const app = Elm.Main.init({
    node: document.getElementById('app'),
    flags: {
      id: serverId
    }
  })

  let shared = { conn: null }

  const onData = (msg) => {
    console.log('INCOMING', msg)
    app.ports.incoming.send(msg)
  }

  app.ports.outgoing.subscribe(function ({ action, payload }) {
    console.log(action, payload)
    switch (action) {
      case 'HOST_GAME':
        return rtc.host({
          id: Date.now(),
          onData,
          onConnect: c => { shared.conn = c }
        })
          .then(url => onData({
            action: 'HOST_URL',
            payload: url
          }))
          .catch(console.error)
      case 'READY_UP':
        return rtc.join({
          id: Date.now(),
          serverId: payload,
          onData,
          onConnect: c => { shared.conn = c }
        })
      case 'SEND_GAME':
        return rtc.send({
          conn: shared.conn,
          msg: { action: 'GAME_RECEIVED', payload }
        })
    }
  })
}

start()
