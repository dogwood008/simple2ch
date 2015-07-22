require 'rspec'
require 'spec_helper'

RSpec::Matchers.define :have_news4vip do
  match do |boards|
    !boards.nil? && (news4vip = boards.find { |b| b.title == 'ニュー速VIP' }) && news4vip.url.to_s.index('news4vip')
  end
end

describe Simple2ch do
  describe Simple2ch::BBS do
    before(:all) { @sc = Simple2ch::BBS.new(:sc) }
    before(:all) { @open = Simple2ch::BBS.new(:open) }

    describe '#boards' do
    #describe 'should get board from board list' do
      #let(:board_list_url) { { sc: 'http://2ch.sc/bbsmenu.html', open: 'http://open2ch.net/menu/pc_menu.html' } }
      shared_examples 'get board list from bbsmenu' do
        subject { bbs.boards(type_of_2ch) }
        it { expect(bbs.types_of_2ch).to include type_of_2ch }
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

    describe 'should get reses from board url' do
      skip 'TODO'
      let(:sc) { @sc }
      let(:board_name) { 'ニュー速VIP' }
      let(:board_url) { 'http://viper.2ch.sc/news4vip/' }
      let(:board) { Board.new board_name, board_url }
      let(:threads) { board.threads }
      let(:res) { threads[0].reses[0] }

      it { expect(@board.threads).to be_a_kind_of Array }
      it { expect(@board.threads.size).to be > 0 }

      it { expect(@threads[0]).to be_a_kind_of Thre }
      it { expect(@threads[0].reses).to be_a_kind_of Array }

      it { expect(@res).to be_a_kind_of Res }
      it { expect(@res.date).to be < Time.now }
      it { expect(@res.author_id.size).to be > 0 }
    end
  end
end