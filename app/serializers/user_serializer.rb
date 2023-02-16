class UserSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  
  attributes :id, :name, :username, :email, :avatar_url
  
  def avatar_url
    if object.avatar.attached?
      url_for(object.avatar)
    else
      nil
    end
  end
end