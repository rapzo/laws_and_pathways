class AddCreatedByAndUpdatedByToLitigations < ActiveRecord::Migration[5.2]
  def change
    add_reference :litigations, :created_by, foreign_key: { to_table: :admin_users }, index: true
    add_reference :litigations, :updated_by, foreign_key: { to_table: :admin_users }, index: true
  end
end
