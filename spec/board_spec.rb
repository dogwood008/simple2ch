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
            title: 'ニュー速VIP'
        },
        open: {
            url: 'http://viper.open2ch.net/news4vip/',
            title: 'ニュー速VIP'
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
  let(:threads) do
    {
        sc: {
            url: 'http://viper.2ch.sc/test/read.cgi/news4vip/9990000001/',
            title: '★★★ ２ちゃんねる(sc)のご案内 ★★★'.force_encoding('utf-8')
        },
        open: open2ch_thread_data_example
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
      it { is_expected.to be_a_kind_of(String) }
      it { is_expected.to eq url }
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
        let(:title) { threads[:sc][:title] }
        let(:url) { threads[:sc][:url] }
        let(:board) { Simple2ch::Board.new(nil, boards[:sc][:url], fetch_title: true) }
      end
    end
    context 'when open2ch.net' do
      include_examples '#find' do
        let(:title) { threads[:open][:title] }
        let(:url) { threads[:open][:url] }
        let(:board) { Simple2ch::Board.new(nil, boards[:open][:url], fetch_title: true) }
      end
    end
  end

  describe '#contain' do
    shared_examples '#contain' do
      subject { board.contain(title) }
      let(:title) { 'の' }
      it { should a_kind_of(Simple2ch::Thre) } #TODO: Thre->Thread
      it { expect(subject.title.index(title)).to be_truthy }
    end

    context 'open2ch.net' do
      include_examples '#contain' do
        let(:board) { @open['ニュー速VIP'] }
      end
    end
    context '2ch.sc' do
      include_examples '#contain' do
        let(:board) { @sc['ニュー速VIP'] }
      end
    end
  end

  describe '#contain_all' do
    shared_examples '#contain_all' do
      subject { board.contain_all(title) }
      let(:title) { 'の' }
      it { should a_kind_of(Array) }
      its(:size) { should be > 0 }
      its(:first) { should be_a_kind_of(Simple2ch::Thre) } #TODO: Thre->Thread
      it { expect(subject.last.title.index(title)).to be_truthy }
    end

    context 'open2ch.net' do
      include_examples '#contain_all' do
        let(:board) { @open['ニュー速VIP'] }
      end
    end
    context '2ch.sc' do
      include_examples '#contain_all' do
        let(:board) { @sc['ニュー速VIP'] }
      end
    end
  end
end
