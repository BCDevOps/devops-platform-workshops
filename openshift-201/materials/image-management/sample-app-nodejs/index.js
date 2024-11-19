const express = require('express');
const app = express();
const port = 8080;

// Get environment variables with default values
const envVar1 = process.env.NAME || 'unkonwn';
const envVar2 = process.env.APP_MSG || '';
const envVar3 = process.env.SECRET_APP_MSG || '';

// Define a route to return the environment variables as JSON
app.get('/', (req, res) => {
  res.send(`Hello world from ${envVar1} ${envVar2} ${envVar3}`);
});

// Start the server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
