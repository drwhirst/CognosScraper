class CreateIbmInfos < ActiveRecord::Migration[6.0]
  def change
    create_table :ibm_infos do |t|
      t.string :IBMid
      t.string :password
      t.string :report_name
      t.string :report_xml

      t.timestamps
    end
  end
end
