class CreateRelationships < ActiveRecord::Migration[5.1]
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
    add_index :relationships, :follower_id  #follower_idにインデックスをつける
    add_index :relationships, :followed_id  #followed_idにインデックスをつける
    add_index :relationships, [:follower_id, :followed_id], unique: true
      # 複合キーインデックス：followed_idとfollowed_idの組み合わせが一意であること
      # uniqueは↑のadd_index2行でやればいいんじゃね？ておもったけど
      # 複合キーインデックスは２つ同時指定が必要なので3行目が必要となる
  end
end
# ———————————————————————————————
# 演習：https://railstutorial.jp/chapters/following_users?version=5.1#sec-exercises_a_problem_with_the_data_model
# の予想（解答ではない）
# ———————————————————————————————
# has_many :relations
# has_many :following, throgh: :relations
# ———————————————————————————————
# user = User.find(1)
# user.following.map(n)
# ユーザID：1がfollowしているユーザnのテーブル1行の配列が返される
# ———————————————————————————————
# user = User.find(1)
# user.following：ユーザ１がフォローしているユーザのリストが返される
# user.following.map(n)：ユーザ１がフォローしているユーザn１個分の配列が返される
