require 'rspec'
require 'spec_helper'

describe Board do
  context 'should get list' do
    subject do
     Ruby2ch.get_board_list
    end
    its('is_a?') { expect.to(Array) }
    it do
      subject.each do |b|
        expect(b.is_a?).to eq(Board)
      end
    end
  end
end

