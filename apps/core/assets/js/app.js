import 'phoenix_html'
import 'flowbite/dist/flowbite.phoenix.js'
import { Socket } from 'phoenix'
import { LiveSocket } from 'phoenix_live_view'
import topbar from 'topbar'

const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute('content')

const liveSocket = new LiveSocket('/live', Socket, {
  params: { _csrf_token: csrfToken }
})

topbar.config({ barColors: { 0: '#29d' }, shadowColor: 'rgba(0, 0, 0, .3)' })
window.addEventListener('phx:page-loading-start', (_info) => topbar.show())
window.addEventListener('phx:page-loading-stop', (_info) => topbar.hide())

liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
