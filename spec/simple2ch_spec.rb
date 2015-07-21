require 'rspec'
require 'spec_helper'

RSpec::Matchers.define :have_news4vip do
  match do |boards|
    !boards.nil? && (news4vip = boards.find { |b| b.title == 'ニュー速VIP' }) && news4vip.url.to_s.index('news4vip')
  end
end

describe Simple2ch do
  describe 'should get board from board list' do
    #let(:board_list_url) { { sc: 'http://2ch.sc/bbsmenu.html', open: 'http://open2ch.net/menu/pc_menu.html' } }
    shared_examples 'get board list from bbsmenu' do
      before(:all) { @sc = Simple2ch::Simple2ch.new(:sc) }
      before(:all) { @open = Simple2ch::Simple2ch.new(:open) }
      subject { smpl.boards type_of_2ch }
      it { is_expected.not_to be_empty }
      it { is_expected.to have_news4vip }
    end

    context 'from 2ch.sc' do
      let(:smpl) { @sc }
      let(:type_of_2ch) { :sc }
      include_examples 'get board list from bbsmenu'
    end
    context 'from open2ch.net' do
      let(:smpl) { @open }
      let(:type_of_2ch) { :sc }
      let(:type_of_2ch) { :open }
      include_examples 'get board list from bbsmenu'
    end
  end

  describe 'should get reses from board url' do
    pending 'TODO'
    before do
      board_name = 'ニュー速VIP'
      board_url = 'http://viper.2ch.sc/news4vip/'
      @board = Board.new board_name, board_url
      @threads= @board.thres
      @res = @threads[0].reses[0]
    end
    it { expect(@board.thres).to be_a_kind_of Array }
    it { expect(@board.thres.size).to be > 0 }

    it { expect(@threads[0]).to be_a_kind_of Thre }
    it { expect(@threads[0].reses).to be_a_kind_of Array }

    it { expect(@res).to be_a_kind_of Res }
    it { expect(@res.date).to be < Time.now }
    it { expect(@res.author_id.size).to be > 0 }
  end
end