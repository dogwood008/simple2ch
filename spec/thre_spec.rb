require 'rspec'
require 'spec_helper'

describe Simple2ch::Thre do
  def first_res_from_html(source_url)
    source = Simple2ch.fetch(source_url)
  end

  before(:all) do
    @sc = Simple2ch::BBS.new(:sc)
    @open = Simple2ch::BBS.new(:open)
  end

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

  describe '#new' do
    shared_examples '#new' do
      let(:thread_key) { Simple2ch.parse_url(threads[type_of_2ch][:url])[:thread_key] }
      let(:thread) { Simple2ch::Thre.new board, thread_key }
      let(:board) { Board.new nil, boards[type_of_2ch][:url] }
      subject { thread }
      it { should be_a_kind_of Simple2ch::Thre }
      it { should be_valid_responses }
    end
    context '2ch.sc' do
      include_examples '#new' do
        let(:type_of_2ch) { :sc }
      end
    end
    context 'open2ch.net' do
      include_examples '#new' do
        let(:type_of_2ch) { :open }
      end
    end
  end

  describe '#create_from_url' do
    shared_examples '#create_from_url' do
      subject { thread }
      it { should be_a_kind_of Simple2ch::Thre }
      it { should be_valid_responses }
    end
    context '2ch.sc' do
      include_examples '#create_from_url' do
        let(:thread) { Simple2ch::Thre.create_from_url threads[:sc][:url] }
      end
    end
    context 'open2ch.net' do
      include_examples '#create_from_url' do
        let(:thread) { Simple2ch::Thre.create_from_url threads[:open][:url] }
      end
    end
  end

  describe '#parse' do
    shared_examples '#parse' do
      let(:board) { Board.new nil, boards[type_of_2ch][:url] }
      subject { Thre.parse board, thread_data }
      it { should be_an_kind_of Simple2ch::Thre }
      it { should be_valid_responses }
    end
    context '2ch.sc' do
      include_examples '#parse' do
        let(:type_of_2ch) { :sc }
        let(:thread_data) { '9990000001.dat<>★★★ ２ちゃんねる(sc)のご案内 ★★★ (6)' }
      end
    end
    context 'open2ch.net' do
      include_examples '#parse' do
        let(:type_of_2ch) { :open }
        let(:thread_data) { '1439125834.dat<>面白い洋画ランキングベスト10作ってみた！ (52)' }
      end
    end
  end

  describe '#responses' do
    let(:thread) { Thre.create_from_url threads[type_of_2ch][:url] }
    subject { thread.responses }
    let(:type_of_2ch) { :sc }
    it { should be_a_kind_of Array }
    its(:first) { should be_a_kind_of Simple2ch::Res }
    its(:first) { should be_a_valid_response }
  end

  describe '#title' do
    let(:thread) { Thre.create_from_url threads[type_of_2ch][:url] }
    subject { thread.title }
    let(:type_of_2ch) { :sc }
    it { should be_a_kind_of String }
    its(:size) { should be > 0 }
  end
end
