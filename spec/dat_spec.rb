require 'rspec'
require 'spec_helper'

describe Dat do
  let(:board) { Board.new 'ニュース速報(VIP)', 'http://viper.2ch.sc/news4vip/' }
  let(:dat_data) { '1409796283.dat<>Ｃ言語の勉強始めたんだがな (144)' }
  let(:thre) { Thre.new(board, dat_data) }
  let(:thread_key) { '1409796283' }
  let(:dat) { Dat.new thre }

  context 'should have thread key' do
    subject { dat.thread_key }
    it { is_expected.to be_a_kind_of(String) }
    it { is_expected.to match /\d{10}/ }
  end

  context 'should have reses' do
    subject { dat.reses }
    it { is_expected.to be_a_kind_of(Array) }
    its(:size) { is_expected.to be > 0 }
    it do
      subject.each do |r|
        expect(r).to be_a_kind_of(Res)
      end
    end
  end
end
