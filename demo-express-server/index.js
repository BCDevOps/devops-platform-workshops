
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const axios = require('axios');
const config = require('./config/index.json');

const PORT = process.env.port || 3000;
const app = express();

const whitelist = config.corsWhitelist;

// prevent other origins from making requests
const corsOptions = {
  origin: function (origin, callback) {

    if (!origin || whitelist.indexOf(origin) !== -1) {
      callback(null, true)
    } else {
      callback(new Error('Not allowed by CORS'))
    }
  }
}


app.use(cors(corsOptions));

app.get('/', (req, res) => {
  res.sendStatus(200);
});

app.get('/health-check', (req, res) => {
  res.sendStatus(200);
});

app.get('/joke', async (req, res) => {
  const response = await axios.get('https://icanhazdadjoke.com', {
    headers: {
      'User-Agent': 'bcgov hello world application (https://github.com/patricksimonian/hello-world-express-react)',
      Accept: 'application/json'
    }
  });
  console.log('fetching joke', response.data);
  res.status(200).json({
    joke: response.data.joke
  });
});

app.listen(PORT, () => {
  console.log(`Listening on ${PORT}`);
});