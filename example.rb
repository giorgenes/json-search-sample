#!/usr/bin/env ruby


class MyProblem
  def matches?(line)
    line =~ /[0-9]+/
  end

  def initialize(foo)
    puts foo
  end
end


