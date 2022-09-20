class Api::V1::TestController < ApplicationController
  def index
    render json: "Test"
  end
end
