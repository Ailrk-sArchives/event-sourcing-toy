const main = () => {

  const newCandidate = (cid, name) => {
    m = {
      contents : {
        cid : cid,
        name : name,
        status : "Begin"
      },
      tag : "AddCandidate"
    }

    return JSON.stringify(m)
  }

  const drawRow = (row) => {
    const tr = document.createElement("tr")
    tr.appendChild((() => {
      const td = document.createElement("td")
      td.innerText = row.cid
      return td
    })())

    tr.appendChild((() => {
      const td = document.createElement("td")
      td.innerText = row.name
      return td
    })())

    tr.appendChild((() => {
      const td = document.createElement("td")
      td.innerText = row.status
      return td
    })())
    return tr
  }

  const drawTable = (candidates) => {
    console.log(candidates)
    const oldTable = document.querySelector("#table-id table")
    const newTable = document.createElement("table")

    const header = document.createElement("tr")
    const headers =  ["cid", "name"]
    headers.forEach(h => {
      header.appendChild((() => {
        const th = document.createElement("th")
        th.innerText = h
        return th
      })())
    })

    newTable.appendChild(header)
    candidates.forEach((row) => {
      newTable.appendChild(drawRow(row))
    })
    oldTable.replaceWith(newTable)
  }

  let connecting = false

  const reconnect = (to, wsHandler) => {
    setTimeout(() => connect(wsHandler), to)
  }

  const connect = (wsHandler) => {
    if(connecting) return
    connecting = true

    const webSockerAddress = (window.location.protocol == "http:" ? "ws://" : `wss://`) + `${window.location.hostname}:${window.location.port}/stream`

    let socket = new WebSocket(webSockerAddress)

    // This needs to be upgraded to a queue datastructure
    // because the time can change the order of messages
    const sendMessageWhenOpen = (message) => {
      if (socket.readyState == WebSocket.OPEN) {
        console.log("open!!")
        socket.send(message)
      } else {
        setTimeout(() => {
          sendMessageWhenOpen(message)
        }, 1000)
      }
    }

    socket.onopen = (evt) => {
      connecting = false
      if (socket.readyState == WebSocket.OPEN) {
        socket.addEventListener("message", (event) => {
          wsHandler(event.data)
        })
      }
    }

    socket.onerror = (evt) => {
      console.log("ws error", evt)
      connecting = false
        reconnect(2000, wsHandler)
    }

    socket.onclose = (evt) => {
      console.log("ws close", evt)
      connecting = false
      reconnect(1000, wsHandler)
    }

    return sendMessageWhenOpen
  }

  const wsHandler = (data) => {
    candidates = JSON.parse(data)
    drawTable(candidates)
  }

  const sendMessageWhenOpen = connect(wsHandler)

  document.getElementById("new-candidate-form-button").addEventListener("click", function(evt) {
    const cid = document.getElementById("form-cid").value
    const name = document.getElementById("form-name").value
    c = newCandidate(cid, name)
    console.log("clicked")
    sendMessageWhenOpen(c)
  })
}

main()
