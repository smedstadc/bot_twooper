# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:events) do
      primary_key :id, null: false
      String :room, null: false, index: true
      Time   :time, null: false, index: true
      String :message, null: false
    end
  end
end
