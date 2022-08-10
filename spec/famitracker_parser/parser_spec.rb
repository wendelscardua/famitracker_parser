# frozen_string_literal: true

RSpec.describe FamitrackerParser::Parser do
  let(:famitracker_text) { fixture("famitracker-export.txt") }

  it "Parses famitracker file without errors" do
    expect(FamitrackerParser::Parser.new(famitracker_text.read).parse).not_to be nil
  end
end
