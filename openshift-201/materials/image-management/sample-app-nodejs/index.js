const express = require('express');
const app = express();
const port = 8080;

// Get environment variables with default values
const envVar1 = process.env.ENV_VAR1 || 'unkonwn';
const envVar2 = process.env.ENV_VAR2 || 'default2';
const envVar3 = process.env.ENV_VAR3 || 'default3';

// Define a route to return the environment variables as JSON
app.get('/', (req, res) => {
  res.json({
    ENV_VAR1: envVar1,
    ENV_VAR2: envVar2,
    ENV_VAR3: envVar3
  });
});

// Start the server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
