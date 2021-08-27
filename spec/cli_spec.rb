$LOAD_PATH << '.'

require 'cli'
require 'rspec'

describe CLI do
  let(:input) { '' }
  let(:stdin) { StringIO.new(input) }
  let(:stdout) { StringIO.new }
  let(:cli) { CLI.new(stdin, stdout) }

  describe '#execute' do
    subject { cli.execute; stdout.string }

    it 'displays the initial prompt' do
      expect(subject).to match('Welcome to Zendesk').
        and match('Press 1').
        and match('Press 2')
    end

    context 'with quit command' do
      let(:input) { "quit\n" }

      it 'finishes the operation' do
        expect(subject).to match('Goodbye')
      end
    end

    context 'with an invalid command' do
      let(:input) { "invalid\n" }

      it 'display an error' do
        expect(subject).to match('Invalid command')
      end
    end

    context 'with search option (1)' do
    end

    context 'with fields option (2)' do
    end
  end
end
