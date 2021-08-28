$LOAD_PATH << '.'

require 'cli'
require 'json_database'
require 'rspec'

describe CLI do
  let(:bars) { JsonDatabase.new('Bars') }
  let(:cocktails) { JsonDatabase.new('Cocktails') }
  let(:databases) { [bars, cocktails] }
  let(:input) { '' }
  let(:stdin) { StringIO.new(input) }
  let(:stdout) { StringIO.new }
  let(:cli) { CLI.new(input: stdin, output: stdout, databases: databases) }

  shared_examples 'finds document' do
    it 'shows the search' do
      expect(subject).to include("Searching users for #{field} with a value of #{value}")
    end

    it 'finds the documents' do
      docs.each do |doc|
        doc.each_pair do |k, v|
          expect(subject).to match("#{k}.+=.+#{v}")
        end
      end
    end
  end

  describe '#execute' do
    subject do
      cli.execute
      stdout.string
    end

    before do
      allow(bars).to receive(:fields) { %w[_id name tags] }
      allow(cocktails).to receive(:fields) { %w[_id name tags base] }
    end

    it 'displays the initial prompt' do
      expect(subject).to match('Welcome to Zendesk').and match('Press 1').and match('Press 2')
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
        expect(subject).to include('Select 1) Bars or 2) Cocktails')
      end

      context 'with table options' do
        let(:db) { bars }
        let(:input) { super() + "1\n" }

        it 'asks for search term' do
          expect(subject).to include('Enter search term')
        end

        context 'with search term' do
          let(:docs) { [] }
          let(:field) { 'tags' }
          let(:input) { super() + "#{field}\n" }

          it 'asks for search value' do
            expect(subject).to include('Enter search value')
          end

          context 'with a valid value' do
            let(:value) { '71' }
            let(:input) { super() + "#{value}\n" }

            before do
              expect(db).to receive(:find_by).with(field, value).and_return(docs)
            end

            context 'with a single document' do
              let(:field) { '_id' }
              let(:value) { '71' }
              let(:doc) { { _id: value } }
              let(:docs) { [doc] }

              it_behaves_like 'finds document'
            end

            context 'with multiple documents' do
              let(:field) { 'tags' }
              let(:value) { 'Melbourne' }
              let(:doc1) { { _id: '71' } }
              let(:doc2) { { _id: '72' } }
              let(:docs) { [doc1, doc2] }

              it_behaves_like 'finds document'
            end

            context 'with no documents' do
              let(:value) { 'notfound' }

              it 'shows not found' do
                expect(subject).to include('No documents found')
              end
            end
          end
        end
      end
    end

    context 'with fields option (2)' do
      let(:input) { super() + "2\n" }

      it 'shows the json fields' do
        expect(subject).to include("Search #{bars.name} with: _id, name, tags")
        expect(subject).to include("Search #{cocktails.name} with: _id, name, tags, base")
      end
    end
  end
end
