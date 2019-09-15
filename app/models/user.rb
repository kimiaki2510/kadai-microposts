class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password

  has_many :microposts
  has_many :relationships
  has_many :followings, through: :relationships, source: :follow
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user
  
  #お気に入り機能
  has_many :favorites
  has_many :favposts, through: :favorites, source: :micropost
  
  def follow(other_user)
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end

  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end

  def following?(other_user)
    self.followings.include?(other_user)
  end
  
  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
  end
  
#お気に入り追加メソッド
#お気に入り追加
  def like(micropost)
    #micropost_idとmicropost.idの照合し、新規作成
    favorites.find_or_create_by(micropost_id: micropost.id)
  end
  
  #お気に入り解除
  def unlike(micropost)
    #micropost_idとmicropost.idの照合し、削除
    favorite = favorites.find_by(micropost_id: micropost.id)
    favorite.destroy if favorite
  end

#お気に入り登録判定
  def  favpost?(micropost)
    #お気に入り追加した投稿が、投稿一覧の投稿一覧のインスタンスmicropostを含むかどうかを判定
    self.favposts.include?(micropost)
  end
  
end