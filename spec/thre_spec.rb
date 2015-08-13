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
  shared_examples 'have specified reses' do
    subject { thre.reses(specified_reses) }
    it { is_expected.to be_a_kind_of Array }
    its(:size) { is_expected.to be == size }
  end
  shared_examples 'should be valid' do
    describe 'should have title' do
      subject { thre.title }
      it { is_expected.to be_a_kind_of(String) }
    end

    describe 'should have thread key' do
      subject { thre.thread_key }
      it { is_expected.to be_a_kind_of(String) }
      it { is_expected.to match /\d{10}/ }
    end

    describe 'should have numbers of responses' do
      subject { thre.num_of_response }
      it { is_expected.to be_a_kind_of(Fixnum) }
      it { is_expected.to be > 0 }
    end

    describe 'should have responses' do
      subject { thre.reses }
      it { is_expected.to be_a_kind_of(Array) }
      it { subject.each { |r| expect(r).to be_a_kind_of(Simple2ch::Res) } }
      its(:size) { is_expected.to be > 0 }
    end

    describe 'should have if Kako log' do
      subject { thre.kako_log? }
      it { is_expected.to kako_log }
    end

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

  describe 'should be created from URL' do
    shared_examples 'create from URL' do
      let(:thre) { Simple2ch::Thre.create_from_url(url) }
      subject { thre }
      it { is_expected.to be_a_kind_of Simple2ch::Thre }
      its(:board) { is_expected.to be_a_kind_of Simple2ch::Board }
      its('board.title') { is_expected.not_to be_empty }
      its(:title) { is_expected.not_to be_empty }
      include_examples 'should be valid'
    end
    context 'from 2ch.sc URL' do
      let(:url) { 'http://peace.2ch.sc/test/read.cgi/tech/1158807229/l50' }
      let(:kako_log) { be_falsey }
      include_examples 'create from URL'
    end
    context 'from open2ch.net URL' do
      let(:url) { 'http://toro.open2ch.net/test/read.cgi/tech/1371956681/l50' }
      let(:kako_log) { be_falsey }
      include_examples 'create from URL'
    end
  end

  describe 'should have a type of 2ch' do
    subject { Simple2ch::Thre.new(board, thread_key) }
    context '2ch.sc' do
      let!(:board) { Simple2ch::Board.new 'ニュース速報(VIP)', 'http://viper.2ch.sc/news4vip/' }
      let(:thread_key) { board.thres[0].thread_key }
      its(:type_of_2ch) { is_expected.to eq :sc }
    end
    context 'open2ch.net' do
      let!(:board) { Simple2ch::Board.new 'ニュース速報(VIP)', 'http://viper.open2ch.net/news4vip/' }
      let(:thread_key) { board.thres[0].thread_key }
      its(:type_of_2ch) { is_expected.to eq :open }
    end
  end

  describe 'is valid' do
    let(:board) { Simple2ch::Board.new 'ニュース速報(VIP)', 'http://viper.2ch.sc/news4vip/' }
    let(:dat_data) { '1409796283.dat<>Ｃ言語の勉強始めたんだがな (144)' }
    let(:thre) { Simple2ch::Thre.parse(board, dat_data) }
    let(:kako_log) { be_truthy }
    include_examples 'should be valid'

    context 'when without res_num' do
      let(:size) { 144 }
      let(:specified_reses) { nil }
      it_behaves_like 'have specified reses'
    end

    context 'when with res_nums' do
      let(:size) { 3 }
      let(:specified_reses) { [1, 2, 10] }
      it_behaves_like 'have specified reses'
      it {
        extracted_reses = thre.reses(specified_reses)
        expect(extracted_reses[2]).to be == thre.reses.find { |r| r.res_num==10 }
      }
    end

    context 'when with only a res_num' do
      let(:size) { 3 }
      let(:specified_res_num) { 10 }
      subject { thre.reses(specified_res_num) }
      it { is_expected.to be_a_kind_of Res }
      it {
        extracted_res = thre.reses(specified_res_num)
        expect(extracted_res).to be == thre.reses.find { |r| r.res_num==specified_res_num }
      }
    end
  end
end
