-- Get port from user input and set up rednet
print("Enter server port:")
local port = tonumber(read())
if not port then
  print("Invalid port. Exiting.")
  return
end

-- Open rednet on the specified port
rednet.open("top")
rednet.CHANNEL_BROADCAST = port

-- Function to print usage instructions for the client
local function printUsage()
  print("\nAvailable commands:")
  print("add <name> <IP> <private(true/false)> - Add a new host")
  print("remove <name> - Remove an existing host")
  print("list - List all public hosts")
  print("get <name> - Get the IP address of a host")
end

-- Main loop for client interaction
while true do
  printUsage()
  print("\nEnter command:")
  local input = read()
  
  -- Split the input into command and arguments
  local command, arg1, arg2, arg3 = input:match("^(%S+)%s*(%S*)%s*(%S*)%s*(%S*)$")
  
  -- Validate and send commands
  if command == "add" and arg1 ~= "" and arg2 ~= "" and (arg3 == "true" or arg3 == "false") then
    rednet.broadcast("add " .. arg1 .. " " .. arg2 .. " " .. arg3)
    print("Sent add command for host:", arg1)
  
  elseif command == "remove" and arg1 ~= "" then
    rednet.broadcast("remove " .. arg1)
    print("Sent remove command for host:", arg1)
  
  elseif command == "list" then
    rednet.broadcast("list")
    print("Requested list of public hosts")
  
  elseif command == "get" and arg1 ~= "" then
    rednet.broadcast("get " .. arg1)
    print("Requested IP for host:", arg1)
  
  else
    print("Invalid command or arguments. Please try again.")
  end
  
  -- Wait for and print server response
  local senderID, response = rednet.receive()
  if senderID then
    print("Server response:", response)
  end
end