class RankingProcessState < ActiveRecord::Migration[6.1]
  def change
    create_table :ranking_process_states do |t|
      t.string :evaluation_id, null: false
      t.binary :data
      t.timestamps
    end
    add_index(
      :ranking_process_states,
      [:evaluation_id],
      unique: true,
      )
  end
end
