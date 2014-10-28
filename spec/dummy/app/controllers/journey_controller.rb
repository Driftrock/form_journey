class JourneyController < ApplicationController
  include FormJourney::Controller
  include FormJourney::Parameters
  steps :signup, :personal, :additional_information

  def signup
    when_post do
      redirect_to next_step_path
    end
  end

  def personal
  end

  def additional_information
  end
end
