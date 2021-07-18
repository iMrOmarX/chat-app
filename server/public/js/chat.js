const socket = io()


socket.on("message" , (data) => {
    console.log(data)
})


const messageForm = document.querySelector("#message-form")
const messageField = document.querySelector("input")

messageForm.addEventListener("submit" , (e) => {
    e.preventDefault()

    const message = e.target.elements.message.value

    socket.emit("sendMessage" , message)
})