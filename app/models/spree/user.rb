class Spree::User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Spree modules
  include Spree::UserAddress
  include Spree::UserMethods
  include Spree::UserPaymentSource

  # Komplex associations
  has_one :merchant, class_name: 'Komplex::Merchant', dependent: :destroy

  # Returns all users who have an associated merchant record
  def self.merchants
    joins("INNER JOIN komplex_merchants ON komplex_merchants.user_id = #{table_name}.id")
      .where("komplex_merchants.status = 'approved'")
      .distinct
  end
end
