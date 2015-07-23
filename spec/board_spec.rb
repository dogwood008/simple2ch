require 'rspec'
require 'spec_helper'

describe Simple2ch::Board do
  before(:all) do
    @sc = Simple2ch::BBS.new(:sc)
    @open = Simple2ch::BBS.new(:open)
  end

  let(:title) { 'ニュー速VIP' }
  let(:urls) do
    {
        sc: 'http://viper.2ch.sc/news4vip/',
        open: 'http://viper.open2ch.net/news4vip/',
        not_a_2ch_format: 'http://test.example.com/hoge/',
        invalid_url: 'http://abc_def.com/foobar/' # under score in host is invalid
    }
  end
  let(:board) { Simple2ch::Board.new(title, url) }

  describe '#new' do
    context 'should raise NotA2chUrlException if URL is not a 2ch format' do
      subject { -> { Simple2ch::Board.new(title, urls[:not_a_2ch_format]) } }
      it { is_expected.to raise_error Simple2ch::NotA2chUrlException }
    end

    context 'should raise URI::InvalidURL if URL is invalid format' do
      subject { -> { Simple2ch::Board.new(title, urls[:invalid_url]) } }
      it { is_expected.to raise_error URI::InvalidURIError }
    end
  end

  describe '#setting_txt' do
    shared_examples '#setting_txt' do
      subject { board.setting :BBS_TITLE }
      it { is_expected.to eq title }
    end
    include_examples '#setting_txt' do
      let(:url) { urls[:sc] }
    end
    include_examples '#setting_txt' do
      let(:url) { urls[:open] }
    end
  end

  describe '#title' do
    shared_examples '#title' do
      subject { board.title }
      it { is_expected.to be_a_kind_of(String) }
      it { is_expected.to eq title }
    end
    include_examples '#title' do
      let(:url) { urls[:sc] }
    end
    include_examples '#title' do
      let(:url) { urls[:open] }
    end
  end

  describe '#url' do
    shared_examples '#url' do
      subject { board.url }
      it { is_expected.to be_a_kind_of(URI) }
      it { is_expected.to eq URI.parse(url) }
    end
    include_examples '#url' do
      let(:url) { urls[:sc] }
    end
    include_examples '#url' do
      let(:url) { urls[:open] }
    end
  end

  describe '#threads' do
    shared_examples '#threads' do
      let(:board) { Simple2ch::Board.new(title, url) }
      subject { board.threads }
      it { is_expected.to be_a_kind_of(Array) }
      it { subject.each { |t| expect(t).to be_a_kind_of(Simple2ch::Thre) } } #TODO Thre->Thread
      it { expect(board.threads.size).to be > 0 }
      it { expect(board.title).to be_a_kind_of String }
      it { expect(board.title).to be == title }
      it { expect(board.url.to_s).to be == url }
    end
    include_examples '#threads' do
      let(:url) { urls[:sc] }
    end
    include_examples '#threads' do
      let(:url) { urls[:open] }
    end
  end
end
