$: << "."

require 'example'
require 'rspec'

describe MyProblem do
  describe '#matches?' do
    MyProblem.new(2).matches?('124A').should_not == nil
  end
end
