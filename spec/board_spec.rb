require 'rspec'
require 'spec_helper'

describe Ruby2ch::Board do
  let(:title) { 'ニュー速VIP' }
  let(:url) do
    {
        sc: 'http://viper.2ch.sc/news4vip/',
        net: 'http://viper.2ch.net/news4vip/',
        #open: 'http://viper.open2ch.net/news4vip/', #TODO
        not_a_2ch_format: 'http://test.example.com/hoge/',
        invalid_url: 'http://abc_def.com/foobar/' # under score in host is invalid
    }
  end
  let(:board) { Ruby2ch::Board.new(title, url[:sc]) }

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
    subject { board.threads }
    it { is_expected.to be_a_kind_of(Array) }
    it { subject.each{ |t| expect(t).to be_a_kind_of(Ruby2ch::Thre) } }
    its(:size) { is_expected.to be > 0 }
  end

  context 'should raise NotA2chUrlException if URL is not a 2ch format' do
    subject { lambda{ Ruby2ch::Board.new(title, url[:not_a_2ch_format]) } }
    it { is_expected.to raise_error Ruby2ch::NotA2chUrlException }
  end

  context 'should raise URI::InvalidURL if URL is invalid format' do
    subject { lambda{ Ruby2ch::Board.new(title, url[:invalid_url]) } }
    it { is_expected.to raise_error URI::InvalidURIError }
  end
end
