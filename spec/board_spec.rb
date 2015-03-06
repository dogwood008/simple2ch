require 'rspec'
require 'spec_helper'

describe Simple2ch::Board do
  let(:title) { 'ニュー速VIP' }
  let(:url) do
    {
        sc: 'http://viper.2ch.sc/news4vip/',
        net: 'http://viper.2ch.net/news4vip/',
        open: 'http://viper.open2ch.net/news4vip/',
        not_a_2ch_format: 'http://test.example.com/hoge/',
        invalid_url: 'http://abc_def.com/foobar/' # under score in host is invalid
    }
  end
  let(:board) { Simple2ch::Board.new(title, url[:sc]) }

  describe 'have a type of 2ch' do
    subject{ Simple2ch::Board.new(title, given_url) }
    context 'when 2ch.net' do
      let(:given_url){ url[:net] }
      its(:type_of_2ch){ is_expected.to eq :net }
    end
    context 'when 2ch.sc' do
      let(:given_url){ url[:sc] }
      its(:type_of_2ch){ is_expected.to eq :sc }
    end
    context 'when open2ch.net' do
      let(:given_url){ url[:open] }
      its(:type_of_2ch){ is_expected.to eq :open }
    end
  end

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
    subject { board.thres }
    it { is_expected.to be_a_kind_of(Array) }
    it { subject.each{ |t| expect(t).to be_a_kind_of(Simple2ch::Thre) } }
    its(:size) { is_expected.to be > 0 }
  end

  context 'should be a valid Simple2ch::Board object' do
    subject { Simple2ch::Board.new(title, url[:open]) }
    its(:title) { is_expected.to be_a_kind_of String }
    its(:title) { is_expected.to be == title }
    its('url.to_s') { is_expected.to be == url[:open] }
  end

  context 'should raise NotA2chUrlException if URL is not a 2ch format' do
    subject { lambda{ Simple2ch::Board.new(title, url[:not_a_2ch_format]) } }
    it { is_expected.to raise_error Simple2ch::NotA2chUrlException }
  end

  context 'should raise URI::InvalidURL if URL is invalid format' do
    subject { lambda{ Simple2ch::Board.new(title, url[:invalid_url]) } }
    it { is_expected.to raise_error URI::InvalidURIError }
  end
end
