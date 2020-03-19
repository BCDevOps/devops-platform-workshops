# Demo Express Server

This server is used to demonstrate openshift s2i builds. 

## To Run Locally

Requires Node > 10.15.x

1. Install Packages `npm install`
2. Copy and replace environment file with your desired values `cp .env.example .env`
3. Run Server `npm start`


## Configuration

The application uses `cors` to allow only certain origins to access the api. This configuration can
be found at `config/index.json`.

### Environment Variables

`PORT` The port you want to run the api on. This defaults to __3000__. 
