require 'rspec'
require 'spec_helper'

describe Ruby2ch::Res do
  let(:dat_data) { %q{以下、＼(^o^)／でVIPがお送りします<><>2014/09/04(木) 18:46:36.03 ID:wBAvTswZ0.net<> http://livedoor.blogimg.jp/hatima/imgs/b/c/bccae87d.jpg <br>  <br>  <br> ※二次創作ではなく、公式です <>古参よ、これが今の東方projectだ
以下、＼(^o^)／でVIPがお送りします<><>2014/09/04(木) 18:47:10.12 ID:X4fy/81O0.net<> うそつけ <>
以下、＼(^o^)／でVIPがお送りします<><>2014/09/04(木) 18:47:14.08 ID:WDyAzc5v0.net<> 嘘乙 <>
以下、＼(^o^)／でVIPがお送りします<><>2014/09/04(木) 18:47:19.71 ID:9QYJSuKn0.net<> 正直楽しみ <>
以下、＼(^o^)／でVIPがお送りします<><>2014/09/04(木) 18:47:35.65 ID:rbjZvMWo0.net<> はてぃま <>
以下、＼(^o^)／でVIPがお送りします<><>2014/09/04(木) 18:47:41.41 ID:bHgEtoQU0.net<> 思い切り二次創作じゃねえか <br> PS4でやるんだっけ <>} }
  let(:res) { dat_data.split(/\n/).map.with_index(1) { |d, i| Ruby2ch::Res.parse i, d } }

  context 'should have res number' do
    subject { res[0].res_num }
    it { is_expected.to be_a_kind_of(Numeric) }
    it { is_expected.to be > 0 }
  end

  context 'should have author' do
    subject { res[0].author }
    it { is_expected.to be_a_kind_of(String) }
    it { is_expected.not_to be eq nil }
  end

  context 'should have author_id' do
    subject { res[0].author_id }
    it { is_expected.to be_a_kind_of(String) }
    it { is_expected.not_to be eq nil }
  end

  context 'should have contents' do
    subject { res[0].contents }
    it { is_expected.to be_a_kind_of(String) }
    it { is_expected.not_to be eq nil }
  end

  context 'should have date' do
    subject { res[0].date }
    it { is_expected.to be_a_kind_of(Time) }
    it { is_expected.not_to be eq nil }
  end
end
