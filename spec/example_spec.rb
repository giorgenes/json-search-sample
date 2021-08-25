$LOAD_PATH << '.'

require 'example'
require 'rspec'

describe MyProblem do
  describe '#matches?' do
    it 'matches' do
      expect(MyProblem.new(2).matches?('124A')).not_to be_nil
    end
  end
end
