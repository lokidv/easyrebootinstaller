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




EOF
sleep 5
# Create public directory and index.html
mkdir public
cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <title>Server Reboot</title>

<style>

body{

  padding: 19px;
direction: rtl;
margin: 5px;
}

label{

font-size:18px;
}

button{
padding :10px 35px;
background-color:#79799d;
border-radius:35px;
color:white;
margin: 5px;

}


input{
border-radius: 35px;
  padding: 8px 15px;
  background-color: #eee;
  border: 1px solid #ccc;
}


</style>

</head>



<body>
  <h1>پنل مدیریت کاربرها</h1>
  <p>برای شروع رمز را در قسمت رمز وارد کنید</p>
<label for="apiKeyInput">سرور فعال سازی</label>
  <input type="text" id="apiKeyInput" placeholder="Enter API Key">

  <button id="rebootButton">ریستارت کردن سرور</button>
  <button id="enableIpForwardingButton">Enable IP Forwarding فقط مخصوص وایرگارد</button>
  <p id="message"></p>



  <form id="nameForm">
        <label for="name">نام کاربر جدید:</label>
        <input type="text" id="name" name="name">
        <input type="submit" style="background-color: #79aa79;
  color: white;" value="ساختن">
    </form>



<label for="fileName"> نام کاربر </label>
<input type="text" id="fileName" name="fileName">

<label for="expirationDate">تاریخ انقضا</label>
<input type="date" id="expirationDate" name="expirationDate">

<input type="submit" style="background-color: #79aa79; color: white;" value="ذخیره" onclick="createRecord()">



<button style="background-color: #79aa79; color: white;" onclick="fetchExpirationTime()">نمایش زمان انقضاء</button>
<p id="expirationTime"></p>

<button onclick="showAllRecords()">لیست تاریخ انقضا </button>
<div id="allRecords"></div>



 <div id="removeDiv">
        <label for="removeName">حذف کاربر:</label>
        <input type="text" id="removeName" name="removeName">
        <button style="background-color: #d08686;" onclick="removeNameFunction()">حذف شود</button>
    </div>



<button onclick="fetchDataFunction()">لیست تمامی کاربرها</button>



<button onclick="showOvpnFiles()">تاریخ ایجاد کاربرها</button>
    <div id="fileList"></div>

<!-- Box to display the data in a table -->
<div id="dataBox">
    <table id="dataTable">
        <thead>
            <tr>
                <th>#</th>
                <th>نام</th>
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





function showAllRecords() {
  const apiKey = document.getElementById('apiKeyInput').value;
  if (apiKey !== 'loki') {
    return;
  }

  // Fetch all records
  fetch('/getAllRecords', {
    headers: {
      'API-Key': apiKey
    }
  })
    .then(response => response.json())
    .then(records => {
      const recordsDiv = document.getElementById('allRecords');
      recordsDiv.innerHTML = '<strong>All Records:</strong><br>';
      
      records.forEach(record => {
        recordsDiv.innerHTML += `${record}<br>`;
      });
    })
    .catch(error => {
      console.error('Error fetching records:', error);
    });
}




 function fetchExpirationTime() {
    // Call the server-side function to fetch expiration time
 const nameInput = prompt('نام کاربری که تاریخ انقضا ان را میخواهید وارد کنید:'); // Prompt for the name

    if (!nameInput) {
      // User clicked cancel or entered an empty name
      return;
    }

  fetch(`/fetchExpirationTime?name=${encodeURIComponent(nameInput)}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'API-Key': 'loki', // Replace with your actual API key
      },
    })
      .then(response => response.text())
      .then(data => {
        console.log(data); // Log the response from the server
        document.getElementById('expirationTime').textContent = data; // Display the expiration time
      })
      .catch(error => {
        console.error('Error fetching expiration time:', error);
        // Handle the error, display an error message, etc.
      });

  }






  function createRecord() {
    const fileNameInput = document.getElementById('fileName').value;
    const expirationDateInput = document.getElementById('expirationDate').value;

    // Call the server-side function to create a record
    fetch(`/createRecord?fileName=${encodeURIComponent(fileNameInput)}&expirationDate=${encodeURIComponent(expirationDateInput)}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'API-Key': 'loki', // Replace with your actual API key
      },
    })
      .then(response => response.text())
      .then(data => {
        console.log(data); // Log the response from the server
        // Optionally, display a message to the user
      })
      .catch(error => {
        console.error('Error creating record:', error);
        // Handle the error, display an error message, etc.
      });
  }









  async function showOvpnFiles() {
      console.log("here")
      const fileListDiv = document.getElementById('fileList');
      fileListDiv.innerHTML = ''; // Clear previous content

      try {
        const response = await fetch(`http://${isp}:3800/getOvpnFiles`);
        const fileList = await response.json();

        fileList.forEach(file => {
          const listItem = document.createElement('div');
          convertToSolarDate(file.creationTime)
            .then(gregorianDate => {
              listItem.innerHTML = `<strong>${file.fileName}</strong>   : ${gregorianDate}`;
              fileListDiv.appendChild(listItem);
            })
            .catch(error => {
              console.error('Error converting date to Gregorian:', error);
              listItem.innerHTML = `<strong>${file.fileName}</strong> - Error converting date to Gregorian`;
              fileListDiv.appendChild(listItem);
            });
        });
      } catch (error) {
        console.error('Error fetching .ovpn files:', error);
      }
    }

    function convertToSolarDate(islamicDate) {
      return new Promise((resolve, reject) => {
        try {
          const dateObj = new Date(islamicDate);
          const year = dateObj.getFullYear();
          const month = String(dateObj.getMonth() + 1).padStart(2, '0');
          const day = String(dateObj.getDate()).padStart(2, '0');
          const gregorianDate = `${year}/${month}/${day}`;
          resolve(gregorianDate);
        } catch (error) {
          console.error('Error converting date to Gregorian:', error);
          reject(error);
        }
      });
    }



 function formatDate(date) {
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0'); // Adding 1 because months are zero-based
            const day = String(date.getDate()).padStart(2, '0');
            return `${year}/${month}/${day}`;
        }

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
