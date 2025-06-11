class PagesController < ApplicationController
  def home
    @banners = Banner.all
  end
  def about
  end

  def delivery
  end

  def contacts
  end
end
