create table if not exists deleted (
  id integer primary key autoincrement,
  status integer,
  to_user string,
  from_user string
);
