# Stream

🔥 Streaming app written in Elixir powered by Membrane Framework. 🔥

## Motivation

This study objective is not to create an application restricted in a stack, but to elaborate and test SOTA tools that enable a stable and productive stack.

Or goals with the final product is to find a stack that:

1. Stream videos;
2. Enable stable and robust async IO traffic;
3. Implements code quality tools (e.g. test, static analysis, linting, etc.);
4. Target the largest number of devices (e.g. ios, android, and web).

## Usage

TODO...

<!-- We are almost there! The following steps are missing:

    $ cd stream_core

Then configure your database in config/dev.exs and run:

    $ mix ecto.create

Start your Phoenix app with:

    $ mix phx.server

You can also run your app inside IEx (Interactive Elixir) as:

    $ iex -S mix phx.server -->

## Screen Shots

TODO...

## Architecture

The current architecture is a monorepo divided in two modules:

### Core

It is the monolith that contains core stream services and web platform.

Current stack been used in the challenge:

#### Base

- [x] Elixir
- [x] Phoenix

#### Stream

- [x] Membrane Framework

#### Web

- [x] Live View
- [x] Tailwind
- [x] Alpine JS

### Mobile

TODO...
