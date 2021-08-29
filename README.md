# CLI JSON Database search

[![Gitpod ready-to-code](https://img.shields.io/badge/Gitpod-ready--to--code-908a85?logo=gitpod)](https://gitpod.io/#https://github.com/giorgenes/json-search-sample)
[![CircleCI](https://circleci.com/gh/circleci/circleci-docs.svg?style=svg)](https://circleci.com/gh/circleci/circleci-docs)


# Running and Setup

## Running on Gitpod

The environment is ready to test and run from the gitpod instance (button above). All you need to test is click the button and sign in to Gitpod
using your github account (it's free).

To run, simply type `./main.rb` on the terminal (TIP: There's already a tab running the CLI that you can simply jump in right away).

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
- I doesn't properly handle fetching by fields with lots elements (ie, there's no pagination), for example searching boolean fields.
