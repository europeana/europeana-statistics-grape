require 'pg'
require 'json'
require_relative '../lib/common_queries'

class Row

  def self.batch_add(core_db_connection_id, table_name, grid_data)
    return false if grid_data.empty?
    column_names = Column.get_columns(core_db_connection_id, table_name)
    
    insert_rows_query = "INSERT INTO #{table_name}"
    column_names.shift #remove id 
    if column_names
      insert_rows_query += " ( "
      column_names.each do |col|
        insert_rows_query += " #{col},"
      end
      insert_rows_query = insert_rows_query[0..-2] + ") VALUES "
    end

    grid_data.each do |row|
      insert_rows_query += " (" 
      row.each do |cell_value|
        cell_value = cell_value[0...254] if cell_value and cell_value.length > 254
        cell_value.gsub! "'", "''" if cell_value and cell_value.include?"'"
        if not cell_value or cell_value.empty?
          insert_rows_query += " NULL," 
        else
          insert_rows_query += " '#{cell_value}'," 
        end
      end
      insert_rows_query = insert_rows_query[0..-2] + "),"
    end
    insert_rows_query = insert_rows_query[0..-2] + ";"
    CQ.execute_custom_query(core_db_connection_id, insert_rows_query)
  end

end

