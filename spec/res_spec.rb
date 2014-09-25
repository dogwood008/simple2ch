require 'rspec'
require 'spec_helper'

describe Simple2ch::Res do
  let(:dat_data) { %q{以下、＼(^o^)／でVIPがお送りします<><>2014/09/04(木) 18:46:36.03 ID:wBAvTswZ0.net<> http://livedoor.blogimg.jp/hatima/imgs/b/c/bccae87d.jpg <br>  <br>  <br> ※二次創作ではなく、公式です <>古参よ、これが今の東方projectだ
以下、＼(^o^)／でVIPがお送りします<><>2014/09/04(木) 18:47:10.12 ID:X4fy/81O0.net<> うそつけ <>
以下、＼(^o^)／でVIPがお送りします<><>2014/09/04(木) 18:47:14.08 ID:WDyAzc5v0.net<> 嘘乙 <>
以下、＼(^o^)／でVIPがお送りします<><>2014/09/04(木) 18:47:19.71 ID:9QYJSuKn0.net<> 正直楽しみ <>
以下、＼(^o^)／でVIPがお送りします<><>2014/09/04(木) 18:47:35.65 ID:rbjZvMWo0.net<> はてぃま <>
以下、＼(^o^)／でVIPがお送りします<><>2014/09/04(木) 18:47:41.41 ID:bHgEtoQU0.net<> 思い切り二次創作じゃねえか <br> PS4でやるんだっけ <>} }
  let(:res) { dat_data.split(/\n/).map.with_index(1) { |d, i| Simple2ch::Res.parse i, d } }

  describe 'should have res number' do
    subject { res[0].res_num }
    it { is_expected.to be_a_kind_of(Numeric) }
    it { is_expected.to be > 0 }
  end

  describe 'should have author' do
    subject { res[0].author }
    it { is_expected.to be_a_kind_of(String) }
    it { is_expected.not_to be eq nil }
  end

  describe 'should have author_id' do
    subject { res[0].author_id }
    it { is_expected.to be_a_kind_of(String) }
    it { is_expected.not_to be eq nil }
  end

  describe 'should have contents' do
    subject { res[0].contents }
    it { is_expected.to be_a_kind_of(String) }
    it { is_expected.not_to be eq nil }
  end

  describe 'should have date' do
    subject { res[0].date }
    it { is_expected.to be_a_kind_of(Time) }
    it { is_expected.not_to be eq nil }
  end

  describe '#anchors' do
    shared_examples('have valid anchors') do
      let(:res_num) { 100 }
      subject { Res.new(res_num, contents: contents) }

      describe 'that\'s anchored res is valid' do
        its(:anchors) { is_expected.to be_a_kind_of Array }
        its(:anchors) { is_expected.to be == anchor }
        its('anchors.size') { is_expected.to be == anchor.size }
      end
    end
    context 'when it have anchors separated commas' do
      let(:contents) { %Q{&gt;&gt;1, 2,　3,12,　３４\n9} }
      let(:anchor) { [1, 2, 3, 12, 34] }
      it_behaves_like 'have valid anchors'
    end
    context 'when it have anchors separated commas & spaces' do
      let(:contents) { %Q{&gt;&gt;1, 2,　3 4　5　６, １２、　３４\n9} }
      let(:anchor) { [1, 2, 3, 4, 5, 6, 12, 34] }
      it_behaves_like 'have valid anchors'
    end
    context 'when it have anchors range' do
      let(:contents) { %Q{&gt;1-5\n9} }
      let(:anchor) { (1..5).to_a }
      it_behaves_like 'have valid anchors'
    end
    context 'when it have range and separated anchors pattern#1' do
      let(:contents) { %Q{&gt;1-5,6,8} }
      let(:anchor) { [1, 2, 3, 4, 5, 6, 8] }
      it_behaves_like 'have valid anchors'
    end
    context 'when it have range and separated anchors pattern#2' do
      let(:contents) { %Q{&gt;1,3, ９−１３\n25} }
      let(:anchor) { [1, 3, 9, 10, 11, 12, 13] }
      it_behaves_like 'have valid anchors'
    end
    context 'when it have ARASHI anchors' do
      let(:contents) { %Q{>1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,
>52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,

>>1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
　　∧＿∧
　 (´･ω･｀)　　 　　n
￣　..　 　 ＼　 　 （ E）
ﾌ ア.フ.ィ /ヽ ヽ_／／
>>21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40
　　∧＿∧
　 (´･ω･｀)　　 　　n
￣　　 ..　 ＼　 　 （ E）
ﾌ ア.フ.ィ /ヽ ヽ_／／
>>41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60 } }
      let(:anchor) { [] }
      it_behaves_like 'have valid anchors'
    end
    context 'when a thre have both id and non-id reses', force: true do
      let(:board_name) { 'プログラム技術' }
      let(:url) { 'http://toro.2ch.sc/tech/' }
      let(:thread_key) { '1382307475' }
      let(:board) { Board.new(board_name, url) }
      let(:thre) { Thre.new(board, thread_key) }
      subject{thre.reses}
      it{ is_expected.to be_a_kind_of Array }
    end

  end

  describe '#recepted_anchors' do
    let(:board_name) { 'ニュー速VIP' }
    let(:url) { 'http://viper.2ch.sc/news4vip/' }
    let(:thread_key) { '1409796283' }
    let(:board) { Board.new board_name, url }
    let(:thre) { Thre.new board, thread_key }
    let(:res) { thre.reses([40])[0] }
    let(:input_thre) { res.thre = thre }
    subject { input_thre; res.received_anchors }
    it { is_expected.to be_a_kind_of Array }
    its(:size) { is_expected.to be == 4 }
    it { is_expected.to be == [43, 44, 45, 54] }
  end

end
