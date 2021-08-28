$LOAD_PATH << "."

require "cli"
require "json_database"
require "rspec"

describe CLI do
  let(:bars) { JsonDatabase.new("Bars") }
  let(:cocktails) { JsonDatabase.new("Cocktails") }
  let(:databases) { [bars, cocktails] }
  let(:input) { "" }
  let(:stdin) { StringIO.new(input) }
  let(:stdout) { StringIO.new }
  let(:relations) do
    {
      "Bars" => { "_id" => "Cocktails.bar_id" },
      "Cocktails" => { "bar_id" => "Bars._id" },
    }
  end
  let(:cli) { CLI.new(input: stdin, output: stdout, databases: databases, relations: relations) }

  shared_examples "finds document" do
    before do
      docs.each do |doc|
        expect(relation).to receive(:find_by).with(foreign_key, doc[key]).and_return(related_docs)
      end
    end

    it "shows the search" do
      expect(subject).to include("Searching users for #{search_field} with a value of #{search_value}")
    end

    it "finds the documents" do
      docs.each do |doc|
        doc.each_pair do |k, v|
          expect(subject).to match("#{k}.+=.+#{v}")
        end
      end
    end

    context "with a related document" do
      let(:related_docs) { [related_doc] }
      let(:docs) { [doc] }

      it "shows the related documents" do
        expect(subject).to match(related_doc["name"])
      end
    end
  end

  shared_examples "database search" do |option|
    context "with search option (1)" do
      let(:input) { "1\n" }

      it 'asks for "table" name' do
        expect(subject).to include("Select 1) Bars or 2) Cocktails")
      end

      context "with table options" do
        let(:input) { super() + "#{option}\n" }

        it "asks for search term" do
          expect(subject).to include("Enter search term")
        end

        context "with search term" do
          let(:docs) { [] }
          let(:related_docs) { [] }
          let(:search_field) { "tags" }
          let(:input) { super() + "#{search_field}\n" }

          it "asks for search value" do
            expect(subject).to include("Enter search value")
          end

          context "with a valid value" do
            let(:search_value) { key }
            let(:input) { super() + "#{search_value}\n" }
            let(:doc) { { "_id" => key } }
            let(:search_field) { "_id" }

            before do
              expect(db).to receive(:find_by).with(search_field, search_value).and_return(docs)
            end

            context "with a single document" do
              let(:docs) { [doc] }

              it_behaves_like "finds document"
            end

            context "with an empty search_value" do
              let(:search_field) { "tags" }
              let(:search_value) { "" }
              let(:docs) { [doc] }

              it_behaves_like "finds document"
            end

            context "with multiple documents" do
              let(:search_field) { "tags" }
              let(:search_value) { "Melbourne" }
              let(:doc1) { { _id: "71" } }
              let(:doc2) { { _id: "72" } }
              let(:docs) { [doc1, doc2] }

              it_behaves_like "finds document"
            end

            context "with no documents" do
              let(:search_value) { "notfound" }

              it "shows not found" do
                expect(subject).to include("No documents found")
              end
            end
          end
        end
      end
    end
  end

  describe "#execute" do
    subject do
      cli.execute
      stdout.string
    end

    before do
      allow(bars).to receive(:fields) { %w[_id name tags] }
      allow(cocktails).to receive(:fields) { %w[_id name tags base] }
    end

    it "displays the initial prompt" do
      expect(subject).to match("Welcome to Zendesk").and match("Press 1").and match("Press 2")
    end

    context "with quit command" do
      let(:input) { "quit\n" }

      it "finishes the operation" do
        expect(subject).to match("Goodbye")
      end
    end

    context "with an invalid command" do
      let(:input) { "invalid\n" }

      it "display an error" do
        expect(subject).to match("Invalid command")
      end
    end

    it_behaves_like "database search", 1 do
      let(:db) { bars }
      let(:key) { "_id" }
      let(:relation) { cocktails }
      let(:foreign_key) { "bar_id" }
      let(:related_doc) { { "name" => "white russian", "bar_id" => "71" } }
    end

    context "with fields option (2)" do
      let(:input) { super() + "2\n" }

      it "shows the json fields" do
        expect(subject).to include("Search #{bars.name} with: _id, name, tags")
        expect(subject).to include("Search #{cocktails.name} with: _id, name, tags, base")
      end
    end
  end
end
