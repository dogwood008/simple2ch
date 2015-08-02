require 'rspec'
require 'spec_helper'

describe Simple2ch::Board do
  before(:all) do
    @sc = Simple2ch::BBS.new(:sc)
    @open = Simple2ch::BBS.new(:open)
  end

  let(:title) { 'ニュー速VIP' }
  let(:boards) do
    {
        sc: {
            url: 'http://viper.2ch.sc/news4vip/',
            title: 'ニュース速報(VIP)＠２ちゃんねる'
        },
        open: {
            url: 'http://viper.open2ch.net/news4vip/',
            title: 'ニュース速報(VIP)＠２ちゃんねる'
        },
        not_a_2ch_format: {
            url: 'http://test.example.com/hoge/',
            title: nil
        },
        invalid_url: {
            url: 'http://^example.com', # carat in host is invalid
            title: nil
        }
    }
  end

  let(:board) { Simple2ch::Board.new(title, url) }

  describe '#new' do
    context 'should raise NotA2chUrlException if URL is not a 2ch format' do
      subject { -> { Simple2ch::Board.new(title, boards[:not_a_2ch_format][:url]) } }
      it { is_expected.to raise_error Simple2ch::NotA2chUrlException }
    end

    context 'should raise URI::InvalidURL if URL is invalid format' do
      subject { -> { Simple2ch::Board.new(title, boards[:invalid_url][:url]) } }
      it { is_expected.to raise_error URI::InvalidURIError }
    end
  end

  describe '#bbs' do
    let(:type_of_2ch) { :sc }
    let(:url) { boards[type_of_2ch][:url] }
    subject { board.bbs }

    it { is_expected.to be_a_kind_of Simple2ch::BBS }
    its(:type_of_2ch) { is_expected.to eq type_of_2ch }
  end

  describe '#setting_txt' do
    shared_examples '#setting_txt' do
      subject { board.setting :BBS_TITLE }
      it { is_expected.to eq title }
    end
    include_examples '#setting_txt' do
      let(:url) { boards[:sc][:url] }
    end
    include_examples '#setting_txt' do
      let(:url) { boards[:open][:url] }
    end
  end

  describe '#title' do
    shared_examples '#title' do
      subject { board.title }
      it { is_expected.to be_a_kind_of(String) }
      it { is_expected.to eq title }
    end
    include_examples '#title' do
      let(:url) { boards[:sc][:url] }
    end
    include_examples '#title' do
      let(:url) { boards[:open][:url] }
    end
  end

  describe '#url' do
    shared_examples '#url' do
      subject { board.url }
      it { is_expected.to be_a_kind_of(URI) }
      it { is_expected.to eq URI.parse(url) }
    end
    include_examples '#url' do
      let(:url) { boards[:sc][:url] }
    end
    include_examples '#url' do
      let(:url) { boards[:open][:url] }
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
      let(:url) { boards[:sc][:url] }
    end
    include_examples '#threads' do
      let(:url) { boards[:open][:url] }
    end
  end

=begin
  describe '#find' do
    shared_examples '#find' do
      subject { board.find(title) }
      it { should be_a_kind_of(Simple2ch::Thre) } #TODO: Thre -> Thread
      it { expect(board[title].title).to eq title }
      its(:title) { should eq title }
      its(:url) { should eq url }
    end
    context 'when 2ch.sc' do
      include_examples '#find' do
        let(:title) { boards[:sc][:title] }
        let(:url) { boards[:sc][:url] }
        let(:board) { Simple2ch::Board.new(nil, url, fetch_title: true) }
      end
    end
    context 'when open2ch.net' do
      include_examples '#find' do
        let(:title) { boards[:open][:title] }
        let(:url) { boards[:open][:url] }
        let(:board) { Simple2ch::Board.new(nil, url, fetch_title: true) }
      end
    end
  end
=end
end
