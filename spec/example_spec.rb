$LOAD_PATH << '.'

require 'example'
require 'rspec'

describe MyProblem do
  context '#matches?' do

    subject { MyProblem.new(2).matches?('124A') }

    it { is_expected.not_to be_nil }
  end
end
