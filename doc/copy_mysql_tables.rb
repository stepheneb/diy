# will copy a set of tables with the same prefix from one database to another replacing the destination tables
# you need to have created the destination database before running this
def copy_mysql_tables(table_prefix, from_host, from_db, from_user, from_password, to_host, to_db, to_user, to_password)
  table_list = `mysqlshow -u #{from_user} --password='#{from_password}' -h #{from_host} #{from_db} '#{table_prefix}%'`.scan(/#{table_prefix}\S*/)[1..-1].join(' ')
  `mysqldump -u #{from_db} --password='#{from_password}' -h #{from_host} #{from_db} #{table_list} | mysql -u #{to_user} --password='#{to_password}' -h #{to_host} -C #{to_db}`
end

copy_mysql_tables('teemss2diy_', 'railsdb.concord.org', 'rails', 'rails', '****', 'localhost', 'teemss2diy_realdata', 'root', '*******')
