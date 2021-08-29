# CLI JSON Database search

[![Gitpod ready-to-code](https://img.shields.io/badge/Gitpod-ready--to--code-908a85?logo=gitpod)](https://gitpod.io/#https://github.com/giorgenes/json-search-sample)
[![CircleCI](https://circleci.com/gh/circleci/circleci-docs.svg?style=svg)](https://circleci.com/gh/circleci/circleci-docs)

# Design

The application has 3 main components depicted in the class diagram below.
  - [main.rb](main.rb): simple ruby executable that loads the json database files and pass it on to the CLI class
  - [CLI](lib/cli.rb) class: Handles all the user interaction and output and delegates the searches to the `JsonDatabase` instances.
  - [JsonDatabase](lib/json_database.rb): Handles the logic of loading a single json database, indexing and searching it.

![](https://yuml.me/04156771.svg)


### Json Database

#### Indexing
Indexing works by breaking down each field into its unique index. An index is sorted list of values which points to the actual document (`[value, document]`).

#### Searching

Searching is done by simply doing a binary search on the speficic field index, then collecting all elements around it (an index may have multiple duplicate keys pointing to different documents).


# Running and Setup

## Running on Gitpod

The environment is ready to test and run from the gitpod instance (button above). All you need to test is click the button and sign in to Gitpod
using your github account (it's free).

To run, simply type `./main.rb` on the terminal (TIP: There's already a tab running the CLI that you can simply jump in right away).

## Running from Docker

Build directly from github then run with the commands below:

```
docker build -t jsonsearch https://github.com/giorgenes/json-search-sample.git
docker run -ti jsonsearch
```

## Running Locally

The CLI application is built on ruby `2.7.3`. To run, make sure you have ruby installed and run the following commands to setup:

```
bundle install
./main.rb
```

## Testing

Tests can be executed by simply running `rspec` in the terminal.

# Caveats and Assumptions

- I'm not handling data types. Types are converted to string for simplicity to avoid having to figure out the data
  and map between user input and the database. Also to prevent having different types of indexes.
- It doesn't properly handle fetching by fields with lots elements (ie, there's no pagination), for example searching boolean fields.
