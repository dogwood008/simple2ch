require 'rspec'
require 'spec_helper'

VCR.use_cassette 'thread' do
  describe Simple2ch::Thread, vcr: true do  
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
        let(:url) { threads[type_of_2ch][:url] }
        let(:thread_key) { Bbs2chUrlValidator::URL.parse(url).thread_key }
        let(:thread) { Simple2ch::Thread.new(url) }
        let(:board) { Board.new nil, boards[type_of_2ch][:url] }
        subject { thread }
        it { should be_a_kind_of Simple2ch::Thread }
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

    describe '#responses' do
      let(:thread) {Simple2ch::Thread.new(threads[type_of_2ch][:url]) }
      subject { thread.responses }
      let(:type_of_2ch) { :sc }
      it { should be_a_kind_of Array }
      its(:first) { should be_a_kind_of Simple2ch::Response }
      its(:first) { should be_a_valid_response }
    end

    describe '#title' do
      let(:thread) {Simple2ch::Thread.new(threads[type_of_2ch][:url]) }
      subject { thread.title }
      let(:type_of_2ch) { :sc }
      it { should be_a_kind_of String }
      its(:size) { should be > 0 }
    end
  end
end
