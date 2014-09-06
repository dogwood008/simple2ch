require 'rspec'
require 'spec_helper'

describe Thre do
  let(:board) { Board.new 'ニュース速報(VIP)', 'http://viper.2ch.sc/news4vip/'}
  let(:dat_data) { '1409796283.dat<>Ｃ言語の勉強始めたんだがな (144)' }
  let(:thre) { Thre.new(board, dat_data) }

  context 'should have title' do
    subject { thre.title }
    it { is_expected.to be_a_kind_of(String) }
  end

  context 'should have thread key' do
    subject { thre.thread_key }
    it { is_expected.to be_a_kind_of(String) }
    it { is_expected.to match /\d{10}/ }
  end

  context 'should have numbers of responses' do
    subject { thre.num_of_response }
    it { is_expected.to be_a_kind_of(Fixnum) }
    it { is_expected.to be > 0 }
  end

  context 'should have responses' do
    subject { thre.all_of_reses }
    it { is_expected.to be_a_kind_of(Array) }
    it { subject.each{ |r| expect(r).to be_a_kind_of(Res) } }
    its(:size) { is_expected.to be > 0 }
  end
end
