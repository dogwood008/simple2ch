require 'rspec'
require 'spec_helper'

RSpec::Matchers.define :have_news4vip do
  match do |boards|
    boards.find{|b| b.title == 'ニュー速VIP'}
  end
end

describe Simple2ch do
  describe 'should get board from board list' do
    let(:board_list_url) { {net: 'http://menu.2ch.net/bbsmenu.html', sc: 'http://2ch.sc/bbsmenu.html', open: 'http://open2ch.net/menu/pc_menu.html' } }
    shared_examples 'get board list from bbsmenu' do
      subject{ Simple2ch.board_lists(bbsmenu_url, site) }
      it{ is_expected.not_to be_empty }
      it{ is_expected.to have_news4vip}
    end

    context 'from 2ch.net' do
      let(:bbsmenu_url) { board_list_url[:net] }
      let(:site) { :net }
      include_examples 'get board list from bbsmenu'
    end
  end

  context 'should get reses from board url' do
    before(:all) do
      board_name = 'ニュー速VIP'
      board_url = 'http://viper.2ch.sc/news4vip/'
      @board = Board.new board_name, board_url
      @threads= @board.thres
      @res = @threads[0].reses[0]
    end
    it{ expect(@board.thres).to be_a_kind_of Array }
    it do
      #@threads = board.threads
      expect(@board.thres.size).to be > 0
    end

    it { expect(@threads[0]).to be_a_kind_of Thre }
    it { expect(@threads[0].reses).to be_a_kind_of Array }

    it do
      #@res = @threads[0].reses[0]
      expect(@res).to be_a_kind_of Res
    end
    it { expect(@res.date).to be < Time.now }
    it { expect(@res.author_id.size).to be > 0 }

  end


#its(:reses){ is_expected.to be a_kind_of Array}
end