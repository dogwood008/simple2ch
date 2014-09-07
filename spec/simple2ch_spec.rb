require 'rspec'
require 'spec_helper'

describe Simple2ch do
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