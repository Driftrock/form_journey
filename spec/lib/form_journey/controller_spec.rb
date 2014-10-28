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
    before do
      subject.update_steps(:new_step)
    end

    it 'updates steps only for instance' do
      expect(subject.steps).to eq([:step_one, :step_two, :new_step])
    end

    it 'keeps class level steps the same' do
      expect(subject.class._steps).to eq([:step_one, :step_two, :step_three])
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
end
