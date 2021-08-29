$LOAD_PATH << "."

require "json_database"
require "rspec"

describe JsonDatabase do
  let(:database) { JsonDatabase.new(name: "Movies", display_field: "name") }
  let(:thematrix) { {"_id" => 10, "name" => "The Matrix", "rating" => 10, "stars" => "five", "tags" => ["scifi"]} }
  let(:inception) { {"_id" => 11, "name" => "Inception", "rating" => 10, "stars" => "five", "tags" => ["scifi"]} }
  let(:residentevil) { {"_id" => 12, "name" => "Resident Evil", "rating" => 4, "stars" => "one", "tags" => ["scifi", "horror"]} }

  shared_examples "finds docs" do |term, value|
    let(:field_name) { term }
    let(:field_value) { value }

    it "find the values" do
      expect(subject).to match_array(expected_docs)
    end
  end

  RSpec::Matchers.define :equal_index_to do |values, docs|
    match do |actual|
      actual.map { |item| [item.value, item.doc] } == values.each_with_index.map { |value, index| [value, docs[index]] }
    end

    failure_message do |actual|
      "expected that #{actual.map { |item| [item.value, item.doc["name"]] }} would be a multiple of #{values.each_with_index.map { |value, index| [value, docs[index]["name"]] }}"
    end
  end

  describe "#fields" do
    subject { database.fields }

    before do
      database.add_docs([thematrix, inception, residentevil])
    end

    it { is_expected.to match_array(%w[_id name rating stars tags]) }
  end

  describe "#add_docs" do
    subject { database.indexes }

    before do
      database.add_docs([thematrix, inception, residentevil])
    end

    it "indexes all fields" do
      expect(subject.keys).to match_array(%w[_id name rating stars tags])
    end

    it "build the sorted indexes" do
      expect(subject["_id"]).to equal_index_to(["10", "11", "12"], [thematrix, inception, residentevil])
      expect(subject["name"]).to equal_index_to(["Inception", "Resident Evil", "The Matrix"], [inception, residentevil, thematrix])
      expect(subject["rating"]).to equal_index_to(["10", "10", "4"], [thematrix, inception, residentevil])
      expect(subject["tags"]).to equal_index_to(["horror", "scifi", "scifi", "scifi"], [residentevil, thematrix, inception, residentevil])
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

    context "with missing item" do
      let(:expected_docs) { [] }

      it_behaves_like "finds docs", "stars", "notfound"
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
