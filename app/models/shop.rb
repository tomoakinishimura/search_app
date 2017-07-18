class Shop < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions 
  belongs_to_active_hash :status
end
