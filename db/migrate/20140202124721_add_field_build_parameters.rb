class AddFieldBuildParameters < ActiveRecord::Migration
  def change
    add_column :builds, :parameters, :text
    add_column :projects, :private_token, :string
  end
end
