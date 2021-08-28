#!/bin/env ruby

require './lib/cli'
require './lib/json_database'

databases = [
    JsonDatabase.new("Users"),
    JsonDatabase.new("Tickets")
]

CLI.new(databases: databases).execute