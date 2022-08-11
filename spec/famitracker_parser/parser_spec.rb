# frozen_string_literal: true

RSpec.describe FamitrackerParser::Parser do
  let(:exported_2a03_text) { fixture("2a03-example.txt") }
  let(:invalid_text) { fixture("invalid-file.txt") }
  let(:song) { FamitrackerParser::Parser.new(exported_2a03_text.read).parse! }

  it "Raises error when file is invalid" do
    expect { FamitrackerParser::Parser.new(invalid_text.read).parse! }.to raise_error
  end

  it "Finds information on the file correctly" do
    expect { song }.not_to raise_error
    expect(song.song_information.title).to eq "Parser Example"
    expect(song.dpcm_samples[2].name).to eq "dpcm d5"
    expect(song.global_settings.vibrato).to eq 1
    song.macros[13].tap do |macro|
      expect(macro.values).to eq [12, 12, 12, 12, 12, 12, 0, 0, 0, 0, 0, 0, 0, 0]
      expect(macro.loop_index).to eq 0
      expect(macro.release_index).to eq 5
    end
    song.instruments[4].tap do |piano|
      expect(piano.name).to eq "piano"
      expect(piano.volume_macro).to eq 4
    end
    expect(song.tracks.size).to eq 4
    song.tracks[3].tap do |track|
      expect(track.name).to eq "Neon Starlight - Necrophageon"
      expect(track.tempo).to eq 150
      track.patterns[1].rows[3].channels[0] do |some_row_channel|
        expect(some_row_channel.note_octave).to eq "A#2"
        expect(some_row_channel.volume).to eq 3
        expect(some_row_channel.instrument).to eq 24
        some_row_channel.effects[0].tap do |effect|
          expect(effect.command).to eq "V"
          expect(effect.argument).to eq 1
        end
      end
    end
  end
end
