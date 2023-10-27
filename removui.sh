#!/bin/bash


# Install Node.js
sudo apt-get update
sleep 30
sudo apt-get install -y ca-certificates curl gnupg
sleep 10
sudo mkdir -p /etc/apt/keyrings
sleep 5
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
sleep 10

# Sleep for 30 seconds

NODE_MAJOR=20
sleep 1
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sleep 5
sudo apt-get update
sudo apt install -y nodejs
sleep 7

# Sleep for 30 seconds

cd
# Create a directory for the Node.js app
mkdir server-reboot-app
sleep 2
cd server-reboot-app
sleep 2

npm init -y
sleep 6
npm install express child_process
sleep 9

# Sleep for 30 seconds


# Create the app.js file
cat > app.js << 'EOF'
const express = require('express');
const { exec } = require('child_process');

const app = express();
const port = 3800; // You can choose any available port


app.use(express.static('/root/server-reboot-app/public'));


const apikey = 'loki';
app.get('/', (req, res) => {
  // This can be an optional route or a redirection to your main HTML page.
  res.sendFile('/root/server-reboot-app/public/index.html');
});

app.post('/reboot', (req, res) => {
  // Add security measures here to validate access, e.g., check the API key
  const requestApiKey = req.header('API-Key');
  if (requestApiKey !== apikey) {
    res.status(403).send('Access denied: Invalid API key.');
    return;
  }

  // Execute the reboot command (ensure that the user running the Node.js app has the necessary permissions)
  exec('sudo reboot', (error, stdout, stderr) => {
    if (error) {
      console.error(`Error: ${error}`);
      res.status(500).send('Error occurred while rebooting the server.');
    } else {
      console.log(`Server rebooted: ${stdout}`);
      res.send('Server rebooted successfully.');
    }
  });
});


app.post('/restartbvpn', (req, res) => {
  // Add security measures here to validate access, e.g., check the API key
  const requestApiKey = req.header('API-Key');
  if (requestApiKey !== apikey) {
    res.status(403).send('Access denied: Invalid API key.');
    return;
  }

  // Execute the reboot command (ensure that the user running the Node.js app has the necessary permissions)
  exec('sudo /usr/bin/systemctl restart bvpn.service', (error, stdout, stderr) => {
    if (error) {
      console.error(`Error: ${error}`);
      res.status(500).send('Error occurred while rebooting the server.');
    } else {
      console.log(`Server rebooted: ${stdout}`);
      res.send('Server rebooted successfully.');
    }
  });
});


app.post('/enable-ip-forwarding', (req, res) => {
  // Extract the API key from the request headers
  const requestApiKey = req.header('API-Key');

  if (requestApiKey !== apikey) {
    res.status(403).send('Invalid API key.');
    return;
  }


  exec('sudo sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.d/99-sysctl.conf', (error, stdout, stderr) => {
    if (error) {
      console.error(`Error: ${error}`);
      res.status(500).send('Error occurred while enabling IP forwarding.');
    } else {
      console.log(`IP forwarding enabled: ${stdout}`);
      res.send('IP forwarding enabled successfully. You may need to reboot for the changes to take effect.');
    }
  });
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});


EOF
sleep 5
# Create public directory and index.html
mkdir public
cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <title>Server Reboot</title>
</head>



<body>
  <h1>Server Reboot</h1>
  <p>Enter your API key and click the button below to reboot the server:</p>
  <input type="text" id="apiKeyInput" placeholder="Enter API Key">

  <button id="rebootButton">Reboot Server</button>
  <button id="enableIpForwardingButton">Enable IP Forwarding</button>
  <p id="message"></p>



  <form id="nameForm">
        <label for="name">Name:</label>
        <input type="text" id="name" name="name">
        <input type="submit" value="Submit">
    </form>



 <div id="removeDiv">
        <label for="removeName">Name (Remove):</label>
        <input type="text" id="removeName" name="removeName">
        <button onclick="removeNameFunction()">Remove</button>
    </div>



<button onclick="fetchDataFunction()">Fetch Data</button>

<!-- Box to display the data in a table -->
<div id="dataBox">
    <table id="dataTable">
        <thead>
            <tr>
                <th>#</th>
                <th>Name</th>
            </tr>
        </thead>
        <tbody></tbody>
    </table>
</div>
<div id="loge"></div>

  <script>



let ips ;
const serverHost = window.location.hostname;
console.log(serverHost); 
let isp = serverHost;




function fetchDataFunction() {
 const apiKey = document.getElementById('apiKeyInput').value;
if(apiKey!='loki'){
return;
} 
   const serverURL = `http://${isp}:3000/list`;

    fetch(serverURL)
        .then(response => response.text())  // Get the raw text
        .then(text => {
            console.log('Raw response:', text);  // Log the raw response

        document.getElementById("loge").innerText=text;

            const data = JSON.parse(text);  // Attempt to parse the JSON

            const tableBody = document.querySelector("#dataTable tbody");
            tableBody.innerHTML = ''; // Clear previous data

        document.getElementById("loge").innerText=text;

            data.forEach((name, index) => {
                const row = tableBody.insertRow();
                const cell1 = row.insertCell(0);
                const cell2 = row.insertCell(1);
                cell1.textContent = index + 1;
                cell2.textContent = name;
            });
        })
        .catch(error => {
            console.error('There was an error:', error);
        });
}


  function removeNameFunction() {
 const apiKey = document.getElementById('apiKeyInput').value;
if(apiKey!='loki'){
return;
}       
     const removeNameInput = document.getElementById('removeName').value;
            const serverURL = `http://${isp}:3000/remove?publicKey=${encodeURIComponent(removeNameInput)}`;

            fetch(serverURL)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    console.log('Name removed successfully!');
                })
                .catch(error => {
                    console.error('There was an error:', error);
                });
        }

document.getElementById('nameForm').addEventListener('submit',async function(e) {
    e.preventDefault(); // Prevents the default form submission behaviour
 const apiKey = document.getElementById('apiKeyInput').value;
if(apiKey!='loki'){
return;
}
    const nameInput = document.getElementById('name').value;




         fetch('/restartbvpn', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'API-Key': apiKey
        }
      })
        .then(response => response.text())
        .then(data => {
          document.getElementById('message').textContent = data; // Display a message from the server
        })
        .catch(error => {
          console.error('Error:', error);
          document.getElementById('message').textContent = 'An error occurred while rebooting the server.';
        });



await new Promise(r => setTimeout(r, 1000));


    const serverURL = `http://${isp}:3000/create?publicKey=${encodeURIComponent(nameInput)}`;

   
    fetch(serverURL)
        .then(response => response.text()) // Convert the response to text
        .then(text => {
            // Convert the text to a blob with MIME type 'text/plain'
            const blob = new Blob([text], { type: 'text/plain' });

            // Create a link to download the file
            const a = document.createElement('a');
            a.href = URL.createObjectURL(blob);
            a.download = `${nameInput}.ovpn`; // Give your file a .txt extension
            document.body.appendChild(a);
            a.click(); // Prompt user to download the file
            document.body.removeChild(a); // Remove the link after download
        })
        .catch(error => {
            console.error('There was an error:', error);
        });
});





    document.getElementById('rebootButton').addEventListener('click', () => {
      const apiKey = document.getElementById('apiKeyInput').value;
      // Send a request to trigger the reboot with the entered API key
      fetch('/reboot', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'API-Key': apiKey
        }
      })
        .then(response => response.text())
        .then(data => {
          document.getElementById('message').textContent = data; // Display a message from the server
        })
        .catch(error => {
          console.error('Error:', error);
          document.getElementById('message').textContent = 'An error occurred while rebooting the server.';
        });
    });

    document.getElementById('enableIpForwardingButton').addEventListener('click', () => {
      const apiKey = document.getElementById('apiKeyInput').value;
      // Send a request to enable IP forwarding with the entered API key
      fetch('/enable-ip-forwarding', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'API-Key': apiKey
        }
      })
        .then(response => response.text())
        .then(data => {
          document.getElementById('message').textContent = data; // Display a message from the server
        })
        .catch(error => {
          console.error('Error:', error);
          document.getElementById('message').textContent = 'An error occurred while enabling IP forwarding.';
        });
    });
  </script>
</body>
</html>

EOF
# Sleep for 15 seconds
sleep 15

# Create a systemd service for the Node.js app
cat <<EOF | sudo tee /etc/systemd/system/removeui.service
  [Unit]
  Description=Tunnel WireGuard with udp2raw
  After=network.target

  [Service]
  Type=simple
  User=root
  ExecStart=sudo node /root/server-reboot-app/app.js
  Restart=no

  [Install]
  WantedBy=multi-user.target
EOF

# Sleep for 30 seconds
sleep 7

# Enable and start the systemd service
sudo systemctl enable removeui.service
sudo systemctl start removeui.service

echo "Server Reboot App is installed and running."
