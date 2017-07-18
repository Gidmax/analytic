class HomeController < ApplicationController
  require 'google/apis/drive_v2'

  def index
    @hello = "world"
  end
end
