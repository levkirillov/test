if not (fs.exists('port.cfg')) then
  print('Port for DNS server.')
  port = read()
  if (tonumber(port)) < 0 or (tonumber(port)) > 65535 then
    file2 = exit()
  end
  file2 = fs.open('port.cfg',w)
  file2.write(port)
  file2.close()
end
readp = fs.open('port.cfg',r)
rport = readp.readLine()
readp.close()
rednet.open("top")
if not (fs.exists('hosts.json')) then
  h = fs.open('hosts.json',w)
  h.write('{}')
  h.close()
end
hostfile = fs.open('hosts.json',r)
hosts = textutils.unserializeJSON(hostfile.readAll())

while true do
  d = rednet.receive()
  if d[0] then
    print('id')
    print(d[0])
    print('msg')
    print(d[1])
    if last_c then
      if last_c == 'add' then
      end
      last_c = nil
    end
    if not last_c then
      last_c = d[1]
    end
  end
end
