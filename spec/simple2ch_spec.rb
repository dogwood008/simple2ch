require 'rspec'
require 'spec_helper'


describe Simple2ch do
  before(:all) do
    @sc = Simple2ch::BBS.new(:sc)
    @open = Simple2ch::BBS.new(:open)
  end

  describe '#new' do
    shared_examples '#new' do
      subject { s2 }
      it { should be_a_kind_of Simple2ch::BBS }
    end

    context '2ch.sc' do
      include_examples '#new' do
        let(:s2) { @sc }
        let(:type_of_2ch) { :sc }
      end
    end
    context 'open2ch.net' do
      include_examples '#new' do
        let(:s2) { @open }
        let(:type_of_2ch) { :open }
      end
    end
  end

  describe '#find' do
    context 'when only a board' do
      let(:title) { 'ニュー速VIP' }
      let(:bbs) { @sc }
      subject { bbs.find(title) }
      it { should a_kind_of(Simple2ch::Board) }
      it { expect(bbs[title]).to be_a_kind_of(Simple2ch::Board)}
      its(:title) { should eq title }
    end
  end
  describe '#["search_word"]' do
  end
end