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

  describe '#reses' do
    shared_examples 'have specified reses' do
      subject{thre.reses(specified_reses)}
      it{is_expected.to be_a_kind_of Array}
      its(:size){is_expected.to be == size}
    end
    context 'when without res_num' do
      let(:size){144}
      let(:specified_reses){nil}
      it_behaves_like 'have specified reses'
    end

    context 'when with res_num' do
      let(:size){3}
      let(:specified_reses){[1,2,10]}
      it_behaves_like 'have specified reses'
      it{
        extracted_reses = thre.reses(specified_reses)
        expect(extracted_reses[2]).to be == thre.reses.find{|r| r.res_num==10}
      }
    end
  end
end
