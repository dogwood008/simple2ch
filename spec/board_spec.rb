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
    subject { board.title }
    it { is_expected.to be_a_kind_of(String) }
    it { is_expected.to eq title }
  end

  context 'should get board url' do
    subject { board.url }
    it { is_expected.to be_a_kind_of(URI) }
    it { is_expected.to eq URI.parse(url[:sc]) }
  end

  context 'should get all of thread' do
    subject { board.all_of_threads }
    it { is_expected.to be_a_kind_of(Array) }
    it { subject.each{ |t| expect(t).to be_a_kind_of(Thre) } }
    its(:size) { is_expected.to be > 0 }
  end
end
