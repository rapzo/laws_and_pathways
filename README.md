# Laws and Pathways backoffice

The backoffice for laws and pathways

## Dependencies:

- Ruby v2.6.3
- Rails v5.2.3
- Node v10
- PostgreSQL v11

## Local installation

These are the steps to run the project locally:

### Installing ruby dependencies

On the project's root run `bundle install`.

### Installing npm dependencies

`yarn`

### Database

#### Create database schema

`bundle exec rails db:setup` to setup the database

### Run the server

`yarn start` and access the project on `http://localhost:3000`

### Run the tests

`yarn test`

## Docker

There's a `docker-compose.yml` file that boots a container with postgresql server and adminer (a cheap tool to inspect the database).
The database folder in the container is mapped to `./tmp/db` in order to persist data despite the container status.

- `docker-compose up` should be enough to bring it up
- `docker-compose down` to stop


## Configuration

### Google Cloud Storage

Credential key JSON file is stored in `config/secrets` directory. You can override file by setting `GCS_CREDENTIALS_FILE` env variable, all files
must be stored in `config/secrets` directory.

Be sure to never commit credentials file!

## API
