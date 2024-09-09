# Go Champs Web API ![build status](https://github.com/lairjr/go_champs_api/actions/workflows/master.yml/badge.svg)

*This is the Go Champs Web API repository.*

It is based on the REST principles, so the endpoints return JSON data about organizations, tournaments, phases, teams, games, etc. A diagram view explaning the main entities and how the we built the relations is under construction.

[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](http://badges.mit-license.org)

### How to contribute

It was mainly written in Elixir using Phoenix, so you will have to set up your environment correctly before get start.

After that, you will be able to run your server:
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`
  * Run unit tests `mix test`

---

## License

- **[MIT license](https://github.com/lairjr/go_champs_api/blob/master/LICENSE)**
- Copyright 2019.
