import { Elm } from './Main.elm'

const config = {
  secure: process.env.PEERJS_SECURE === 'true',
  host: process.env.PEERJS_HOST || 'localhost',
  port: parseInt(process.env.PEERJS_PORT) || 9000,
  path: process.env.PEERJS_PATH || '/'
}

const send = (conn, msg) => _ => {
  conn.send(msg)
  window.requestAnimationFrame(send(conn, msg))
}

window.rtc = {
  host: ({ id, onData, onUrl }) => {
    const peer = new window.Peer(id, config)
    peer.on('open', function (id) {
      const { host, protocol } = window.location
      const url = `${protocol}//${host}?id=${id}`
      onUrl(url)
    })
    peer.on('connection', function (conn) {
      conn.on('open', function () {
        // Receive messages
        conn.on('data', onData)
        // Send messages
        window.requestAnimationFrame(send(conn, 'Hello from server!'))
      })
    })
  },
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
  const serverId = window.location.search.slice('?id='.length) || undefined
  const isServer = serverId === undefined

  const app = Elm.Main.init({
    node: document.getElementById('app')
  })

  // if (isServer) {
  //   rtc.host({ onUrl: console.log, onData: console.log })
  // } else {
  //   rtc.join({ id: serverId, onData: console.log })
  // }
}

start()

window.rtc.host({
  id: Date.now(),
  onData: console.log,
  onUrl: console.log
})