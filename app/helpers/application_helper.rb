module ApplicationHelper
  TYPE_TRANSLATIONS = {
    "bouquet" => "букет",
    "flower"  => "цветок",
    "toy"     => "игрушка",
    "vase"    => "ваза",
    "plant"   => "растение"
  }

  def translated_type(param_type)
    TYPE_TRANSLATIONS[param_type.to_s.downcase] || param_type
  end
end
