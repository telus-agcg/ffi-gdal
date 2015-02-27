require 'spec_helper'
require 'ogr/internal_helpers'

RSpec.describe OGR::InternalHelpers do
  describe '._boolean_access_flag' do
    context "when 'w'" do
      subject { OGR._boolean_access_flag('w') }
      it { is_expected.to eq true }
    end

    context "when 'r'" do
      subject { OGR._boolean_access_flag('r') }
      it { is_expected.to eq false }
    end

    context "when anything else" do
      it 'raises a RuntimeError' do
        expect { OGR._boolean_access_flag('a') }.to raise_exception RuntimeError
      end
    end
  end

  describe '._format_time_zone_for_ruby' do
    context 'time_zone is 0' do
      subject { OGR._format_time_zone_for_ruby(0) }
      it { is_expected.to be_nil }
    end

    context 'time_zone is 1' do
      subject { OGR._format_time_zone_for_ruby(1) }
      it { is_expected.to be_a String }
      it { is_expected.to_not be_empty }
    end

    context 'time_zone is 100' do
      subject { OGR._format_time_zone_for_ruby(100) }
      it { is_expected.to eq '+0' }
    end
  end

  describe '._format_time_zone_for_ogr' do
    context 'GMT' do
      subject { OGR._format_time_zone_for_ogr('asdf GMT') }
      it { is_expected.to eq 100 }
    end

    context 'not nil and not GMT' do
      subject { OGR._format_time_zone_for_ogr('asdf') }
      it { is_expected.to eq 1 }
    end

    context 'nil' do
      subject { OGR._format_time_zone_for_ogr(nil) }
      it { is_expected.to eq 0 }
    end
  end
end
