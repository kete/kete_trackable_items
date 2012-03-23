# repository_id
# some sort of shelf description? 
# status - for deactivation

# relationship between trackable_item and shelf_location is polymorphic ??

class ShelfLocation < ActiveRecord::Base
  belongs_to :repository
  belongs_to :trackable_item, :polymorphic => true
  
  # has_many :items

end