class UserSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :email, :created_at, :updated_at
  has_one :user_profile, serializer: UserProfileSerializer
end
