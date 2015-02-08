class Activity
  include Mongoid::Document

  field :Name
  field :Description
  field :AgeFrom
  field :AgeTo
  field :Code
  field :DropIn
  field :Fees
  field :Times

  validates :Code, uniqueness: true
  
end
