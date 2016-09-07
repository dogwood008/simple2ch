require 'rspec'
require 'spec_helper'

VCR.use_cassette 'board' do
  describe Simple2ch::Board, vcr: true do
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
        it { is_expected.to raise_error Simple2ch::NotA2chUrlError }
      end

      context 'should raise URI::InvalidURL if URL is invalid format' do
        subject { -> { Simple2ch::Board.new(title, boards[:invalid_url][:url]) } }
        it { is_expected.to raise_error Simple2ch::NotA2chUrlError }
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
        subject { board.url.to_s }
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
        it { expect(board.title).to eq title }
        it { expect(board.url.built_url).to eq url }
      end
      include_examples '#threads' do
        let(:url) { boards[:sc][:url] }
      end
      include_examples '#threads' do
        let(:url) { boards[:open][:url] }
      end
    end
  end
end
