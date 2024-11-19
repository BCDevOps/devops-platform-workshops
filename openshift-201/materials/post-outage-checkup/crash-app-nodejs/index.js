const express = require('express');
const app = express();
const port = 8080;

// check if the env var exist
if (!process.env.NAME) {
  console.error(`Error: Missing required environment variable: NAME`);
  process.exit(1); // Exit the application with an error code
}

// Get environment variables with default values
const envVar1 = process.env.NAME;

// Define a route to return the environment variables as JSON
app.get('/', (req, res) => {
  res.send(`Hello world from ${envVar1}`);
});

// Start the server
app.listen(port, () => {
  console.log(`Crash App starting now! Server running at http://localhost:${port}`);
});
