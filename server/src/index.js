const express = require("express")
const path = require("path")
const http = require("http")
const socketio = require("socket.io")

const app = express()
const server = http.createServer(app) // express does it by default , used to get access to it 
const io = socketio(server)

const port = process.env.PORT || 3000
const publicDirPath = path.join(__dirname , "../public")

app.use(express.static(publicDirPath))

io.on('connection' , (socket) => {
    /* console.log("New WebSocket Connection")

    socket.emit("countUpdated" , count)

    
    socket.on("increment" , () => {
        
        count++;
        //socket.emit("countUpdated" , count)
        io.emit("countUpdated" , count)
    }) */
    console.log("New WebSocket Connection")

    socket.on("sendMessage" , (data) => {
        console.log(data)
        io.emit("message" , data)
    })
})



app.get("/" , (req, res) => {
    res.sendFile("index.html")
})

server.listen(port ,"0.0.0.0", ()=> {
    console.log(`Your server is up on port ${port}`)
})