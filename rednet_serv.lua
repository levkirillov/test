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

-- Main server loop
while true do
  local id, msg = rednet.receive()
  if id then
    print('Received from ID:', id)
    print('Message:', msg)
    
    -- Split message into command and arguments
    local parts = splitMessage(msg)
    local command = parts[1]
    local arg1 = parts[2]
    local arg2 = parts[3]

    -- Process command with arguments directly
    if command == "add" and arg1 and arg2 then
      hosts[arg1] = arg2  -- Add entry to hosts (e.g., hostname = IP)

      -- Save updated hosts data back to 'hosts.json'
      local hostFile = fs.open('hosts.json', 'w')
      hostFile.write(textutils.serializeJSON(hosts))
      hostFile.close()
      
      print("Added host:", arg1, "with IP:", arg2)
    
    elseif command == "remove" and arg1 then
      hosts[arg1] = nil  -- Remove entry from hosts

      -- Save updated hosts data
      local hostFile = fs.open('hosts.json', 'w')
      hostFile.write(textutils.serializeJSON(hosts))
      hostFile.close()
      
      print("Removed host:", arg1)
    
    elseif command == "list" then
      print("Current hosts list:")
      for hostname, ip in pairs(hosts) do
        print(hostname, ":", ip)
      end
    
    else
      print("Invalid command or arguments:", command, arg1, arg2)
    end
  end
end