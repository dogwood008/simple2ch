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

  skip 'ここから未完'
  describe '#title' do
    subject { board.title }
    it { is_expected.to be_a_kind_of(String) }
    it { is_expected.to eq title }
  end

  describe '#url' do
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

=begin

  describe Simple2ch::Board do
    describe '#responses' do
      skip 'TODO'
      let(:sc) { @sc }
      let(:board_name) { 'ニュー速VIP' }
      let(:board_url) { 'http://viper.2ch.sc/news4vip/' }
      let(:board) { Board.new board_name, board_url }
      let(:threads) { board.threads }
      let(:res) { threads[0].responses[0] }

      it { expect(board.threads).to be_a_kind_of Array }
      it { expect(board.threads.size).to be > 0 }

      it { expect(threads[0]).to be_a_kind_of Thre }
      it { expect(threads[0].reses).to be_a_kind_of Array }

      it { expect(res).to be_a_kind_of Res }
      it { expect(res.date).to be < Time.now }
      it { expect(res.author_id.size).to be > 0 }
    end
  end
=end
end
