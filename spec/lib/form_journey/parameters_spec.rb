require 'spec_helper'

RSpec.describe FormJourney::Parameters do

  let(:params) do
    {
      action: :step_two,
      user: {
        name: 'John Smith',
        id: '123456'
      }
    }
  end

  let(:request_session) do
    @request_session = {
      user: {
        email: 'email@example.com'
      }
    }
  end

  subject { FormJourney::Parameters.new(params, request_session) }

  describe '#get_step_param' do
    it 'fetches nested param' do
      expect(subject.get(:user, :name)).to eq('John Smith')
    end

    it 'returns nil for non existing param' do
      expect(subject.get(:a_param, :non_existent)).to be_nil
    end
  end

  describe '#del_step_param' do
    it 'deletes nested param from hash' do
      subject.del(:user, :id)
      expect(subject[:user][:id]).to be_nil
    end

    it 'does not raise exception when trying to delete an inexistent param' do
      expect {
        subject.del(:a_param, :non_existent)
      }.to_not raise_error
    end
  end

  describe '#[]=' do
    it 'updates the session hash' do
      subject.set(:user, :address, value: 'Regent Street')
      expect(request_session).to eq({
        action: :step_two,
        user: {
          email: 'email@example.com',
          name: 'John Smith',
          id: '123456',
          address: 'Regent Street'
        }
      })
    end
  end

  describe '#clear' do
    it 'clears the params' do
      expect(subject.keys).to include('user')
      subject.clear
      expect(subject).to eq({})
    end
  end
end
