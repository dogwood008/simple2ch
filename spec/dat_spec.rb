require 'rspec'
require 'spec_helper'

VCR.use_cassette 'dat' do
  describe Simple2ch::Dat, vcr: true do
    #let(:dat_data) { '1409796283.dat<>Ｃ言語の勉強始めたんだがな (144)' }
    let(:thre) { Simple2ch::Thre.new('http://viper.2ch.sc/test/read.cgi/news4vip/1409796283/') }
    let(:thread_key) { '1409796283' }
    let(:dat) { Simple2ch::Dat.new thre }

    context 'should have thread key' do
      subject { dat.url.thread_key }
      it { is_expected.to be_a_kind_of(String) }
      it { is_expected.to match /\d{10}/ }
    end

    context 'should have responses' do
      subject { dat.responses }
      it { is_expected.to be_a_kind_of(Array) }
      its(:size) { is_expected.to be == 144 }
      it { expect(dat.kako_log?).to be == true }
      it do
        subject.each do |r|
          expect(r).to be_a_kind_of(Simple2ch::Res)
        end
      end
    end
  end
end
