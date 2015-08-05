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
    shared_examples '#find' do
      shared_examples '_#find' do
        let(:title) { 'ニュー速VIP' }
        it { should a_kind_of(Simple2ch::Board) }
        its(:title) { should eq title }
      end

      include_examples '_#find' do
        subject { bbs.find(title) }
      end
      include_examples '_#find' do
        subject { bbs[title] }
      end
    end

    context 'open2ch.net' do
      include_examples '#find' do
        let(:bbs) { @open }
      end
    end
    context '2ch.sc' do
      include_examples '#find' do
        let(:bbs) { @sc }
      end
    end
  end

  describe '#contain' do
    shared_examples '#contain_all' do
      subject { bbs.contain(title) }
      let(:title) { 'の' }
      it { should a_kind_of(Simple2ch::Board) }
      it { expect(subject.title.index(title)).to be_truthy }
    end

    context 'open2ch.net' do
      include_examples '#contain_all' do
        let(:bbs) { @open }
      end
    end
    context '2ch.sc' do
      include_examples '#contain_all' do
        let(:bbs) { @sc }
      end
    end
  end

  describe '#contain_all' do
    shared_examples '#contain_all' do
      subject { bbs.contain_all(title) }
      let(:title) { 'の' }
      it { should a_kind_of(Array) }
      its(:size) { should be > 0 }
      its(:first) { should be_a_kind_of(Simple2ch::Board)}
      it { expect(subject.last.title.index(title)).to be_truthy }
    end

    context 'open2ch.net' do
      include_examples '#contain_all' do
        let(:bbs) { @open }
      end
    end
    context '2ch.sc' do
      include_examples '#contain_all' do
        let(:bbs) { @sc }
      end
    end
  end
end