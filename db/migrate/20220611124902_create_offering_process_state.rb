class CreateOfferingProcessState < ActiveRecord::Migration[6.1]
  def change
    create_table :offering_process_states do |t|
      t.string :advertisement_id, null: false
      t.binary :data
      t.timestamps
    end
    add_index(
      :offering_process_states,
      [:advertisement_id],
      unique: true,
      )
  end
end
