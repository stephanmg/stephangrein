create table if not exists messages (
  id integer primary key autoincrement,
  message string not null,
  subject string not null,
  from_user string not null,
  to_user string not null,
  read integer default(0)
);
