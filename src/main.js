import { Elm } from './Main.elm'

const config = {}

// Stream actions, because UDP is maybes
let localQueue = []
let otherQueue = []

const perform = (msg) => localQueue.push(msg)
const streamActions = (conn) =>
  setInterval(_ => conn.send(localQueue), 100)

const onOpen = ({ id, conn, onData }) => {
  streamActions(conn)
  // Receive messages
  conn.on('data', onData)
  // Send messages
  perform({ action: 'FRIEND_READY', payload: String(id) })
}

const rtc = {
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
        conn.on('open', onOpen({ id, conn, onData }))
      })
  }),
  join: ({ id, serverId, onData }) => {
    const peer = new window.Peer(id, config)
    const conn = peer.connect(serverId)
    conn.on('open', onOpen({ id, conn, onData }))
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

  const onData = (latestOtherQueue) => {
    const changes = latestOtherQueue.slice(otherQueue.length)
    if (changes.length > 0) {
      otherQueue = latestOtherQueue
      changes.forEach(msg => {
        app.ports.incoming.send(msg)
      })
    }
  }

  app.ports.outgoing.subscribe(function ({ action, payload }) {
    switch (action) {
      case 'HOST_GAME':
        return rtc.host({
          id: Date.now(),
          onData
        })
          .then(url => app.ports.incoming.send({
            action: 'HOST_URL',
            payload: url
          }))
          .catch(console.error)
      case 'READY_UP':
        return rtc.join({
          id: Date.now(),
          serverId: payload,
          onData
        })
      case 'SEND_GAME':
        return perform({
          action: 'GAME_RECEIVED',
          payload
        })
    }
  })
}

start()
