class Admin::BaseController < ApplicationController
  before_action :authorized
  before_action :require_admin
end
