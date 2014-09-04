require 'rspec'
require 'spec_helper'

describe Board do
  let(:title) { 'ニュー速VIP' }
  let(:url) do
    {
        sc: 'http://viper.2ch.sc/news4vip/',
        net: 'http://viper.2ch.net/news4vip/',
        open: 'http://viper.open2ch.net/news4vip/'
    }
  end
  let(:board) { Board.new(title, url[:sc]) }

  context 'should get board title' do
    subject do
      board.title
    end
    it { is_expected.to be_a_kind_of(String) }
    it { is_expected.to eq title }
  end

  context 'should get board url' do
    subject do
      board.url
    end
    it { is_expected.to be_a_kind_of(URI) }
    it { is_expected.to eq URI.parse(url[:sc]) }
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
