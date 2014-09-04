require 'rspec'
require 'spec_helper'

describe Thre do
  let(:dat_data) { '1409796283.dat<>Ｃ言語の勉強始めたんだがな (144)' }
  let(:board) { Thre.new(dat_data) }

  context 'should get title' do
    subject do
      board.title
    end
    it { is_expected.to be_a_kind_of(String) }
  end
=begin
  context 'should get list' do
    subject do
     Ruby2ch.get_board_list
    end
    #its('is_a?') { expect.to eq(Array) }
    it { expect(subject.is_a?).to eq(Array) }
    it do
      subject.each do |b|
        expect(b.is_a?).to eq(Board)
      end
    end
  end
=end
end
