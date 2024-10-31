print('port')
port = read()
rednet.open("top")
rednet.CHANNEL_BROADCAST = tonumber(port)
while true do
  rednet.broadcast(tostring(read()))
end