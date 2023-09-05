# Stream

🔥 Streaming app written in Elixir powered by Membrane Framework. 🔥

## Screen Shots

TODO

## Motivation

This study objective is not to create an application restricted in a stack, but to elaborate and test SOTA tools that enable a stable and productive stack.

**Our goals with the final product** is to find a stack that:

1. Stream videos
2. Enable stable and robust async IO traffic
3. Implements code quality tools (e.g. test, static analysis, linting, etc.)
4. Target the largest number of devices (e.g. ios, android, and web)

## Features

Features we aim to achieve in this software:

- [x] Watch video stream
- [x] Authentication
- [x] Users (CRUD)
- [x] Users (start stream)
- [ ] Stream comments
- [ ] Stream likes (with animation)
- [ ] Stream views (number of)
- [ ] Followers (number of)

## Usage

### Dependencies

We are using the following versions for running this app.

```c
elixir 1.14.3
erlang 25.3
nodejs 16.13.0
```

We provide a `.tool-versions` file for `asdf` users.

To install the mix dependencies, we must:

```bash
cd apps/core

mix deps.get
```

### Local Development

To run the application in local development we must have `docker` installed.

#### Start

First, inside the **root dir** make sure you have our docker container image running, to start the postgres database.

```bash
docker compose -f docker/docker-compose.dev.yml up
```

Then, setup the database and start phoenix server:

```bash
cd apps/core

mix setup
mix phx.server
```

#### Lint

To lint application we use:

```bash
mix lint
```

#### Test

To test application we use:

```bash
mix test
```

### Deployment

TODO

## Architecture

The current architecture is a monorepo divided in two modules, core and mobile, that is structured as demonstrated in the follow diagram

![Architecture diagram](/docs/images/architecture-diagram.png "architecture diagram")

The architecture aims to:

1. Allow new apps to connect easily, enabling an open API with https, socket and rtp communication;
2. Delivery a core application with everything needed to stream stuff;
3. Allow different technologies to be explored outside the core application without any holdback.

### Stack

#### Core

It is the monolith that contains core stream services and web platform.

Current stack been used in the challenge:

**API**

- [x] Elixir
- [x] Phoenix
- [x] Membrane Framework

**Web**

- [x] Live View
- [x] Tailwind
- [x] Alpine JS

#### Mobile

TODO
