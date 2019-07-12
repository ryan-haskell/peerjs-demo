import { Elm } from './Main.elm'

const config = {}

const send = (conn, msg) => _ => {
  conn.send(msg)
  window.requestAnimationFrame(send(conn, msg))
}

window.rtc = {
  host: ({ id, onData }) =>
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
          // Receive messages
          conn.on('data', onData)
          // Send messages
          window.requestAnimationFrame(send(conn, 'Hello from server!'))
        })
      })
  }),
  join: ({ id, serverId, onData }) => {
    const peer = new window.Peer(id, config)
    const conn = peer.connect(serverId)
    conn.on('open', function () {
      // Receive messages
      conn.on('data', onData)
      // Send messages
      window.requestAnimationFrame(send(conn, 'Hello from client!'))
    })
  }
}

const start = () => {
  const serverId = window.location.search.slice('?id='.length) || null

  const app = Elm.Main.init({
    node: document.getElementById('app'),
    flags: {
      id: serverId
    }
  })

  app.ports.outgoing.subscribe(function ({ action, payload }) {
    switch (action) {
      case 'HOST_GAME':
        return rtc.host({
          id: Date.now(),
          onData: console.log
        })
          .then(url => app.ports.incoming.send(url))
          .catch(console.error)
      case 'READY_UP':
        return rtc.join({
          id: Date.now(),
          serverId: payload,
          onData: console.log
        })
    }
  })
}

start()
