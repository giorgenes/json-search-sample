$LOAD_PATH << "."

require "cli"
require "json_database"
require "rspec"

describe CLI do
  let(:bars) { JsonDatabase.new(name: "Bars", display_field: "name") }
  let(:cocktails) { JsonDatabase.new(name: "Cocktails", display_field: "title") }
  let(:databases) { [bars, cocktails] }
  let(:input) { "" }
  let(:stdin) { StringIO.new(input) }
  let(:stdout) { StringIO.new }

  # Some useful data
  let(:workshop) { { "_id" => "10", "name" => "Workshop Bar" } }
  let(:whitehart) { { "_id" => "11", "name" => "Whitehart Bar" } }
  let(:mojito) { { "title" => "Mojito", "bar_id" => "10" } }
  let(:whiterussian) { { "title" => "White Russian", "bar_id" => "10" } }
  let(:ginandtonic) { { "title" => "Gin and Tonic", "bar_id" => "11" } }

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

  shared_examples "database search" do |db_choice, search_term, search_value|
    let(:input) { "1\n#{db_choice}\n#{search_term}\n#{search_value}\n" }

    before do
      expect(db).to receive(:find_by).with(search_term, search_value).and_return(expected_docs)
      expected_docs.each do |doc|
        expect(relation).to receive(:find_by).with(foreign_key, doc[key]).and_return(expected_related_docs)
      end
    end

    it "shows the search" do
      expect(subject).to include("Searching users for #{search_term} with a value of #{search_value}")
    end

    it "finds the documents" do
      expected_docs.each do |doc|
        doc.each_pair do |k, v|
          expect(subject).to match("#{k}.+=.+#{v}")
        end
      end
    end

    it "shows the related documents" do
      subject

      expected_related_docs.each do |related_doc|
        expect(subject).to match(related_doc[relation.display_field])
      end
    end
  end

  # shared_examples "database search" do |option|
  #   let(:input) { "1\n#{db_choice}\n#{search_term}\n#{search_value}\n"}

  #         let(:docs) { [] }
  #         let(:related_docs) { [] }
  #         let(:search_field) { "tags" }
  #         let(:input) { super() + "#{search_field}\n" }

  #         context "with a valid value" do
  #           let(:search_value) { key }
  #           let(:input) { super() + "#{search_value}\n" }
  #           let(:doc) { { "_id" => key } }
  #           let(:search_field) { "_id" }

  #           before do
  #             expect(db).to receive(:find_by).with(search_term, search_value).and_return(expected_docs)
  #           end

  #           context "with a single document" do
  #             let(:docs) { [doc] }

  #             it_behaves_like "finds document"
  #           end

  #           context "with an empty search_value" do
  #             let(:search_field) { "tags" }
  #             let(:search_value) { "" }
  #             let(:docs) { [doc] }

  #             it_behaves_like "finds document"
  #           end

  #           context "with multiple documents" do
  #             let(:search_field) { "tags" }
  #             let(:search_value) { "Melbourne" }
  #             let(:doc1) { { _id: "71" } }
  #             let(:doc2) { { _id: "72" } }
  #             let(:docs) { [doc1, doc2] }

  #             it_behaves_like "finds document"
  #           end

  #           context "with no documents" do
  #             let(:search_value) { "notfound" }

  #             it "shows not found" do
  #               expect(subject).to include("No documents found")
  #             end
  #           end
  #         end
  #       end
  #     end
  #   end
  # end

  describe "#execute" do
    subject do
      cli.execute
      stdout.string
    end

    before do
      allow(bars).to receive(:fields) { %w[_id name tags] }
      allow(cocktails).to receive(:fields) { %w[_id title tags] }
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

    context "with search option (1)" do
      let(:input) { "1\n" }

      it 'asks for "table" name' do
        expect(subject).to include("Select 1) Bars or 2) Cocktails")
      end

      context "with table options" do
        let(:input) { super() + "1\n" }

        it "asks for search term" do
          expect(subject).to include("Enter search term")
        end

        context "with search term" do
          let(:input) { super() + "tags\n" }

          it "asks for search value" do
            expect(subject).to include("Enter search value")
          end
        end
      end
    end

    context "with fields option (2)" do
      let(:input) { super() + "2\n" }

      it "shows the json fields" do
        expect(subject).to include("Search #{bars.name} with: _id, name, tags")
        expect(subject).to include("Search #{cocktails.name} with: _id, title, tags")
      end
    end

    context "searching the bars database" do
      let(:db) { bars }
      let(:key) { "_id" }
      let(:relation) { cocktails }
      let(:foreign_key) { "bar_id" }
      let(:expected_related_docs) { [] }

      context "with a single doc" do
        let(:expected_docs) { [whitehart] }

        it_behaves_like "database search", "1", "_id", "10"

        context "with a related document" do
          let(:expected_related_docs) { [whiterussian] }

          it_behaves_like "database search", "1", "_id", "10"
        end

        context "with multiple related document" do
          let(:expected_related_docs) { [whiterussian, mojito] }

          it_behaves_like "database search", "1", "_id", "10"
        end
      end

      context "with multiple docs" do
        let(:expected_docs) { [whitehart, workshop] }

        it_behaves_like "database search", "1", "tags", "Melbourne"
      end
    end

    context "searching the cocktails database" do
      let(:db) { cocktails }
      let(:key) { "bar_id" }
      let(:relation) { bars }
      let(:foreign_key) { "_id" }
      let(:expected_related_docs) { [] }

      context "with a single doc" do
        let(:expected_docs) { [mojito] }

        it_behaves_like "database search", "2", "_id", "10"

        context "with a related document" do
          let(:expected_related_docs) { [workshop] }

          it_behaves_like "database search", "2", "_id", "10"
        end

        context "with multiple related document" do
          let(:expected_related_docs) { [workshop, whitehart] }

          it_behaves_like "database search", "2", "_id", "10"
        end
      end

      context "with multiple docs" do
        let(:expected_docs) { [mojito, whiterussian] }

        it_behaves_like "database search", "2", "tags", "Sour"
      end
    end

    # TODO: test general output

  end
end
