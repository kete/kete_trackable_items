# repository_id
# some sort of shelf description? 
# status - for deactivation

class ShelfLocation < ActiveRecord::Base
  belongs_to :repository
  
  has_many :items

end