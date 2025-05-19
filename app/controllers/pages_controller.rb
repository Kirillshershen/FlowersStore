class PagesController < ApplicationController
  def home
    @products = Product.all  # или другая логика получения продуктов
  end
  def about
  end

  def delivery
  end

  def contacts
  end
end
