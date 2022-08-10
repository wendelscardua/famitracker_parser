# frozen_string_literal: true

RSpec.describe FamitrackerParser::Parser do
  let(:exported_2a03_text) { fixture("2a03-example.txt") }

  it "Parses 2a03 famitracker file without errors" do
    expect { FamitrackerParser::Parser.new(exported_2a03_text.read).parse! }.not_to raise_error
  end
end
