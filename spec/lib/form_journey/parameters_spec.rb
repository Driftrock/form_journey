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

  let!(:request_session) do
    {
      user: {
        email: 'email@example.com'
      }
    }
  end

  subject { FormJourney::Parameters.new(params, request_session) }

  describe '#add_to_array' do
    let(:key) { :array_key_path }
    let(:value) { :a }
    context 'no array yet exists' do
      before do
        subject.set(key, value: nil)
      end

      it 'should create an array' do
        expect do
          subject.add_to_array(key, value: value)
        end.to change { subject.get(key).class }.to(Array)
      end
    end

    it 'should add the item to the array' do
      subject.add_to_array(key, value: :any)
      expect do
        subject.add_to_array(key, value: value)
      end.to change { subject.get(key).include?(value) }.from(false).to(true)
    end

    context 'when unique' do
      before do
        subject.add_to_array(key, value: value)
      end

      it 'should not let the same value be added twice' do
        expect do
          subject.add_to_array(key, value: value, unique: true)
        end.to_not change { subject.get(key).size }
      end
    end

    context 'not unique' do
      before do
        subject.add_to_array(key, value: value)
      end

      it 'should let the same value be added twice' do
        expect do
          subject.add_to_array(key, value: value)
        end.to change { subject.get(key).size }.from(1).to(2)
      end
    end
  end

  describe '#remove_from_array' do
    let(:key) { :array_key_path }
    let(:value) { :a }
    context 'no array yet exists' do
      before do
        subject.set(key, value: nil)
      end

      it 'should create an array' do
        expect do
          subject.remove_from_array(key, value: value)
        end.to change { subject.get(key).class }.to(Array)
      end
    end

    context 'item is in array' do
      before do
        subject.add_to_array(key, value: value)
      end

      it 'should remove the item from the array' do
        expect do
          subject.remove_from_array(key, value: value)
        end.to change { subject.get(key).include?(value) }.from(true).to(false)
      end
    end
  end

  describe '#require' do
    let(:key) { :user }
    it 'should create action controller params on self' do
      expect(subject.require(key).class).to be ActionController::Parameters
    end

    it 'should require the key from params' do
      expect_any_instance_of(ActionController::Parameters).to receive(:require)
        .with(key)
      expect(subject.require(key))
    end
  end

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

  describe '#set' do
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

    context 'with empty session' do
      before do
        params.clear
        request_session.clear
      end

      it 'updates deep values' do
        subject.set(:user, value: { address: 'Regent Street' })
        new_subject = FormJourney::Parameters.new({ 'user' => { 'name' => 'Test' } }, request_session)
        expect(request_session).to eq({
          user: {
            address: 'Regent Street',
            name: 'Test'
          }
        })
      end
    end
  end

  describe '#clear!' do
    it 'clears the params' do
      expect(subject.keys).to include('user')
      subject.clear!
      expect(subject).to eq({})
    end
  end
end
