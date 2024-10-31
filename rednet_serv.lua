-- Function to split a message into command and arguments
local function splitMessage(message)
  local words = {}
  for word in message:gmatch("%S+") do
    table.insert(words, word)
  end
  return words
end

-- Check if the port configuration file exists
if not fs.exists('port.cfg') then
  print('Enter the port number for the DNS server (0-65535):')
  local port = tonumber(read())

  -- Validate the port number
  if not port or port < 0 or port > 65535 then
    print("Invalid port number. Exiting.")
    return
  end

  -- Save the valid port to 'port.cfg'
  local file = fs.open('port.cfg', 'w')
  file.write(port)
  file.close()
end

-- Read the port number from 'port.cfg'
local portFile = fs.open('port.cfg', 'r')
local rport = portFile.readLine()
portFile.close()

-- Open rednet on the top side of the computer
rednet.open("top")

-- Check if the hosts configuration file exists, if not, create it
if not fs.exists('hosts.json') then
  local hostFile = fs.open('hosts.json', 'w')
  hostFile.write('{}')
  hostFile.close()
end

-- Load hosts data from 'hosts.json'
local hostFile = fs.open('hosts.json', 'r')
local hosts = textutils.unserializeJSON(hostFile.readAll())
hostFile.close()

-- Set up admin ID (hardcoded here for example, you could set this differently)
local adminID = 1

-- Main server loop
while true do
  local senderID, msg = rednet.receive()
  if senderID then
    print('Received from ID:', senderID)
    print('Message:', msg)
    
    -- Split message into command and arguments
    local parts = splitMessage(msg)
    local command = parts[1]
    local arg1 = parts[2]
    local arg2 = parts[3]
    local arg3 = parts[4] == "true"

    if command == "add" and arg1 and arg2 then
      -- Add entry to hosts with privacy and owner info
      hosts[arg1] = { ip = arg2, private = arg3, ownerID = senderID }
      
      -- Save updated hosts data back to 'hosts.json'
      local hostFile = fs.open('hosts.json', 'w')
      hostFile.write(textutils.serializeJSON(hosts))
      hostFile.close()
      
      rednet.send(senderID, "Host added: " .. arg1)
      print("Added host:", arg1, "with IP:", arg2, "private:", tostring(arg3))

    elseif command == "remove" and arg1 then
      -- Check if the host exists and the sender has permission to delete
      local host = hosts[arg1]
      if host and (host.ownerID == senderID or senderID == adminID) then
        hosts[arg1] = nil  -- Remove entry from hosts

        -- Save updated hosts data
        local hostFile = fs.open('hosts.json', 'w')
        hostFile.write(textutils.serializeJSON(hosts))
        hostFile.close()
        
        rednet.send(senderID, "Host removed: " .. arg1)
        print("Removed host:", arg1)
      else
        rednet.send(senderID, "Permission denied or host not found.")
      end

    elseif command == "list" then
      -- Collect only public hostnames
      local publicHosts = {}
      for hostname, data in pairs(hosts) do
        if not data.private then
          table.insert(publicHosts, hostname)
        end
      end
      -- Send list of public hosts
      rednet.send(senderID, "Public hosts: " .. textutils.serialize(publicHosts))
      print("Sent public hosts list to ID:", senderID)

    elseif command == "get" and arg1 then
      -- Check if the host exists and send back its IP
      local host = hosts[arg1]
      if host then
        rednet.send(senderID, "IP of " .. arg1 .. ": " .. host.ip)
      else
        rednet.send(senderID, "Host not found: " .. arg1)
      end

    else
      -- Send usage instructions if command is unrecognized
      local usage = "Commands:\n"
        .. "add <name> <IP> <private(true/false)>\n"
        .. "remove <name>\n"
        .. "list\n"
        .. "get <name>"
      rednet.send(senderID, "Invalid command.\n" .. usage)
      print("Sent usage instructions to ID:", senderID)
    end
  end
end