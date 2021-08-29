$LOAD_PATH << "."

require "rspec"
require "open3"

describe "the cli" do
  let(:input) { "quit\n" }

  shared_examples "matches output" do |file, save_output|
    let(:output_path) { File.join(File.dirname(__FILE__), file) }
    let(:expected_output) {
      begin
        File.read(output_path)
      rescue
        ""
      end
    }

    it { is_expected.to eq expected_output }

    if save_output
      after do
        File.open(output_path, "w") { |f| f << subject }
      end
    end
  end

  subject do
    output = ""

    Dir.chdir(File.join(File.dirname(__FILE__), "..")) do
      Open3.popen3("./main.rb") do |stdin, stdout, stderr|
        stdin << input
        stdin.close
        output = stdout.read
      end

      output
    end
  end

  context "document search" do
    context "users" do
      let(:input) { "1\n1\n_id\n2\n" }

      it_behaves_like "matches output", "users.txt", false
    end

    context "tickets" do
      let(:input) { "1\n2\ntags\nTexas\n" }

      it_behaves_like "matches output", "tickets.txt", false
    end
  end

  context "fields" do
    let(:input) { "2\n" }

    it_behaves_like "matches output", "fields.txt", false
  end
end
