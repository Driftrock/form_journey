require 'spec_helper'

RSpec.describe FormJourney::Controller do
  class DummyModel
    def self.for_company(company)
      DummyModel
    end
  end


  let(:obj_params) { {} }

  subject do
    DummySingleModelController.new.tap do |cont|
      allow(cont).to receive(:obj_params).and_return(obj_params)
    end
  end

  let(:params) { {} }

  let(:session) { {} }

  let(:journey_params) do
    FormJourney::Parameters.new(params, session)
  end
  
  before do
    stub_const 'DummySingleModelController', ActionController::Base
    DummySingleModelController.class_eval do
      include FormJourney::Controller
      include FormJourney::UsesSingleModel
      steps :step_one, :step_two, :step_three
      params_method :obj_params
      model_scope nil
      model_class DummyModel
      def current_company_id
        "123"
      end
    end

    allow(subject).to receive(:params).and_return(params)
    allow(subject).to receive(:journey_params).and_return(journey_params)
  end

  describe '::model_scope' do

    context 'with a single value' do
      let(:scope) { 'rargh' }

      before do
        subject.class.send(:model_scope, scope)
      end

      it 'should set the scope to that val' do
        expect(subject.class._model_scope).to eq scope
      end
    end

    context 'with multiple values' do
      let(:scope) { ['rargh', 'argh'] }
      before do
        subject.class.send(:model_scope, *scope)
      end
      it 'should set the scope to an array' do
        expect(subject.class._model_scope).to be_a Array
      end
    end
  end

  describe '::params_method' do
    context 'with a callable' do
      let(:params_callable) { double(:callable) }
      before do
        subject.class.send(:params_method, params_callable)
      end

      describe '#model_params' do
        it 'should call it' do
          expect(params_callable).to receive(:call)
          subject.send(:model_params)
        end
      end
    end
    
    context 'with a string/sym' do
      let(:params_method) { 'rargh' }
      before do
        subject.class.send(:params_method, params_method)
      end

      describe '#model_params' do
        it 'should send it to self' do
          expect(subject).to receive(params_method.to_sym)
          subject.send(:model_params)
        end
      end
    end
  end

  describe '::model_class' do
    it 'should deal with a string' do
      subject.class.send(:model_class, 'DummyModel')
      expect(subject.class._model_class).to eq DummyModel
    end

    it 'should set the model class for the controller' do
      expect(subject.class._model_class).to eq DummyModel
    end

    it 'should have assigned a method to to get the model object for the given object name' do
      expect(subject).to respond_to(:dummy_model)
    end

    it 'should return the model object when the model name is called' do
      expect(subject).to receive(:model_object)
      subject.dummy_model
    end
  end

  describe '#edit' do
    let(:params) { { id: 132 } }
    before do
      allow(subject).to receive(:redirect_to)
      allow(subject).to receive(:step_path)
    end

    it 'should clear the journey params' do
      expect(journey_params).to receive(:clear!)
      subject.edit
    end

    it 'should assign the model object id' do
      expect do
        subject.edit
      end.to change { journey_params.get(:_model_object_id) }
        .from(nil).to params[:id]
    end

    it 'should redirect to the first step' do
      redirect_location = 'blah'
      expect(subject).to receive(:step_path).with(subject.steps.first)
        .and_return(redirect_location)
      expect(subject).to receive(:redirect_to).with(redirect_location)
      subject.edit
    end
  end

  describe '#model_object (via model name)' do
    before do
      subject.class.params_method :obj_params
      subject.class.model_class DummyModel
    end
    let(:model_instance) do
      DummyModel.new.tap do |model|
        allow(model).to receive(:id).and_return(123213)
        allow(model).to receive(:assign_attributes)
      end
    end
    
    context 'with a model scope' do
      before do
        allow(DummyModel).to receive(:new).and_return(model_instance)
        subject.class.model_scope scope
      end

      context 'using a callable' do
        let(:scope) { proc { |clasz| clasz.for_company(current_company_id) } }

        it 'should work in the correct instance' do
          expect(subject).to receive(:current_company_id).and_call_original
          subject.dummy_model
        end
      end

      context 'using chained messages' do
        let(:scope) { nil }
        let(:message) { :some_scope }
        let(:message2) { :some_other_scope }

        before do
          subject.class.model_scope message, message2
        end

        it 'should attempt to call all messages' do
          expect(DummyModel).to receive(message).and_return(DummyModel)
          expect(DummyModel).to receive(message2).and_return(DummyModel)
          subject.dummy_model
        end

      end
    end

    context 'when new' do
      before do
        allow(DummyModel).to receive(:new).and_return(model_instance)
        journey_params.set(:_model_object_id, value: nil)
      end

      it 'should create a new instance of the model with object params' do
        expect(DummyModel).to receive(:new).with(subject.obj_params)
        subject.dummy_model
      end

      it 'should return the model instance' do
        expect(subject.dummy_model).to be model_instance
      end
    end

    context 'when editing' do
      before do
        journey_params.set(:_model_object_id, value: model_instance.id)
        allow(DummyModel).to receive(:find).and_return(model_instance)
      end

      it 'should find the model instance' do
        expect(DummyModel).to receive(:find).with(model_instance.id)
          .and_return(model_instance)
        subject.dummy_model
      end

      it 'should assign attributes to the model instance' do
        expect(model_instance).to receive(:assign_attributes)
          .with(subject.obj_params)
        subject.dummy_model
      end

      it 'should return the model instance' do
        expect(subject.dummy_model).to be model_instance
      end
    end
  end

  describe '#editing?' do
    context 'when there is not a model object id' do
      before do
        journey_params.set(:_model_object_id, value: nil)
      end

      it 'should return false' do
        expect(subject.editing?).to be false
      end
    end

    context 'when there is a model object id' do
      before do
        journey_params.set(:_model_object_id, value: 3424)
      end

      it 'should return true' do
        expect(subject.editing?).to be true
      end
    end
  end

end
