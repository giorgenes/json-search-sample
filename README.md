[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/giorgenes/json-search-sample)

[![CircleCI](https://circleci.com/gh/circleci/circleci-docs.svg?style=svg)](https://circleci.com/gh/circleci/circleci-docs)




## Testing

Tests can be executed by simply running `rspec` in the terminal.

## Caveats and Assumptions

- I'm not handling data types. Types are converted to string for simplicity to avoid having to figure out the data
  and map between user input and the database. Also to prevent having different types of indexes.
- I doesn't properly handle fetching by fields with lots elements (ie, there's no pagination), for example searching boolean fields.
