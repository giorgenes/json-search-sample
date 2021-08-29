#!/bin/env ruby

require "./lib/cli"
require "./lib/json_database"

users = JsonDatabase.new(name: "Users", display_field: "name")
tickets = JsonDatabase.new(name: "Tickets", display_field: "subject")

users.load_json_file("users.json")
tickets.load_json_file("tickets.json")

CLI.new(databases: [users, tickets], relations:  {
  "Users" => {"_id" => "Tickets.assignee_id"},
  "Tickets" => {"assignee_id" => "Users._id"}
}).execute
