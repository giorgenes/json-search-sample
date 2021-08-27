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
      let(:input) { "1\n" }

      it 'asks for "table" name' do
        expect(subject).to include('Select 1) Users or 2) Tickets')
      end

      context 'with table options' do
        let(:input) { super() + "1\n" }

        it 'asks for search term' do
           expect(subject).to include('Enter search term')
        end

        context 'with search term' do
          let(:input) { super() + "_id\n" }

          it 'asks for search value' do
            expect(subject).to include('Enter search value')
          end

          context 'with a valid value' do
            let(:input) { super() + "71\n" }

            it 'shows the corresponding element' do
              expect(subject).to include('Searching users for _id with a value of 71')
            end
          end
        end
      end
    end

    context 'with fields option (2)' do
      let(:input) { super() + "2\n" }

      it 'shows the json fields' do
          expect(subject).to include('Search Users with: _id, name')
          expect(subject).to include('Search Tickets with: _id, name')
      end
    end
  end
end
