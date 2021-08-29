$LOAD_PATH << "."

require "json_database"
require "rspec"

describe JsonDatabase do
  let(:database) { JsonDatabase.new(name: "Movies", display_field: "name") }
  let(:thematrix) { {"_id" => 10, "name" => "The Matrix", "rating" => 10, "stars" => "five", "tags" => ["scifi"]} }
  let(:inception) { {"_id" => 11, "name" => "Inception", "rating" => 10, "stars" => "five", "tags" => ["scifi"]} }
  let(:residentevil) { {"_id" => 12, "name" => "Residend Evil", "rating" => 4, "stars" => "one", "tags" => ["scifi", "horror"]} }

  shared_examples "finds docs" do |term, value|
    let(:field_name) { term }
    let(:field_value) { value }

    it "find the values" do
      expect(subject).to eq expected_docs
    end
  end

  describe "#find_by" do
    before do
      database.add_docs([thematrix, inception, residentevil])
    end

    subject { database.find_by(field_name, field_value) }

    context "searching a string field" do
      context "with a single found document" do
        let(:expected_docs) { [thematrix] }

        it_behaves_like "finds docs", "name", "The Matrix"
      end

      context "with a multiple found documents" do
        let(:expected_docs) { [thematrix, inception] }

        it_behaves_like "finds docs", "stars", "five"
      end
    end

    context "searching an integer field" do
      context "with a single found document" do
        let(:expected_docs) { [thematrix] }

        it_behaves_like "finds docs", "_id", "10"
      end

      context "with a multiple found documents" do
        let(:expected_docs) { [thematrix, inception] }

        it_behaves_like "finds docs", "rating", "10"
      end
    end

    context "searching an array field" do
      context "with a single found document" do
        let(:expected_docs) { [residentevil] }

        it_behaves_like "finds docs", "tags", "horror"
      end

      context "with a multiple found documents" do
        let(:expected_docs) { [thematrix, inception, residentevil] }

        it_behaves_like "finds docs", "tags", "scifi"
      end
    end
  end
end
