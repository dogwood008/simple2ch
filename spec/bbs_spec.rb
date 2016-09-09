require 'spec_helper'

VCR.use_cassette 'bbs' do
  describe Simple2ch::BBS, vcr: true do
    describe '#boards' do
      shared_examples '#boards' do |force_reload|
        shared_examples 'get board list from bbsmenu' do |bbs, type_of_2ch|
          subject { bbs.boards(force_reload: force_reload) }
          it { expect(bbs.type_of_2ch).to eq type_of_2ch }
          it { is_expected.not_to be_empty }
          it { is_expected.to have_news4vip }
        end

        context 'from 2ch.sc' do
          include_examples 'get board list from bbsmenu', Simple2ch::BBS.new(:sc), :sc
        end
        context 'from open2ch.net' do
          include_examples 'get board list from bbsmenu', Simple2ch::BBS.new(:open), :open
        end
      end

      context 'use cache' do
        it_behaves_like '#boards', false
      end
      context 'use force reload' do
        it_behaves_like '#boards', true
      end
    end
  end
end
