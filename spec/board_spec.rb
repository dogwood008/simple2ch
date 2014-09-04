require 'rspec'
require 'spec_helper'

describe Board do
  let(:url) { 'http://test' }
  let(:board) { Board.new(url) }

  context 'should get board title' do
    subject do
      board.get_title
    end
    #its('is_a?') { expect.to eq(Array) }
    it { expect(subject.is_a?).to eq(String) }
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
