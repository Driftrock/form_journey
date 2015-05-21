require 'spec_helper'

RSpec.describe FormJourney::Controller do

  class DummyController < ApplicationController
    include FormJourney::Controller
    steps :step_one, :step_two, :step_three
  end

  subject { DummyController.new }

  let(:params) { { action: :step_two } }

  before do
    allow(subject).to receive(:step_two)
    allow(subject).to receive(:before_step_two)
    allow(subject).to receive(:params) { params }
  end

  describe '#update_steps' do
    before(:each) do
      subject.update_steps(:other_step)
      subject.update_steps(:new_step)
    end

    it 'updates steps only for instance' do
      expect(subject.steps).to eq([:new_step])
    end

    it 'keeps class level steps the same' do
      expect(subject.class._steps).to eq([:step_one, :step_two, :step_three])
    end
  end

  describe '#add_step' do
    describe 'without an index' do
      before do
        subject.add_step(:new_step)
      end

      it 'adds the step at the end of the array' do
        expect(subject.steps).to eq([:step_one, :step_two, :step_three, :new_step])
      end
    end

    describe 'with an index' do
      before do
        subject.add_step(:new_step, before: :step_two)
      end

      it 'adds the step after the specified index' do
        expect(subject.steps).to eq([:step_one, :new_step, :step_two, :step_three])
      end
    end
  end

  describe '#remove_step' do
    before do
      subject.remove_step(:step_one)
    end

    it 'removes the step' do
      expect(subject.steps).to eq([:step_two, :step_three])
    end
  end

  describe '#current_step' do
    it 'returns current step' do
      expect(subject.current_step).to eq(:step_two)
    end
  end

  describe '#previous_step' do
    it 'returns previous step' do
      expect(subject.previous_step).to eq(:step_one)
    end
  end

  describe '#next_step' do
    it 'returns next step' do
      expect(subject.next_step).to eq(:step_three)
    end
  end

  describe '#before_step_action' do
    it 'sends message with before action method name' do
      expect(subject).to receive(:before_step_two)

      subject.send(:before_step_action)
    end
  end

  context 'with multiple instances' do
    let(:instance_one) { DummyController.new }
    let(:instance_two) { DummyController.new }
    let(:instance_three) { DummyController.new }

    let(:params_one) do
      {
        name: 'Test One',
        journey_session_key: '1'
      }
    end

    let(:params_two) do
      {
        name: 'Test One',
        journey_session_key: '2'
      }
    end

    let(:params_three) do
      {}
    end

    let(:session) { {} }

    before do
      allow(instance_one).to receive(:params) { params_one }
      allow(instance_one).to receive(:session) { session }
      allow(instance_two).to receive(:params) { params_two }
      allow(instance_two).to receive(:session) { session }
      allow(instance_three).to receive(:params) { params_three }
      allow(instance_three).to receive(:session) { session }
    end

    it 'creates namespaced sessions' do
      instance_one.journey_params
      instance_two.journey_params

      expect(session.keys).to eq [:dummy_journey_session_1, :dummy_journey_session_2]
    end

    context 'when session key is not present' do
      it 'generates a new key' do
        instance_three.journey_params
        key = session.keys.first.to_s

        expect(key).to match(/dummy_journey_session_[a-z0-9]+\z/)
      end
    end
  end
end
