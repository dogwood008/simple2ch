require 'rspec'
require 'spec_helper'

describe Simple2ch::Thre do
  let(:board) { Simple2ch::Board.new 'ニュース速報(VIP)', 'http://viper.2ch.sc/news4vip/'}
  let(:dat_data) { '1409796283.dat<>Ｃ言語の勉強始めたんだがな (144)' }
  let(:thre) { Simple2ch::Thre.parse(board, dat_data) }

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
    it { subject.each{ |r| expect(r).to be_a_kind_of(Simple2ch::Res) } }
    its(:size) { is_expected.to be > 0 }
  end

  describe 'should have if Kako log' do
    subject { thre.kako_log? }
    it { is_expected.to be_truthy }
  end
end
