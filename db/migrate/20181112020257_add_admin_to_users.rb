class AddAdminToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :admin, :boolean, default: false
      # defaultの動作はnilなのでdefault:を書かなくても同じ動作
      # コードの読み手に対してわかりやすいようにあえてdefault:を記載
  end
end
