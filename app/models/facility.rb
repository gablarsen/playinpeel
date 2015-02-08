class Facility
  include Mongoid::Document

  field :Name
  field :Aliases
  field :Address
  field :City
  field :Phone
  field :Lat
  field :Lon

  validates_uniqueness_of :Lat, :scope => :Lon
end
