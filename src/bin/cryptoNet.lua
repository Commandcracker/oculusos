-- CryptoNet's command line interface, used by a certificate authority
-- to sign certificates.
-- Supports two commands: initCertAuth and signCert.
--
-- initCertAuth is used to generate the keys used to sign and verify certificates.
-- The public key should be distributed to all clients using the certificate
-- authority, while the private key should be kept secure on the cert auth's
-- machine.
--
-- Certificates to be signed should be copied to the cert auth machine,
-- e.g. using floppy disks. signCert is then used to sign the certificate,
-- which can then be transferred back to the server machine.
-- Only sign the certificates of trusted servers, and don't sign two certificates
-- with the same name and different public keys.

local function Usage()
    print("Usage: cryptoNet signCert <file>")
    print("       cryptoNet demo <server/client>")
end

cryptoNet.setLoggingEnabled(true)
-- Set the CryptoNet working directory to match the system one.

local args = {...}
if args[1] == "signCert" then
    -- Sign a certificate loaded from a file.
    local certPath = args[2]
    if certPath == nil then
        Usage()
        return
    end

    -- Make paths relative to the working directory.
    certPath = workingDir == "" and certPath or shell.dir().."/"..certPath
    -- Optional private key file argument, can be omitted to use default.
    local keyPath = args[3]
    local ok, msg = pcall(cryptoNet.signCertificate, certPath, keyPath)

    if not ok then
        cryptoNet.log("Error: "..msg:sub(8))
    end
    elseif args[1] == "initCertAuth" then
        -- Generate the cert auth key pair and save them to the specified files.
        -- The file arguments can be omitted to use the default values.
        local ok, msg = pcall(cryptoNet.initCertificateAuthority, args[2], args[3])
    if not ok then
        cryptoNet.log("Error: "..msg:sub(8))
    end
elseif args[1] == "demo" then
    local server_type = args[2]
    if server_type == nil then
        Usage()
        return
    end
    if server_type == "server" then
        -- Runs when the event loop starts
        function onStart()
            -- Start the server
            cryptoNet.host("DemoServer")
        end
        
        -- Runs every time an event occurs
        function onEvent(event)
            -- When a client opens a connection
            if event[1] == "connection_opened" then
                -- The socket used to send messages to the client
                local socket = event[2]
                -- Send some encypted messages back to the client
                cryptoNet.send(socket, "Welcome to the server!")
                cryptoNet.send(socket, "Please wait while I show off CryptoNet...")
                -- Each call to onEvent is run in a different thread, so you can use
                -- blocking calls like sleep() and pullEvent() without freezing the whole server
                os.sleep(5)
                cryptoNet.send(socket, "Done!")
            -- Received a message from the client
            elseif event[1] == "encrypted_message" then
                if term.isColor() then
                    term.write('[')
                    term.setTextColour(colors.lime)
                    term.write('Client')
                    term.setTextColour(colors.white)
                    print('] '..event[2])
                else
                    print("[Client] "..event[2])
                end
            end
        end
        
        -- Let CryptoNet handle messages in the background
        cryptoNet.startEventLoop(onStart, onEvent)
    elseif server_type == "client" then
        -- Runs when the event loop starts
        function onStart()
            -- Connect to the server
            local socket = cryptoNet.connect("DemoServer")
            -- Send an encrypted message
            cryptoNet.send(socket, "Hello server!")
        end
        
        -- Runs every time an event occurs
        function onEvent(event)
            -- Received a message from the server
            if event[1] == "encrypted_message" then
                if term.isColor() then
                    term.write('[')
                    term.setTextColour(colors.red)
                    term.write('Server')
                    term.setTextColour(colors.white)
                    print('] '..event[2])
                else
                    print("[Server] "..event[2])
                end
            end
        end
        
        -- Let CryptoNet handle messages in the background
        cryptoNet.startEventLoop(onStart, onEvent)
    else
        Usage()
    end
else
    Usage()
end
