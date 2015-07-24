require 'rspec'
require 'spec_helper'

describe Simple2ch::BBS do
  before(:all) do
    @sc = Simple2ch::BBS.new(:sc)
    @open = Simple2ch::BBS.new(:open)
  end

  describe '#get_boards_by_type_of_2ch' do
    shared_examples '#get_boards_by_type_of_2ch' do
      shared_examples 'get board list from bbsmenu' do
        subject { bbs.get_boards_by_type_of_2ch(type_of_2ch, force_reload: force_reload) }
        it { expect(bbs.type_of_2ch).to eq type_of_2ch }
        it { is_expected.not_to be_empty }
        it { is_expected.to have_news4vip }
      end

      context 'from 2ch.sc' do
        include_examples 'get board list from bbsmenu' do
          let(:bbs) { @sc }
          let(:type_of_2ch) { :sc }
        end
      end
      context 'from open2ch.net' do
        include_examples 'get board list from bbsmenu' do
          let(:bbs) { @open }
          let(:type_of_2ch) { :open }
        end
      end
    end

    context 'use cache' do
      let(:force_reload) { false }
      it_behaves_like '#get_boards_by_type_of_2ch'
    end
    context 'use force reload' do
      let(:force_reload) { true }
      it_behaves_like '#get_boards_by_type_of_2ch'
    end
  end

  describe '#boards' do
    shared_examples 'get board list from bbsmenu' do
      subject { bbs.boards }
      it { expect(bbs.type_of_2ch).to eq type_of_2ch }
      it { is_expected.not_to be_empty }
      it { is_expected.to have_news4vip }
    end

    context 'from 2ch.sc' do
      let(:bbs) { @sc }
      let(:type_of_2ch) { :sc }
      include_examples 'get board list from bbsmenu'
    end
    context 'from open2ch.net' do
      let(:bbs) { @open }
      let(:type_of_2ch) { :open }
      include_examples 'get board list from bbsmenu'
    end
  end
end