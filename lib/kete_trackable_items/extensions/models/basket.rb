# extensions to the kete basket model
Basket.class_eval do
  has_many :repositories, :dependent => :destroy
end
