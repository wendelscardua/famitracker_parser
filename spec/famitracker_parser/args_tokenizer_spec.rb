# frozen_string_literal: true

RSpec.describe FamitrackerParser::ArgsTokenizer do
  let(:sample_text) { %(  12    23  ==>  "Hello world" 3 1 4 1 5) }

  subject(:tokenizer) { described_class.new(sample_text) }

  it "Extracts tokens by type" do
    expect(subject.read(:decimal)).to eq 12
    expect(subject.read(:decimal)).to eq 23
    expect { subject.read("==>") }.not_to raise_error
    expect(subject.read(:string)).to eq "Hello world"
    expect(subject.read(array: :decimal)).to eq [3, 1, 4, 1, 5]
  end
end
