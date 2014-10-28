require 'spec_helper'

RSpec.describe FormJourney::Parameters do

  class DummyParamsController < ApplicationController
    include FormJourney::Controller
    include FormJourney::Parameters
    steps :step_one, :step_two, :step_three
  end

  subject { DummyParamsController.new }

  let(:params) do
    {
      action: :step_two,
      user: {
        name: 'Custom audience test',
        id: '123456'
      }
    }
  end

  let(:fake_session) { {} }

  before do
    allow(subject).to receive(:params) { params }
    allow(subject).to receive(:session) { fake_session }
    subject.send(:update_journey_params)
  end

  describe '#get_step_param' do
    it 'fetches nested param' do
      expect(subject.get_journey_param(:user, :name)).to eq('Custom audience test')
    end

    it 'returns nil for non existing param' do
      expect(subject.get_journey_param(:a_param, :non_existent)).to be_nil
    end
  end

  describe '#del_step_param' do
    it 'deletes nested param from hash' do
      subject.del_journey_param(:user, :id)
      expect(subject.journey_params['user']['id']).to be_nil
    end

    it 'does not raise exception when trying to delete an inexistent param' do
      expect {
        subject.del_journey_param(:a_param, :non_existent)
      }.to_not raise_error
    end
  end
end
